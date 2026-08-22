# CalcX architecture

Este documento sigue las dos entradas que existen en el repositorio y no mezcla el menú Bash de compatibilidad con el motor Python moderno.

## Cómo leerlo

La primera figura responde qué se ejecuta. La secuencia responde qué ocurre con una expresión. La tabla responde qué puede cambiar el resultado. No muestra cada función matemática porque eso no ayuda a entender el sistema; esas funciones están en el código y en el manual.

## 1. Mapa de componentes

~~~mermaid
flowchart LR
    subgraph ENTRY[Entradas]
      SH[calcx shell]
      PM[python module]
      PX[pipx console]
    end
    SH -->|sin expresión| MENU[menu Bash legado]
    SH -->|expresión o flags| PX
    PM --> CLI[modulo CLI]
    PX --> CLI
    subgraph PY[Paquete Python]
      CLI --> CFG[carga de config]
      CLI --> ENG[evaluacion]
      ENG --> AST[AST y lista permitida]
      ENG --> NUM[Decimal complex y math]
      CLI --> HIST[historial]
      OPS[API de operaciones]
    end
    CFG --> ENG
    CFG --> HIST
    ENG --> OUT[salida texto o JSON]
    ENG --> ERR[error tipado y salida 2]
    HIST --> FILE[archivo de historial atomico]
~~~

Componentes comprobables:

- `calcx.sh` conserva el menú Bash cuando no recibe una expresión; no pasa por `calcx/cli.py` en ese caso.
- `calcx/cli.py` decide entre cálculo directo, JSON y REPL. `--interactive` entra en el REPL Python.
- `calcx/engine.py` solo visita `Expression`, constantes, nombres permitidos, llamadas permitidas, operadores binarios y unarios. `generic_visit` rechaza lo demás.
- `calcx/operations.py` es una API de operaciones numéricas y no significa que esas funciones estén expuestas desde expresiones de consola.

## 2. Secuencia de una expresión

~~~mermaid
sequenceDiagram
    participant User
    participant CLI as main CLI
    participant Config as carga config
    participant Parser as parser AST
    participant Eval as evaluador
    participant History
    User->>CLI: calcx --precision N --json expression
    CLI->>Config: load cli_precision
    Config-->>CLI: precision + history path + limit
    CLI->>Parser: replace ^ with **; parse expression
    Parser-->>Eval: AST or SyntaxError
    Eval->>Eval: allow-list visits nodes
    Eval-->>CLI: value or typed Domain/Expression error
    alt success
      CLI->>History: add expression and rendered result
      CLI-->>User: one JSON object + exit 0
    else expected input/domain failure
      CLI-->>User: error on stderr + exit 2
    end
~~~

## 3. Precedencia y persistencia

| Nivel | Fuente | Qué controla |
| --- | --- | --- |
| 1 | CLI | precision explícita |
| 2 | entorno | `CALCX_PRECISION`, `CALCX_HISTORY_LIMIT`, `CALCX_HISTORY` |
| 3 | `config.env` | `PRECISION`, `HISTORY_LIMIT`, `HISTORY_FILE` |
| 4 | defaults | precision 28, límite 1000, ruta XDG/local |

`Config.load` limita precisión a 1..1000 y el límite de historial a un mínimo de 1. `History` crea el directorio y reemplaza el archivo mediante escritura temporal; no es una base de datos ni un almacén multiusuario.

## 4. Validación real

- `tests/test_engine.py`: AST, operaciones, errores, JSON y rechazo de ejecución de código.
- `tests/test_basic.sh`: wrapper y operaciones shell básicas.
- `tests/run_tests.sh`, `compileall` y `bash -n`: contratos locales de shell y sintaxis.
- No existe una garantía de precisión certificada para uso financiero o safety-critical; el propio resultado debe verificarse fuera de CalcX.
