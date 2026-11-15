`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Engineer:
//
// Create Date: 12.11.2026
// Design Name: Microarquitectura RV32I
// Module Name: registro
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
// Description:
//   Registro con habilitacion. En el diagrama hay varios que funcionan igual
//   (PC, OldPC, Instr, Data, A, WriteData y ALUOut), entonces se hace un solo
//   modulo y en el top se pone una instancia para cada uno.
//   Parametro:
//     WIDTH - ancho del registro, por defecto 32
//   Entradas:
//     clk, reset
//     en - habilitacion; si esta en 0 el registro se queda con lo que tiene
//     d  - dato que entra
//   Salida:
//     q  - lo que esta guardado
//
// Dependencies: ninguna
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   Como se conecta en el top:
//     PC        en = PCWrite   d = PCNext
//     OldPC     en = IRWrite   d = PC
//     Instr     en = IRWrite   d = ReadData
//     Data, A, WriteData y ALUOut van con en = 1 (se cargan en cada ciclo)
//       Data <- DataExt, A <- RD1, WriteData <- RD2, ALUOut <- ALUResult
//   El reset deja el PC en 0, que es donde empieza el programa.
//////////////////////////////////////////////////////////////////////////////////


module registro #(
    parameter WIDTH = 32
    )(
    input clk,
    input reset,
    input en,
    input [WIDTH-1:0] d,
    output reg [WIDTH-1:0] q
    );

always @(posedge clk) begin
    if (reset)
        q <= {WIDTH{1'b0}};
    else if (en)
        q <= d;
    // si en = 0 no se hace nada y q se mantiene
end

endmodule
