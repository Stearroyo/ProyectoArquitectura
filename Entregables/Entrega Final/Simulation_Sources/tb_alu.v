`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Engineer:
// Create Date: 11.11.2026
// Design Name: Microarquitectura RV32I
// Module Name: tb_alu
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
//
// Que se prueba:
// Objetivo: comprobar las cuentas de la ALU y sus 4 indicadores Z, N, V y C.
// Pruebas: cada 10 ns se cambian los datos y ALUControl. Se hacen sumas,
// Restas: iguales, negativo y desbordamiento con signo.s, AND, desplazamientos y una seleccion que no usamos.
// Tambien se prueba BGE con numeros positivos y con desbordamiento.
// Esperado: los resultados y los indicadores deben coincidir con los valores
// que se pasan a probar y probar_bge. BGE salta cuando N xor V es 0.
// Son 14 pruebas. Si todo esta bien, al final salen 0 errores.
//
// Dependencies: alu.v
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

// Hace una cuenta y compara el resultado y las 4 banderas (Z N V C).
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

// Para BGE se resta y se revisa N xor V: debe dar cero si hay salto.
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
    // Sumas normales y sumas que no caben en 32 bits.
    probar(4'b0000, 32'd5, 32'd3, 32'h00000008, 4'b0000);
    probar(4'b0000, 32'h7FFFFFFF, 32'd1, 32'h80000000, 4'b0110);
    probar(4'b0000, 32'hFFFFFFFF, 32'd1, 32'h00000000, 4'b1001);
    // Restas: iguales, negativo y desbordamiento con signo.
    probar(4'b0001, 32'd5, 32'd5, 32'h00000000, 4'b1001);
    probar(4'b0001, 32'd3, 32'd5, 32'hFFFFFFFE, 4'b0100);
    probar(4'b0001, 32'h80000000, 32'd1, 32'h7FFFFFFF, 4'b0011);
    // BGE: comprobar cuando se tomaria el salto.
    probar_bge(32'd5, 32'd3, 1'b0);
    probar_bge(32'd3, 32'd5, 1'b1);
    probar_bge(32'h80000000, 32'd1, 1'b1);
    // Operacion AND.
    probar(4'b0010, 32'hF0F0F0F0, 32'h0FF00FF0, 32'h00F000F0, 4'b0000);
    // Mover bits a la izquierda 0, 4 y 31 lugares.
    probar(4'b0011, 32'd1, 32'd0, 32'h00000001, 4'b0000);
    probar(4'b0011, 32'd1, 32'd4, 32'h00000010, 4'b0000);
    probar(4'b0011, 32'd1, 32'd31, 32'h80000000, 4'b0100);
    // Codigo no usado: debe salir cero.
    probar(4'b1111, 32'd5, 32'd3, 32'h00000000, 4'b1000);
    $display("Pruebas terminadas, errores: %0d", errores);
    $finish;
end

endmodule
