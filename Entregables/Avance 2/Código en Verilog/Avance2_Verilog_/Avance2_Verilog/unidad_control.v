`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Module Name: unidad_control
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
// Description:
//   Se conectan la FSM y los dos decodificadores.
//   Entradas: clk, reset, op, funct3 y funct7b5.
//   Salidas: PCUpdate, Branch, IRWrite, RegWrite, MemWrite, AdrSrc,
//   ResultSrc, ALUSrcA, ALUSrcB, ALUControl e ImmSrc.
//   Dependencias: fsm.v, alu_decoder.v, instr_decoder.v.
//////////////////////////////////////////////////////////////////////////////////

module unidad_control(
    input clk, reset,
    input [6:0] op,
    input [2:0] funct3,
    input funct7b5,
    output PCUpdate, Branch, IRWrite, RegWrite, MemWrite, AdrSrc,
    output [1:0] ResultSrc, ALUSrcA, ALUSrcB,
    output [3:0] ALUControl,
    output [2:0] ImmSrc
);
wire [1:0] ALUOp;

// Se generan las senales de control de cada etapa.
fsm fsm_inst (
    .clk(clk), .reset(reset), .op(op),
    .PCUpdate(PCUpdate), .Branch(Branch), .IRWrite(IRWrite),
    .RegWrite(RegWrite), .MemWrite(MemWrite), .AdrSrc(AdrSrc),
    .ResultSrc(ResultSrc), .ALUSrcA(ALUSrcA), .ALUSrcB(ALUSrcB),
    .ALUOp(ALUOp)
);

// Se selecciona la operacion concreta de la ALU.
alu_decoder alu_decoder_inst (
    .ALUOp(ALUOp), .funct3(funct3), .funct7b5(funct7b5),
    .ALUControl(ALUControl)
);

// Se selecciona el formato del inmediato.
instr_decoder instr_decoder_inst (
    .op(op), .ImmSrc(ImmSrc)
);
endmodule
