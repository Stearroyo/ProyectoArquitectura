`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Engineer:
//
// Create Date: 25.10.2026
// Design Name: Microarquitectura RV32I
// Module Name: tb_memoria
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
// Description:
//   Objetivo de la prueba:
//     Revisar que la memoria arranca en 0, que con sw escribe la palabra
//     completa, que con sb cambia solo un byte sin tocar los demas y que el
//     dump saca el archivo con el formato que pide el enunciado.
//   Estimulos (en este orden, cambiando las entradas en el flanco de bajada):
//     1. Leer las direcciones 0x0 y 0x4 (la memoria arranca vacia)
//     2. sw: escribir 0x11223344 en 0x100 (BE = 1111)
//     3. sb: escribir el byte 0x62 ('b') en cada byte de 0x200:
//        0x200 (BE = 0001), 0x201 (0010), 0x202 (0100), 0x203 (1000)
//     4. WE = 0 con BE = 1111 en 0x100: no debe cambiar
//     5. dump de toda la memoria a dump_memoria.txt
//   Resultados esperados:
//     1. 0x00000000 en las dos
//     2. 0x11223344
//     3. 0x00000062, 0x00006262, 0x00626262, 0x62626262
//     4. sigue en 0x11223344
//     5. archivo con "Direccion de memoria    Valor en hexadecimal"
//     En la consola tiene que salir OK en todas y 0 errores.
//
// Dependencies: memoria.v
//
// Revision:
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

// reloj de 10 ns (cambia cada 5)
initial clk = 0;
always #5 clk = ~clk;

// lee una direccion y compara con lo que deberia haber
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

// escribe: las entradas se ponen en negedge para que esten estables
// cuando llegue el flanco de subida, que es cuando la memoria escribe
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

    // 1. tiene que arrancar en 0
    leer(32'h00000000, 32'h00000000);
    leer(32'h00000004, 32'h00000000);

    // 2. sw, la palabra completa
    escribir(32'h00000100, 4'b1111, 32'h11223344);
    leer(32'h00000100, 32'h11223344);

    // 3. sb byte por byte en 0x200. WD trae el byte repetido 4 veces, igual
    //    que como lo entrega logica_bytes; BE es el que escoge cual se escribe
    escribir(32'h00000200, 4'b0001, 32'h62626262);
    leer(32'h00000200, 32'h00000062);
    escribir(32'h00000201, 4'b0010, 32'h62626262);
    leer(32'h00000200, 32'h00006262);
    escribir(32'h00000202, 4'b0100, 32'h62626262);
    leer(32'h00000200, 32'h00626262);
    escribir(32'h00000203, 4'b1000, 32'h62626262);
    leer(32'h00000200, 32'h62626262);

    // 4. con WE = 0 no deberia escribir nada, aunque BE este en 1111
    @(negedge clk);
    Adr = 32'h00000100; BE = 4'b1111; WD = 32'hFFFFFFFF; WE = 0;
    @(negedge clk);
    leer(32'h00000100, 32'h11223344);

    // 5. dump de toda la memoria
    uut.dump("dump_memoria.txt");
    $display("Dump guardado en dump_memoria.txt");

    $display("Pruebas terminadas, errores: %0d", errores);
    $finish;
end

endmodule
