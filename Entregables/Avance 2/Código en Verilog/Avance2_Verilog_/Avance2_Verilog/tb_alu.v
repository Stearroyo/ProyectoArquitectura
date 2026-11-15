`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Engineer:
//
// Create Date: 11.11.2026
// Design Name: Microarquitectura RV32I
// Module Name: tb_alu
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
// Description:
//   Objetivo: revisar el resultado y las banderas (Z N V C) de cada
//   operacion, y ver que con la resta se puede decidir bge usando N xor V.
//   Cada prueba dura 10 ns. Lo que deberia salir:
//   Suma
//     5 + 3 = 00000008, ZNVC = 0000
//     7FFFFFFF + 1 = 80000000, ZNVC = 0110 (overflow)
//     FFFFFFFF + 1 = 00000000, ZNVC = 1001 (carry)
//   Resta
//     5 - 5 = 00000000, ZNVC = 1001
//     3 - 5 = FFFFFFFE, ZNVC = 0100
//     80000000 - 1 = 7FFFFFFF, ZNVC = 0011 (overflow)
//   bge (0 = salta, 1 = no salta)
//     5 - 3 -> N xor V = 0
//     3 - 5 -> N xor V = 1
//     80000000 - 1 -> N xor V = 1. Aqui N es 0 pero V es 1, por eso bge
//     usa N xor V y no solamente N
//   AND
//     F0F0F0F0 and 0FF00FF0 = 00F000F0
//   SLL
//     1 << 0 = 00000001, 1 << 4 = 00000010, 1 << 31 = 80000000 (N = 1)
//   Codigo que no se usa (1111) -> 00000000, Z = 1
//   Tienen que salir las 14 pruebas OK y 0 errores.
//
// Dependencies: alu.v
//
// Revision:
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module tb_alu(

    );

reg [31:0] SrcA, SrcB;
reg [3:0] ALUControl;
wire [31:0] ALUResult;
wire Z, N, V, C;

integer errores = 0;

alu uut (
    .SrcA(SrcA),
    .SrcB(SrcB),
    .ALUControl(ALUControl),
    .ALUResult(ALUResult),
    .Z(Z),
    .N(N),
    .V(V),
    .C(C)
);

// compara el resultado y las 4 banderas, en orden Z N V C
task probar(input [3:0] ctrl, input [31:0] a, input [31:0] b, input [31:0] res_esp, input [3:0] znvc_esp);
begin
    ALUControl = ctrl;
    SrcA = a;
    SrcB = b;
    #10;
    if (ALUResult == res_esp && {Z, N, V, C} == znvc_esp)
        $display("OK    ctrl=%b A=%h B=%h -> %h ZNVC=%b", ctrl, a, b, ALUResult, {Z, N, V, C});
    else begin
        $display("ERROR ctrl=%b A=%h B=%h -> %h ZNVC=%b (esperado %h ZNVC=%b)", ctrl, a, b, ALUResult, {Z, N, V, C}, res_esp, znvc_esp);
        errores = errores + 1;
    end
end
endtask

// para bge solo se revisa N xor V despues de restar
task probar_bge(input [31:0] a, input [31:0] b, input nxv_esp);
begin
    ALUControl = 4'b0001;
    SrcA = a;
    SrcB = b;
    #10;
    if ((N ^ V) == nxv_esp)
        $display("OK    bge A=%h B=%h -> N xor V = %b", a, b, N ^ V);
    else begin
        $display("ERROR bge A=%h B=%h -> N xor V = %b (esperado %b)", a, b, N ^ V, nxv_esp);
        errores = errores + 1;
    end
end
endtask

initial begin
    $display("---- Prueba alu ----");
    // suma
    probar(4'b0000, 32'd5, 32'd3, 32'h00000008, 4'b0000);
    probar(4'b0000, 32'h7FFFFFFF, 32'd1, 32'h80000000, 4'b0110);
    probar(4'b0000, 32'hFFFFFFFF, 32'd1, 32'h00000000, 4'b1001);
    // resta
    probar(4'b0001, 32'd5, 32'd5, 32'h00000000, 4'b1001);
    probar(4'b0001, 32'd3, 32'd5, 32'hFFFFFFFE, 4'b0100);
    probar(4'b0001, 32'h80000000, 32'd1, 32'h7FFFFFFF, 4'b0011);
    // bge
    probar_bge(32'd5, 32'd3, 1'b0);
    probar_bge(32'd3, 32'd5, 1'b1);
    probar_bge(32'h80000000, 32'd1, 1'b1);
    // and
    probar(4'b0010, 32'hF0F0F0F0, 32'h0FF00FF0, 32'h00F000F0, 4'b0000);
    // sll
    probar(4'b0011, 32'd1, 32'd0, 32'h00000001, 4'b0000);
    probar(4'b0011, 32'd1, 32'd4, 32'h00000010, 4'b0000);
    probar(4'b0011, 32'd1, 32'd31, 32'h80000000, 4'b0100);
    // codigo sin usar
    probar(4'b1111, 32'd5, 32'd3, 32'h00000000, 4'b1000);
    $display("Pruebas terminadas, errores: %0d", errores);
    $finish;
end

endmodule
