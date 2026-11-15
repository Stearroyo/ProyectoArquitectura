`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Engineer:
//
// Create Date: 11.11.2026
// Design Name: Microarquitectura RV32I
// Module Name: alu
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
// Description:
//   ALU del diagrama. Hace la operacion que le indica ALUControl y saca las
//   banderas Z, N, V y C (con estas se deciden los saltos).
//   Entradas:
//     SrcA - sale del mux ALUSrcA (PC, OldPC, A o 0)
//     SrcB - sale del mux ALUSrcB (WriteData, ImmExt o 4)
//     ALUControl - viene del ALU Decoder:
//        0000 suma, 0001 resta, 0010 AND, 0011 SLL
//   Salidas:
//     ALUResult - va al registro ALUOut y al mux ResultSrc
//     Z - 1 si el resultado da 0
//     N - el bit 31 del resultado
//     V - overflow con signo
//     C - carry de la suma/resta
//
// Dependencies: ninguna
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   En el diagrama ALUControl es de 4 bits pero los codigos no estan
//   definidos ahi, estos los escogio el grupo (tienen que coincidir con el
//   ALU Decoder).
//   La resta es SrcA + ~SrcB + 1. Si en la resta C = 1 entonces SrcA >= SrcB
//   sin signo.
//   bne salta con Z = 0 y bge con N xor V = 0.
//////////////////////////////////////////////////////////////////////////////////


module alu(
    input [31:0] SrcA,
    input [31:0] SrcB,
    input [3:0] ALUControl,
    output reg [31:0] ALUResult,
    output Z,
    output N,
    output reg V,
    output reg C
    );

always @(*) begin
    case (ALUControl)
        4'b0000: begin  // suma, el bit que sobra es el carry
            {C, ALUResult} = {1'b0, SrcA} + {1'b0, SrcB};
            // hay overflow si los dos tienen el mismo signo y el resultado no
            V = (SrcA[31] == SrcB[31]) && (ALUResult[31] != SrcA[31]);
        end
        4'b0001: begin  // resta con complemento a 2
            {C, ALUResult} = {1'b0, SrcA} + {1'b0, ~SrcB} + 33'd1;
            V = (SrcA[31] != SrcB[31]) && (ALUResult[31] != SrcA[31]);
        end
        4'b0010: begin   // andi
            ALUResult = SrcA & SrcB;
            C = 1'b0;
            V = 1'b0;
        end
        4'b0011: begin   // slli, solo importan los 5 bits bajos de SrcB
            ALUResult = SrcA << SrcB[4:0];
            C = 1'b0;
            V = 1'b0;
        end
        default: begin
            ALUResult = 32'b0;
            C = 1'b0;
            V = 1'b0;
        end
    endcase
end

assign Z = (ALUResult == 32'b0);
assign N = ALUResult[31];

endmodule
