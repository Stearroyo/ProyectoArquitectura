`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Module Name: unidad_control
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
//
// Que hace:
// Junta la FSM con los dos decodificadores para controlar el procesador.
// Entradas: clk, reset y los campos op, funct3 y funct7b5 de la instruccion.
// La FSM genera PCUpdate, Branch, IRWrite, RegWrite, MemWrite y AdrSrc,
// ademas de los selectores ResultSrc, ALUSrcA y ALUSrcB.
// ALUOp es una conexion interna que ayuda a sacar ALUControl.
// ImmSrc indica el formato del inmediato. No se repite la logica de los modulos.
//
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

// La FSM dice que se hace en cada paso de la instruccion.
fsm fsm_inst (
    .clk(clk), .reset(reset), .op(op),
    .PCUpdate(PCUpdate), .Branch(Branch), .IRWrite(IRWrite),
    .RegWrite(RegWrite), .MemWrite(MemWrite), .AdrSrc(AdrSrc),
    .ResultSrc(ResultSrc), .ALUSrcA(ALUSrcA), .ALUSrcB(ALUSrcB),
    .ALUOp(ALUOp)
);

// Con ALUOp y funct3 se elige la cuenta que hace la ALU.
alu_decoder alu_decoder_inst (
    .ALUOp(ALUOp), .funct3(funct3), .funct7b5(funct7b5),
    .ALUControl(ALUControl)
);

// El opcode dice como se debe armar el inmediato.
instr_decoder instr_decoder_inst (
    .op(op), .ImmSrc(ImmSrc)
);
endmodule
