# Spec — `logica_bytes.v`

> **Prompt para la IA:** Crea el archivo Verilog y su testbench siguiendo exactamente esta especificación. No agregues puertos ni cambies nombres.

## Qué es en el diagrama
Es la **lógica de escritura por bytes**, entre el registro **WriteData** y la **memoria**. En un store decide qué bytes de la palabra se escriben (**BE**) y entrega el dato acomodado (**WD**), para que sb no borre los otros bytes de la palabra.

## Entradas y salidas
| Señal | Dir. | Ancho | Descripción |
|---|---|---|---|
| `funct3` | entrada | [2:0] | Instr[14:12]: 010 sw, 001 sh, 000 sb |
| `Adr` | entrada | [1:0] | 2 bits bajos de la dirección de memoria |
| `WriteData` | entrada | [31:0] | Dato a guardar (rs2) |
| `BE` | salida | [3:0] | Byte enable hacia la memoria |
| `WD` | salida | [31:0] | Dato alineado hacia la memoria |

## Qué debe hacer
Bloque combinacional. Según `funct3`:

| funct3 | Store | BE | WD |
|---|---|---|---|
| 010 | sw | 1111 | WriteData |
| 001 | sh | 1100 si Adr[1]=1, si no 0011 | WriteData[15:0] repetido 2 veces |
| 000 | sb | 0001 corrido `Adr` posiciones a la izquierda | WriteData[7:0] repetido 4 veces |
| otro | — | 0000 | WriteData |

## Testbench
Archivo `tb_logica_bytes.v`. WriteData fijo en 32'h11223344. Pruebas de 10 ns; si BE esperado es 0000 no se revisa WD:

| funct3 | Adr | BE | WD |
|---|---|---|---|
| 010 | 00 | 1111 | 11223344 |
| 001 | 00 | 0011 | 33443344 |
| 001 | 10 | 1100 | 33443344 |
| 000 | 00 | 0001 | 44444444 |
| 000 | 01 | 0010 | 44444444 |
| 000 | 10 | 0100 | 44444444 |
| 000 | 11 | 1000 | 44444444 |
| 111 | 00 | 0000 | — |

## Reglas para el código
- Verilog 2005, para Vivado 2025.2 (device xc7a35tcpg236-1).
- Un módulo por archivo; el archivo se llama igual que el módulo.
- Usar exactamente los nombres de módulo y de señales de este documento, porque son los del diagrama.
- Lógica combinacional con `always @(*)` y `=`; lógica secuencial con `always @(posedge clk)` y `<=`.
- Todo `case` combinacional lleva `default` y todas las salidas se asignan en todos los casos (sin latches).
- Encabezado al inicio con: nombre del módulo, descripción, entradas y salidas.
- Comentarios en español, cortos y en tercera persona ("se usa", "se calcula"), como los escribiría una persona.
- El testbench es autoverificable: usa una task que compara la salida con el valor esperado, imprime `OK` o `ERROR` con los valores, cuenta los errores y al final imprime `Pruebas terminadas, errores: N` y hace `$finish`. La instancia del módulo se llama `uut`.
