`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Module Name: mux4
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
// Description:
//   Multiplexor de 4 entradas. Se usa para seleccionar un dato de WIDTH bits.
//   Entradas: d0, d1, d2, d3 (datos), s (selector de 2 bits).
//   Salida: y (dato seleccionado).
//   Parametro: WIDTH = 32 por defecto.
//////////////////////////////////////////////////////////////////////////////////

module mux4 #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] d0,
    input [WIDTH-1:0] d1,
    input [WIDTH-1:0] d2,
    input [WIDTH-1:0] d3,
    input [1:0] s,
    output reg [WIDTH-1:0] y
);

always @(*) begin
    case (s)
        2'b00: y = d0;
        2'b01: y = d1;
        2'b10: y = d2;
        2'b11: y = d3;
        default: y = {WIDTH{1'b0}};
    endcase
end

endmodule
