`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Module Name: instr_decoder
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
// Description:
//   Se identifica el formato del inmediato mediante el opcode.
//   Entrada: op (7 bits, Instr[6:0]).
//   Salida: ImmSrc (3 bits, seleccion de la unidad de signo).
//////////////////////////////////////////////////////////////////////////////////

module instr_decoder(
    input [6:0] op,
    output reg [2:0] ImmSrc
);

always @(*) begin
    case (op)
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
