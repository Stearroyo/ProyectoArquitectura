`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Engineer:
// Create Date: 25.10.2026
// Design Name: Microarquitectura RV32I
// Module Name: tb_memoria
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
//
// Que se prueba:
// Objetivo: revisar la lectura, la escritura por bytes y el archivo dump.
// Pruebas: reloj de 10 ns; al bajar el reloj se preparan las entradas.
// Se lee 0x0 y 0x4, se escribe 11223344 en 0x100, y se guarda el byte 62
// ('b') en las cuatro posiciones de la palabra de 0x200, una por una.
// Esperado: al principio cero; luego 11223344 en 0x100 y, en 0x200,
// 00000062, 00006262, 00626262 y 62626262. WE=0 no debe cambiar 0x100.
// Se guarda dump_memoria.txt con direcciones y valores. Se esperan 0 errores.
//
// Dependencies: memoria.v
// Revision 0.01 - File Created (Avance 2)
// Revision 0.02 - Nombres de puertos iguales a los del diagrama
//////////////////////////////////////////////////////////////////////////////////


module tb_memoria(

    );

reg         clk;
reg         WE;
reg  [3:0]  BE;
reg  [31:0] Adr;
reg  [31:0] WD;
wire [31:0] ReadData;

integer errores = 0;

memoria uut (
    .clk(clk), .WE(WE), .BE(BE), .Adr(Adr), .WD(WD), .ReadData(ReadData)
);

// El reloj cambia cada 5 ns; una vuelta completa dura 10 ns.
initial clk = 0;
always #5 clk = ~clk;

// Lee una direccion y revisa que tenga el dato esperado.
task leer(input [31:0] dir, input [31:0] esperado);
begin
    WE = 0;
    Adr = dir;
    #1;
    if (ReadData == esperado)
        $display("OK    dir=%h ReadData=%h", dir, ReadData);
    else begin
        $display("ERROR dir=%h ReadData=%h (esperado %h)", dir, ReadData, esperado);
        errores = errores + 1;
    end
end
endtask

// Prepara la direccion y el dato cuando baja el reloj.
// La memoria los guarda cuando el reloj vuelve a subir.
task escribir(input [31:0] dir, input [3:0] bytes, input [31:0] dato);
begin
    @(negedge clk);
    Adr = dir; BE = bytes; WD = dato; WE = 1;
    @(negedge clk);
    WE = 0;
end
endtask

initial begin
    $display("---- Prueba memoria ----");
    WE = 0; BE = 0; Adr = 0; WD = 0;

    // 1. La memoria debe empezar en cero.
    leer(32'h00000000, 32'h00000000);
    leer(32'h00000004, 32'h00000000);

    // 2. SW: guardar los cuatro bytes.
    escribir(32'h00000100, 4'b1111, 32'h11223344);
    leer(32'h00000100, 32'h11223344);

    // 3. SB: guardar un byte a la vez. WD trae el mismo byte 4 veces.
    // BE permite cambiar solo uno, sin tocar los demas.
    escribir(32'h00000200, 4'b0001, 32'h62626262);
    leer(32'h00000200, 32'h00000062);
    escribir(32'h00000201, 4'b0010, 32'h62626262);
    leer(32'h00000200, 32'h00006262);
    escribir(32'h00000202, 4'b0100, 32'h62626262);
    leer(32'h00000200, 32'h00626262);
    escribir(32'h00000203, 4'b1000, 32'h62626262);
    leer(32'h00000200, 32'h62626262);

    // 4. Sin permiso, el dato anterior debe quedar igual.
    @(negedge clk);
    Adr = 32'h00000100; BE = 4'b1111; WD = 32'hFFFFFFFF; WE = 0;
    @(negedge clk);
    leer(32'h00000100, 32'h11223344);

    // 5. Guardar toda la memoria en un archivo de texto.
    uut.dump("dump_memoria.txt");
    $display("Dump guardado en dump_memoria.txt");

    $display("Pruebas terminadas, errores: %0d", errores);
    $finish;
end

endmodule
