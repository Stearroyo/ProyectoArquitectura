`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_instr_decoder
// Project Name: Proyecto Arquitectura MT-7003
//
// Que se prueba:
// Objetivo: revisar que ImmSrc indique el formato correcto.
// Pruebas: se prueban los 7 opcodes del proyecto y uno no usado, 10 ns cada uno.
// Esperado: I=000, S=001, B=010, J=011, U=100 y otro=000.
// Son 8 pruebas; al final se esperan 0 errores.
//
// Dependencies: instr_decoder.v
//////////////////////////////////////////////////////////////////////////////////

module tb_instr_decoder;
reg [6:0] op;
wire [2:0] ImmSrc;
integer errores = 0;

instr_decoder uut (.op(op), .ImmSrc(ImmSrc));

// Pone los datos de una prueba, espera 10 ns y revisa la salida.
task revisar;
    input [6:0] codigo;
    input [2:0] esperado;
    begin
        op = codigo;
        #10;
        if (ImmSrc === esperado)
            $display("OK    op=%b ImmSrc=%b esperado=%b", op, ImmSrc, esperado);
        else begin
            $display("ERROR op=%b ImmSrc=%b esperado=%b", op, ImmSrc, esperado);
            errores = errores + 1;
        end
    end
endtask

initial begin
    $display("---- Prueba instr_decoder ----");
    revisar(7'b0010011, 3'b000); // addi, andi, slli
    revisar(7'b0000011, 3'b000); // lw
    revisar(7'b1100111, 3'b000); // jalr
    revisar(7'b0100011, 3'b001); // sw, sb
    revisar(7'b1100011, 3'b010); // bge, bne
    revisar(7'b1101111, 3'b011); // jal
    revisar(7'b0110111, 3'b100); // lui
    revisar(7'b0110011, 3'b000); // opcode no usado
    $display("Pruebas terminadas, errores: %0d", errores);
    $finish;
end
endmodule
