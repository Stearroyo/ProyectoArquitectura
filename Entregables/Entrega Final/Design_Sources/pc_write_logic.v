`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Module Name: pc_write_logic
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
//
// Que hace:
// Decide si el PC puede cambiar de valor.
// PCUpdate pide cambiarlo directamente. Branch indica un salto condicional.
// funct3 dice que comparacion hacer; Z, N, V y C vienen de la ALU.
// PCWrite vale 1 si hay permiso de cambiar el PC; si vale 0 se queda igual.
// No necesita reloj, solo revisa las entradas.
//////////////////////////////////////////////////////////////////////////////////

module pc_write_logic(
    input PCUpdate, Branch,
    input [2:0] funct3,
    input Z, N, V, C,
    output reg PCWrite
);
reg Cond;

always @(*) begin
    // Segun funct3, revisamos si se cumple la condicion del salto.
    case (funct3)
        3'b000: Cond = Z;          // BEQ: iguales.
        3'b001: Cond = ~Z;         // BNE: diferentes.
        3'b100: Cond = N ^ V;      // BLT: menor con signo.
        3'b101: Cond = ~(N ^ V);   // BGE: mayor o igual con signo.
        3'b110: Cond = ~C;         // BLTU: menor sin signo.
        3'b111: Cond = C;          // BGEU: mayor o igual sin signo.
        default: Cond = 1'b0;
    endcase
    // Permiso directo o salto condicional que si se cumple.
    PCWrite = PCUpdate | (Branch & Cond);
end
endmodule
