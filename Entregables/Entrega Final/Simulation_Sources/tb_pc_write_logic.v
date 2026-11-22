`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Module Name: tb_pc_write_logic
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
//
// Que se prueba:
// Objetivo: revisar cuando se permite cambiar el PC.
// Pruebas: cada 10 ns se cambian PCUpdate, Branch, funct3 y Z, N, V, C.
// Se prueban los seis tipos de salto y los codigos que no se usan.
// Esperado: PCUpdate=1 siempre da permiso. Si PCUpdate=0, solo da permiso
// cuando Branch=1 y se cumple la condicion del salto. Son 19 pruebas;
// al final se esperan 0 errores.
//
//   Dependencias: pc_write_logic.v.
//////////////////////////////////////////////////////////////////////////////////

module tb_pc_write_logic;
reg PCUpdate, Branch;
reg [2:0] funct3;
reg Z, N, V, C;
wire PCWrite;
integer errores = 0;

pc_write_logic uut (
    .PCUpdate(PCUpdate), .Branch(Branch), .funct3(funct3),
    .Z(Z), .N(N), .V(V), .C(C), .PCWrite(PCWrite)
);

// Pone los datos de una prueba, espera 10 ns y revisa la salida.
task revisar;
    input p, b;
    input [2:0] f3;
    input z_in, n_in, v_in, c_in, esperado;
    begin
        PCUpdate = p; Branch = b; funct3 = f3;
        Z = z_in; N = n_in; V = v_in; C = c_in;
        #10;
        if (PCWrite === esperado)
            $display("OK PCUpdate=%b Branch=%b funct3=%b ZNVC=%b PCWrite=%b esperado=%b", PCUpdate, Branch, funct3, {Z,N,V,C}, PCWrite, esperado);
        else begin
            $display("ERROR PCUpdate=%b Branch=%b funct3=%b ZNVC=%b PCWrite=%b esperado=%b", PCUpdate, Branch, funct3, {Z,N,V,C}, PCWrite, esperado);
            errores = errores + 1;
        end
    end
endtask

initial begin
    $display("---- Prueba PC Write Logic ----");
    revisar(1, 0, 3'b010, 0, 1, 0, 0, 1);
    revisar(0, 0, 3'b001, 0, 0, 0, 0, 0);
    revisar(0, 1, 3'b001, 0, 0, 0, 0, 1);
    revisar(0, 1, 3'b001, 1, 0, 0, 1, 0);
    revisar(0, 1, 3'b101, 0, 0, 0, 1, 1);
    revisar(0, 1, 3'b101, 0, 1, 0, 0, 0);
    revisar(0, 1, 3'b101, 0, 1, 1, 1, 1);
    revisar(0, 1, 3'b000, 1, 0, 0, 1, 1);
    revisar(0, 1, 3'b000, 0, 0, 0, 0, 0);
    revisar(0, 1, 3'b100, 0, 1, 0, 0, 1);
    revisar(0, 1, 3'b100, 0, 1, 1, 1, 0);
    revisar(0, 1, 3'b110, 0, 0, 0, 0, 1);
    revisar(0, 1, 3'b110, 0, 0, 0, 1, 0);
    revisar(0, 1, 3'b111, 0, 0, 0, 1, 1);
    revisar(0, 1, 3'b111, 0, 0, 0, 0, 0);
    revisar(0, 1, 3'b010, 0, 0, 0, 0, 0);
    revisar(0, 1, 3'b101, 0, 0, 1, 0, 0);
    revisar(1, 1, 3'b001, 1, 0, 0, 0, 1);
    revisar(0, 1, 3'b011, 1, 1, 1, 1, 0);
    $display("Pruebas terminadas, errores: %0d", errores);
    $finish;
end
endmodule
