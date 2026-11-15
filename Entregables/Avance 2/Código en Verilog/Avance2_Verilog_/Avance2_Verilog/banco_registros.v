`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Engineer:
//
// Create Date: 11.11.2026
// Design Name: Microarquitectura RV32I
// Module Name: banco_registros
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
// Description:
//   Banco de registros del diagrama, x0 a x31. Se leen 2 registros a la vez
//   (rs1 y rs2) y se escribe 1 (rd).
//   Entradas:
//     clk, reset
//     A1 - rs1, Instr[19:15]
//     A2 - rs2, Instr[24:20]
//     A3 - rd, Instr[11:7]
//     WD3 - lo que se escribe (Result)
//     WE3 - RegWrite, si esta en 0 no se escribe nada
//   Salidas:
//     RD1 - valor de rs1, va al registro A
//     RD2 - valor de rs2, va al registro WriteData
//
// Dependencies: ninguna
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   Leer es combinacional y escribir es en el flanco de subida.
//   x0 tiene que valer siempre 0, por eso nunca se escribe y al leerlo se
//   devuelve 0 directamente.
//   Con el reset sp (x2) queda en 0, que es como arranca el programa.
//////////////////////////////////////////////////////////////////////////////////


module banco_registros(
    input clk,
    input reset,
    input [4:0] A1,
    input [4:0] A2,
    input [4:0] A3,
    input [31:0] WD3,
    input WE3,
    output [31:0] RD1,
    output [31:0] RD2
    );

reg [31:0] REG [0:31];
integer i;

// si piden x0 se devuelve 0
assign RD1 = (A1 == 5'd0) ? 32'b0 : REG[A1];
assign RD2 = (A2 == 5'd0) ? 32'b0 : REG[A2];

always @(posedge clk) begin
    if (reset) begin
        for (i = 0; i < 32; i = i + 1)
            REG[i] <= 32'b0;
    end
    else if (WE3 && A3 != 5'd0)   // en x0 no se escribe
        REG[A3] <= WD3;
end

endmodule
