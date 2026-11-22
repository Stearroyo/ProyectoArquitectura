`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Engineer: Dilana Jimenez
// Create Date: 11.10.2026 11:10:00
// Design Name: Microarquitectura RV32I
// Module Name: unidadsigno
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2026.1
//
// Que hace:
// Saca de la instruccion el numero inmediato y lo deja de 32 bits.
// Entradas: instr[31:7] trae los bits necesarios; ImmSrc elige el formato.
// Salida: ImmExt, que va a la entrada 01 del mux ALUSrcB.
// 000 I: el numero viene junto. 001 S: hay que juntar dos partes.
// 010 B y 011 J: hay que ordenar los bits y poner el ultimo en cero.
// 100 U: los 20 bits de la instruccion van arriba y los 12 de abajo son cero.
// En I, S, B y J se copia el bit 31 para mantener el signo del numero.
// ImmSrc tiene 3 bits porque necesitamos 5 formatos y con 2 solo caben 4.
//
// Dependencies: ninguna
// Revision 0.01 - File Created (formatos I y S, Avance 1)
// Revision 0.02 - Avance 2: ImmSrc pasa a 3 bits y se agregan B, J y U
//////////////////////////////////////////////////////////////////////////////////


module unidadsigno(
    input  [31:7] instr,
    input  [2:0]  ImmSrc,
    output reg [31:0] ImmExt
    );

always @(*) begin
    case (ImmSrc)
        // I: tomar los 12 bits del inmediato y copiar el signo.
        3'b000: ImmExt = {{20{instr[31]}}, instr[31:20]};
        // S: unir 7 bits de arriba con 5 de abajo y copiar el signo.
        3'b001: ImmExt = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        // B: ordenar las partes del salto, copiar el signo y agregar un cero al final.
        3'b010: ImmExt = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
        // J: ordenar las partes del salto largo, copiar el signo y poner el ultimo bit en 0.
        3'b011: ImmExt = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
        // U: dejar los 20 bits arriba y llenar los 12 de abajo con ceros.
        3'b100: ImmExt = {instr[31:12], 12'b0};
        // Si no se reconoce ImmSrc, devolver cero.
        default: ImmExt = 32'b0;
    endcase
end

endmodule
