`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Engineer:
// Create Date: 11.11.2026
// Design Name: Microarquitectura RV32I
// Module Name: alu
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
//
// Que hace:
// La ALU hace cuentas y operaciones con bits. Tambien ayuda a decidir los saltos.
// Entradas: SrcA y SrcB son los dos datos; ALUControl elige la operacion.
// 0000 suma, 0001 resta, 0010 AND, 0011 desplazamiento a la izquierda.
// Salida: ALUResult es el resultado, que va a ALUOut y al mux ResultSrc.
// Z vale 1 si el resultado es cero; N es el bit de signo (bit 31).
// V vale 1 si el resultado con signo no cabe en 32 bits.
// C es el bit extra de la cuenta. Al restar, C=1 indica A >= B sin signo.
// BNE usa Z=0; BGE usa N=V. Los codigos deben coincidir con alu_decoder.
//
// Dependencies: ninguna
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

//Es la calculadora del procesador
module alu(
    input [31:0] SrcA,
    input [31:0] SrcB,
    input [3:0] ALUControl,//viene de la unidad de control
    output reg [31:0] ALUResult,
    output Z,//0
    output N,//negativo
    output reg V,//desbordamiento
    output reg C//acarreo
    );

always @(*) begin
    case (ALUControl)//¿qué operación debe realizar la alu?
        4'b0000: begin  // Suma: C guarda el bit que sobra.
            {C, ALUResult} = {1'b0, SrcA} + {1'b0, SrcB};
            // Si sumamos dos del mismo signo y sale otro signo, no cabe.
            V = (SrcA[31] == SrcB[31]) && (ALUResult[31] != SrcA[31]);
        end
        4'b0001: begin  // Resta: A + el inverso de B + 1.
            {C, ALUResult} = {1'b0, SrcA} + {1'b0, ~SrcB} + 33'd1;
            V = (SrcA[31] != SrcB[31]) && (ALUResult[31] != SrcA[31]);
        end
        4'b0010: begin   // AND: un bit sale en 1 solo si ambos son 1.
            ALUResult = SrcA & SrcB;
            C = 1'b0;
            V = 1'b0;
        end
        4'b0011: begin   // SLLI: mueve bits a la izquierda (de 0 a 31 lugares).
            ALUResult = SrcA << SrcB[4:0];
            C = 1'b0;
            V = 1'b0;
        end
        default: begin
            ALUResult = 32'b0;
            C = 1'b0;
            V = 1'b0;
        end
    endcase
end

// Dos indicadores que se obtienen mirando el resultado.
assign Z = (ALUResult == 32'b0);
assign N = ALUResult[31];

endmodule
