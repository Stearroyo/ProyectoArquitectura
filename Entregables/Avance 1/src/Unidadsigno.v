`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Engineer: Dilana Jimenez
// 
// Create Date: 11.10.2026 11:10:00
// Design Name: Microarquitectura RV32I
// Module Name: unidad_signo
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2026.1
// Description: 
//   Arma el inmediato de 12 bits segun el formato de la instruccion y lo
//   extiende con signo a 32 bits.
//   Entradas:
//     instr[31:7] : bits de la instruccion donde estan los inmediatos
//     ImmSrc[1:0] : viene de la UC, indica el formato
//                   00 -> tipo I (addi, lw, jalr)
//                   01 -> tipo S (sw, sh, sb)
//   Salidas:
//     ImmExt[31:0]: inmediato extendido, va al mux ALUSrc (entrada B ALU)
//   Por que existe: en tipo S el inmediato viene partido (imm[11:5] en
//   bits 31:25 e imm[4:0] en bits 11:7), entonces hay que juntarlo antes
//   de sumarlo con rs1. El signo siempre esta en instr[31].
// 
// Dependencies: ninguna
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   ImmSrc es de 2 bits para poder agregar los formatos B y J despues.
//   El default evita que se genere un latch.
//////////////////////////////////////////////////////////////////////////////////


module unidadsigno(
    input  [31:7] instr,
    input  [1:0]  ImmSrc,
    output reg [31:0] ImmExt
    );

always @(*) begin
    case (ImmSrc)
        // tipo I: imm[11:0] = instr[31:20]
        2'b00: ImmExt = {{20{instr[31]}}, instr[31:20]};
        // tipo S: imm[11:5] = instr[31:25], imm[4:0] = instr[11:7]
        2'b01: ImmExt = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        // B y J todavia no
        default: ImmExt = 32'b0;
    endcase
end

endmodule
