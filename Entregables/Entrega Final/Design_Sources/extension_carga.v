`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Engineer:
// Create Date: 11.11.2026
// Design Name: Microarquitectura RV32I
// Module Name: extension_carga
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
//
// Que hace:
// La memoria entrega 32 bits. Aqui se toma solo la parte que pide la carga.
// ReadData es el dato de memoria. Adr indica la posicion dentro de la palabra.
// funct3 elige el tipo: 010 LW, 000 LB, 100 LBU, 001 LH, 101 LHU.
// DataExt es el dato final de 32 bits y va al registro Data.
// LB y LH copian el bit de signo para conservar el valor con signo.
// LBU y LHU rellenan con ceros. LW pasa los 32 bits sin cambiarlos.
// El programa pide LW, pero se dejaron las otras cargas del bloque.
//
// Dependencies: ninguna
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

//Extensión de carga: sirve para leer la memoria
//La memoria siempre entrega la palabra completa pero si la instrucción pide solo 1 byte, lo saca y lo convierte en un número 
//de 32 bits para guardaarlo en el registro

module extension_carga(
    input [31:0] ReadData,//sale de memoria
    input [1:0] Adr,//para decidir cuál byte o mitad de palabra se toma
    input [2:0] funct3,//qué tipo de carga es
    output reg [31:0] DataExt
    );

reg [7:0] byte_sel;
reg [15:0] media_sel;

always @(*) begin
    // Adr indica cual de los 4 bytes queremos leer.
    case (Adr)
        2'b00: byte_sel = ReadData[7:0];
        2'b01: byte_sel = ReadData[15:8];
        2'b10: byte_sel = ReadData[23:16];
        default: byte_sel = ReadData[31:24];
    endcase

    // Adr[1] escoge la mitad de abajo o la de arriba.
    media_sel = Adr[1] ? ReadData[31:16] : ReadData[15:0];

    case (funct3)
        3'b010: DataExt = ReadData;   // LW: deja los 32 bits iguales.
        3'b000: DataExt = {{24{byte_sel[7]}}, byte_sel};  // LB: rellena con el bit de signo.
        3'b100: DataExt = {24'b0, byte_sel}; // LBU: rellena con ceros.
        3'b001: DataExt = {{16{media_sel[15]}}, media_sel}; // LH: rellena con el bit de signo.
        3'b101: DataExt = {16'b0, media_sel};  // LHU: rellena con ceros.
        default: DataExt = ReadData;
    endcase
end

endmodule
