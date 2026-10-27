`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Engineer:
//
// Create Date: 25.10.2026
// Design Name: Microarquitectura RV32I
// Module Name: logica_bytes
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
// Description:
//   Logica de escritura por bytes (el bloque con ese nombre en los
//   diagramas). Con funct3 se sabe cuantos bytes se escriben y con los 2 bits
//   bajos de la direccion se sabe cuales. Sale BE (que bytes) y el dato ya
//   acomodado para la memoria (WD alineado).
//   Entradas:
//     funct3[2:0]    : Instr[14:12]; 010 es sw, 001 es sh y 000 es sb
//     Adr[1:0]       : 2 bits bajos de Adr, o sea en cual de los 4 bytes de
//                      la palabra cae el dato
//     WriteData[31:0]: el valor de rs2 (sale del registro WriteData)
//   Salidas:
//     BE[3:0] : byte enable, un bit por cada byte (1 = ese byte se escribe)
//     WD[31:0]: el dato que va para la memoria
//   Por que existe:
//     La memoria guarda palabras de 4 bytes. Con sw se escriben los 4, con
//     sh se escriben 2 y con sb (el que usa el codigo C para char a) solo 1.
//     Por ejemplo, si la direccion termina en 11, el byte de sb va en el 3.
//
// Dependencies: ninguna
//
// Revision:
// Revision 0.01 - File Created (Avance 2)
// Revision 0.02 - Nombres de modulo y puertos iguales a los del diagrama
// Revision 0.03 - Se agrega sh, que tambien aparece en el bloque del diagrama
// Additional Comments:
//   En sb se copia el byte en las 4 posiciones y en sh la media palabra en
//   las 2 mitades; BE decide que parte se escribe. Asi no hace falta mover
//   el dato segun Adr.
//   El programa del grupo no usa sh, pero se deja hecho para que el codigo
//   quede igual al diagrama.
//////////////////////////////////////////////////////////////////////////////////


module logica_bytes(
    input      [2:0]  funct3,
    input      [1:0]  Adr,
    input      [31:0] WriteData,
    output reg [3:0]  BE,
    output reg [31:0] WD
    );

always @(*) begin
    case (funct3)
        // sw: se escribe la palabra completa
        3'b010: begin
            BE = 4'b1111;
            WD = WriteData;
        end
        // sh: se escribe media palabra. Como sh siempre va en direccion par,
        // solo se mira Adr[1] para saber si va en la mitad baja o la alta
        3'b001: begin
            BE = Adr[1] ? 4'b1100 : 4'b0011;
            WD = {2{WriteData[15:0]}};
        end
        // sb: el 1 se corre segun Adr, entonces solo se habilita ese byte
        3'b000: begin
            BE = 4'b0001 << Adr;
            WD = {4{WriteData[7:0]}};
        end
        // si no es store, mejor no habilitar ningun byte
        default: begin
            BE = 4'b0000;
            WD = WriteData;
        end
    endcase
end

endmodule
