// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Hucha} from "../src/Hucha.sol";

/// Nivel 3: sacar el dinero con reglas.
/// Ejecutar: forge test --match-path test/Nivel3.t.sol -vv
contract Nivel3Test is Test {
    Hucha hucha;
    address profesor = makeAddr("profesor");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    uint256 constant DURACION = 7 days;
    uint256 inicio;

    event Retirada(address indexed owner, uint256 cantidad);
    event Reembolso(address indexed donante, uint256 cantidad);

    function setUp() public {
        inicio = block.timestamp;
        vm.prank(profesor);
        hucha = new Hucha("Viaje fin de master", 1 ether, DURACION);
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
    }

    // ---------------------------------------------------------------- tiempo

    function test_tiempoRestante() public {
        assertEq(hucha.tiempoRestante(), DURACION);
        vm.warp(inicio + 2 days);
        assertEq(hucha.tiempoRestante(), 5 days);
        vm.warp(inicio + 30 days);
        assertEq(hucha.tiempoRestante(), 0, "pasado el plazo debe ser 0, no un numero negativo");
    }

    function test_noSePuedeAportarPasadoElPlazo() public {
        vm.warp(inicio + DURACION + 1);
        vm.prank(alice);
        vm.expectRevert();
        hucha.aportar{value: 0.1 ether}();
    }

    // ---------------------------------------------------------------- retirar

    function test_elOwnerRetiraCuandoSeAlcanzaElObjetivo() public {
        vm.prank(alice);
        hucha.aportar{value: 1.5 ether}();

        uint256 antes = profesor.balance;
        vm.expectEmit(true, false, false, true);
        emit Retirada(profesor, 1.5 ether);
        vm.prank(profesor);
        hucha.retirar();

        assertEq(profesor.balance, antes + 1.5 ether);
        assertEq(hucha.saldo(), 0);
        assertTrue(hucha.retirado());
    }

    function test_noSePuedeRetirarSinAlcanzarElObjetivo() public {
        vm.prank(alice);
        hucha.aportar{value: 0.5 ether}();
        vm.prank(profesor);
        vm.expectRevert();
        hucha.retirar();
    }

    function test_soloElOwnerPuedeRetirar() public {
        vm.prank(alice);
        hucha.aportar{value: 1 ether}();
        vm.prank(alice);
        vm.expectRevert(bytes4(keccak256("Unauthorized()")));
        hucha.retirar();
    }

    function test_noSePuedeRetirarDosVeces() public {
        vm.prank(alice);
        hucha.aportar{value: 1 ether}();
        vm.startPrank(profesor);
        hucha.retirar();
        vm.expectRevert();
        hucha.retirar();
        vm.stopPrank();
    }

    // ---------------------------------------------------------------- reembolsar

    function test_reembolsoSiLaHuchaFracasa() public {
        vm.prank(alice);
        hucha.aportar{value: 0.4 ether}();
        vm.prank(bob);
        hucha.aportar{value: 0.2 ether}();
        vm.warp(inicio + DURACION + 1);

        uint256 antes = alice.balance;
        vm.expectEmit(true, false, false, true);
        emit Reembolso(alice, 0.4 ether);
        vm.prank(alice);
        hucha.reembolsar();

        assertEq(alice.balance, antes + 0.4 ether);
        assertEq(hucha.aportaciones(alice), 0);
        assertEq(hucha.totalRecaudado(), 0.2 ether, "lo de bob sigue contando");
        assertEq(hucha.saldo(), 0.2 ether, "lo de bob sigue en la hucha");
    }

    function test_noHayReembolsoAntesDelPlazo() public {
        vm.prank(alice);
        hucha.aportar{value: 0.4 ether}();
        vm.prank(alice);
        vm.expectRevert();
        hucha.reembolsar();
    }

    function test_noHayReembolsoSiSeAlcanzoElObjetivo() public {
        vm.prank(alice);
        hucha.aportar{value: 1 ether}();
        vm.warp(inicio + DURACION + 1);
        vm.prank(alice);
        vm.expectRevert();
        hucha.reembolsar();
    }

    function test_noSePuedeReembolsarDosVeces() public {
        vm.prank(alice);
        hucha.aportar{value: 0.4 ether}();
        vm.warp(inicio + DURACION + 1);
        vm.startPrank(alice);
        hucha.reembolsar();
        vm.expectRevert();
        hucha.reembolsar();
        vm.stopPrank();
    }

    function test_quienNoAportoNoPuedeReembolsar() public {
        vm.prank(alice);
        hucha.aportar{value: 0.4 ether}();
        vm.warp(inicio + DURACION + 1);
        vm.prank(bob);
        vm.expectRevert();
        hucha.reembolsar();
    }

    // ---------------------------------------------------------------- bonus: primero apunta, luego paga

    /// Un donante malicioso intenta cobrar el reembolso dos veces: cuando recibe el ether,
    /// vuelve a llamar a reembolsar() antes de que la primera llamada termine.
    /// Si pones la aportacion a 0 ANTES de enviar el ether, la segunda llamada falla y el test pasa.
    function test_bonus_reembolsarResisteLaReentrada() public {
        DonanteMalicioso malo = new DonanteMalicioso(hucha);
        vm.deal(address(malo), 1 ether);
        malo.aportar(0.4 ether);
        vm.prank(bob);
        hucha.aportar{value: 0.5 ether}();
        vm.warp(inicio + DURACION + 1);

        malo.atacar();

        assertEq(address(malo).balance, 1 ether, "el atacante solo puede recuperar lo que aporto");
        assertEq(hucha.saldo(), 0.5 ether, "el dinero de bob sigue en la hucha");
    }
}

contract DonanteMalicioso {
    Hucha hucha;

    constructor(Hucha _hucha) {
        hucha = _hucha;
    }

    function aportar(uint256 cantidad) external {
        hucha.aportar{value: cantidad}();
    }

    function atacar() external {
        hucha.reembolsar();
    }

    receive() external payable {
        // Mientras recibe el reembolso, intenta cobrarlo otra vez. Ignora el resultado.
        (bool ok,) = address(hucha).call(abi.encodeWithSignature("reembolsar()"));
        ok;
    }
}
