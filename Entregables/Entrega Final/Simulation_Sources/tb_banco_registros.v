`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Engineer:
// Create Date: 11.11.2026
// Design Name: Microarquitectura RV32I
// Module Name: tb_banco_registros
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
//
// Que se prueba:
// Objetivo: revisar que los registros guarden y entreguen bien los datos.
// Pruebas: reloj de 10 ns; se cambian entradas cuando baja el reloj.
// Primero se reinicia. Luego se escriben x1, x2 y x31 y se leen por RD1 y RD2.
// Se intenta escribir en x0 y tambien en x1 sin permiso (WE3=0).
// Esperado: despues del reset, todo en cero. Los datos guardados deben ser
// x1=0000000A, x2=FFFFFFFC y x31=12345678. x0 no debe cambiar.
// Se comprueba que se puedan leer dos registros a la vez. Se esperan 0 errores.
//
// Dependencies: banco_registros.v
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module tb_banco_registros(

    );

reg clk;
reg reset;
reg [4:0] A1, A2, A3;
reg [31:0] WD3;
reg WE3;
wire [31:0] RD1, RD2;

integer errores = 0;

banco_registros uut (
    .clk(clk),
    .reset(reset),
    .A1(A1),
    .A2(A2),
    .A3(A3),
    .WD3(WD3),
    .WE3(WE3),
    .RD1(RD1),
    .RD2(RD2)
);

initial clk = 0;
always #5 clk = ~clk;

// Lee dos registros y compara los datos con lo que se espera.
task leer(input [4:0] r1, input [31:0] esp1, input [4:0] r2, input [31:0] esp2);
begin
    A1 = r1;
    A2 = r2;
    #1;
    if (RD1 == esp1 && RD2 == esp2)
        $display("OK    x%0d: RD1=%h   x%0d: RD2=%h", r1, RD1, r2, RD2);
    else begin
        $display("ERROR x%0d: RD1=%h   x%0d: RD2=%h (esperado %h y %h)", r1, RD1, r2, RD2, esp1, esp2);
        errores = errores + 1;
    end
end
endtask

// Intenta guardar un dato. Con we=0 no deberia cambiar nada.
task escribir(input [4:0] rd, input [31:0] dato, input we);
begin
    @(negedge clk);
    A3 = rd; WD3 = dato; WE3 = we;
    @(negedge clk);
    WE3 = 0;
end
endtask

initial begin
    $display("---- Prueba banco_registros ----");
    A1 = 0; A2 = 0; A3 = 0; WD3 = 0; WE3 = 0;

    // 1. Reiniciar y revisar que los registros esten en cero.
    reset = 1;
    @(negedge clk);
    @(negedge clk);
    reset = 0;
    leer(5'd1, 32'h0, 5'd2, 32'h0);
    leer(5'd31, 32'h0, 5'd0, 32'h0);

    // 2. Guardar tres datos y leerlos por las dos salidas.
    escribir(5'd1, 32'h0000000A, 1'b1);
    escribir(5'd2, 32'hFFFFFFFC, 1'b1);
    escribir(5'd31, 32'h12345678, 1'b1);
    leer(5'd1, 32'h0000000A, 5'd2, 32'hFFFFFFFC);
    leer(5'd31, 32'h12345678, 5'd1, 32'h0000000A);
    leer(5'd2, 32'hFFFFFFFC, 5'd31, 32'h12345678);

    // 3. Intentar cambiar x0; debe seguir en cero.
    escribir(5'd0, 32'h0000FFFF, 1'b1);
    leer(5'd0, 32'h0, 5'd0, 32'h0);

    // 4. Intentar cambiar x1 sin permiso; debe quedar igual.
    escribir(5'd1, 32'hDEADBEEF, 1'b0);
    leer(5'd1, 32'h0000000A, 5'd0, 32'h0);

    // 5. Leer dos registros a la vez, como en Decode.
    leer(5'd1, 32'h0000000A, 5'd2, 32'hFFFFFFFC);

    $display("Pruebas terminadas, errores: %0d", errores);
    $finish;
end

endmodule
