`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Module Name: tb_unidad_control
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
// Description:
//   Objetivo: verificar la conexion de FSM, ALU Decoder e Instr Decoder.
//   Estimulos: reloj de 10 ns; se cambia opcode, funct3 y funct7b5.
//   Se prueban instrucciones de los cinco formatos, con todas las salidas.
//   Se esperan 41 comprobaciones correctas y 0 errores.
//   Dependencias: unidad_control.v, fsm.v, alu_decoder.v, instr_decoder.v.
//////////////////////////////////////////////////////////////////////////////////

module tb_unidad_control;
reg clk, reset;
reg [6:0] op;
reg [2:0] funct3;
reg funct7b5;
wire PCUpdate, Branch, IRWrite, RegWrite, MemWrite, AdrSrc;
wire [1:0] ResultSrc, ALUSrcA, ALUSrcB;
wire [3:0] ALUControl;
wire [2:0] ImmSrc;
integer errores = 0;

unidad_control uut (
    .clk(clk), .reset(reset), .op(op),
    .PCUpdate(PCUpdate), .Branch(Branch), .IRWrite(IRWrite),
    .RegWrite(RegWrite), .MemWrite(MemWrite), .AdrSrc(AdrSrc),
    .ResultSrc(ResultSrc), .ALUSrcA(ALUSrcA), .ALUSrcB(ALUSrcB),
    .ALUControl(ALUControl), .ImmSrc(ImmSrc)
);

initial clk = 0;
always #5 clk = ~clk;

// Se verifican todas las salidas de la unidad de control.
// Orden: PCUpdate, Branch, IRWrite, RegWrite, MemWrite, AdrSrc,
// ResultSrc, ALUSrcA, ALUSrcB, ALUControl, ImmSrc.
task revisar;
    input [18:0] esperado;
    reg [18:0] obtenido;
    begin
        obtenido = {PCUpdate, Branch, IRWrite, RegWrite, MemWrite,
                    AdrSrc, ResultSrc, ALUSrcA, ALUSrcB, ALUControl, ImmSrc};
        if (obtenido === esperado)
            $display("OK opcode=%b funct3=%b control=%b esperado=%b", op, funct3, obtenido, esperado);
        else begin
            $display("ERROR opcode=%b funct3=%b control=%b esperado=%b", op, funct3, obtenido, esperado);
            errores = errores + 1;
        end
    end
endtask

task paso;
    input [18:0] esperado;
    begin
        @(posedge clk); #1;
        revisar(esperado);
    end
endtask

initial begin
    reset = 1'b1; op = 7'b0000000; funct3 = 3'b000; funct7b5 = 0;
    $display("---- Prueba Unidad de Control ----");
    paso(19'b1010001000100000000);

    $display("-- addi --");
    @(negedge clk); reset = 0; op = 7'b0010011; funct3 = 3'b000; funct7b5 = 1;
    paso(19'b0000000001010000000);
    paso(19'b0000000010010000000);
    paso(19'b0001000000000000000);
    paso(19'b1010001000100000000);

    $display("-- andi --");
    @(negedge clk); reset = 0; op = 7'b0010011; funct3 = 3'b111; funct7b5 = 1;
    paso(19'b0000000001010000000);
    paso(19'b0000000010010010000);
    paso(19'b0001000000000000000);
    paso(19'b1010001000100000000);

    $display("-- slli --");
    @(negedge clk); reset = 0; op = 7'b0010011; funct3 = 3'b001; funct7b5 = 0;
    paso(19'b0000000001010000000);
    paso(19'b0000000010010011000);
    paso(19'b0001000000000000000);
    paso(19'b1010001000100000000);

    $display("-- bne --");
    @(negedge clk); reset = 0; op = 7'b1100011; funct3 = 3'b001; funct7b5 = 0;
    paso(19'b0000000001010000010);
    paso(19'b0100000010000001010);
    paso(19'b1010001000100000010);

    $display("-- bge --");
    @(negedge clk); reset = 0; op = 7'b1100011; funct3 = 3'b101; funct7b5 = 0;
    paso(19'b0000000001010000010);
    paso(19'b0100000010000001010);
    paso(19'b1010001000100000010);

    $display("-- sw --");
    @(negedge clk); reset = 0; op = 7'b0100011; funct3 = 3'b010; funct7b5 = 0;
    paso(19'b0000000001010000001);
    paso(19'b0000000010010000001);
    paso(19'b0000110000000000001);
    paso(19'b1010001000100000001);

    $display("-- lw --");
    @(negedge clk); reset = 0; op = 7'b0000011; funct3 = 3'b010; funct7b5 = 0;
    paso(19'b0000000001010000000);
    paso(19'b0000000010010000000);
    paso(19'b0000010000000000000);
    paso(19'b0001000100000000000);
    paso(19'b1010001000100000000);

    $display("-- lui --");
    @(negedge clk); reset = 0; op = 7'b0110111; funct3 = 3'b000; funct7b5 = 0;
    paso(19'b0000000001010000100);
    paso(19'b0000000011010000100);
    paso(19'b0001000000000000100);
    paso(19'b1010001000100000100);

    $display("-- jal --");
    @(negedge clk); reset = 0; op = 7'b1101111; funct3 = 3'b000; funct7b5 = 0;
    paso(19'b0000000001010000011);
    paso(19'b1000000001100000011);
    paso(19'b0001000000000000011);
    paso(19'b1010001000100000011);

    $display("-- jalr --");
    @(negedge clk); reset = 0; op = 7'b1100111; funct3 = 3'b000; funct7b5 = 0;
    paso(19'b0000000001010000000);
    paso(19'b0000000010010000000);
    paso(19'b1000000001100000000);
    paso(19'b0001000000000000000);
    paso(19'b1010001000100000000);
    $display("Pruebas terminadas, errores: %0d", errores);
    $finish;
end
endmodule
