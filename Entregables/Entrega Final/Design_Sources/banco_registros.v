`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Engineer:
// Create Date: 11.11.2026
// Design Name: Microarquitectura RV32I
// Module Name: banco_registros
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
//
// Que hace:
// Aqui se guardan los 32 registros (x0 a x31), de 32 bits cada uno.
// A1 y A2 eligen los registros que salen por RD1 y RD2 (rs1 y rs2).
// A3 elige donde guardar WD3 (rd). WE3 es el permiso para escribir.
// Con clk se guarda el dato cuando el reloj pasa de 0 a 1.
// Con reset se ponen todos en cero, incluido sp (x2).
// Se puede leer sin esperar al reloj. x0 siempre devuelve cero.
//
// Dependencies: ninguna
// Revision 0.01 - File Created
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

// Leer x0 siempre devuelve cero.
assign RD1 = (A1 == 5'd0) ? 32'b0 : REG[A1];
assign RD2 = (A2 == 5'd0) ? 32'b0 : REG[A2];

// Solo se guarda un dato cuando sube el reloj y hay permiso.
always @(posedge clk) begin
    if (reset) begin
        for (i = 0; i < 32; i = i + 1)
            REG[i] <= 32'b0;
    end
    else if (WE3 && A3 != 5'd0)   // x0 no se puede cambiar.
        REG[A3] <= WD3;
end

endmodule
