`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Engineer:
// Create Date: 12.11.2026
// Design Name: Microarquitectura RV32I
// Module Name: tb_registro
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
//
// Que se prueba:
// Objetivo: comprobar que el registro recuerde el dato y solo cambie cuando deba.
// Pruebas: reloj de 10 ns. Se activa reset, se guarda AABBCCDD con en=1,
// se intenta guardar 11111111 con en=0 y se cambia d a 22222222 entre flancos.
// Esperado: reset deja cero aunque en=1. Con en=0 se conserva AABBCCDD.
// El nuevo dato 22222222 solo aparece cuando el reloj sube con en=1.
// Al final se esperan 0 errores.
//
// Dependencies: registro.v
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

// Compara lo guardado con el dato que deberia tener.
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

    // 1. Reset tiene prioridad: borra aunque en valga 1.
    reset = 1; en = 1; d = 32'hFFFFFFFF;
    @(negedge clk);
    revisar(32'h00000000);

    // 2. Con permiso, guarda el dato cuando sube el reloj.
    reset = 0; en = 1; d = 32'hAABBCCDD;
    @(negedge clk);
    revisar(32'hAABBCCDD);

    // 3. Sin permiso, conserva el dato anterior.
    en = 0; d = 32'h11111111;
    @(negedge clk);
    revisar(32'hAABBCCDD);

    // 4. Cambiar d antes de que suba el reloj: q todavia no debe cambiar.
    en = 1; d = 32'h22222222;
    #1;
    revisar(32'hAABBCCDD);
    @(negedge clk);
    revisar(32'h22222222);

    $display("Pruebas terminadas, errores: %0d", errores);
    $finish;
end

endmodule
