# Spec — `top.v`

> **Prompt para la IA:** Crea el archivo Verilog y su testbench siguiendo exactamente esta especificación. No agregues puertos ni cambies nombres. Usa los módulos que ya existen: memoria, logica_bytes, extension_carga, unidadsigno, banco_registros, alu, registro, mux2, mux3, mux4, unidad_control y pc_write_logic.

## Qué es en el diagrama
Es el **procesador completo**: une la ruta de datos y la unidad de control como en el diagrama general. **Solo tiene las entradas `clk` y `reset`.**

## Entradas y salidas
| Señal | Dir. | Ancho |
|---|---|---|
| `clk` | entrada | 1 |
| `reset` | entrada | 1 |

## Qué debe hacer
Señales internas de 32 bits: PC, PCNext, OldPC, Instr, ReadData, DataExt, Data, A, WriteData, RD1, RD2, ImmExt, SrcA, SrcB, ALUResult, ALUOut, Result, Adr, WD. Además BE [3:0] y las señales de control.

Conexiones:
1. `unidad_control`: op = Instr[6:0], funct3 = Instr[14:12], funct7b5 = Instr[30].
2. `pc_write_logic`: PCUpdate y Branch de la unidad de control, funct3 = Instr[14:12], Z, N, V y C de la ALU → PCWrite.
3. `PCNext = {Result[31:1], 1'b0}`.
4. Registro PC (en = PCWrite, d = PCNext). Registros OldPC (en = IRWrite, d = PC) e Instr (en = IRWrite, d = ReadData).
5. mux2 AdrSrc: d0 = PC, d1 = Result → Adr.
6. `logica_bytes`: funct3 = Instr[14:12], Adr = Adr[1:0], WriteData → BE y WD.
7. `memoria` con MEMFILE = "programa.mem", instancia llamada `mem`: WE = MemWrite, BE, Adr, WD → ReadData.
8. `extension_carga`: ReadData, Adr = Adr[1:0], funct3 = Instr[14:12] → DataExt.
9. Registro Data (en = 1, d = DataExt).
10. `banco_registros`: A1 = Instr[19:15], A2 = Instr[24:20], A3 = Instr[11:7], WD3 = Result, WE3 = RegWrite → RD1 y RD2.
11. Registros A (d = RD1) y WriteData (d = RD2), ambos con en = 1.
12. `unidadsigno`: instr = Instr[31:7], ImmSrc → ImmExt.
13. mux4 ALUSrcA: PC, OldPC, A, 0 → SrcA. mux3 ALUSrcB: WriteData, ImmExt, 4 → SrcB.
14. `alu`: SrcA, SrcB, ALUControl → ALUResult, Z, N, V, C.
15. Registro ALUOut (en = 1, d = ALUResult).
16. mux3 ResultSrc: ALUOut, Data, ALUResult → Result.

## Testbench
Archivo `tb_top.v`.
1. Reloj de 10 ns; reset = 1 durante 2 ciclos y luego 0.
2. Dejar correr el programa una cantidad fija de ciclos (por ejemplo 2000) o hasta que el PC llegue a la dirección final del programa.
3. Llamar `uut.mem.dump("dump_memoria.txt")` y terminar con `$finish`.
4. Criterio: el dump y los registros finales coinciden con los del mismo programa en Ripes o RARS.

## Reglas para el código
- Verilog 2005, para Vivado 2025.2 (device xc7a35tcpg236-1).
- Un módulo por archivo; el archivo se llama igual que el módulo.
- Usar exactamente los nombres de módulo y de señales de este documento, porque son los del diagrama.
- Lógica combinacional con `always @(*)` y `=`; lógica secuencial con `always @(posedge clk)` y `<=`.
- Todo `case` combinacional lleva `default` y todas las salidas se asignan en todos los casos (sin latches).
- Encabezado al inicio con: nombre del módulo, descripción, entradas y salidas.
- Comentarios en español, cortos y en tercera persona ("se usa", "se calcula"), como los escribiría una persona.
- El testbench es autoverificable: usa una task que compara la salida con el valor esperado, imprime `OK` o `ERROR` con los valores, cuenta los errores y al final imprime `Pruebas terminadas, errores: N` y hace `$finish`. La instancia del módulo se llama `uut`.
