# Spec — `fsm.v`

> **Prompt para la IA:** Crea el archivo Verilog y su testbench siguiendo exactamente esta especificación. No agregues puertos ni cambies nombres.

## Qué es en el diagrama
Es la **máquina de estados** de la unidad de control. Recorre los pasos de cada instrucción y en cada estado activa las señales de control. Tiene **12 estados**: parte de la FSM de clase (10 estados), sin ExecuteR, con JAL, JALR y LUI agregados y con BEQ renombrado a Branch.

## Entradas y salidas
| Señal | Dir. | Ancho |
|---|---|---|
| `clk`, `reset` | entrada | 1 |
| `op` | entrada | [6:0] |
| `PCUpdate`, `Branch`, `IRWrite`, `RegWrite`, `MemWrite`, `AdrSrc` | salida | 1 cada una |
| `ResultSrc`, `ALUSrcA`, `ALUSrcB`, `ALUOp` | salida | [1:0] cada una |

## Qué debe hacer
- El estado se guarda en 4 bits: 0 Fetch, 1 Decode, 2 MemAdr, 3 MemRead, 4 MemWB, 5 MemWrite, 6 ExecuteI, 7 ALUWB, 8 JAL, 9 Branch, 10 LUI, 11 JALR. Se usan `localparam` con esos nombres.
- En el flanco de subida: si reset = 1, el estado es Fetch; si no, pasa al siguiente.

**Siguiente estado:**

| Estado | Siguiente |
|---|---|
| Fetch | Decode |
| Decode | op 0000011 o 0100011 → MemAdr · 0010011 → ExecuteI · 1100011 → Branch · 1101111 → JAL · 1100111 → JALR · 0110111 → LUI · otro → Fetch |
| MemAdr | MemRead si op = 0000011, si no MemWrite |
| MemRead | MemWB |
| MemWB, MemWrite, ALUWB, Branch | Fetch |
| ExecuteI, LUI, JAL | ALUWB |
| JALR | JAL |

**Salidas:** en cada estado, primero todas las salidas en 0 y luego solo las de la tabla:

| Estado | Señales | Qué pasa |
|---|---|---|
| Fetch | AdrSrc=0, IRWrite=1, ALUSrcA=00, ALUSrcB=10, ALUOp=00, ResultSrc=10, PCUpdate=1 | Lee la instrucción y PC = PC + 4 |
| Decode | ALUSrcA=01, ALUSrcB=01, ALUOp=00 | ALUOut = OldPC + imm |
| MemAdr | ALUSrcA=10, ALUSrcB=01, ALUOp=00 | ALUOut = rs1 + imm |
| MemRead | ResultSrc=00, AdrSrc=1 | Lee la memoria en ALUOut |
| MemWB | ResultSrc=01, RegWrite=1 | rd = Data |
| MemWrite | ResultSrc=00, AdrSrc=1, MemWrite=1 | Escribe rs2 en la memoria |
| ExecuteI | ALUSrcA=10, ALUSrcB=01, ALUOp=10 | rs1 op imm |
| ALUWB | ResultSrc=00, RegWrite=1 | rd = ALUOut |
| JAL | ALUSrcA=01, ALUSrcB=10, ALUOp=00, ResultSrc=00, PCUpdate=1 | PC = ALUOut ; ALUOut = OldPC + 4 |
| Branch | ALUSrcA=10, ALUSrcB=00, ALUOp=01, ResultSrc=00, Branch=1 | rs1 − rs2 ; salta si se cumple |
| LUI | ALUSrcA=11, ALUSrcB=01, ALUOp=00 | ALUOut = 0 + imm |
| JALR | ALUSrcA=10, ALUSrcB=01, ALUOp=00 | ALUOut = rs1 + imm |

Ciclos: branch 3 · sw, sb, addi, andi, slli, lui, jal 4 · lw, jalr 5.

## Testbench
Archivo `tb_fsm.v`. Reloj de 10 ns. Se puede leer el estado interno como `uut.estado`.
1. Con reset → Fetch.
2. Para cada opcode (lw, sw, addi, bne, jal, jalr, lui), recorrer los estados y en cada ciclo comparar el estado y las señales con la tabla:
   - lw: Fetch → Decode → MemAdr → MemRead → MemWB → Fetch
   - sw: Fetch → Decode → MemAdr → MemWrite → Fetch
   - addi: Fetch → Decode → ExecuteI → ALUWB → Fetch
   - bne: Fetch → Decode → Branch → Fetch
   - jal: Fetch → Decode → JAL → ALUWB → Fetch
   - jalr: Fetch → Decode → JALR → JAL → ALUWB → Fetch
   - lui: Fetch → Decode → LUI → ALUWB → Fetch
3. Un opcode no usado → de Decode vuelve a Fetch.

## Reglas para el código
- Verilog 2005, para Vivado 2025.2 (device xc7a35tcpg236-1).
- Un módulo por archivo; el archivo se llama igual que el módulo.
- Usar exactamente los nombres de módulo y de señales de este documento, porque son los del diagrama.
- Lógica combinacional con `always @(*)` y `=`; lógica secuencial con `always @(posedge clk)` y `<=`.
- Todo `case` combinacional lleva `default` y todas las salidas se asignan en todos los casos (sin latches).
- Encabezado al inicio con: nombre del módulo, descripción, entradas y salidas.
- Comentarios en español, cortos y en tercera persona ("se usa", "se calcula"), como los escribiría una persona.
- El testbench es autoverificable: usa una task que compara la salida con el valor esperado, imprime `OK` o `ERROR` con los valores, cuenta los errores y al final imprime `Pruebas terminadas, errores: N` y hace `$finish`. La instancia del módulo se llama `uut`.
