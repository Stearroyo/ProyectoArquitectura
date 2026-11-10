# Spec — `alu.v`

> **Prompt para la IA:** Crea el archivo Verilog y su testbench siguiendo exactamente esta especificación. No agregues puertos ni cambies nombres.

## Qué es en el diagrama
Es la **ALU**. **SrcA** viene del mux **ALUSrcA** y **SrcB** del mux **ALUSrcB**; la operación la escoge **ALUControl**, que viene del **ALU Decoder**. **ALUResult** va al registro **ALUOut** y a la entrada 10 del mux **ResultSrc**. Las banderas **Z, N, V** van a la unidad de control para decidir los saltos.

## Entradas y salidas
| Señal | Dir. | Ancho | Descripción |
|---|---|---|---|
| `SrcA` | entrada | [31:0] | Operando A |
| `SrcB` | entrada | [31:0] | Operando B |
| `ALUControl` | entrada | [3:0] | Operación (4 bits, como en el diagrama) |
| `ALUResult` | salida | [31:0] | Resultado |
| `Z` | salida | 1 | 1 si el resultado es 0 |
| `N` | salida | 1 | Bit 31 del resultado (negativo) |
| `V` | salida | 1 | Desbordamiento con signo |
| `C` | salida | 1 | Acarreo |

## Qué debe hacer
Bloque combinacional:

| ALUControl | Operación | Instrucciones |
|---|---|---|
| 0000 | ALUResult = SrcA + SrcB | addi, lw, sw, sb, jalr, lui, PC+4 |
| 0001 | ALUResult = SrcA − SrcB (SrcA + ~SrcB + 1) | bge, bne |
| 0010 | ALUResult = SrcA AND SrcB | andi |
| 0011 | ALUResult = SrcA << SrcB[4:0] | slli |
| otro | ALUResult = 0 | — |

- El diagrama solo fija que ALUControl tiene 4 bits; los códigos de la tabla son decisión del grupo y deben ser los mismos en el ALU Decoder.
- C: el bit 33 de la suma o de la resta; 0 en las demás. En la resta, C = 1 significa SrcA ≥ SrcB sin signo.
- V en la suma: 1 si SrcA y SrcB tienen el mismo signo y el resultado tiene otro.
- V en la resta: 1 si SrcA y SrcB tienen distinto signo y el resultado tiene distinto signo que SrcA. En las demás, 0.
- Z = 1 si ALUResult = 0. N = ALUResult[31].

## Testbench
Archivo `tb_alu.v`. Pruebas de 10 ns revisando ALUResult y las banderas:
1. Suma: 5 + 3 = 8; 7FFFFFFF + 1 = 80000000 con V = 1; FFFFFFFF + 1 = 0 con Z = 1 y C = 1.
2. Resta: 5 − 5 = 0 con Z = 1; 3 − 5 = FFFFFFFE con N = 1; 80000000 − 1 con V = 1.
3. Para bge: 5 − 3 da N xor V = 0, y 3 − 5 da N xor V = 1.
4. AND: F0F0F0F0 AND 0FF00FF0 = 00F000F0.
5. SLL: 1 << 0 = 1; 1 << 4 = 10; 1 << 31 = 80000000.
6. Código 1111 → 0.

## Reglas para el código
- Verilog 2005, para Vivado 2025.2 (device xc7a35tcpg236-1).
- Un módulo por archivo; el archivo se llama igual que el módulo.
- Usar exactamente los nombres de módulo y de señales de este documento, porque son los del diagrama.
- Lógica combinacional con `always @(*)` y `=`; lógica secuencial con `always @(posedge clk)` y `<=`.
- Todo `case` combinacional lleva `default` y todas las salidas se asignan en todos los casos (sin latches).
- Encabezado al inicio con: nombre del módulo, descripción, entradas y salidas.
- Comentarios en español, cortos y en tercera persona ("se usa", "se calcula"), como los escribiría una persona.
- El testbench es autoverificable: usa una task que compara la salida con el valor esperado, imprime `OK` o `ERROR` con los valores, cuenta los errores y al final imprime `Pruebas terminadas, errores: N` y hace `$finish`. La instancia del módulo se llama `uut`.
