# Spec — `unidadsigno.v`

> **Prompt para la IA:** Crea el archivo Verilog y su testbench siguiendo exactamente esta especificación. No agregues puertos ni cambies nombres.

## Qué es en el diagrama
Es la **unidad de signo (Extend)**. Recibe la instrucción desde el registro **Instr** y el formato desde el **Instr Decoder** (ImmSrc). Su salida **ImmExt** va a la entrada 01 del mux **ALUSrcB**. Los inmediatos vienen partidos y desordenados dentro de la instrucción; este bloque los junta en orden y los extiende a 32 bits con signo.

## Entradas y salidas
| Señal | Dir. | Ancho | Descripción |
|---|---|---|---|
| `instr` | entrada | [31:7] | Bits de la instrucción (el opcode no se usa) |
| `ImmSrc` | entrada | [2:0] | Formato del inmediato |
| `ImmExt` | salida | [31:0] | Inmediato ordenado y extendido |

## Qué debe hacer
Bloque combinacional. Según `ImmSrc`:

| ImmSrc | Formato | ImmExt |
|---|---|---|
| 000 | I | 20 copias de instr[31], instr[31:20] |
| 001 | S | 20 copias de instr[31], instr[31:25], instr[11:7] |
| 010 | B | 19 copias de instr[31], instr[31], instr[7], instr[30:25], instr[11:8], 1'b0 |
| 011 | J | 11 copias de instr[31], instr[31], instr[19:12], instr[20], instr[30:21], 1'b0 |
| 100 | U | instr[31:12], 12 ceros |
| otro | — | 0 |

- El signo siempre es instr[31]. En B y J el bit 0 siempre es 0.

## Testbench
Archivo `tbunidadsigno.v`. Cada prueba dura 10 ns y usa instrucciones reales en hex:

| Instrucción | Hex | ImmSrc | Esperado |
|---|---|---|---|
| sw x5,8(x2) | 00512423 | 001 | 00000008 |
| sw x5,-4(x2) | FE512E23 | 001 | FFFFFFFC |
| sw x5,-2048(x2) | 80512023 | 001 | FFFFF800 |
| addi x5,x0,10 | 00A00293 | 000 | 0000000A |
| addi x5,x0,-1 | FFF00293 | 000 | FFFFFFFF |
| bge a0,a1,+8 | 00B55463 | 010 | 00000008 |
| bnez a0,+8 | 00051463 | 010 | 00000008 |
| beq x0,x0,-4 | FE000EE3 | 010 | FFFFFFFC |
| beq x0,x0,-4096 | 80000063 | 010 | FFFFF000 |
| beq x0,x0,+4094 | 7E000FE3 | 010 | 00000FFE |
| jal ra,+8 | 008000EF | 011 | 00000008 |
| j -0x5C | FA5FF06F | 011 | FFFFFFA4 |
| jal zero,-1048576 | 8000006F | 011 | FFF00000 |
| jal zero,+1048574 | 7FFFF06F | 011 | 000FFFFE |
| lui sp,0x1 | 00001137 | 100 | 00001000 |
| lui a0,0xC | 0000C537 | 100 | 0000C000 |
| lui x5,0xFFFFF | FFFFF2B7 | 100 | FFFFF000 |
| (igual a la primera) | 00512423 | 111 | 00000000 |

## Reglas para el código
- Verilog 2005, para Vivado 2025.2 (device xc7a35tcpg236-1).
- Un módulo por archivo; el archivo se llama igual que el módulo.
- Usar exactamente los nombres de módulo y de señales de este documento, porque son los del diagrama.
- Lógica combinacional con `always @(*)` y `=`; lógica secuencial con `always @(posedge clk)` y `<=`.
- Todo `case` combinacional lleva `default` y todas las salidas se asignan en todos los casos (sin latches).
- Encabezado al inicio con: nombre del módulo, descripción, entradas y salidas.
- Comentarios en español, cortos y en tercera persona ("se usa", "se calcula"), como los escribiría una persona.
- El testbench es autoverificable: usa una task que compara la salida con el valor esperado, imprime `OK` o `ERROR` con los valores, cuenta los errores y al final imprime `Pruebas terminadas, errores: N` y hace `$finish`. La instancia del módulo se llama `uut`.
