`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Module Name: fsm
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
//
// Que hace:
// La FSM controla el orden de los pasos de cada instruccion.
// clk marca cuando se pasa al siguiente estado. reset=1 vuelve a Fetch.
// op son los 7 bits que indican el grupo de la instruccion.
// PCUpdate y Branch sirven para decidir si cambia el PC.
// IRWrite guarda la instruccion y OldPC. RegWrite escribe en rd.
// MemWrite permite guardar en memoria; AdrSrc elige su direccion.
// ALUSrcA y ALUSrcB eligen los datos de la ALU; ALUOp indica la operacion.
// ResultSrc elige de donde sale el resultado del procesador.
//////////////////////////////////////////////////////////////////////////////////

//corazón de la unidad de control
//hay 12 estados diferentes
module fsm(
    input clk, reset,
    input [6:0] op,
    output reg PCUpdate, Branch, IRWrite, RegWrite, MemWrite, AdrSrc,
    output reg [1:0] ResultSrc, ALUSrcA, ALUSrcB, ALUOp
);

// ST_ identifica los nombres de los estados, no las senales de control.
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

reg [3:0] estado, siguiente;//estado: paso actual. siguiente: paso que viene

// Cuando el reloj sube, pasamos al siguiente estado. Reset vuelve a Fetch.
always @(posedge clk) begin
    if (reset)
        estado <= ST_Fetch;
    else
        estado <= siguiente;
end

// Aqui se decide el siguiente estado, segun la instruccion.
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

// Primero dejamos todo en cero; abajo cambiamos lo que necesita cada paso.
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

    //Según el estado actual, enciende las señales de ese paso
    case (estado)
        // Buscar la instruccion, guardar OldPC y calcular PC+4.
        ST_Fetch: begin
            IRWrite = 1'b1;
            ALUSrcB = 2'b10;
            ResultSrc = 2'b10;
            PCUpdate = 1'b1;
        end
        // Preparar OldPC + inmediato, que sirve para los saltos.
        ST_Decode: begin
            ALUSrcA = 2'b01;
            ALUSrcB = 2'b01;
        end
        // Calcular la direccion de memoria con rs1 + inmediato.
        ST_MemAdr: begin
            ALUSrcA = 2'b10;
            ALUSrcB = 2'b01;
        end
        // Leer la memoria en la direccion calculada.
        ST_MemRead: begin
            AdrSrc = 1'b1;
        end
        // Guardar el dato leido en rd.
        ST_MemWB: begin
            ResultSrc = 2'b01;
            RegWrite = 1'b1;
        end
        // Dar permiso para escribir en memoria.
        ST_MemWrite: begin
            AdrSrc = 1'b1;
            MemWrite = 1'b1;
        end
        // Hacer ADDI, ANDI o SLLI, segun lo que diga el decodificador.
        ST_ExecuteI: begin
            ALUSrcA = 2'b10;
            ALUSrcB = 2'b01;
            ALUOp = 2'b10;
        end
        // Guardar en rd el resultado que quedo en ALUOut.
        ST_ALUWB: begin
            RegWrite = 1'b1;
        end
        // Saltar al destino de ALUOut y calcular OldPC+4 para el retorno.
        ST_JAL: begin
            ALUSrcA = 2'b01;
            ALUSrcB = 2'b10;
            PCUpdate = 1'b1;
        end
        // Restar los registros para ver si se cumple la condicion del salto.
        ST_Branch: begin
            ALUSrcA = 2'b10;
            ALUOp = 2'b01;
            Branch = 1'b1;
        end
        // Sumar cero al inmediato U para obtener el valor que se quiere guardar.
        ST_LUI: begin
            ALUSrcA = 2'b11;
            ALUSrcB = 2'b01;
        end
        // Calcular rs1+inmediato. Despues se usa el estado JAL para saltar.
        ST_JALR: begin
            ALUSrcA = 2'b10;
            ALUSrcB = 2'b01;
        end
        default: begin
            // Si no se reconoce el estado, las salidas quedan en cero.
        end
    endcase
end
endmodule
