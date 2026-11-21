`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Module Name: mux2
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
// Description:
//   Multiplexor de 2 entradas. Se usa para seleccionar un dato de WIDTH bits.
//   Entradas: d0, d1 (datos), s (selector de 1 bit).
//   Salida: y (dato seleccionado).
//   Parametro: WIDTH = 32 por defecto.
//////////////////////////////////////////////////////////////////////////////////

module mux2 #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] d0,
    input [WIDTH-1:0] d1,
    input s,
    output reg [WIDTH-1:0] y
);

always @(*) begin
    // Se elige una de las dos entradas.
    if (s == 1'b1)
        y = d1;
    else
        y = d0;
end

endmodule
