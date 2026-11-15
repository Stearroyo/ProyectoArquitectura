`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Engineer:
//
// Create Date: 11.11.2026
// Design Name: Microarquitectura RV32I
// Module Name: tb_banco_registros
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
// Description:
//   Objetivo: revisar que el banco arranca en 0 con el reset, que solo
//   escribe con WE3 = 1, que x0 no cambia y que los 2 puertos leen bien.
//   El reloj es de 10 ns. Las entradas se cambian en el flanco de bajada
//   para que ya esten estables cuando llega el de subida (ahi escribe).
//   Estimulos:
//     1. reset un ciclo y se leen x1, x2 y x31
//     2. se escribe x1 = 0000000A, x2 = FFFFFFFC, x31 = 12345678 y se leen
//        por RD1 y por RD2
//     3. se trata de escribir 0000FFFF en x0
//     4. con WE3 = 0 se trata de escribir DEADBEEF en x1
//     5. se lee x1 por RD1 y x2 por RD2 al mismo tiempo
//   Resultado esperado:
//     1. todo en 0
//     2. cada registro da lo que se le escribio, por cualquiera de los puertos
//     3. x0 sigue en 0
//     4. x1 sigue en 0000000A
//     5. RD1 = 0000000A, RD2 = FFFFFFFC
//   En la consola tiene que salir todo OK y 0 errores.
//
// Dependencies: banco_registros.v
//
// Revision:
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module tb_banco_registros(

    );

reg clk;
reg reset;
reg [4:0] A1, A2, A3;
reg [31:0] WD3;
reg WE3;
wire [31:0] RD1, RD2;

integer errores = 0;

banco_registros uut (
    .clk(clk),
    .reset(reset),
    .A1(A1),
    .A2(A2),
    .A3(A3),
    .WD3(WD3),
    .WE3(WE3),
    .RD1(RD1),
    .RD2(RD2)
);

initial clk = 0;
always #5 clk = ~clk;

// lee dos registros (uno por cada puerto) y compara
task leer(input [4:0] r1, input [31:0] esp1, input [4:0] r2, input [31:0] esp2);
begin
    A1 = r1;
    A2 = r2;
    #1;
    if (RD1 == esp1 && RD2 == esp2)
        $display("OK    x%0d: RD1=%h   x%0d: RD2=%h", r1, RD1, r2, RD2);
    else begin
        $display("ERROR x%0d: RD1=%h   x%0d: RD2=%h (esperado %h y %h)", r1, RD1, r2, RD2, esp1, esp2);
        errores = errores + 1;
    end
end
endtask

// we = 0 es para probar que sin permiso no escribe
task escribir(input [4:0] rd, input [31:0] dato, input we);
begin
    @(negedge clk);
    A3 = rd; WD3 = dato; WE3 = we;
    @(negedge clk);
    WE3 = 0;
end
endtask

initial begin
    $display("---- Prueba banco_registros ----");
    A1 = 0; A2 = 0; A3 = 0; WD3 = 0; WE3 = 0;

    // 1. reset
    reset = 1;
    @(negedge clk);
    @(negedge clk);
    reset = 0;
    leer(5'd1, 32'h0, 5'd2, 32'h0);
    leer(5'd31, 32'h0, 5'd0, 32'h0);

    // 2. se escriben 3 registros y se leen por los dos puertos
    escribir(5'd1, 32'h0000000A, 1'b1);
    escribir(5'd2, 32'hFFFFFFFC, 1'b1);
    escribir(5'd31, 32'h12345678, 1'b1);
    leer(5'd1, 32'h0000000A, 5'd2, 32'hFFFFFFFC);
    leer(5'd31, 32'h12345678, 5'd1, 32'h0000000A);
    leer(5'd2, 32'hFFFFFFFC, 5'd31, 32'h12345678);

    // 3. x0 no se deja escribir
    escribir(5'd0, 32'h0000FFFF, 1'b1);
    leer(5'd0, 32'h0, 5'd0, 32'h0);

    // 4. con WE3 en 0 no deberia cambiar x1
    escribir(5'd1, 32'hDEADBEEF, 1'b0);
    leer(5'd1, 32'h0000000A, 5'd0, 32'h0);

    // 5. lectura de rs1 y rs2 a la vez (como pasa en Decode)
    leer(5'd1, 32'h0000000A, 5'd2, 32'hFFFFFFFC);

    $display("Pruebas terminadas, errores: %0d", errores);
    $finish;
end

endmodule
