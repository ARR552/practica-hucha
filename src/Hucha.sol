// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Hucha - una hucha colectiva (mini crowdfunding).
/// @notice Completa este contrato nivel a nivel siguiendo docs/ENUNCIADO.md.
///         Cada funcion tiene un comentario con lo que debe hacer. Donde pone `revert("TODO ...")`
///         borra esa linea y escribe tu codigo. Ejecuta los tests de cada nivel para comprobarlo:
///           forge test --match-path test/Nivel1.t.sol -vv
///         Regla para toda la practica: los reverts tienen que devolver custom errors. No utilizar require
///         con mensajes de texto. El unico error obligatorio es `Unauthorized`, que comprueban los tests.
contract Hucha {
    // =====================================================================
    // NIVEL 1: estado y propietario
    // =====================================================================

    /// @notice Cuenta que desplego el contrato. Es la unica que puede retirar el dinero.
    address public owner;

    /// @notice Nombre de la hucha, por ejemplo "Viaje fin de master".
    string public nombre;

    /// @notice Cantidad que se quiere recaudar, en wei.
    uint256 public objetivo;

    /// @notice Momento (timestamp en segundos) a partir del cual ya no se admiten aportaciones.
    uint256 public fechaLimite;

    // =====================================================================
    // NIVEL 2: recibir dinero y llevar la cuenta
    // =====================================================================

    /// @notice Cuanto ha aportado cada cuenta, en wei.
    mapping(address => uint256) public aportaciones;

    /// @notice Lista de cuentas que han aportado alguna vez (cada una aparece una sola vez).
    address[] public donantes;

    /// @notice Suma de todas las aportaciones vigentes, en wei.
    uint256 public totalRecaudado;

    /// @notice Se emite cada vez que alguien aporta.
    event Aportacion(address indexed donante, uint256 cantidad);

    // =====================================================================
    // NIVEL 3: sacar el dinero con reglas
    // =====================================================================

    /// @notice true cuando el owner ya ha retirado el dinero.
    bool public retirado;

    event Retirada(address indexed owner, uint256 cantidad);
    event Reembolso(address indexed donante, uint256 cantidad);

    // ---------------------------------------------------------------------
    // NIVEL 1
    // ---------------------------------------------------------------------

    /// @param _nombre Nombre de la hucha.
    /// @param _objetivo Cantidad a recaudar, en wei. Debe ser mayor que 0.
    /// @param _duracion Segundos durante los que se admiten aportaciones, contados desde el despliegue.
    /// @dev Guarda el owner (quien despliega), el nombre, el objetivo y calcula fechaLimite.
    constructor(string memory _nombre, uint256 _objetivo, uint256 _duracion) {
        // TODO nivel 1
    }

    /// @dev Permite ejecutar la funcion solo si quien llama es el owner.
    ///      Si no lo es, revierte con el custom error `Unauthorized`, sin parametros.
    modifier onlyOwner() {
        // TODO nivel 1
        _;
    }

    /// @notice Cambia el objetivo. Solo el owner. El nuevo objetivo debe ser mayor que 0.
    function cambiarObjetivo(uint256 nuevoObjetivo) external {
        revert("TODO nivel 1: cambiarObjetivo");
    }

    // ---------------------------------------------------------------------
    // NIVEL 2
    // ---------------------------------------------------------------------

    /// @notice Aporta el ether enviado con la llamada (msg.value) a la hucha.
    /// @dev Revierte si no se envia nada. Si es la primera aportacion de esta cuenta,
    ///      la añade a `donantes`. Actualiza `aportaciones` y `totalRecaudado` y emite `Aportacion`.
    ///      (En el nivel 3 añadirás: revierte si ya ha pasado fechaLimite.)
    function aportar() external payable {
        revert("TODO nivel 2: aportar");
    }

    /// @notice Numero de cuentas distintas que han aportado.
    function numDonantes() external view returns (uint256) {
        revert("TODO nivel 2: numDonantes");
    }

    /// @notice true si lo recaudado llega al objetivo.
    function objetivoAlcanzado() public view returns (bool) {
        revert("TODO nivel 2: objetivoAlcanzado");
    }

    /// @notice Ether que custodia el contrato ahora mismo, en wei.
    function saldo() external view returns (uint256) {
        revert("TODO nivel 2: saldo");
    }

    // ---------------------------------------------------------------------
    // NIVEL 3
    // ---------------------------------------------------------------------

    /// @notice Segundos que faltan para fechaLimite, o 0 si ya ha pasado.
    function tiempoRestante() external view returns (uint256) {
        revert("TODO nivel 3: tiempoRestante");
    }

    /// @notice El owner se lleva todo el ether de la hucha.
    /// @dev Solo el owner. Solo si se ha alcanzado el objetivo. Solo una vez.
    ///      Marca `retirado`, envia el ether al owner y emite `Retirada`.
    function retirar() external {
        revert("TODO nivel 3: retirar");
    }

    /// @notice Un donante recupera su aportacion si la hucha ha fracasado.
    /// @dev Solo si ya ha pasado fechaLimite y NO se ha alcanzado el objetivo.
    ///      Revierte si quien llama no tiene nada que recuperar.
    ///      Pone su aportacion a 0, resta de totalRecaudado y le envia el ether siguiendo el patron CEI. Emite `Reembolso`.
    function reembolsar() external {
        revert("TODO nivel 3: reembolsar");
    }
}
