`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Engineer:
// Create Date: 25.10.2026
// Design Name: Microarquitectura RV32I
// Module Name: logica_bytes
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
//
// Que hace:
// La memoria guarda palabras de 4 bytes, pero a veces solo queremos cambiar
// uno o dos bytes. Por ejemplo, SB guarda un char del programa C.
// funct3 dice cuantos bytes: 010 SW (4), 001 SH (2), 000 SB (1).
// Adr son los 2 bits bajos de la direccion: indican donde cae el dato.
// WriteData trae rs2. WD es el dato preparado para escribir en memoria.
// BE tiene un bit por cada byte: un 1 permite cambiar ese byte.
// Se repite el byte de SB o la media palabra de SH en WD; BE elige la parte.
// El programa usa SW y SB; tambien se deja SH para direcciones pares.
//
// Dependencies: ninguna
// Revision 0.01 - File Created (Avance 2)
// Revision 0.02 - Nombres de modulo y puertos iguales a los del diagrama
// Revision 0.03 - Se agrega sh, que tambien aparece en el bloque del diagrama
//////////////////////////////////////////////////////////////////////////////////

//lógica_bytes: decide qué bytes de memoria se escriben en un sw,sh o sb
//la memoria guarda palabras de 4 bytes pero no sabe si es sw,sh o sb. lógica_bytes está a la par de la memoria porque le dice qué bytes puede escribir
//sin este bloque, un sb borraría los bytes de al lado

//cables del bloque
module logica_bytes(
    input      [2:0]  funct3,//tipo de guardado y: ¿cuántos bytes se guardan?
    input      [1:0]  Adr,//¿en qué posición?
    input      [31:0] WriteData,//¿qué valor guarda?
    output reg [3:0]  BE,//salida: le dice a la memoria dónde escribir el valor
    output reg [31:0] WD //salida: le dice a la memoria qué valor escribir
    );

always @(*) begin
    case (funct3)//funct3 me dice qué tipo de guardado es (sb, sh, sw)
        // SW: permite escribir los 4 bytes.
        3'b010: begin
            BE = 4'b1111;
            WD = WriteData;
        end
        // SH: escribe 2 bytes. En una direccion par, Adr[1] elige la mitad.
        3'b001: begin
            BE = Adr[1] ? 4'b1100 : 4'b0011;
            WD = {2{WriteData[15:0]}};
        end
        // SB: mueve el 1 a la posicion del unico byte que se quiere cambiar.
        3'b000: begin
            BE = 4'b0001 << Adr;
            WD = {4{WriteData[7:0]}};
        end
        // Si el codigo no se reconoce, no se permite escribir ningun byte.
        default: begin
            BE = 4'b0000;
            WD = WriteData;
        end
    endcase
end

endmodule
