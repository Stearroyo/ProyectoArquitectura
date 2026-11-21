`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: tb_top
// Description:
//   Se prueba la integracion del procesador con programa.mem.
//   Estimulos: reloj de 10 ns, reset durante dos ciclos y ejecucion del programa.
//   Resultados: se comparan PC, registros y memoria con los valores esperados.
//   Se genera dump_memoria.txt para revisar la memoria completa.
//   Para otro programa, se ajusta VERIFICAR_EJEMPLO a 0; en ese caso solo se
//   ejecuta y se genera el dump, sin validar los resultados del ejemplo.
//////////////////////////////////////////////////////////////////////////////////
module tb_top;
    parameter VERIFICAR_EJEMPLO = 1;
    parameter CICLOS_MAX = 2000;
    reg clk, reset;
    integer errores, ciclos;

    top uut (.clk(clk), .reset(reset));
    always #5 clk = ~clk;

    task comprobar;
        input [8*48-1:0] nombre;
        input [31:0] obtenido, esperado;
        begin
            if (obtenido !== esperado) begin
                $display("ERROR %0s: obtenido=%08h esperado=%08h", nombre, obtenido, esperado);
                errores = errores + 1;
            end else begin
                $display("OK %0s: obtenido=%08h esperado=%08h", nombre, obtenido, esperado);
            end
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        errores = 0;
        ciclos = 0;
        // Se libera reset en el flanco de bajada, despues de dos flancos utiles.
        repeat (2) @(posedge clk);
        #1;
        if (VERIFICAR_EJEMPLO)
            comprobar("PC despues de reset", uut.PC, 32'h00000000);
        @(negedge clk);
        reset = 0;

        if (VERIFICAR_EJEMPLO) begin
            // Se espera el fin del programa de prueba, en Fetch, con limite.
            while ((ciclos < CICLOS_MAX) &&
                   ((uut.PC !== 32'h00000078) ||
                    (uut.uc.fsm_inst.estado !== 4'd0))) begin
                @(posedge clk);
                #1;
                ciclos = ciclos + 1;
            end
            if ((uut.PC !== 32'h00000078) ||
                (uut.uc.fsm_inst.estado !== 4'd0)) begin
                $display("ERROR: no se llego al final del ejemplo en %0d ciclos", ciclos);
                errores = errores + 1;
            end else begin
                $display("OK: fin del ejemplo en %0d ciclos", ciclos);
                comprobar("ciclos hasta fin del ejemplo", ciclos, 32'd107);
                // Se comprueba una vuelta del salto final (jal x0, halt).
                repeat (4) @(posedge clk);
                #1;
            end
            comprobar("PC final", uut.PC, 32'h00000078);
            comprobar("estado final Fetch", {28'b0, uut.uc.fsm_inst.estado}, 32'd0);
            comprobar("x0", uut.banco.REG[0], 32'h00000000);
            comprobar("x1: retorno JAL", uut.banco.REG[1], 32'h00000054);
            comprobar("x2: base datos", uut.banco.REG[2], 32'h00000400);
            comprobar("x3: ADDI, SLLI, ANDI", uut.banco.REG[3], 32'h00000002);
            comprobar("x4: LUI y ADDI", uut.banco.REG[4], 32'h12345678);
            comprobar("x5: byte b", uut.banco.REG[5], 32'h00000062);
            comprobar("x6: LW despues de SB", uut.banco.REG[6], 32'h12346278);
            comprobar("x7: LW despues de SW", uut.banco.REG[7], 32'h00000002);
            comprobar("x8: contador BNE", uut.banco.REG[8], 32'h00000002);
            comprobar("x9: limite", uut.banco.REG[9], 32'h00000002);
            comprobar("x10: BGE tomado y no tomado", uut.banco.REG[10], 32'h00000007);
            comprobar("x11: retorno correcto", uut.banco.REG[11], 32'h00000009);
            comprobar("x12: destino impar JALR", uut.banco.REG[12], 32'h00000055);
            comprobar("x13: retorno JALR", uut.banco.REG[13], 32'h0000006c);
            comprobar("x14: marca de fin", uut.banco.REG[14], 32'h00000001);
            comprobar("memoria 0x400", uut.mem.RAM[256], 32'h00000002);
            comprobar("memoria 0x404", uut.mem.RAM[257], 32'h12346278);
            $display("Pruebas terminadas, errores: %0d", errores);
        end else begin
            repeat (CICLOS_MAX) @(posedge clk);
            #1;
            $display("Programa propio: %0d ciclos ejecutados, PC=%08h", CICLOS_MAX, uut.PC);
            $display("Sin comparacion automatica: se debe revisar el dump y los registros.");
        end
        uut.mem.dump("dump_memoria.txt");
        $finish;
    end
endmodule
