`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Engineer:
// Create Date: 11.11.2026
// Design Name: Microarquitectura RV32I
// Module Name: tb_extension_carga
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
//
// Que se prueba:
// Objetivo: comprobar que se saque la parte correcta de la palabra de memoria.
// Pruebas: se deja ReadData=8822F344 y se cambian funct3 y Adr cada 10 ns.
// LW debe dejar el dato igual. LB y LH deben conservar el signo.
// LBU y LHU deben rellenar con ceros. Se prueban las distintas posiciones.
// Para un codigo no usado se espera la palabra completa.
// Los resultados esperados estan en cada llamada a probar. Son 12 pruebas;
// al final se esperan 0 errores.
//
// Dependencies: extension_carga.v
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////


module tb_extension_carga(

    );

reg [31:0] ReadData;
reg [1:0] Adr;
reg [2:0] funct3;
wire [31:0] DataExt;

integer errores = 0;

extension_carga uut (
    .ReadData(ReadData),
    .Adr(Adr),
    .funct3(funct3),
    .DataExt(DataExt)
);

// Cambia el tipo de carga y la posicion, espera y compara.
task probar(input [2:0] f3, input [1:0] ad, input [31:0] esperado);
begin
    funct3 = f3;
    Adr = ad;
    #10;
    if (DataExt == esperado)
        $display("OK    funct3=%b Adr=%b DataExt=%h", f3, ad, DataExt);
    else begin
        $display("ERROR funct3=%b Adr=%b DataExt=%h (esperado %h)", f3, ad, DataExt, esperado);
        errores = errores + 1;
    end
end
endtask

initial begin
    $display("---- Prueba extension_carga ----");
    ReadData = 32'h8822F344;
    probar(3'b010, 2'b00, 32'h8822F344); // lw
    // LB: leer cada uno de los cuatro bytes.
    probar(3'b000, 2'b00, 32'h00000044);
    probar(3'b000, 2'b01, 32'hFFFFFFF3);  // El bit de signo vale 1.
    probar(3'b000, 2'b10, 32'h00000022);
    probar(3'b000, 2'b11, 32'hFFFFFF88);  // El bit de signo vale 1.
    // LBU: rellenar con ceros aunque el bit de arriba sea 1.
    probar(3'b100, 2'b01, 32'h000000F3);
    probar(3'b100, 2'b11, 32'h00000088);
    // LH y LHU: probar las dos mitades de la palabra.
    probar(3'b001, 2'b00, 32'hFFFFF344);
    probar(3'b001, 2'b10, 32'hFFFF8822);
    probar(3'b101, 2'b00, 32'h0000F344);
    probar(3'b101, 2'b10, 32'h00008822);
    probar(3'b111, 2'b00, 32'h8822F344); // Codigo no usado; sale la palabra entera.
    $display("Pruebas terminadas, errores: %0d", errores);
    $finish;
end

endmodule
