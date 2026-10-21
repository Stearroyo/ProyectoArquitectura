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
//     formatos I y S y que extiende el signo correctamente a 32 bits.
//   Estimulos (en este orden, cada uno dura 10 ns):
//     1. sw x5, 8(x2)      -> 0x00512423, ImmSrc=01 (S, positivo)
//     2. sw x5, -4(x2)     -> 0xFE512E23, ImmSrc=01 (S, negativo)
//     3. sw x5, -2048(x2)  -> 0x80512023, ImmSrc=01 (S, valor minimo)
//     4. addi x5, x0, 10   -> 0x00A00293, ImmSrc=00 (I, positivo)
//     5. addi x5, x0, -1   -> 0xFFF00293, ImmSrc=00 (I, negativo)
//     6. misma instr. 1 con ImmSrc=10 (formato no soportado)
//   Resultados esperados:
//     1. 0x00000008   2. 0xFFFFFFFC   3. 0xFFFFF800
//     4. 0x0000000A   5. 0xFFFFFFFF   6. 0x00000000 (default)
//     En la consola debe salir OK en las 6 pruebas y 0 errores.
// 
// Dependencies: unidadsigno.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   Las instrucciones se pueden verificar ensamblandolas en Ripes.
//////////////////////////////////////////////////////////////////////////////////


module tbunidadsigno(

    );

reg  [31:0] instruccion;   // instruccion completa de 32 bits
reg  [1:0]  ImmSrc;
wire [31:0] ImmExt;

integer errores = 0;

// el modulo solo recibe los bits 31:7
unidadsigno uut (
    .instr(instruccion[31:7]),
    .ImmSrc(ImmSrc),
    .ImmExt(ImmExt)
);

// tarea para no repetir lo mismo en cada prueba
task probar(input [31:0] ins, input [1:0] src, input [31:0] esperado);
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
    probar(32'h00512423, 2'b01, 32'h00000008); // sw x5, 8(x2)
    probar(32'hFE512E23, 2'b01, 32'hFFFFFFFC); // sw x5, -4(x2)
    probar(32'h80512023, 2'b01, 32'hFFFFF800); // sw x5, -2048(x2)
    probar(32'h00A00293, 2'b00, 32'h0000000A); // addi x5, x0, 10
    probar(32'hFFF00293, 2'b00, 32'hFFFFFFFF); // addi x5, x0, -1
    probar(32'h00512423, 2'b10, 32'h00000000); // default
    $display("Pruebas terminadas, errores: %0d", errores);
    $finish;
end

endmodule
