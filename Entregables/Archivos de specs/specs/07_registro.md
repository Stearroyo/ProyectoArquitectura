# Spec — `registro.v`

> **Prompt para la IA:** Crea el archivo Verilog y su testbench siguiendo exactamente esta especificación. No agregues puertos ni cambies nombres.

## Qué es en el diagrama
Es un **registro de 32 bits con habilitación**. En el diagrama hay varios iguales: **PC, OldPC, Instr, Data, A, WriteData y ALUOut**. Se escribe un solo módulo y se usa varias veces en el top.

## Entradas y salidas
| Señal | Dir. | Ancho | Descripción |
|---|---|---|---|
| `WIDTH` | parámetro | — | Ancho; por defecto 32 |
| `clk` | entrada | 1 | Reloj |
| `reset` | entrada | 1 | Pone la salida en 0 |
| `en` | entrada | 1 | Habilitación |
| `d` | entrada | [WIDTH-1:0] | Dato de entrada |
| `q` | salida | [WIDTH-1:0] | Dato guardado |

## Qué debe hacer
- En el flanco de subida: si reset = 1, q = 0. Si no, y en = 1, q = d. Si en = 0, q se mantiene.

Cómo se usa en el top:

| Registro | en | d |
|---|---|---|
| PC | PCWrite | PCNext |
| OldPC | IRWrite | PC |
| Instr | IRWrite | ReadData |
| Data | 1 | DataExt (salida de la Extensión de carga) |
| A | 1 | RD1 |
| WriteData | 1 | RD2 |
| ALUOut | 1 | ALUResult |

## Testbench
Archivo `tb_registro.v`. Reloj de 10 ns.
1. Con reset = 1 → q = 0.
2. en = 1, d = AABBCCDD → después del flanco q = AABBCCDD.
3. en = 0, d = 11111111 → después del flanco q sigue en AABBCCDD.
4. Cambiar d entre flancos → q no cambia hasta el siguiente flanco con en = 1.

## Reglas para el código
- Verilog 2005, para Vivado 2025.2 (device xc7a35tcpg236-1).
- Un módulo por archivo; el archivo se llama igual que el módulo.
- Usar exactamente los nombres de módulo y de señales de este documento, porque son los del diagrama.
- Lógica combinacional con `always @(*)` y `=`; lógica secuencial con `always @(posedge clk)` y `<=`.
- Todo `case` combinacional lleva `default` y todas las salidas se asignan en todos los casos (sin latches).
- Encabezado al inicio con: nombre del módulo, descripción, entradas y salidas.
- Comentarios en español, cortos y en tercera persona ("se usa", "se calcula"), como los escribiría una persona.
- El testbench es autoverificable: usa una task que compara la salida con el valor esperado, imprime `OK` o `ERROR` con los valores, cuenta los errores y al final imprime `Pruebas terminadas, errores: N` y hace `$finish`. La instancia del módulo se llama `uut`.
