`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Module Name: tb_mux2
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
// Description:
//   Objetivo: comprobar que se selecciona la entrada correcta del mux2.
//   Estimulos: cada entrada tiene un valor distinto; se cambia s cada 10 ns.
//   Resultados esperados:
//     s = 0 -> y = 11111111
//     s = 1 -> y = 22222222
//   Se esperan 2 pruebas OK y 0 errores.
// Dependencies: mux2.v
//////////////////////////////////////////////////////////////////////////////////

module tb_mux2;

reg [31:0] d0;
reg [31:0] d1;
reg s;
wire [31:0] y;
integer errores = 0;

mux2 uut (
    .d0(d0),
    .d1(d1),
    .s(s),
    .y(y)
);

// Se cambia el selector y se compara la salida despues de 10 ns.
task revisar;
    input seleccion;
    input [31:0] esperado;
    begin
        s = seleccion;
        #10;
        if (y === esperado)
            $display("OK    t=%0t s=%b y=%h esperado=%h", $time, s, y, esperado);
        else begin
            $display("ERROR t=%0t s=%b y=%h esperado=%h", $time, s, y, esperado);
            errores = errores + 1;
        end
    end
endtask

initial begin
    $timeformat(-9, 0, " ns", 1);
    $display("---- Prueba mux2 ----");
    d0 = 32'h11111111;
    d1 = 32'h22222222;

    revisar(1'b0, 32'h11111111);
    revisar(1'b1, 32'h22222222);

    $display("Pruebas terminadas, errores: %0d", errores);
    $finish;
end

endmodule
