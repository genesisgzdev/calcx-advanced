# CalcX architecture

Este documento sigue las dos entradas que existen en el repositorio y no mezcla el menú Bash de compatibilidad con el motor Python moderno.

## Cómo leerlo

La primera figura responde qué se ejecuta. La secuencia responde qué ocurre con una expresión. La tabla responde qué puede cambiar el resultado. No muestra cada función matemática porque eso no ayuda a entender el sistema; esas funciones están en el código y en el manual.

## 1. Mapa de componentes

~~~mermaid
flowchart LR
    subgraph ENTRY[Entradas]
      SH[calcx.sh]
      PM[python -m calcx]
      PX[pipx console: calcx]
    end
    SH -->|sin expresión| MENU[src/calcx-advanced.sh menu]
    SH -->|expresión o flags| PX
    PM --> CLI[calcx/cli.py]
    PX --> CLI
    subgraph PY[Paquete Python]
      CLI --> CFG[config.Config.load]
      CLI --> ENG[engine.evaluate]
      ENG --> AST[ast.Expression + NodeVisitor allow-list]
      ENG --> NUM[Decimal / complex / math / cmath]
      CLI --> HIST[history.History]
      OPS[operations.py library API]
    end
    CFG --> ENG
    CFG --> HIST
    ENG --> OUT[stdout: text or JSON]
    ENG --> ERR[typed error + exit 2]
    HIST --> FILE[bounded atomic history file]
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
    participant CLI as cli.main
    participant Config as Config.load
    participant Parser as ast.parse eval
    participant Eval as _Evaluator
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
