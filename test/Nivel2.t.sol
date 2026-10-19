// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Hucha} from "../src/Hucha.sol";

/// Nivel 2: recibir dinero y llevar la cuenta.
/// Ejecutar: forge test --match-path test/Nivel2.t.sol -vv
contract Nivel2Test is Test {
    Hucha hucha;
    address profesor = makeAddr("profesor");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");

    event Aportacion(address indexed donante, uint256 cantidad);

    function setUp() public {
        vm.prank(profesor);
        hucha = new Hucha("Viaje fin de master", 1 ether, 7 days);
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
    }

    function test_alPrincipioNoHayNada() public view {
        assertEq(hucha.totalRecaudado(), 0);
        assertEq(hucha.numDonantes(), 0);
        assertEq(hucha.saldo(), 0);
        assertFalse(hucha.objetivoAlcanzado());
    }

    function test_aportarGuardaLaAportacion() public {
        vm.prank(alice);
        hucha.aportar{value: 0.3 ether}();

        assertEq(hucha.aportaciones(alice), 0.3 ether);
        assertEq(hucha.totalRecaudado(), 0.3 ether);
        assertEq(hucha.saldo(), 0.3 ether);
        assertEq(hucha.numDonantes(), 1);
        assertEq(hucha.donantes(0), alice);
    }

    function test_aportarEmiteElEvento() public {
        vm.expectEmit(true, false, false, true);
        emit Aportacion(alice, 0.3 ether);
        vm.prank(alice);
        hucha.aportar{value: 0.3 ether}();
    }

    function test_noSePuedeAportarCero() public {
        vm.prank(alice);
        vm.expectRevert();
        hucha.aportar{value: 0}();
    }

    function test_variasAportacionesDelMismoDonanteSeSuman() public {
        vm.startPrank(alice);
        hucha.aportar{value: 0.2 ether}();
        hucha.aportar{value: 0.3 ether}();
        vm.stopPrank();

        assertEq(hucha.aportaciones(alice), 0.5 ether);
        assertEq(hucha.totalRecaudado(), 0.5 ether);
        assertEq(hucha.numDonantes(), 1, "un donante que repite solo cuenta una vez");
    }

    function test_variosDonantes() public {
        vm.prank(alice);
        hucha.aportar{value: 0.4 ether}();
        vm.prank(bob);
        hucha.aportar{value: 0.5 ether}();

        assertEq(hucha.numDonantes(), 2);
        assertEq(hucha.donantes(0), alice);
        assertEq(hucha.donantes(1), bob);
        assertEq(hucha.totalRecaudado(), 0.9 ether);
        assertFalse(hucha.objetivoAlcanzado());
    }

    function test_objetivoAlcanzado() public {
        vm.prank(alice);
        hucha.aportar{value: 0.6 ether}();
        vm.prank(bob);
        hucha.aportar{value: 0.4 ether}();
        assertTrue(hucha.objetivoAlcanzado(), "0.6 + 0.4 llega justo al objetivo de 1 ether");
    }

    function test_elContratoNoAceptaEtherSinLlamarAAportar() public {
        vm.prank(alice);
        (bool ok,) = address(hucha).call{value: 0.1 ether}("");
        assertFalse(ok, "enviar ether sin llamar a aportar() debe fallar");
        assertEq(hucha.saldo(), 0);
    }
}
