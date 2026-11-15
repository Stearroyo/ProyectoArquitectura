`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Engineer:
//
// Create Date: 11.11.2026
// Design Name: Microarquitectura RV32I
// Module Name: tb_extension_carga
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
// Description:
//   Objetivo: revisar que extension_carga saca bien la parte de la palabra y
//   la extiende bien para lw, lb, lbu, lh y lhu.
//   ReadData se deja fijo en 0x8822F344. Asi los bytes son 44, F3, 22 y 88,
//   F3 y 88 tienen el bit 7 en 1 y los otros dos no, entonces se ve la
//   diferencia entre extender con signo y con ceros.
//   Estimulos (10 ns c/u) y lo que deberia salir:
//     lw  Adr=00 -> 8822F344
//     lb  Adr=00 -> 00000044     lb Adr=01 -> FFFFFFF3
//     lb  Adr=10 -> 00000022     lb Adr=11 -> FFFFFF88
//     lbu Adr=01 -> 000000F3     lbu Adr=11 -> 00000088
//     lh  Adr=00 -> FFFFF344     lh Adr=10 -> FFFF8822
//     lhu Adr=00 -> 0000F344     lhu Adr=10 -> 00008822
//     funct3=111 (no es load) -> 8822F344
//   Tienen que salir las 12 pruebas OK y 0 errores.
//
// Dependencies: extension_carga.v
//
// Revision:
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
    // lb en los 4 bytes
    probar(3'b000, 2'b00, 32'h00000044);
    probar(3'b000, 2'b01, 32'hFFFFFFF3);  // negativo
    probar(3'b000, 2'b10, 32'h00000022);
    probar(3'b000, 2'b11, 32'hFFFFFF88);  // negativo
    // lbu, aunque el byte sea "negativo" se rellena con 0
    probar(3'b100, 2'b01, 32'h000000F3);
    probar(3'b100, 2'b11, 32'h00000088);
    // lh y lhu en las dos mitades
    probar(3'b001, 2'b00, 32'hFFFFF344);
    probar(3'b001, 2'b10, 32'hFFFF8822);
    probar(3'b101, 2'b00, 32'h0000F344);
    probar(3'b101, 2'b10, 32'h00008822);
    probar(3'b111, 2'b00, 32'h8822F344); // no es load
    $display("Pruebas terminadas, errores: %0d", errores);
    $finish;
end

endmodule
