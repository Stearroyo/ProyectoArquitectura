# Spec — `instr_decoder.v`

> **Prompt para la IA:** Crea el archivo Verilog y su testbench siguiendo exactamente esta especificación. No agregues puertos ni cambies nombres.

## Qué es en el diagrama
Es el **Instr Decoder**, dentro de la unidad de control. Mira el **opcode** de la instrucción y le dice a la unidad de signo qué formato tiene el inmediato (**ImmSrc**).

## Entradas y salidas
| Señal | Dir. | Ancho | Descripción |
|---|---|---|---|
| `op` | entrada | [6:0] | Instr[6:0] |
| `ImmSrc` | salida | [2:0] | Formato del inmediato |

## Qué debe hacer
Combinacional:

| op | Instrucciones | ImmSrc |
|---|---|---|
| 0010011 | addi, andi, slli | 000 (I) |
| 0000011 | lw | 000 (I) |
| 1100111 | jalr | 000 (I) |
| 0100011 | sw, sb | 001 (S) |
| 1100011 | bge, bne | 010 (B) |
| 1101111 | jal | 011 (J) |
| 0110111 | lui | 100 (U) |
| otro | — | 000 |

## Testbench
Archivo `tb_instr_decoder.v`. Probar los 7 opcodes de la tabla y uno que no se usa (por ejemplo 0110011) → 000.

## Reglas para el código
- Verilog 2005, para Vivado 2025.2 (device xc7a35tcpg236-1).
- Un módulo por archivo; el archivo se llama igual que el módulo.
- Usar exactamente los nombres de módulo y de señales de este documento, porque son los del diagrama.
- Lógica combinacional con `always @(*)` y `=`; lógica secuencial con `always @(posedge clk)` y `<=`.
- Todo `case` combinacional lleva `default` y todas las salidas se asignan en todos los casos (sin latches).
- Encabezado al inicio con: nombre del módulo, descripción, entradas y salidas.
- Comentarios en español, cortos y en tercera persona ("se usa", "se calcula"), como los escribiría una persona.
- El testbench es autoverificable: usa una task que compara la salida con el valor esperado, imprime `OK` o `ERROR` con los valores, cuenta los errores y al final imprime `Pruebas terminadas, errores: N` y hace `$finish`. La instancia del módulo se llama `uut`.
