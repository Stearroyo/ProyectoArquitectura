`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Module Name: instr_decoder
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
//
// Que hace:
// Revisa op (los 7 bits inferiores de la instruccion) para saber su formato.
// ImmSrc le indica a la unidad de signo como armar el inmediato.
// 000=I, 001=S, 010=B, 011=J, 100=U. Si no se reconoce, sale 000.
// No ejecuta la instruccion ni necesita reloj.
//////////////////////////////////////////////////////////////////////////////////

// Aca se crea el instr decoder: con el opcode dice el formato del inmediato (ImmSrc)
module instr_decoder(
    input [6:0] op,
    output reg [2:0] ImmSrc //su salida le dice a la unidad de signo en qué formato viene el inmediato
);

always @(*) begin
    case (op)//segun el opcode, se sabe el tipo
        7'b0010011: ImmSrc = 3'b000; // Tipo I: addi, andi, slli
        7'b0000011: ImmSrc = 3'b000; // Tipo I: lw
        7'b1100111: ImmSrc = 3'b000; // Tipo I: jalr
        7'b0100011: ImmSrc = 3'b001; // Tipo S: sw, sb
        7'b1100011: ImmSrc = 3'b010; // Tipo B: bge, bne
        7'b1101111: ImmSrc = 3'b011; // Tipo J: jal
        7'b0110111: ImmSrc = 3'b100; // Tipo U: lui
        default:    ImmSrc = 3'b000;
    endcase
end

endmodule
