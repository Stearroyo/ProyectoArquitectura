# Spec — `unidad_control.v`

> **Prompt para la IA:** Crea el archivo Verilog y su testbench siguiendo exactamente esta especificación. No agregues puertos ni cambies nombres.

## Qué es en el diagrama
Es la **unidad de control** del diagrama: "Main FSM + ALU Decoder + Instr Decoder". Recibe **opcode [6:0], funct3 [14:12] y funct7[5]** de la instrucción. Usa los módulos `fsm`, `alu_decoder` e `instr_decoder`, que ya existen. **PCUpdate** y **Branch** salen hacia el bloque **PC Write Logic**, que en el diagrama está afuera.

## Entradas y salidas
| Señal | Dir. | Ancho | Descripción |
|---|---|---|---|
| `clk`, `reset` | entrada | 1 | |
| `op` | entrada | [6:0] | Instr[6:0] |
| `funct3` | entrada | [2:0] | Instr[14:12] |
| `funct7b5` | entrada | 1 | Instr[30] |
| `PCUpdate`, `Branch`, `IRWrite`, `RegWrite`, `MemWrite`, `AdrSrc` | salida | 1 | |
| `ResultSrc`, `ALUSrcA`, `ALUSrcB` | salida | [1:0] | |
| `ALUControl` | salida | [3:0] | |
| `ImmSrc` | salida | [2:0] | |

## Qué debe hacer
- Instancia `fsm` con clk, reset y op. De ahí salen PCUpdate, Branch, ALUOp y las demás señales, que pasan directo a las salidas.
- Instancia `alu_decoder` con ALUOp, funct3 y funct7b5 → ALUControl.
- Instancia `instr_decoder` con op → ImmSrc.
- No tiene lógica propia: solo conecta los tres bloques.

## Testbench
Archivo `tb_unidad_control.v`. Reloj de 10 ns.
1. En Fetch, PCUpdate = 1 e IRWrite = 1.
2. addi → ImmSrc = 000 y en ExecuteI ALUControl = 0000.
3. andi → en ExecuteI ALUControl = 0010; slli → 0011.
4. bne → ImmSrc = 010 y en Branch: Branch = 1 y ALUControl = 0001.
5. sw → ImmSrc = 001 y en MemWrite: MemWrite = 1.

## Reglas para el código
- Verilog 2005, para Vivado 2025.2 (device xc7a35tcpg236-1).
- Un módulo por archivo; el archivo se llama igual que el módulo.
- Usar exactamente los nombres de módulo y de señales de este documento, porque son los del diagrama.
- Lógica combinacional con `always @(*)` y `=`; lógica secuencial con `always @(posedge clk)` y `<=`.
- Todo `case` combinacional lleva `default` y todas las salidas se asignan en todos los casos (sin latches).
- Encabezado al inicio con: nombre del módulo, descripción, entradas y salidas.
- Comentarios en español, cortos y en tercera persona ("se usa", "se calcula"), como los escribiría una persona.
- El testbench es autoverificable: usa una task que compara la salida con el valor esperado, imprime `OK` o `ERROR` con los valores, cuenta los errores y al final imprime `Pruebas terminadas, errores: N` y hace `$finish`. La instancia del módulo se llama `uut`.
