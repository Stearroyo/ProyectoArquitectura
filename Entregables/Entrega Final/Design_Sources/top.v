`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Module Name: top
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
//
// Que hace:
// Aqui se conectan todos los modulos del procesador, como en el diagrama.
// Las unicas entradas son clk (reloj) y reset (reinicio).
// No hay salidas externas: en la simulacion se revisan la memoria y registros.
// La memoria carga programa.mem al empezar.
// Se siguen las conexiones de 14_top.md, sin agregar operaciones nuevas.
//////////////////////////////////////////////////////////////////////////////////
module top #(
    parameter MEMFILE = "programa.mem"   // programa que se carga en la memoria
)(
    input clk,
    input reset
);

// Cables por donde pasan los datos de 32 bits.
wire [31:0] PC, PCNext, OldPC, Instr, ReadData, DataExt, Data;
wire [31:0] A, WriteData, RD1, RD2, ImmExt, SrcA, SrcB;
wire [31:0] ALUResult, ALUOut, Result, Adr, WD;
wire [3:0] BE;

// Cables que indican que hacer y como salieron las cuentas.
wire PCUpdate, Branch, IRWrite, RegWrite, MemWrite, AdrSrc, PCWrite;
wire [1:0] ResultSrc, ALUSrcA, ALUSrcB;
wire [3:0] ALUControl;
wire [2:0] ImmSrc;
wire Z, N, V, C;

// La unidad de control organiza los pasos de la instruccion.
unidad_control uc (
    .clk(clk), .reset(reset),
    .op(Instr[6:0]), .funct3(Instr[14:12]), .funct7b5(Instr[30]),
    .PCUpdate(PCUpdate), .Branch(Branch), .IRWrite(IRWrite),
    .RegWrite(RegWrite), .MemWrite(MemWrite), .AdrSrc(AdrSrc),
    .ResultSrc(ResultSrc), .ALUSrcA(ALUSrcA), .ALUSrcB(ALUSrcB),
    .ALUControl(ALUControl), .ImmSrc(ImmSrc)
);

// Se decide si el PC cambia y se pone en cero el ultimo bit de su direccion.
pc_write_logic pc_logic (
    .PCUpdate(PCUpdate), .Branch(Branch), .funct3(Instr[14:12]),
    .Z(Z), .N(N), .V(V), .C(C), .PCWrite(PCWrite)
);
assign PCNext = {Result[31:1], 1'b0};

registro reg_pc (
    .clk(clk), .reset(reset), .en(PCWrite), .d(PCNext), .q(PC)
);
// Durante Fetch se guardan la direccion original y la instruccion.
registro reg_oldpc (
    .clk(clk), .reset(reset), .en(IRWrite), .d(PC), .q(OldPC)
);
registro reg_instr (
    .clk(clk), .reset(reset), .en(IRWrite), .d(ReadData), .q(Instr)
);

// La misma memoria sirve para buscar instrucciones y guardar datos.
mux2 mux_adr (
    .d0(PC), .d1(Result), .s(AdrSrc), .y(Adr)
);
logica_bytes bytes_inst (
    .funct3(Instr[14:12]), .Adr(Adr[1:0]), .WriteData(WriteData),
    .BE(BE), .WD(WD)
);
memoria #(.MEMFILE(MEMFILE)) mem (
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

// Se sacan rs1 y rs2; cuando hay permiso se escribe el resultado en rd.
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

// Se arma el inmediato y los mux eligen los dos datos para la ALU.
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

// El mux final elige el dato que se usa para rd, memoria o PC.
mux3 mux_result (
    .d0(ALUOut), .d1(Data), .d2(ALUResult), .s(ResultSrc), .y(Result)
);
endmodule
