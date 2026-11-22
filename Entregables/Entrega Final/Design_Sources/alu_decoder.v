`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Module Name: alu_decoder
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
//
// Que hace:
// Le dice a la ALU que operacion debe hacer.
// ALUOp viene de la FSM: 00 pide suma, 01 resta y 10 usa funct3.
// funct3 distingue ADDI, ANDI y SLLI. Los codigos salen en ALUControl.
// funct7b5 es el bit 30 de la instruccion. Esta en el diagrama, pero aqui
// no hace falta usarlo. No necesita reloj.
//////////////////////////////////////////////////////////////////////////////////

module alu_decoder(
    input [1:0] ALUOp,
    input [2:0] funct3,
    input funct7b5,
    output reg [3:0] ALUControl
);

always @(*) begin
    case (ALUOp)
        2'b00: ALUControl = 4'b0000; // Suma
        2'b01: ALUControl = 4'b0001; // Resta
        2'b10: begin // Aqui funct3 indica cual operacion tipo I hacer.
            case (funct3)
                3'b000: ALUControl = 4'b0000; // addi
                3'b111: ALUControl = 4'b0010; // andi
                3'b001: ALUControl = 4'b0011; // slli
                default: ALUControl = 4'b0000;
            endcase
        end
        default: ALUControl = 4'b0000;
    endcase
end

endmodule
