`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Module Name: tb_mux3
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
//
// Que se prueba:
// Objetivo: revisar que y copie la entrada elegida por s.
// Pruebas: d0=11111111, d1=22222222 y d2=33333333 (hexadecimal).
// Se cambia s cada 10 ns. Esperado: 00 da d0, 01 da d1, 10 da d2 y 11 da cero.
// Son 4 pruebas; al final se esperan 0 errores.
//
// Dependencies: mux3.v
//////////////////////////////////////////////////////////////////////////////////

module tb_mux3;

reg [31:0] d0;
reg [31:0] d1;
reg [31:0] d2;
reg [1:0] s;
wire [31:0] y;
integer errores = 0;

mux3 uut (
    .d0(d0),
    .d1(d1),
    .d2(d2),
    .s(s),
    .y(y)
);

// Cambia s, espera 10 ns y revisa si y tiene el valor correcto.
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
    $display("---- Prueba mux3 ----");
    d0 = 32'h11111111;
    d1 = 32'h22222222;
    d2 = 32'h33333333;

    revisar(2'b00, 32'h11111111);
    revisar(2'b01, 32'h22222222);
    revisar(2'b10, 32'h33333333);
    revisar(2'b11, 32'h00000000);

    $display("Pruebas terminadas, errores: %0d", errores);
    $finish;
end

endmodule
