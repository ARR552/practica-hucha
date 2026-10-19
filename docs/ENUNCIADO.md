# Práctica: la hucha de clase

Asignatura de Blockchain, Máster en Ciberseguridad.

## Objetivo

Escribir tu primer contrato inteligente en Solidity y desplegarlo en una red Ethereum de pruebas. El contrato es una hucha colectiva: varias personas aportan ether para un objetivo común, y si se alcanza, el dueño retira el dinero; si no se alcanza en plazo, cada uno recupera lo suyo.

La práctica tiene tres niveles. Cada nivel añade unas pocas funciones y unos pocos conceptos nuevos. Puedes entregar en el nivel que alcances: cada nivel superado suma.

## Qué recibes

- `src/Hucha.sol`: el contrato con todas las variables ya declaradas y las funciones vacías. Cada función tiene un comentario con lo que debe hacer. Tu trabajo es rellenarlas.
- `test/Nivel1.t.sol`, `test/Nivel2.t.sol`, `test/Nivel3.t.sol`: pruebas automáticas de cada nivel. Un nivel está superado cuando todas sus pruebas pasan. No hay que modificarlas, pero conviene leerlas: muestran cómo se usa tu contrato desde fuera.
- `README.md`: cómo instalar las herramientas, ejecutar las pruebas y desplegar.

## Nivel 1: estado y propietario

Conceptos: variables de estado, `constructor`, `msg.sender`, custom errors, modificadores, funciones `view`.

- El constructor recibe el nombre, el objetivo en wei y la duración en segundos. Guarda el `owner` (la cuenta que despliega), el `nombre`, el `objetivo` y calcula `fechaLimite` como el momento actual más la duración. Un objetivo de 0 no tiene sentido: recházalo.
- El modificador `onlyOwner` hace que una función solo se pueda ejecutar desde la cuenta del owner. Si llama otra cuenta, la transacción revierte con el error personalizado `Unauthorized`.
- `cambiarObjetivo(nuevoObjetivo)` cambia el objetivo. Solo el owner. El nuevo objetivo debe ser mayor que 0.

**Custom errors.** En esta práctica todos los reverts tienen que devolver custom errors. No se puede usar `require` con mensajes de texto. Infórmate de qué son los custom errors y de cómo se declaran y se lanzan. Los declaras tú, con los nombres que prefieras. El único nombre obligatorio es `Unauthorized`, sin parámetros, porque el test del nivel 1 comprueba que `onlyOwner` revierte exactamente con él.

Preguntas que debes saber responder: ¿qué es `msg.sender`? ¿Qué diferencia hay entre `wei` y `ether`? ¿Qué pasa con el gas cuando una transacción revierte? ¿Por qué utilizamos custom errors en vez de `require`? ¿Qué ventaja tienen?

## Nivel 2: recibir dinero y llevar la cuenta

Conceptos: `payable`, `msg.value`, mappings, arrays, eventos.

- `aportar()` es `payable`: quien la llama envía ether junto con la llamada y ese ether queda en el contrato. Rechaza aportaciones de 0. Si es la primera vez que esa cuenta aporta, añádela a `donantes`. Suma la cantidad en `aportaciones[msg.sender]` y en `totalRecaudado`. Emite el evento `Aportacion`.
- `numDonantes()` devuelve cuántas cuentas distintas han aportado.
- `objetivoAlcanzado()` devuelve `true` si `totalRecaudado` llega al objetivo.
- `saldo()` devuelve el ether que tiene el contrato ahora mismo.
- El contrato no debe aceptar ether que llegue por otra vía que no sea `aportar()`. En Solidity, un contrato sin función `receive` ni `fallback` rechaza ese ether por defecto: no las añadas.

Preguntas: ¿por qué `donantes` es un array y `aportaciones` un mapping? ¿Para qué sirven los eventos si no cambian el estado? ¿Qué diferencia hay entre `totalRecaudado` y `saldo()`?

## Nivel 3: sacar el dinero con reglas

Conceptos: `block.timestamp`, enviar ether desde un contrato, y el patrón CEI.

- `tiempoRestante()` devuelve los segundos que faltan hasta `fechaLimite`, o 0 si ya ha pasado. Cuidado: en Solidity los enteros no pueden ser negativos.
- `aportar()` debe rechazar aportaciones una vez pasada `fechaLimite`.
- `retirar()`: solo el owner, solo si se alcanzó el objetivo, solo una vez. Marca `retirado`, envía todo el saldo al owner y emite `Retirada`.
- `reembolsar()`: solo si ya pasó `fechaLimite` y no se alcanzó el objetivo. Quien llama recupera lo que aportó. Si no aportó nada, revierte. Emite `Reembolso`.

Para enviar ether desde un contrato usa `(bool ok, ) = destino.call{value: cantidad}("");`. Si `ok` es `false`, revierte con un custom error.

**Patrón CEI.** En todas las funciones que envían ether, y en especial en `reembolsar()`, asegúrate de seguir siempre el patrón CEI (checks-effects-interactions). El último test del nivel 3 comprueba que lo has hecho.

Preguntas: ¿de dónde sale `block.timestamp` y quién lo decide? ¿Por qué `retirar()` necesita la marca `retirado` si el saldo ya se queda a 0? ¿Qué es el patrón CEI y qué ataque evita? ¿Qué pasaría si en `reembolsar()` no lo siguieras?

## Despliegue

Cuando tengas al menos el nivel 2:

1. Crea una wallet nueva solo para la práctica. Nunca uses una wallet con fondos reales.
2. Consigue ether de prueba en la red de la asignatura (datos de la red en `README.md`).
3. Despliega tu `Hucha` con un nombre y un objetivo elegidos por ti y una duración de al menos un día. Vale Remix o `forge create` (ver `README.md`).
4. Haz una aportación desde una segunda wallet distinta a la que desplegó.
5. Comprueba en el explorador de bloques que el evento `Aportacion` aparece en la transacción.

## Entrega

- Tu `Hucha.sol`.
- Dirección del contrato desplegado, wallet que lo desplegó, y hash de la transacción de la aportación.
- Una función extra de tu elección que no esté en el enunciado, con un párrafo explicando qué hace y por qué la has elegido. Ideas: un máximo por aportación, una lista de bloqueados, cambiar el owner, cancelar la hucha.
- Media página con las respuestas a las preguntas de cada nivel que hayas alcanzado.


## Normas

- El trabajo es individual.
- Puedes consultar la documentación de Solidity y cualquier fuente. Debes entender cada línea que entregues.
