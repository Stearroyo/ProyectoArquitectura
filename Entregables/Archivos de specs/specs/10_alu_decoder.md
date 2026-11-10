# Spec — `alu_decoder.v`

> **Prompt para la IA:** Crea el archivo Verilog y su testbench siguiendo exactamente esta especificación. No agregues puertos ni cambies nombres.

## Qué es en el diagrama
Es el **ALU Decoder**, dentro de la unidad de control. Con **ALUOp** (que viene de la FSM), **funct3** y **funct7[5]** (de la instrucción) decide qué operación hace la ALU (**ALUControl**).

## Entradas y salidas
| Señal | Dir. | Ancho | Descripción |
|---|---|---|---|
| `ALUOp` | entrada | [1:0] | De la FSM |
| `funct3` | entrada | [2:0] | Instr[14:12] |
| `funct7b5` | entrada | 1 | Instr[30] (funct7[5]) |
| `ALUControl` | salida | [3:0] | Operación de la ALU |

## Qué debe hacer
Combinacional:

| ALUOp | funct3 | ALUControl | Para qué |
|---|---|---|---|
| 00 | cualquiera | 0000 (suma) | PC + 4, direcciones, lui, saltos |
| 01 | cualquiera | 0001 (resta) | comparar en bge y bne |
| 10 | 000 | 0000 (suma) | addi |
| 10 | 111 | 0010 (AND) | andi |
| 10 | 001 | 0011 (SLL) | slli |
| 10 | otro | 0000 | — |
| 11 | cualquiera | 0000 | — |

- `funct7b5` entra porque está en el diagrama, pero con las instrucciones del programa no cambia el resultado (serviría para distinguir sub o srai, que no se usan).

## Testbench
Archivo `tb_alu_decoder.v`. Probar ALUOp 00 y 01 con dos funct3 distintos cada uno, y ALUOp 10 con 000, 111, 001 y 010.

## Reglas para el código
- Verilog 2005, para Vivado 2025.2 (device xc7a35tcpg236-1).
- Un módulo por archivo; el archivo se llama igual que el módulo.
- Usar exactamente los nombres de módulo y de señales de este documento, porque son los del diagrama.
- Lógica combinacional con `always @(*)` y `=`; lógica secuencial con `always @(posedge clk)` y `<=`.
- Todo `case` combinacional lleva `default` y todas las salidas se asignan en todos los casos (sin latches).
- Encabezado al inicio con: nombre del módulo, descripción, entradas y salidas.
- Comentarios en español, cortos y en tercera persona ("se usa", "se calcula"), como los escribiría una persona.
- El testbench es autoverificable: usa una task que compara la salida con el valor esperado, imprime `OK` o `ERROR` con los valores, cuenta los errores y al final imprime `Pruebas terminadas, errores: N` y hace `$finish`. La instancia del módulo se llama `uut`.
