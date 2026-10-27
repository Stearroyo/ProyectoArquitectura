`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
//
//
// Create Date: 11.10.2026 11:31:22
// Design Name: Microarquitectura RV32I
// Module Name: tbunidadsigno
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2026.1
// Description:
//   Objetivo de la prueba:
//     Verificar que la unidad de signo arma bien el inmediato de los
//     formatos I, S, B, J y U y que extiende el signo correctamente a 32 bits,
//     incluyendo los valores extremos y instrucciones como las del codigo C.
//   Estimulos (en este orden, cada uno dura 10 ns):
//     Tipo S (ImmSrc=001)
//      1. sw x5, 8(x2)        -> 0x00512423 (positivo)
//      2. sw x5, -4(x2)       -> 0xFE512E23 (negativo)
//      3. sw x5, -2048(x2)    -> 0x80512023 (valor minimo)
//     Tipo I (ImmSrc=000)
//      4. addi x5, x0, 10     -> 0x00A00293 (positivo)
//      5. addi x5, x0, -1     -> 0xFFF00293 (negativo)
//     Tipo B (ImmSrc=010)
//      6. bge a0, a1, +8      -> 0x00B55463 (como en el codigo C)
//      7. bnez a0, +8         -> 0x00051463 (bne a0, zero; como en el codigo C)
//      8. beq x0, x0, -4      -> 0xFE000EE3 (negativo)
//      9. beq x0, x0, -4096   -> 0x80000063 (valor minimo)
//     10. beq x0, x0, +4094   -> 0x7E000FE3 (valor maximo)
//     Tipo J (ImmSrc=011)
//     11. jal ra, +8          -> 0x008000EF (jal con enlace)
//     12. j -0x5C             -> 0xFA5FF06F (jal zero; salto hacia atras como el del for)
//     13. jal zero, -1048576  -> 0x8000006F (valor minimo)
//     14. jal zero, +1048574  -> 0x7FFFF06F (valor maximo)
//     Tipo U (ImmSrc=100)
//     15. lui sp, 0x1         -> 0x00001137 (positivo pequeño)
//     16. lui a0, 0xC         -> 0x0000C537 (como en int *r = 0xC7DF)
//     17. lui x5, 0xFFFFF     -> 0xFFFFF2B7 (bit 31 en 1)
//     Otro codigo
//     18. misma instr. 1 con ImmSrc=111 (formato no soportado)
//   Resultados esperados:
//      1. 0x00000008   2. 0xFFFFFFFC   3. 0xFFFFF800
//      4. 0x0000000A   5. 0xFFFFFFFF
//      6. 0x00000008   7. 0x00000008   8. 0xFFFFFFFC   9. 0xFFFFF000  10. 0x00000FFE
//     11. 0x00000008  12. 0xFFFFFFA4  13. 0xFFF00000  14. 0x000FFFFE
//     15. 0x00001000  16. 0x0000C000  17. 0xFFFFF000
//     18. 0x00000000 (default)
//     En la consola debe salir OK en las 18 pruebas y 0 errores.
//
// Dependencies: unidadsigno.v
//
// Revision:
// Revision 0.01 - File Created (formatos I y S, Avance 1)
// Revision 0.02 - Avance 2: ImmSrc de 3 bits, pruebas de B, J y U
// Additional Comments:
//   Las instrucciones se pueden verificar ensamblandolas en Ripes. Las
//   marcadas "como en el codigo C" son del mismo tipo que las que aparecen
//   en la compilacion del programa del proyecto (bge, bnez, j, lui).
//////////////////////////////////////////////////////////////////////////////////


module tbunidadsigno(

    );

reg  [31:0] instruccion;   // instruccion completa de 32 bits
reg  [2:0]  ImmSrc;
wire [31:0] ImmExt;

integer errores = 0;

// el modulo solo recibe los bits 31:7
unidadsigno uut (
    .instr(instruccion[31:7]),
    .ImmSrc(ImmSrc),
    .ImmExt(ImmExt)
);

// tarea para no repetir lo mismo en cada prueba
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
    // tipo S
    probar(32'h00512423, 3'b001, 32'h00000008); // sw x5, 8(x2)
    probar(32'hFE512E23, 3'b001, 32'hFFFFFFFC); // sw x5, -4(x2)
    probar(32'h80512023, 3'b001, 32'hFFFFF800); // sw x5, -2048(x2)
    // tipo I
    probar(32'h00A00293, 3'b000, 32'h0000000A); // addi x5, x0, 10
    probar(32'hFFF00293, 3'b000, 32'hFFFFFFFF); // addi x5, x0, -1
    // tipo B
    probar(32'h00B55463, 3'b010, 32'h00000008); // bge a0, a1, +8
    probar(32'h00051463, 3'b010, 32'h00000008); // bnez a0, +8
    probar(32'hFE000EE3, 3'b010, 32'hFFFFFFFC); // beq x0, x0, -4
    probar(32'h80000063, 3'b010, 32'hFFFFF000); // beq x0, x0, -4096
    probar(32'h7E000FE3, 3'b010, 32'h00000FFE); // beq x0, x0, +4094
    // tipo J
    probar(32'h008000EF, 3'b011, 32'h00000008); // jal ra, +8
    probar(32'hFA5FF06F, 3'b011, 32'hFFFFFFA4); // j -0x5C
    probar(32'h8000006F, 3'b011, 32'hFFF00000); // jal zero, -1048576
    probar(32'h7FFFF06F, 3'b011, 32'h000FFFFE); // jal zero, +1048574
    // tipo U
    probar(32'h00001137, 3'b100, 32'h00001000); // lui sp, 0x1
    probar(32'h0000C537, 3'b100, 32'h0000C000); // lui a0, 0xC
    probar(32'hFFFFF2B7, 3'b100, 32'hFFFFF000); // lui x5, 0xFFFFF
    // codigo no usado
    probar(32'h00512423, 3'b111, 32'h00000000); // default
    $display("Pruebas terminadas, errores: %0d", errores);
    $finish;
end

endmodule
