`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Engineer:
//
// Create Date: 11.11.2026
// Design Name: Microarquitectura RV32I
// Module Name: extension_carga
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
// Description:
//   Bloque de extension de carga del diagrama (va entre la memoria y el
//   registro Data). La memoria da la palabra completa, entonces aqui se saca
//   solo lo que pide el load y se pasa a 32 bits.
//   Entradas:
//     ReadData - palabra que sale de la memoria
//     Adr      - los 2 bits bajos de la direccion (en que byte esta el dato)
//     funct3   - Instr[14:12], tipo de load: 010 lw, 000 lb, 100 lbu,
//                001 lh, 101 lhu
//   Salida:
//     DataExt  - el dato extendido, entra al registro Data
//
// Dependencies: ninguna
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   El programa solo usa lw pero se hicieron los demas loads porque el bloque
//   esta en el diagrama (igual que con sh en logica_bytes).
//////////////////////////////////////////////////////////////////////////////////


module extension_carga(
    input [31:0] ReadData,
    input [1:0] Adr,
    input [2:0] funct3,
    output reg [31:0] DataExt
    );

reg [7:0] byte_sel;
reg [15:0] media_sel;

always @(*) begin
    // se escoge el byte segun Adr
    case (Adr)
        2'b00: byte_sel = ReadData[7:0];
        2'b01: byte_sel = ReadData[15:8];
        2'b10: byte_sel = ReadData[23:16];
        default: byte_sel = ReadData[31:24];
    endcase

    // para media palabra basta con Adr[1]
    media_sel = Adr[1] ? ReadData[31:16] : ReadData[15:0];

    case (funct3)
        3'b010: DataExt = ReadData;   // lw
        3'b000: DataExt = {{24{byte_sel[7]}}, byte_sel};  // lb, se copia el signo
        3'b100: DataExt = {24'b0, byte_sel}; // lbu
        3'b001: DataExt = {{16{media_sel[15]}}, media_sel}; // lh
        3'b101: DataExt = {16'b0, media_sel};  // lhu
        default: DataExt = ReadData;
    endcase
end

endmodule
