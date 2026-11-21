`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Module Name: fsm
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
// Description:
//   Se controla la secuencia de estados de cada instruccion.
//   Entradas: clk, reset y op (opcode de 7 bits).
//   Salidas: PCUpdate, Branch, IRWrite, RegWrite, MemWrite, AdrSrc,
//   ResultSrc, ALUSrcA, ALUSrcB y ALUOp.
//   Se usa reset sincrono, activo en 1.
//////////////////////////////////////////////////////////////////////////////////

module fsm(
    input clk, reset,
    input [6:0] op,
    output reg PCUpdate, Branch, IRWrite, RegWrite, MemWrite, AdrSrc,
    output reg [1:0] ResultSrc, ALUSrcA, ALUSrcB, ALUOp
);

// Se agrega ST_ para distinguir los estados de las senales de salida.
localparam [3:0] ST_Fetch    = 4'd0,
                 ST_Decode   = 4'd1,
                 ST_MemAdr   = 4'd2,
                 ST_MemRead  = 4'd3,
                 ST_MemWB    = 4'd4,
                 ST_MemWrite = 4'd5,
                 ST_ExecuteI = 4'd6,
                 ST_ALUWB    = 4'd7,
                 ST_JAL      = 4'd8,
                 ST_Branch   = 4'd9,
                 ST_LUI      = 4'd10,
                 ST_JALR     = 4'd11;

reg [3:0] estado, siguiente;

// Se guarda el estado en cada flanco de subida.
always @(posedge clk) begin
    if (reset)
        estado <= ST_Fetch;
    else
        estado <= siguiente;
end

// Se determina el siguiente estado segun el opcode.
always @(*) begin
    case (estado)
        ST_Fetch: siguiente = ST_Decode;
        ST_Decode: begin
            case (op)
                7'b0000011, 7'b0100011: siguiente = ST_MemAdr;
                7'b0010011: siguiente = ST_ExecuteI;
                7'b1100011: siguiente = ST_Branch;
                7'b1101111: siguiente = ST_JAL;
                7'b1100111: siguiente = ST_JALR;
                7'b0110111: siguiente = ST_LUI;
                default: siguiente = ST_Fetch;
            endcase
        end
        ST_MemAdr: begin
            if (op == 7'b0000011)
                siguiente = ST_MemRead;
            else
                siguiente = ST_MemWrite;
        end
        ST_MemRead: siguiente = ST_MemWB;
        ST_MemWB, ST_MemWrite, ST_ALUWB, ST_Branch:
            siguiente = ST_Fetch;
        ST_ExecuteI, ST_LUI, ST_JAL: siguiente = ST_ALUWB;
        ST_JALR: siguiente = ST_JAL;
        default: siguiente = ST_Fetch;
    endcase
end

// Se activan solo las senales necesarias de cada estado.
always @(*) begin
    PCUpdate = 1'b0;
    Branch   = 1'b0;
    IRWrite  = 1'b0;
    RegWrite = 1'b0;
    MemWrite = 1'b0;
    AdrSrc   = 1'b0;
    ResultSrc = 2'b00;
    ALUSrcA   = 2'b00;
    ALUSrcB   = 2'b00;
    ALUOp     = 2'b00;

    case (estado)
        ST_Fetch: begin
            IRWrite = 1'b1;
            ALUSrcB = 2'b10;
            ResultSrc = 2'b10;
            PCUpdate = 1'b1;
        end
        ST_Decode: begin
            ALUSrcA = 2'b01;
            ALUSrcB = 2'b01;
        end
        ST_MemAdr: begin
            ALUSrcA = 2'b10;
            ALUSrcB = 2'b01;
        end
        ST_MemRead: begin
            AdrSrc = 1'b1;
        end
        ST_MemWB: begin
            ResultSrc = 2'b01;
            RegWrite = 1'b1;
        end
        ST_MemWrite: begin
            AdrSrc = 1'b1;
            MemWrite = 1'b1;
        end
        ST_ExecuteI: begin
            ALUSrcA = 2'b10;
            ALUSrcB = 2'b01;
            ALUOp = 2'b10;
        end
        ST_ALUWB: begin
            RegWrite = 1'b1;
        end
        ST_JAL: begin
            ALUSrcA = 2'b01;
            ALUSrcB = 2'b10;
            PCUpdate = 1'b1;
        end
        ST_Branch: begin
            ALUSrcA = 2'b10;
            ALUOp = 2'b01;
            Branch = 1'b1;
        end
        ST_LUI: begin
            ALUSrcA = 2'b11;
            ALUSrcB = 2'b01;
        end
        ST_JALR: begin
            ALUSrcA = 2'b10;
            ALUSrcB = 2'b01;
        end
        default: begin
            // Se conservan las salidas en cero.
        end
    endcase
end
endmodule
