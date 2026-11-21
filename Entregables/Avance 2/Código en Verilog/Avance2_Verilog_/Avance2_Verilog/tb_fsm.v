`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Module Name: tb_fsm
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
// Description:
//   Objetivo: verificar los 12 estados y todas las senales de control.
//   Estimulos: reloj de 10 ns, reset sincrono y los siete opcodes del proyecto.
//   Se prueba un opcode no usado y reset durante la ejecucion.
//   Se esperan 34 comprobaciones correctas y 0 errores.
//   Dependencias: fsm.v.
//////////////////////////////////////////////////////////////////////////////////

module tb_fsm;
reg clk, reset;
reg [6:0] op;
wire PCUpdate, Branch, IRWrite, RegWrite, MemWrite, AdrSrc;
wire [1:0] ResultSrc, ALUSrcA, ALUSrcB;
wire [1:0] ALUOp;
integer errores = 0;

fsm uut (
    .clk(clk), .reset(reset), .op(op),
    .PCUpdate(PCUpdate), .Branch(Branch), .IRWrite(IRWrite),
    .RegWrite(RegWrite), .MemWrite(MemWrite), .AdrSrc(AdrSrc),
    .ResultSrc(ResultSrc), .ALUSrcA(ALUSrcA), .ALUSrcB(ALUSrcB),
    .ALUOp(ALUOp)
);

initial clk = 0;
always #5 clk = ~clk;

// Se comprueban el estado y las diez salidas de control.
// Orden: PCUpdate, Branch, IRWrite, RegWrite, MemWrite, AdrSrc,
// ResultSrc, ALUSrcA, ALUSrcB, ALUOp.
task revisar;
    input [3:0] esperado_estado;
    input [13:0] esperado;
    reg [13:0] obtenido;
    begin
        obtenido = {PCUpdate, Branch, IRWrite, RegWrite, MemWrite,
                    AdrSrc, ResultSrc, ALUSrcA, ALUSrcB, ALUOp};
        if ((uut.estado === esperado_estado) && (obtenido === esperado))
            $display("OK estado=%0d esperado=%0d control=%b esperado=%b", uut.estado, esperado_estado, obtenido, esperado);
        else begin
            $display("ERROR estado=%0d esperado=%0d control=%b esperado=%b", uut.estado, esperado_estado, obtenido, esperado);
            errores = errores + 1;
        end
    end
endtask

task paso;
    input [3:0] esperado_estado;
    input [13:0] esperado;
    begin
        @(posedge clk); #1;
        revisar(esperado_estado, esperado);
    end
endtask

initial begin
    reset = 1'b1;
    op = 7'b0000000;
    $display("---- Prueba FSM ----");
    paso(4'd0, 14'b10100010001000);

    $display("-- lw --");
    @(negedge clk); reset = 0; op = 7'b0000011;
    paso(4'd1, 14'b00000000010100);
    paso(4'd2, 14'b00000000100100);
    paso(4'd3, 14'b00000100000000);
    paso(4'd4, 14'b00010001000000);
    paso(4'd0, 14'b10100010001000);

    $display("-- sw --");
    @(negedge clk); reset = 0; op = 7'b0100011;
    paso(4'd1, 14'b00000000010100);
    paso(4'd2, 14'b00000000100100);
    paso(4'd5, 14'b00001100000000);
    paso(4'd0, 14'b10100010001000);

    $display("-- addi --");
    @(negedge clk); reset = 0; op = 7'b0010011;
    paso(4'd1, 14'b00000000010100);
    paso(4'd6, 14'b00000000100110);
    paso(4'd7, 14'b00010000000000);
    paso(4'd0, 14'b10100010001000);

    $display("-- bne --");
    @(negedge clk); reset = 0; op = 7'b1100011;
    paso(4'd1, 14'b00000000010100);
    paso(4'd9, 14'b01000000100001);
    paso(4'd0, 14'b10100010001000);

    $display("-- jal --");
    @(negedge clk); reset = 0; op = 7'b1101111;
    paso(4'd1, 14'b00000000010100);
    paso(4'd8, 14'b10000000011000);
    paso(4'd7, 14'b00010000000000);
    paso(4'd0, 14'b10100010001000);

    $display("-- jalr --");
    @(negedge clk); reset = 0; op = 7'b1100111;
    paso(4'd1, 14'b00000000010100);
    paso(4'd11, 14'b00000000100100);
    paso(4'd8, 14'b10000000011000);
    paso(4'd7, 14'b00010000000000);
    paso(4'd0, 14'b10100010001000);

    $display("-- lui --");
    @(negedge clk); reset = 0; op = 7'b0110111;
    paso(4'd1, 14'b00000000010100);
    paso(4'd10, 14'b00000000110100);
    paso(4'd7, 14'b00010000000000);
    paso(4'd0, 14'b10100010001000);

    $display("-- opcode no usado --");
    @(negedge clk); reset = 0; op = 7'b0000000;
    paso(4'd1, 14'b00000000010100);
    paso(4'd0, 14'b10100010001000);

    // Se comprueba que reset regrese a Fetch desde Decode.
    @(negedge clk); op = 7'b0000011;
    paso(4'd1, 14'b00000000010100);
    @(negedge clk); reset = 1;
    paso(4'd0, 14'b10100010001000);
    $display("Pruebas terminadas, errores: %0d", errores);
    $finish;
end
endmodule
