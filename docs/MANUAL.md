# Usar CalcX a tu manera

## Varias cuentas seguidas

Abre `python -m calcx`, escribe una cuenta y pulsa Enter. No hace falta volver a abrir el programa para la siguiente.

| Acción | Comando dentro de CalcX |
| --- | --- |
| Ver ejemplos | `ayuda` o `ejemplos` |
| Consultar funciones | `funciones` |
| Volver a ver cuentas | `historial` |
| Cambiar las cifras de las próximas cuentas | `precision 40` |
| Eliminar las cuentas guardadas | `borrar` |
| Cerrar | `salir` |

La nueva precisión dura hasta que cierres esa sesión. Usa `CALCX_PRECISION` o el archivo de configuración para conservarla entre sesiones.

## Operaciones y funciones

Puedes sumar, restar, multiplicar y dividir con `+`, `-`, `*` y `/`. `//` calcula división entera, `%` obtiene el resto y `^` eleva a una potencia. Usa paréntesis para dejar claro qué debe calcularse primero.

`pi`, `e`, `tau` e `i` están disponibles sin definirlas. Las funciones incluyen `sqrt`, `abs`, `sin`, `cos`, `tan`, `asin`, `acos`, `atan`, `sinh`, `cosh`, `tanh`, `exp`, `log`, `ln`, `log10`, `floor`, `ceil` y `factorial`.

Los ángulos se expresan en radianes. Para 30 grados escribe `sin(30*pi/180)`. `log(8, 2)` es el logaritmo de 8 en base 2. `factorial(5)` devuelve 120.

## Elegir dónde guardar las cuentas

La configuración opcional vive en `~/.config/calcx/config.env`, o bajo `XDG_CONFIG_HOME` cuando lo hayas definido:

```text
PRECISION=40
HISTORY_LIMIT=500
HISTORY_FILE=~/.local/state/calcx/history
```

`HISTORY_LIMIT` indica cuántas cuentas conservar. Puedes aumentarlo. `CALCX_PRECISION`, `CALCX_HISTORY_LIMIT` y `CALCX_HISTORY` tienen prioridad sobre el archivo. `--precision` tiene prioridad sobre ambas fuentes. La ubicación predeterminada del historial respeta `XDG_STATE_HOME`.

## Conectar con otro programa

```sh
python -m calcx --json "1/7" --precision 40
```

La salida es un único objeto JSON. Un error de cálculo también usa JSON cuando se solicita ese formato. El código de salida es 0 si se calculó y 2 si la entrada o configuración no es válida. Los errores de argumentos se escriben en la salida de errores. `--json` necesita una cuenta; no abre una sesión interactiva.

## Operaciones para Python

Estas funciones sirven cuando ya estás escribiendo un programa. No tienes que aprenderlas para usar la calculadora.

```python
from calcx.operations import quadratic, matrix_inverse, integrate

raices = quadratic(1, -3, 2)
inversa = matrix_inverse([[2, 0], [0, 4]])
area = integrate(lambda x: x * x, 0, 1)
```

`newton` busca una raíz a partir de una estimación y una derivada. `dft` transforma una lista de muestras complejas. Consulta [cómo se controlan la precisión y el tamaño de estas operaciones](ARCHITECTURE.md) antes de trabajar con datos grandes.

[Volver al inicio](../README.md)
