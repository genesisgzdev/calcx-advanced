# Mapa del repositorio

Revisión de estructura y flujos: 2026-09-11. Este inventario cubre los archivos versionados y las incorporaciones de esta revisión; excluye dependencias instaladas y artefactos de build. Los límites de validación aparecen por área.

## Flujos y fronteras

| Área | Recorrido real | Verificación / límite |
| --- | --- | --- |
| Entrada | calcx.sh y script histórico delegan en calcx.cli; argparse separa evaluación y operaciones | La ruta Bash histórica queda fuera del evaluator activo |
| Aritmética | AST con allow-list y presupuestos → Decimal o complex → normalización de salida | Literales conservan texto; math/cmath conserva precisión de máquina |
| Operaciones | matrices, integración, Newton, cuadráticas y DFT en operations.py | Límites de tamaño y no finitos; Newton valida tolerancia e iteraciones |
| Estado | config.py → historial con lock y reemplazo atómico | Error de historial no invalida el cálculo; archivos XDG configurables |
| Distribución | pyproject, wrappers, instalador, Docker, CI | Instalador conserva configuración; Python y pruebas del shell |

## Inventario de archivos

| Archivo | Responsabilidad |
| --- | --- |
| [.dockerignore](../.dockerignore) | Configuración/metadata: .dockerignore |
| [.github/workflows/ci.yml](../.github/workflows/ci.yml) | Automatización de ci |
| [.github/workflows/security.yml](../.github/workflows/security.yml) | Automatización de security |
| [.gitignore](../.gitignore) | Configuración/metadata: .gitignore |
| [CHANGELOG.md](../CHANGELOG.md) | Documentación: CHANGELOG |
| [Dockerfile](../Dockerfile) | Build y ejecución en contenedores |
| [LICENSE](../LICENSE) | Licencia del proyecto |
| [README.md](../README.md) | Documentación: README |
| [VERSION](../VERSION) | Configuración/metadata: VERSION |
| [calcx.sh](../calcx.sh) | Entrada compatible de shell al CLI Python |
| [calcx/__init__.py](../calcx/__init__.py) | Módulo: __init__ |
| [calcx/__main__.py](../calcx/__main__.py) | Módulo: __main__ |
| [calcx/cli.py](../calcx/cli.py) | Módulo: cli |
| [calcx/config.py](../calcx/config.py) | Configuración y rutas XDG |
| [calcx/engine.py](../calcx/engine.py) | Evaluator AST y presupuesto numérico |
| [calcx/errors.py](../calcx/errors.py) | Módulo: errors |
| [calcx/history.py](../calcx/history.py) | Historial y exclusión entre procesos |
| [calcx/operations.py](../calcx/operations.py) | Operaciones científicas acotadas |
| [config/calcx.conf](../config/calcx.conf) | Configuración/metadata: calcx.conf |
| [docker-compose.yml](../docker-compose.yml) | Build y ejecución en contenedores |
| [docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md) | Documentación: ARCHITECTURE |
| [docs/MANUAL.md](../docs/MANUAL.md) | Documentación: MANUAL |
| [docs/REPOSITORY_MAP.md](../docs/REPOSITORY_MAP.md) | Documentación: REPOSITORY_MAP |
| [examples/advanced_usage.sh](../examples/advanced_usage.sh) | Herramienta de ejecución: advanced_usage |
| [examples/basic_usage.sh](../examples/basic_usage.sh) | Herramienta de ejecución: basic_usage |
| [lib/colors.sh](../lib/colors.sh) | Herramienta de ejecución: colors |
| [lib/math_functions.sh](../lib/math_functions.sh) | Herramienta de ejecución: math_functions |
| [pyproject.toml](../pyproject.toml) | Dependencias y comandos del componente |
| [scripts/install.sh](../scripts/install.sh) | Herramienta de ejecución: install |
| [scripts/uninstall.sh](../scripts/uninstall.sh) | Herramienta de ejecución: uninstall |
| [src/calcx-advanced.sh](../src/calcx-advanced.sh) | Entrada histórica delegada al CLI Python |
| [tests/conftest.py](../tests/conftest.py) | Validación: conftest |
| [tests/run_tests.sh](../tests/run_tests.sh) | Validación: run_tests |
| [tests/test_basic.sh](../tests/test_basic.sh) | Validación: test_basic |
| [tests/test_engine.py](../tests/test_engine.py) | Validación: test_engine |
| [tests/test_regressions.py](../tests/test_regressions.py) | Validación: test_regressions |
