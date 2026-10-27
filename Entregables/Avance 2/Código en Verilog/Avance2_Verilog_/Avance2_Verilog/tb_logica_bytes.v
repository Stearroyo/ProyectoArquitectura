`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Engineer:
//
// Create Date: 25.10.2026
// Design Name: Microarquitectura RV32I
// Module Name: tb_logica_bytes
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
// Description:
//   Objetivo de la prueba:
//     Revisar que logica_bytes saca el BE y el WD correctos para sw y para
//     sh en las dos mitades y sb en cada uno de los 4 bytes de la palabra.
//   Estimulos (en este orden, 10 ns cada uno). WriteData se deja fijo en
//   0x11223344 para que se vea facil de donde sale cada byte (el bajo es 44):
//     1. sw, Adr = 00
//     2. sh, Adr = 00   (mitad baja)
//     3. sh, Adr = 10   (mitad alta)
//     4. sb, Adr = 00
//     5. sb, Adr = 01
//     6. sb, Adr = 10
//     7. sb, Adr = 11   (como char a en una direccion que termina en 11)
//     8. funct3 = 111 (no es store)
//   Resultados esperados:
//     1. BE = 1111, WD = 11223344
//     2. BE = 0011, WD = 33443344
//     3. BE = 1100, WD = 33443344
//     4. BE = 0001, WD = 44444444
//     5. BE = 0010, WD = 44444444
//     6. BE = 0100, WD = 44444444
//     7. BE = 1000, WD = 44444444
//     8. BE = 0000
//     En la consola tienen que salir las 8 pruebas OK y 0 errores.
//
// Dependencies: logica_bytes.v
//
// Revision:
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

task probar(input [2:0] f3, input [1:0] ad, input [3:0] be_esp, input [31:0] wd_esp);
begin
    funct3 = f3;
    Adr = ad;
    #10;
    // si se espera BE = 0000 no se revisa WD, total no se escribe nada
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
