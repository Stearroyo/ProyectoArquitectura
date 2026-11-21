`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Module Name: top
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
// Description:
//   Se conecta la ruta de datos con la unidad de control del procesador.
//   Entradas: clk (reloj) y reset (reinicio sincrono activo en 1).
//   Salidas: ninguna externa; se revisan los registros y la memoria en simulacion.
//   Se usa programa.mem para cargar las instrucciones en la memoria compartida.
//   Las conexiones siguen la especificacion 14_top.md.
//////////////////////////////////////////////////////////////////////////////////
module top(
    input clk,
    input reset
);

// Datos y registros de 32 bits.
wire [31:0] PC, PCNext, OldPC, Instr, ReadData, DataExt, Data;
wire [31:0] A, WriteData, RD1, RD2, ImmExt, SrcA, SrcB;
wire [31:0] ALUResult, ALUOut, Result, Adr, WD;
wire [3:0] BE;

// Senales de control y condiciones de la ALU.
wire PCUpdate, Branch, IRWrite, RegWrite, MemWrite, AdrSrc, PCWrite;
wire [1:0] ResultSrc, ALUSrcA, ALUSrcB;
wire [3:0] ALUControl;
wire [2:0] ImmSrc;
wire Z, N, V, C;

// Se identifica la instruccion y se controla cada ciclo.
unidad_control uc (
    .clk(clk), .reset(reset),
    .op(Instr[6:0]), .funct3(Instr[14:12]), .funct7b5(Instr[30]),
    .PCUpdate(PCUpdate), .Branch(Branch), .IRWrite(IRWrite),
    .RegWrite(RegWrite), .MemWrite(MemWrite), .AdrSrc(AdrSrc),
    .ResultSrc(ResultSrc), .ALUSrcA(ALUSrcA), .ALUSrcB(ALUSrcB),
    .ALUControl(ALUControl), .ImmSrc(ImmSrc)
);

// Se decide si se actualiza el PC y se coloca el bit inferior en cero.
pc_write_logic pc_logic (
    .PCUpdate(PCUpdate), .Branch(Branch), .funct3(Instr[14:12]),
    .Z(Z), .N(N), .V(V), .C(C), .PCWrite(PCWrite)
);
assign PCNext = {Result[31:1], 1'b0};

registro reg_pc (
    .clk(clk), .reset(reset), .en(PCWrite), .d(PCNext), .q(PC)
);
// OldPC e Instr se guardan durante Fetch con la misma habilitacion.
registro reg_oldpc (
    .clk(clk), .reset(reset), .en(IRWrite), .d(PC), .q(OldPC)
);
registro reg_instr (
    .clk(clk), .reset(reset), .en(IRWrite), .d(ReadData), .q(Instr)
);

// Se comparte la memoria entre instrucciones y datos.
mux2 mux_adr (
    .d0(PC), .d1(Result), .s(AdrSrc), .y(Adr)
);
logica_bytes bytes_inst (
    .funct3(Instr[14:12]), .Adr(Adr[1:0]), .WriteData(WriteData),
    .BE(BE), .WD(WD)
);
memoria #(.MEMFILE("programa.mem")) mem (
    .clk(clk), .WE(MemWrite), .BE(BE), .Adr(Adr), .WD(WD),
    .ReadData(ReadData)
);
extension_carga carga (
    .ReadData(ReadData), .Adr(Adr[1:0]), .funct3(Instr[14:12]),
    .DataExt(DataExt)
);
registro reg_data (
    .clk(clk), .reset(reset), .en(1'b1), .d(DataExt), .q(Data)
);

// Se leen los registros fuente y se escribe el registro destino.
banco_registros banco (
    .clk(clk), .reset(reset), .A1(Instr[19:15]), .A2(Instr[24:20]),
    .A3(Instr[11:7]), .WD3(Result), .WE3(RegWrite), .RD1(RD1), .RD2(RD2)
);
registro reg_a (
    .clk(clk), .reset(reset), .en(1'b1), .d(RD1), .q(A)
);
registro reg_writedata (
    .clk(clk), .reset(reset), .en(1'b1), .d(RD2), .q(WriteData)
);

// Se forma el inmediato y se seleccionan los operandos de la ALU.
unidadsigno extend (
    .instr(Instr[31:7]), .ImmSrc(ImmSrc), .ImmExt(ImmExt)
);
mux4 mux_srca (
    .d0(PC), .d1(OldPC), .d2(A), .d3(32'b0), .s(ALUSrcA), .y(SrcA)
);
mux3 mux_srcb (
    .d0(WriteData), .d1(ImmExt), .d2(32'd4), .s(ALUSrcB), .y(SrcB)
);
alu alu_inst (
    .SrcA(SrcA), .SrcB(SrcB), .ALUControl(ALUControl),
    .ALUResult(ALUResult), .Z(Z), .N(N), .V(V), .C(C)
);
registro reg_aluout (
    .clk(clk), .reset(reset), .en(1'b1), .d(ALUResult), .q(ALUOut)
);

// Se selecciona el resultado para escribir en rd, acceder a memoria o cambiar PC.
mux3 mux_result (
    .d0(ALUOut), .d1(Data), .d2(ALUResult), .s(ResultSrc), .y(Result)
);
endmodule
