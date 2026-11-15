`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Engineer:
//
// Create Date: 12.11.2026
// Design Name: Microarquitectura RV32I
// Module Name: tb_registro
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
// Description:
//   Objetivo: revisar que el registro se pone en 0 con reset, guarda d solo
//   en el flanco de subida y solo si en = 1, y que si en = 0 se queda igual.
//   Reloj de 10 ns. Las entradas se cambian en el flanco de bajada.
//   Estimulos y lo que deberia pasar:
//     1. reset = 1 (con en = 1 y d = FFFFFFFF) -> q = 00000000
//        o sea el reset le gana a en
//     2. en = 1, d = AABBCCDD, pasa un flanco -> q = AABBCCDD
//     3. en = 0, d = 11111111, pasa un flanco -> q sigue en AABBCCDD
//     4. en = 1 y se cambia d a 22222222 entre flancos -> q todavia no
//        cambia (sigue AABBCCDD); despues del flanco -> q = 22222222
//   Tienen que salir todas las pruebas OK y 0 errores.
//
// Dependencies: registro.v
//
// Revision:
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module tb_registro(

    );

reg clk;
reg reset;
reg en;
reg [31:0] d;
wire [31:0] q;

integer errores = 0;

registro uut (
    .clk(clk),
    .reset(reset),
    .en(en),
    .d(d),
    .q(q)
);

initial clk = 0;
always #5 clk = ~clk;

// compara lo que tiene el registro en este momento
task revisar(input [31:0] esperado);
begin
    if (q == esperado)
        $display("OK    t=%0t en=%b d=%h q=%h", $time, en, d, q);
    else begin
        $display("ERROR t=%0t en=%b d=%h q=%h (esperado %h)", $time, en, d, q, esperado);
        errores = errores + 1;
    end
end
endtask

initial begin
    $timeformat(-9, 0, " ns", 1);  // para que el tiempo salga en ns
    $display("---- Prueba registro ----");

    // 1. reset, aunque en este en 1 tiene que quedar en 0
    reset = 1; en = 1; d = 32'hFFFFFFFF;
    @(negedge clk);
    revisar(32'h00000000);

    // 2. con en = 1 guarda el dato en el flanco
    reset = 0; en = 1; d = 32'hAABBCCDD;
    @(negedge clk);
    revisar(32'hAABBCCDD);

    // 3. con en = 0 no cambia
    en = 0; d = 32'h11111111;
    @(negedge clk);
    revisar(32'hAABBCCDD);

    // 4. se cambia d a medio ciclo, q no deberia cambiar hasta el flanco
    en = 1; d = 32'h22222222;
    #1;
    revisar(32'hAABBCCDD);
    @(negedge clk);
    revisar(32'h22222222);

    $display("Pruebas terminadas, errores: %0d", errores);
    $finish;
end

endmodule
