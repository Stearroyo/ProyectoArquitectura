`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Module Name: mux2
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
//
// Que hace:
// Escoge uno de dos datos: d0 o d1. s indica cual pasa a la salida y.
// Con s=0 pasa d0; con s=1 pasa d1. WIDTH vale 32 por defecto.
// En el procesador sirve para escoger la direccion de la memoria.
//////////////////////////////////////////////////////////////////////////////////

//Qué cables tiene el mux
module mux2 #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] d0, //d0=PC; viene de reg_pc
    input [WIDTH-1:0] d1,//d1=Result; viene de mux_result
    input s,//selector. s=AdrSrc (unidad de control)
    output reg [WIDTH-1:0] y
);

always @(*) begin//combinalcional
    // Si s vale 1 sale d1; si no, sale d0.
    if (s == 1'b1)
        y = d1;
    else
        y = d0;
end

endmodule
