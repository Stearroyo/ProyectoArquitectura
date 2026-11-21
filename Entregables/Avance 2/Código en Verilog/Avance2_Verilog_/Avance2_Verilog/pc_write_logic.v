`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Module Name: pc_write_logic
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
// Description:
//   Se decide si se habilita la escritura del PC.
//   Entradas: PCUpdate, Branch, funct3, Z, N, V, C.
//   Salida: PCWrite (habilitacion del registro PC).
//////////////////////////////////////////////////////////////////////////////////

module pc_write_logic(
    input PCUpdate, Branch,
    input [2:0] funct3,
    input Z, N, V, C,
    output reg PCWrite
);
reg Cond;

always @(*) begin
    // Se evalua la condicion del salto segun funct3.
    case (funct3)
        3'b000: Cond = Z;          // beq
        3'b001: Cond = ~Z;         // bne
        3'b100: Cond = N ^ V;      // blt
        3'b101: Cond = ~(N ^ V);   // bge
        3'b110: Cond = ~C;         // bltu
        3'b111: Cond = C;          // bgeu
        default: Cond = 1'b0;
    endcase
    // PCUpdate se usa en Fetch, JAL y el salto de JALR.
    PCWrite = PCUpdate | (Branch & Cond);
end
endmodule
