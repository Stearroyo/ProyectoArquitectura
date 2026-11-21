`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Module Name: tb_mux4
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
// Description:
//   Objetivo: comprobar que se selecciona la entrada correcta del mux4.
//   Estimulos: cada entrada tiene un valor distinto; se cambia s cada 10 ns.
//   Resultados esperados:
//     s = 00 -> y = 11111111
//     s = 01 -> y = 22222222
//     s = 10 -> y = 33333333
//     s = 11 -> y = 44444444
//   Se esperan 4 pruebas OK y 0 errores.
// Dependencies: mux4.v
//////////////////////////////////////////////////////////////////////////////////

module tb_mux4;

reg [31:0] d0;
reg [31:0] d1;
reg [31:0] d2;
reg [31:0] d3;
reg [1:0] s;
wire [31:0] y;
integer errores = 0;

mux4 uut (
    .d0(d0),
    .d1(d1),
    .d2(d2),
    .d3(d3),
    .s(s),
    .y(y)
);

// Se cambia el selector y se compara la salida despues de 10 ns.
task revisar;
    input [1:0] seleccion;
    input [31:0] esperado;
    begin
        s = seleccion;
        #10;
        if (y === esperado)
            $display("OK    t=%0t s=%b y=%h esperado=%h", $time, s, y, esperado);
        else begin
            $display("ERROR t=%0t s=%b y=%h esperado=%h", $time, s, y, esperado);
            errores = errores + 1;
        end
    end
endtask

initial begin
    $timeformat(-9, 0, " ns", 1);
    $display("---- Prueba mux4 ----");
    d0 = 32'h11111111;
    d1 = 32'h22222222;
    d2 = 32'h33333333;
    d3 = 32'h44444444;

    revisar(2'b00, 32'h11111111);
    revisar(2'b01, 32'h22222222);
    revisar(2'b10, 32'h33333333);
    revisar(2'b11, 32'h44444444);

    $display("Pruebas terminadas, errores: %0d", errores);
    $finish;
end

endmodule
