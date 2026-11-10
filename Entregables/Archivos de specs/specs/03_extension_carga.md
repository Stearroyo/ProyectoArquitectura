# Spec — `extension_carga.v`

> **Prompt para la IA:** Crea el archivo Verilog y su testbench siguiendo exactamente esta especificación. No agregues puertos ni cambies nombres.

## Qué es en el diagrama
Es el bloque **Extensión de carga**, entre la **memoria** y el registro **Data**. La memoria siempre entrega la palabra completa; en un load este bloque toma solo la parte que pide la instrucción (palabra, media palabra o byte) y la extiende a 32 bits. Usa **funct3** de la instrucción y **Adr[1:0]** de la dirección.

## Entradas y salidas
| Señal | Dir. | Ancho | Descripción |
|---|---|---|---|
| `ReadData` | entrada | [31:0] | Palabra leída de la memoria |
| `Adr` | entrada | [1:0] | 2 bits bajos de la dirección de memoria |
| `funct3` | entrada | [2:0] | Instr[14:12]: tipo de load |
| `DataExt` | salida | [31:0] | Dato extendido hacia el registro Data |

## Qué debe hacer
Bloque combinacional. Primero se escoge la parte:
- byte = ReadData[7:0] si Adr = 00, [15:8] si 01, [23:16] si 10, [31:24] si 11
- media = ReadData[15:0] si Adr[1] = 0, si no ReadData[31:16]

Luego, según `funct3`:

| funct3 | Load | DataExt |
|---|---|---|
| 010 | lw | ReadData |
| 000 | lb | 24 copias del bit 7 de byte, byte |
| 100 | lbu | 24 ceros, byte |
| 001 | lh | 16 copias del bit 15 de media, media |
| 101 | lhu | 16 ceros, media |
| otro | — | ReadData |

- El programa solo usa lw; los otros loads se incluyen porque el bloque está en el diagrama, igual que sh en la lógica de escritura por bytes.

## Testbench
Archivo `tb_extension_carga.v`. ReadData fijo en 32'h8822F344 (bytes 44, F3, 22, 88). Pruebas de 10 ns:

| funct3 | Adr | DataExt esperado |
|---|---|---|
| 010 (lw) | 00 | 8822F344 |
| 000 (lb) | 00 | 00000044 |
| 000 (lb) | 01 | FFFFFFF3 |
| 000 (lb) | 10 | 00000022 |
| 000 (lb) | 11 | FFFFFF88 |
| 100 (lbu) | 01 | 000000F3 |
| 100 (lbu) | 11 | 00000088 |
| 001 (lh) | 00 | FFFFF344 |
| 001 (lh) | 10 | FFFF8822 |
| 101 (lhu) | 00 | 0000F344 |
| 101 (lhu) | 10 | 00008822 |
| 111 (otro) | 00 | 8822F344 |

## Reglas para el código
- Verilog 2005, para Vivado 2025.2 (device xc7a35tcpg236-1).
- Un módulo por archivo; el archivo se llama igual que el módulo.
- Usar exactamente los nombres de módulo y de señales de este documento, porque son los del diagrama.
- Lógica combinacional con `always @(*)` y `=`; lógica secuencial con `always @(posedge clk)` y `<=`.
- Todo `case` combinacional lleva `default` y todas las salidas se asignan en todos los casos (sin latches).
- Encabezado al inicio con: nombre del módulo, descripción, entradas y salidas.
- Comentarios en español, cortos y en tercera persona ("se usa", "se calcula"), como los escribiría una persona.
- El testbench es autoverificable: usa una task que compara la salida con el valor esperado, imprime `OK` o `ERROR` con los valores, cuenta los errores y al final imprime `Pruebas terminadas, errores: N` y hace `$finish`. La instancia del módulo se llama `uut`.
