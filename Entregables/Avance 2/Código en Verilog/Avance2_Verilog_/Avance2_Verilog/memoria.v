`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Engineer:
//
// Create Date: 25.10.2026
// Design Name: Microarquitectura RV32I
// Module Name: memoria
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
// Description:
//   Es la memoria del procesador. Como es multiciclo, se usa una sola para
//   instrucciones y datos: en Fetch se lee la instruccion y en otro ciclo
//   se lee o escribe el dato. Se le ponen 1024 palabras de 32 bits (4 KB),
//   que alcanza de sobra para el programa y la pila.
//   Entradas:
//     clk       : reloj
//     WE        : MemWrite (lo manda la UC)
//     BE[3:0]   : cuales bytes de la palabra se escriben (sale de la logica
//                 de escritura por bytes)
//     Adr[31:0] : direccion en bytes. Solo se usan los bits 11:2, porque
//                 cada posicion de la memoria es una palabra de 4 bytes
//     WD[31:0]  : el dato a escribir, ya alineado por la logica de bytes
//   Salidas:
//     ReadData[31:0]: palabra leida
//   Por que existe:
//     Aqui se guardan el programa y las variables. Se hace con escritura
//     por bytes porque el codigo C usa sb para char a, y sb tiene que cambiar
//     un solo byte sin borrar los otros tres de la palabra.
//     Tambien se le agrega una tarea dump que guarda todo en un .txt, que es
//     lo que pide el enunciado para revisar la memoria.
//     Si se le pasa un archivo en MEMFILE (el programa compilado, cuando
//     se integre el procesador) lo carga al inicio; si no, arranca toda en 0.
//
// Dependencies: ninguna
//
// Revision:
// Revision 0.01 - File Created (Avance 2)
// Revision 0.02 - Nombres de puertos iguales a los del diagrama
// Additional Comments:
//   Ojo: leer es combinacional (el dato sale apenas cambia la direccion),
//   pero escribir solo pasa en el flanco de subida.
//////////////////////////////////////////////////////////////////////////////////


module memoria #(
    parameter MEMFILE = ""   // programa en hex; si queda vacio no carga nada
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

// primero se pone todo en 0 y despues, si hay archivo, se carga el programa
initial begin
    for (i = 0; i < 1024; i = i + 1)
        RAM[i] = 32'b0;
    if (MEMFILE != "")
        $readmemh(MEMFILE, RAM);
end

// lectura: con Adr[11:2] se pasa de direccion en bytes a numero de palabra
assign ReadData = RAM[Adr[11:2]];

// escritura: cada bit de BE habilita un byte, asi sb toca solo el suyo
always @(posedge clk) begin
    if (WE) begin
        if (BE[0]) RAM[Adr[11:2]][7:0]   <= WD[7:0];
        if (BE[1]) RAM[Adr[11:2]][15:8]  <= WD[15:8];
        if (BE[2]) RAM[Adr[11:2]][23:16] <= WD[23:16];
        if (BE[3]) RAM[Adr[11:2]][31:24] <= WD[31:24];
    end
end

// dump: pasa toda la memoria a un archivo de texto con el formato del
// enunciado. Escribir archivos solo sirve en simulacion, entonces se
// pone entre translate_off/on para que Vivado lo ignore si se sintetiza.
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
