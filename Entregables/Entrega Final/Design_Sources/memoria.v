`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Engineer:
// Create Date: 25.10.2026
// Design Name: Microarquitectura RV32I
// Module Name: memoria
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
//
// Que hace:
// Aqui se guardan las instrucciones y los datos. Se usa la misma memoria
// porque Fetch y el acceso a datos pasan en ciclos diferentes.
// Hay 1024 palabras de 32 bits (4 KB). Adr[11:2] elige una palabra;
// los otros bits no se usan para elegirla.
// clk es el reloj; WE da permiso de escribir y BE elige los bytes a cambiar.
// WD es el dato a guardar; ReadData es la palabra que se esta leyendo.
// Leer no necesita reloj; escribir ocurre cuando clk pasa de 0 a 1.
// MEMFILE indica el archivo hexadecimal que se carga al empezar.
// La tarea dump guarda la memoria en un txt para revisar los resultados.
//
// Dependencies: ninguna
// Revision 0.01 - File Created (Avance 2)
// Revision 0.02 - Nombres de puertos iguales a los del diagrama
//////////////////////////////////////////////////////////////////////////////////


module memoria #(
    parameter MEMFILE = ""   // Archivo del programa en hexadecimal. Vacio = no carga archivo.
    )(
    input         clk,
    input         WE,
    input  [3:0]  BE,
    input  [31:0] Adr,
    input  [31:0] WD,
    output [31:0] ReadData
    );

reg [31:0] RAM [0:1023];
integer i;

// Al empezar, llena de ceros y despues carga el archivo si se dio uno.
initial begin
    for (i = 0; i < 1024; i = i + 1)
        RAM[i] = 32'b0;
    if (MEMFILE != "")
        $readmemh(MEMFILE, RAM);
end

// Adr[11:2] indica cual palabra se lee. El dato sale sin esperar al reloj.
assign ReadData = RAM[Adr[11:2]];

// Si WE=1, se escriben solo los bytes que tengan un 1 en BE.
always @(posedge clk) begin
    if (WE) begin
        if (BE[0]) RAM[Adr[11:2]][7:0]   <= WD[7:0];
        if (BE[1]) RAM[Adr[11:2]][15:8]  <= WD[15:8];
        if (BE[2]) RAM[Adr[11:2]][23:16] <= WD[23:16];
        if (BE[3]) RAM[Adr[11:2]][31:24] <= WD[31:24];
    end
end

// dump guarda todas las direcciones y sus datos en un txt.
// Las dos lineas synthesis le dicen a Vivado que esto es solo para simular.
// synthesis translate_off
task dump(input [8*64-1:0] archivo);
    integer f, k;
begin
    f = $fopen(archivo, "w");
    $fdisplay(f, "Direccion de memoria    Valor en hexadecimal");
    for (k = 0; k < 1024; k = k + 1)
        $fdisplay(f, "0x%h              0x%h", k*4, RAM[k]);
    $fclose(f);
end
endtask
// synthesis translate_on

endmodule
