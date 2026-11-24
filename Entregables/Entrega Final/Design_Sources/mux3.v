`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Module Name: mux3
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
//
// Que hace:
// Escoge uno de tres datos: d0, d1 o d2, usando s de 2 bits.
// y es el dato elegido. WIDTH vale 32 por defecto.
// 00 elige d0, 01 elige d1, 10 elige d2; con 11 sale cero.
// Se usa para elegir el segundo dato de la ALU y el resultado final.
//////////////////////////////////////////////////////////////////////////////////

module mux3 #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] d0,
    input [WIDTH-1:0] d1,
    input [WIDTH-1:0] d2,
    input [1:0] s,//selector de 2 bits: viene de la unidad de control(ALUSrcB o ResultSrc)
    output reg [WIDTH-1:0] y
);

always @(*) begin//combinacional
    // s indica que dato se copia a y.
    case (s)
        2'b00: y = d0;
        2'b01: y = d1;
        2'b10: y = d2;
        2'b11: y = {WIDTH{1'b0}}; // No hay cuarta entrada, por eso sale cero.
        default: y = {WIDTH{1'b0}};
    endcase
end

endmodule
