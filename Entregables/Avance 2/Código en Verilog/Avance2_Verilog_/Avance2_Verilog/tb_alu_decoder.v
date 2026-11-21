`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_alu_decoder
// Project Name: Proyecto Arquitectura MT-7003
// Description:
//   Objetivo: comprobar que ALUControl seleccione la operacion correcta.
//   Estimulos: se cambian ALUOp, funct3 y funct7b5 cada 10 ns.
//   Se prueban suma, resta, addi, andi, slli y selecciones no usadas.
//   Se comprueba que funct7b5 no cambie la seleccion de addi o andi.
//   Resultados esperados: suma=0000, resta=0001, AND=0010, SLL=0011.
//   Se esperan 11 pruebas OK y 0 errores.
// Dependencies: alu_decoder.v
//////////////////////////////////////////////////////////////////////////////////

module tb_alu_decoder;
reg [1:0] ALUOp;
reg [2:0] funct3;
reg funct7b5;
wire [3:0] ALUControl;
integer errores = 0;

alu_decoder uut (
    .ALUOp(ALUOp), .funct3(funct3), .funct7b5(funct7b5),
    .ALUControl(ALUControl)
);

task revisar;
    input [1:0] operacion;
    input [2:0] f3;
    input f7;
    input [3:0] esperado;
    begin
        ALUOp = operacion;
        funct3 = f3;
        funct7b5 = f7;
        #10;
        if (ALUControl === esperado)
            $display("OK    ALUOp=%b funct3=%b funct7b5=%b ALUControl=%b esperado=%b", ALUOp, funct3, funct7b5, ALUControl, esperado);
        else begin
            $display("ERROR ALUOp=%b funct3=%b funct7b5=%b ALUControl=%b esperado=%b", ALUOp, funct3, funct7b5, ALUControl, esperado);
            errores = errores + 1;
        end
    end
endtask

initial begin
    $display("---- Prueba alu_decoder ----");
    revisar(2'b00, 3'b000, 1'b0, 4'b0000); // suma
    revisar(2'b00, 3'b111, 1'b1, 4'b0000); // suma sin depender de funct3
    revisar(2'b01, 3'b001, 1'b0, 4'b0001); // bne
    revisar(2'b01, 3'b101, 1'b1, 4'b0001); // bge
    revisar(2'b10, 3'b000, 1'b0, 4'b0000); // addi
    revisar(2'b10, 3'b111, 1'b0, 4'b0010); // andi
    revisar(2'b10, 3'b001, 1'b0, 4'b0011); // slli
    revisar(2'b10, 3'b010, 1'b0, 4'b0000); // funct3 no usado
    revisar(2'b11, 3'b111, 1'b0, 4'b0000); // ALUOp no usado
    revisar(2'b10, 3'b000, 1'b1, 4'b0000); // addi con bit 30 en 1
    revisar(2'b10, 3'b111, 1'b1, 4'b0010); // andi con bit 30 en 1
    $display("Pruebas terminadas, errores: %0d", errores);
    $finish;
end
endmodule
