// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {Hucha} from "../src/Hucha.sol";

/// Nivel 1: estado y propietario.
/// Ejecutar: forge test --match-path test/Nivel1.t.sol -vv
contract Nivel1Test is Test {
    Hucha hucha;
    address profesor = makeAddr("profesor"); // despliega la hucha, sera el owner
    address alumno = makeAddr("alumno");

    string constant NOMBRE = "Viaje fin de master";
    uint256 constant OBJETIVO = 1 ether;
    uint256 constant DURACION = 7 days;

    function setUp() public {
        vm.prank(profesor);
        hucha = new Hucha(NOMBRE, OBJETIVO, DURACION);
    }

    function test_elOwnerEsQuienDespliega() public view {
        assertEq(hucha.owner(), profesor);
    }

    function test_guardaNombreYObjetivo() public view {
        assertEq(hucha.nombre(), NOMBRE);
        assertEq(hucha.objetivo(), OBJETIVO);
    }

    function test_calculaFechaLimite() public view {
        assertEq(hucha.fechaLimite(), block.timestamp + DURACION);
    }

    function test_noSePuedeCrearConObjetivoCero() public {
        vm.expectRevert();
        new Hucha(NOMBRE, 0, DURACION);
    }

    function test_elOwnerPuedeCambiarElObjetivo() public {
        vm.prank(profesor);
        hucha.cambiarObjetivo(2 ether);
        assertEq(hucha.objetivo(), 2 ether);
    }

    function test_otroNoPuedeCambiarElObjetivo() public {
        vm.prank(alumno);
        // Debe revertir con el error personalizado Unauthorized(), que declaras tu en Hucha.sol
        vm.expectRevert(bytes4(keccak256("Unauthorized()")));
        hucha.cambiarObjetivo(2 ether);
        assertEq(hucha.objetivo(), OBJETIVO);
    }

    function test_noSePuedeCambiarElObjetivoACero() public {
        vm.prank(profesor);
        vm.expectRevert();
        hucha.cambiarObjetivo(0);
    }
}
