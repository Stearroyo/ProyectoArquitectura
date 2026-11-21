# Spec — `mux2.v, mux3.v, mux4.v`

> **Prompt para la IA:** Crea los tres archivos Verilog y un testbench para cada uno siguiendo exactamente esta especificación. No agregues puertos ni cambies nombres.

## Qué es en el diagrama
Son los **multiplexores** del diagrama: **AdrSrc** (2 entradas), **ResultSrc** (3), **ALUSrcB** (3) y **ALUSrcA** (4).

## Entradas y salidas
| Módulo | Entradas | Selector | Salida |
|---|---|---|---|
| `mux2` | d0, d1 [WIDTH-1:0] | s (1 bit) | y [WIDTH-1:0] |
| `mux3` | d0, d1, d2 [WIDTH-1:0] | s [1:0] | y [WIDTH-1:0] |
| `mux4` | d0, d1, d2, d3 [WIDTH-1:0] | s [1:0] | y [WIDTH-1:0] |

Todos con parámetro `WIDTH` = 32 por defecto.

## Qué debe hacer
Combinacional:
- mux2: y = d1 si s = 1, si no d0.
- mux3: s = 00 → d0, 01 → d1, 10 → d2, 11 → 0.
- mux4: s = 00 → d0, 01 → d1, 10 → d2, 11 → d3.

Cómo se usan en el top:

| Mux | Módulo | d0 | d1 | d2 | d3 | Salida |
|---|---|---|---|---|---|---|
| AdrSrc | mux2 | PC | Result | | | Adr |
| ALUSrcA | mux4 | PC | OldPC | A | 32'b0 | SrcA |
| ALUSrcB | mux3 | WriteData | ImmExt | 32'd4 | | SrcB |
| ResultSrc | mux3 | ALUOut | Data | ALUResult | | Result |

## Testbench
Un testbench por cada mux. En los tres se pone un valor distinto en cada entrada (d0 = 11111111, d1 = 22222222, d2 = 33333333, d3 = 44444444) y se prueban todos los valores del selector. Pruebas de 10 ns:

**`tb_mux2.v`**

| s | y esperado |
|---|---|
| 0 | 11111111 |
| 1 | 22222222 |

**`tb_mux3.v`**

| s | y esperado |
|---|---|
| 00 | 11111111 |
| 01 | 22222222 |
| 10 | 33333333 |
| 11 | 00000000 (no se usa) |

**`tb_mux4.v`**

| s | y esperado |
|---|---|
| 00 | 11111111 |
| 01 | 22222222 |
| 10 | 33333333 |
| 11 | 44444444 |

## Reglas para el código
- Verilog 2005, para Vivado 2025.2 (device xc7a35tcpg236-1).
- Un módulo por archivo; el archivo se llama igual que el módulo.
- Usar exactamente los nombres de módulo y de señales de este documento, porque son los del diagrama.
- Lógica combinacional con `always @(*)` y `=`; lógica secuencial con `always @(posedge clk)` y `<=`.
- Todo `case` combinacional lleva `default` y todas las salidas se asignan en todos los casos (sin latches).
- Encabezado al inicio con: nombre del módulo, descripción, entradas y salidas.
- Comentarios en español, cortos y en tercera persona ("se usa", "se calcula"), como los escribiría una persona.
- El testbench es autoverificable: usa una task que compara la salida con el valor esperado, imprime `OK` o `ERROR` con los valores, cuenta los errores y al final imprime `Pruebas terminadas, errores: N` y hace `$finish`. La instancia del módulo se llama `uut`.
