# Spec — `banco_registros.v`

> **Prompt para la IA:** Crea el archivo Verilog y su testbench siguiendo exactamente esta especificación. No agregues puertos ni cambies nombres.

## Qué es en el diagrama
Es el **banco de registros** (x0 a x31). Las direcciones salen del registro **Instr**: A1 = rs1, A2 = rs2, A3 = rd. Lo que escribe es **Result** (salida del mux ResultSrc) y solo cuando **RegWrite** = 1. RD1 va al registro **A** y RD2 al registro **WriteData**.

## Entradas y salidas
| Señal | Dir. | Ancho | Descripción |
|---|---|---|---|
| `clk` | entrada | 1 | Reloj |
| `reset` | entrada | 1 | Pone todos los registros en 0 |
| `A1` | entrada | [4:0] | Instr[19:15] (rs1) |
| `A2` | entrada | [4:0] | Instr[24:20] (rs2) |
| `A3` | entrada | [4:0] | Instr[11:7] (rd) |
| `WD3` | entrada | [31:0] | Dato a escribir (Result) |
| `WE3` | entrada | 1 | RegWrite |
| `RD1` | salida | [31:0] | Valor de rs1 |
| `RD2` | salida | [31:0] | Valor de rs2 |

## Qué debe hacer
- 32 registros de 32 bits.
- Lectura combinacional: RD1 = registro A1 y RD2 = registro A2. Si la dirección es 0, la salida es 0.
- En el flanco de subida: si reset = 1, todos los registros pasan a 0. Si no, y WE3 = 1 y A3 ≠ 0, se escribe WD3 en el registro A3.
- x0 nunca cambia: siempre vale 0.

## Testbench
Archivo `tb_banco_registros.v`. Reloj de 10 ns.
1. Después del reset, leer x1, x2 y x31 → 0.
2. Escribir x1 = 0000000A, x2 = FFFFFFFC y x31 = 12345678; leerlos por RD1 y RD2.
3. Escribir 0000FFFF en x0 → x0 sigue en 0.
4. Con WE3 = 0, intentar escribir en x1 → no cambia.
5. Leer x1 por RD1 y x2 por RD2 al mismo tiempo.

## Reglas para el código
- Verilog 2005, para Vivado 2025.2 (device xc7a35tcpg236-1).
- Un módulo por archivo; el archivo se llama igual que el módulo.
- Usar exactamente los nombres de módulo y de señales de este documento, porque son los del diagrama.
- Lógica combinacional con `always @(*)` y `=`; lógica secuencial con `always @(posedge clk)` y `<=`.
- Todo `case` combinacional lleva `default` y todas las salidas se asignan en todos los casos (sin latches).
- Encabezado al inicio con: nombre del módulo, descripción, entradas y salidas.
- Comentarios en español, cortos y en tercera persona ("se usa", "se calcula"), como los escribiría una persona.
- El testbench es autoverificable: usa una task que compara la salida con el valor esperado, imprime `OK` o `ERROR` con los valores, cuenta los errores y al final imprime `Pruebas terminadas, errores: N` y hace `$finish`. La instancia del módulo se llama `uut`.
