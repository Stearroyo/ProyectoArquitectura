`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Engineer: Dilana Jimenez
//
// Create Date: 11.10.2026 11:10:00
// Design Name: Microarquitectura RV32I
// Module Name: unidadsigno
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2026.1
// Description:
//   Arma el inmediato segun el formato de la instruccion y lo extiende a
//   32 bits (con signo para I, S, B y J; el tipo U ya ocupa los 20 bits altos).
//   Entradas:
//     instr[31:7] : bits de la instruccion donde estan los inmediatos
//     ImmSrc[2:0] : viene de la UC (Instruction Decoder), indica el formato
//                   000 -> tipo I (addi, andi, slli, lw, jalr)
//                   001 -> tipo S (sw, sh, sb)
//                   010 -> tipo B (beq, bne, blt, bge, bltu, bgeu)
//                   011 -> tipo J (jal)
//                   100 -> tipo U (lui, auipc)
//   Salidas:
//     ImmExt[31:0]: inmediato extendido. Va a la entrada 01 del mux ALUSrcB.
//   Por que existe:
//     - I: imm[11:0] = instr[31:20] (addi, lw del codigo C).
//     - S: el inmediato viene partido (imm[11:5] en 31:25 e imm[4:0] en 11:7);
//       hay que juntarlo antes de sumarlo con rs1 (sw, sb del codigo C).
//     - B: imm[12|10:5|4:1|11] desordenado y con bit 0 = 0 (bge, bnez del
//       codigo C). En Decode se suma con OldPC para el destino del salto.
//     - J: imm[20|10:1|11|19:12] con bit 0 = 0 (j = jal x0 del codigo C).
//     - U: imm[31:12] con los 12 bits bajos en 0 (lui del codigo C).
//     El signo siempre esta en instr[31].
//
// Dependencies: ninguna
//
// Revision:
// Revision 0.01 - File Created (formatos I y S, Avance 1)
// Revision 0.02 - Avance 2: ImmSrc pasa a 3 bits y se agregan B, J y U
// Additional Comments:
//   ImmSrc es de 3 bits porque con 2 bits solo caben 4 formatos y se
//   necesitan 5 (I, S, B, J, U). Los codigos 00 (I) y 01 (S) del Avance 1 se
//   mantienen como 000 y 001. El default (tipo R, que no usa inmediato)
//   evita que se genere un latch.
//////////////////////////////////////////////////////////////////////////////////


module unidadsigno(
    input  [31:7] instr,
    input  [2:0]  ImmSrc,
    output reg [31:0] ImmExt
    );

always @(*) begin
    case (ImmSrc)
        // tipo I: imm[11:0] = instr[31:20]
        3'b000: ImmExt = {{20{instr[31]}}, instr[31:20]};
        // tipo S: imm[11:5] = instr[31:25], imm[4:0] = instr[11:7]
        3'b001: ImmExt = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        // tipo B: imm[12] = instr[31], imm[11] = instr[7],
        //         imm[10:5] = instr[30:25], imm[4:1] = instr[11:8], imm[0] = 0
        3'b010: ImmExt = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
        // tipo J: imm[20] = instr[31], imm[19:12] = instr[19:12],
        //         imm[11] = instr[20], imm[10:1] = instr[30:21], imm[0] = 0
        3'b011: ImmExt = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
        // tipo U: imm[31:12] = instr[31:12], los 12 bits bajos en 0
        3'b100: ImmExt = {instr[31:12], 12'b0};
        // tipo R (no usa inmediato) u otro codigo
        default: ImmExt = 32'b0;
    endcase
end

endmodule
