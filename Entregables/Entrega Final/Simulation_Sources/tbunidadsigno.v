`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Create Date: 11.10.2026 11:31:22
// Design Name: Microarquitectura RV32I
// Module Name: tbunidadsigno
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2026.1
//
// Que se prueba:
// Objetivo: revisar que el inmediato quede bien armado y tenga el signo correcto.
// Pruebas: se manda una instruccion y su ImmSrc cada 10 ns.
// Se prueban I, S, B, J y U con numeros positivos, negativos y limites.
// Tambien se prueba un codigo no usado (111), que debe devolver cero.
// Esperado: cada valor de ImmExt debe coincidir con el tercer dato de probar.
// Las instrucciones de ejemplo se explican junto a cada prueba.
// Son 18 pruebas; al final se esperan 0 errores.
//
// Dependencies: unidadsigno.v
// Revision 0.01 - File Created (formatos I y S, Avance 1)
// Revision 0.02 - Avance 2: ImmSrc de 3 bits, pruebas de B, J y U
//////////////////////////////////////////////////////////////////////////////////


module tbunidadsigno(

    );

reg  [31:0] instruccion;   // instruccion completa de 32 bits
reg  [2:0]  ImmSrc;
wire [31:0] ImmExt;

integer errores = 0;

// Mandamos solo los bits de la instruccion que usa el modulo.
unidadsigno uut (
    .instr(instruccion[31:7]),
    .ImmSrc(ImmSrc),
    .ImmExt(ImmExt)
);

// Esta tarea manda una instruccion y compara el inmediato con el esperado.
task probar(input [31:0] ins, input [2:0] src, input [31:0] esperado);
begin
    instruccion = ins;
    ImmSrc = src;
    #10;
    if (ImmExt == esperado)
        $display("OK    instr=%h ImmSrc=%b ImmExt=%h", ins, src, ImmExt);
    else begin
        $display("ERROR instr=%h ImmSrc=%b ImmExt=%h (esperado %h)", ins, src, ImmExt, esperado);
        errores = errores + 1;
    end
end
endtask

initial begin
    $display("---- Prueba unidad de signo ----");
    // S: inmediatos para guardar datos.
    probar(32'h00512423, 3'b001, 32'h00000008); // sw x5, 8(x2)
    probar(32'hFE512E23, 3'b001, 32'hFFFFFFFC); // sw x5, -4(x2)
    probar(32'h80512023, 3'b001, 32'hFFFFF800); // sw x5, -2048(x2)
    // I: inmediatos para operaciones.
    probar(32'h00A00293, 3'b000, 32'h0000000A); // addi x5, x0, 10
    probar(32'hFFF00293, 3'b000, 32'hFFFFFFFF); // addi x5, x0, -1
    // B: distancias de saltos condicionales.
    probar(32'h00B55463, 3'b010, 32'h00000008); // bge a0, a1, +8
    probar(32'h00051463, 3'b010, 32'h00000008); // bnez a0, +8
    probar(32'hFE000EE3, 3'b010, 32'hFFFFFFFC); // beq x0, x0, -4
    probar(32'h80000063, 3'b010, 32'hFFFFF000); // beq x0, x0, -4096
    probar(32'h7E000FE3, 3'b010, 32'h00000FFE); // beq x0, x0, +4094
    // J: distancias de saltos directos.
    probar(32'h008000EF, 3'b011, 32'h00000008); // jal ra, +8
    probar(32'hFA5FF06F, 3'b011, 32'hFFFFFFA4); // j -0x5C
    probar(32'h8000006F, 3'b011, 32'hFFF00000); // jal zero, -1048576
    probar(32'h7FFFF06F, 3'b011, 32'h000FFFFE); // jal zero, +1048574
    // U: constantes grandes.
    probar(32'h00001137, 3'b100, 32'h00001000); // lui sp, 0x1
    probar(32'h0000C537, 3'b100, 32'h0000C000); // lui a0, 0xC
    probar(32'hFFFFF2B7, 3'b100, 32'hFFFFF000); // lui x5, 0xFFFFF
    // Seleccion no usada: debe devolver cero.
    probar(32'h00512423, 3'b111, 32'h00000000); // default
    $display("Pruebas terminadas, errores: %0d", errores);
    $finish;
end

endmodule
