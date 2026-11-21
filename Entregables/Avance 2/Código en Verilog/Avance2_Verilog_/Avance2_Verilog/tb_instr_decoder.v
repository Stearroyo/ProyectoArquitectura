`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_instr_decoder
// Project Name: Proyecto Arquitectura MT-7003
// Description:
//   Objetivo: comprobar la seleccion del formato del inmediato.
//   Estimulos: se prueban los 7 opcodes de la especificacion y uno no usado.
//   Cada prueba dura 10 ns.
//   Resultados esperados: I=000, S=001, B=010, J=011, U=100, otro=000.
//   Se esperan 8 pruebas OK y 0 errores.
// Dependencies: instr_decoder.v
//////////////////////////////////////////////////////////////////////////////////

module tb_instr_decoder;
reg [6:0] op;
wire [2:0] ImmSrc;
integer errores = 0;

instr_decoder uut (.op(op), .ImmSrc(ImmSrc));

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
