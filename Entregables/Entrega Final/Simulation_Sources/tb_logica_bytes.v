`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Engineer:
// Create Date: 25.10.2026
// Design Name: Microarquitectura RV32I
// Module Name: tb_logica_bytes
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
//
// Que se prueba:
// Objetivo: comprobar que BE permita escribir los bytes correctos y WD
// lleve el dato acomodado para la memoria.
// Pruebas: WriteData=11223344. Cada 10 ns se cambia funct3 y Adr.
// Esperado: SW deja WD igual y BE=1111. SH repite 3344 en las dos mitades
// con BE=0011 o 1100. SB repite 44 y activa solo un bit de BE.
// Si no se usa ese funct3, BE debe ser 0000. Son 8 pruebas; se esperan 0 errores.
//
// Dependencies: logica_bytes.v
// Revision 0.01 - File Created (Avance 2)
// Revision 0.02 - Nombres de modulo y puertos iguales a los del diagrama
// Revision 0.03 - Se agregan las dos pruebas de sh
//////////////////////////////////////////////////////////////////////////////////

module tb_logica_bytes(

    );

reg  [2:0]  funct3;
reg  [1:0]  Adr;
reg  [31:0] WriteData;
wire [3:0]  BE;
wire [31:0] WD;

integer errores = 0;

logica_bytes uut (
    .funct3(funct3),
    .Adr(Adr),
    .WriteData(WriteData),
    .BE(BE),
    .WD(WD)
);

// Da un tipo de escritura y posicion, espera y compara BE y WD.
task probar(input [2:0] f3, input [1:0] ad, input [3:0] be_esp, input [31:0] wd_esp);
begin
    funct3 = f3;
    Adr = ad;
    #10;
    // Si BE debe ser cero, no importa WD porque no se escribe nada.
    if (BE == be_esp && (be_esp == 4'b0000 || WD == wd_esp))
        $display("OK    funct3=%b Adr=%b BE=%b WD=%h", f3, ad, BE, WD);
    else begin
        $display("ERROR funct3=%b Adr=%b BE=%b WD=%h (esperado BE=%b WD=%h)", f3, ad, BE, WD, be_esp, wd_esp);
        errores = errores + 1;
    end
end
endtask

initial begin
    $display("---- Prueba logica_bytes ----");
    WriteData = 32'h11223344;
    probar(3'b010, 2'b00, 4'b1111, 32'h11223344); // sw
    probar(3'b001, 2'b00, 4'b0011, 32'h33443344); // sh mitad baja
    probar(3'b001, 2'b10, 4'b1100, 32'h33443344); // sh mitad alta
    probar(3'b000, 2'b00, 4'b0001, 32'h44444444); // sb byte 0
    probar(3'b000, 2'b01, 4'b0010, 32'h44444444); // sb byte 1
    probar(3'b000, 2'b10, 4'b0100, 32'h44444444); // sb byte 2
    probar(3'b000, 2'b11, 4'b1000, 32'h44444444); // sb byte 3
    probar(3'b111, 2'b00, 4'b0000, 32'h00000000); // no es store
    $display("Pruebas terminadas, errores: %0d", errores);
    $finish;
end

endmodule
