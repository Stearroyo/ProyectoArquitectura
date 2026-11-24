`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Engineer:
// Create Date: 12.11.2026
// Design Name: Microarquitectura RV32I
// Module Name: registro
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
//
// Que hace:
// Guarda un dato hasta que haga falta cambiarlo. WIDTH vale 32 por defecto.
// clk es el reloj, reset borra el dato y en es el permiso de guardar.
// d es el dato que entra y q es lo que esta guardado.
// Cuando clk pasa de 0 a 1: reset=1 borra; si no, en=1 guarda d.
// Si en=0 y reset=0, q sigue igual.
// Se usa para PC, OldPC, Instr, A, WriteData, Data y ALUOut.
// PC usa PCWrite; OldPC e Instr usan IRWrite. Los otros se cargan cada ciclo.
//
// Dependencies: ninguna
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////

//No crea ningún registro, solo crea la estructura (entradas, salidas) y comportamiento

//qué cables tiene el registro
module registro #(
    parameter WIDTH = 32
    )(
    input clk,
    input reset,
    input en,//enable
    input [WIDTH-1:0] d,//entrada de 32 bits, d es el dato nuevo que se quiere guardar
    output reg [WIDTH-1:0] q//salida de 32 bits, q es el valor guardado
    );

//cuando sube el ckl, con rst se pone en 0 y si no (en), guarda
always @(posedge clk) begin //qué hace con los cables. es secuelcial
    if (reset)
        q <= {WIDTH{1'b0}};
    else if (en)
        q <= d;
    // Sin permiso, el dato se queda como estaba.
end

endmodule
