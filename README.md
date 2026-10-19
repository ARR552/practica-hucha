# La hucha de clase: guía de arranque

Lee primero [docs/ENUNCIADO.md](docs/ENUNCIADO.md). Esta guía solo explica las herramientas.

## Qué necesitas

| Herramienta | Para qué | Obligatoria |
|-------------|----------|-------------|
| Foundry (forge, cast, anvil) | Compilar, ejecutar las pruebas, crear la wallet y desplegar | Sí |
| Un editor de texto | Escribir el contrato | Sí (el que quieras) |
| MetaMask | Solo si despliegas desde Remix | No |
| Conexión a internet | La primera compilación descarga el compilador de Solidity | Sí |

Sistemas soportados: macOS, Linux y Windows con WSL. En Windows no uses PowerShell ni CMD para Foundry: instala WSL con Ubuntu y trabaja dentro.

## Clonar el repositorio

```bash
git clone https://github.com/ARR552/practica-hucha.git
```

```bash
cd practica-hucha
```

## Editor

Vale cualquier editor. Si no tienes preferencia, [Visual Studio Code](https://code.visualstudio.com) con la extensión "Solidity" de Nomic Foundation te da resaltado de sintaxis y avisos de errores mientras escribes. Abre la carpeta de la práctica entera, no solo el fichero, para que la extensión encuentre `foundry.toml`.

## Instalar Foundry

Foundry es el conjunto de herramientas que usamos para compilar, probar y desplegar. En macOS o Linux:

```bash
curl -L https://foundry.paradigm.xyz | bash
```

Cierra y abre el terminal, y ejecuta:

```bash
foundryup
```

Comprueba que funciona:

```bash
forge --version
```

En Windows, instala WSL abriendo PowerShell como administrador y ejecutando `wsl --install`; reinicia, abre la aplicación Ubuntu y sigue los pasos anteriores dentro de ella.

## Compilar y ejecutar las pruebas

Desde la carpeta de la práctica:

```bash
forge build
```

La primera vez tarda un poco más porque descarga el compilador de Solidity 0.8.28. Las siguientes son inmediatas.

Pruebas del nivel 1 (cambia el número para los otros niveles):

```bash
forge test --match-path test/Nivel1.t.sol -vv
```

Todas las pruebas a la vez:

```bash
forge test
```

Cada prueba aparece como `[PASS]` o `[FAIL: motivo]`. Al principio casi todas fallan, la mayoría con `TODO`: es normal, ese es el punto de partida. Los avisos del compilador (parámetros sin usar, funciones que podrían ser `pure`) desaparecen según vayas rellenando las funciones.

Si una prueba falla y no entiendes por qué, añade más uves para ver la traza completa de llamadas:

```bash
forge test --match-test test_aportarGuardaLaAportacion -vvvv
```

## Wallet de pruebas

Crea una wallet nueva solo para esta práctica:

```bash
cast wallet new
```

Guarda la dirección y la clave privada. La clave privada no se comparte con nadie ni se sube a ningún sitio. Pide ether de prueba al profesor para esa dirección.

## La red de la asignatura

Las pruebas con `forge test` no necesitan ninguna red: se ejecutan en una cadena simulada en tu ordenador. Solo necesitas la red de la asignatura para desplegar y para la aportación que se entrega.

Datos de la red (los facilita el profesor):

- URL del RPC: `PENDIENTE`
- Chain id: `PENDIENTE`
- Explorador de bloques: `PENDIENTE`
- Cómo conseguir ether de prueba: `PENDIENTE`

Si vas a usar Remix, instala la extensión [MetaMask](https://metamask.io) en el navegador, crea una wallet nueva para la práctica y añade la red desde Ajustes, Redes, Añadir red, con la URL del RPC y el chain id de arriba. Para ver una transacción o un evento, pega el hash de la transacción o la dirección del contrato en el explorador de bloques.

## Desplegar

Con Foundry, sustituyendo `RPC` por la URL de la red de la asignatura y `PK` por tu clave privada:

```bash
forge create src/Hucha.sol:Hucha --rpc-url RPC --private-key PK --broadcast --constructor-args "Viaje fin de master" 100000000000000000 604800
```

Los argumentos son nombre, objetivo en wei (el ejemplo es 0,1 ether) y duración en segundos (el ejemplo es 7 días). Para convertir ether a wei:

```bash
cast to-wei 0.1 ether
```

Aportar desde otra wallet:

```bash
cast send DIRECCION_HUCHA "aportar()" --value 0.01ether --rpc-url RPC --private-key PK_SEGUNDA_WALLET
```

Consultar el estado:

```bash
cast call DIRECCION_HUCHA "totalRecaudado()(uint256)" --rpc-url RPC
```

## Alternativa: Remix

[Remix](https://remix.ethereum.org) es un editor en el navegador, sin instalar nada. Sirve para escribir y desplegar, pero no ejecuta las pruebas de Foundry.

1. Crea un fichero `Hucha.sol` y pega tu contrato.
2. En la pestaña Solidity Compiler, elige la versión 0.8.28, la misma que usa Foundry en este proyecto, y compila.
3. En Deploy & Run, elige "Injected Provider" para usar MetaMask conectada a la red de la asignatura, rellena los argumentos del constructor y pulsa Deploy.
4. Debajo aparecen botones para cada función. Para `aportar`, escribe la cantidad en el campo Value antes de pulsar.

Puedes usar Remix para escribir y Foundry solo para ejecutar las pruebas, copiando el fichero entre los dos.

## Problemas frecuentes

- `forge: command not found` justo después de instalar: cierra y abre el terminal, o ejecuta `source ~/.zshenv` en macOS o `source ~/.bashrc` en Linux. Si sigue sin aparecer, ejecuta `foundryup` otra vez.
- `forge build` falla descargando el compilador: comprueba la conexión a internet. Si estás detrás de un proxy o una red corporativa, prueba desde otra red.
- Las pruebas no encuentran `forge-std`: has clonado solo parte del repositorio o has movido los ficheros. La carpeta `lib/forge-std` tiene que estar al lado de `src` y `test`.
- `Error: insufficient funds` al desplegar: la wallet no tiene ether de prueba, o estás apuntando a otra red. Comprueba la URL del RPC y el saldo con `cast balance TU_DIRECCION --rpc-url RPC`.
- Remix compila pero `forge build` no, o al revés: comprueba que la versión del compilador es 0.8.28 en los dos sitios.
- Un test pasa en Remix "a mano" pero falla en Foundry: Foundry prueba casos que es fácil olvidar probando a mano (cantidad cero, segunda llamada, otra cuenta). Lee el nombre del test y el motivo del fallo: dicen exactamente qué regla no se cumple.
