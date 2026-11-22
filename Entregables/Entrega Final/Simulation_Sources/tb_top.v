`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Instituto Tecnologico de Costa Rica
// Module Name: tb_top
// Project Name: Proyecto Arquitectura MT-7003
// Target Devices: xc7a35tcpg236-1
// Tool Versions: Vivado 2025.2
//
// Que se prueba:
// Objetivo: correr el codigo C del enunciado en el procesador completo y
// guardar toda la memoria en un archivo (el dump). El codigo ya compilado
// esta en programa.mem (36 instrucciones).
// Pruebas: reloj de 10 ns y reset durante dos ciclos. Despues el programa
// corre solo. main termina con ret, que salta a la direccion guardada en ra;
// como ra empieza en 0, el PC vuelve a 0 y asi se sabe que ya termino.
// Si el programa no termina antes de CICLOS_MAX ciclos, se para igual.
// Al final se guarda dump_memoria.txt.
// Esperado: el programa termina en 194 ciclos. Las variables de main quedan
// en la pila, al final de la memoria:
//   0xFE0 = 62000000 -> char a = 'b' (esta en el byte 0xFE3)
//   0xFE4 = 0000C7DF -> int *r
//   0xFE8 = 00000002 -> int i, el for termina con i = 2
//   0xFEC = 00000002 -> int b = (33 << 1) & 0xF = 2
// Ademas sp (x2) vuelve a 0 al salir de main. Se esperan 0 errores.
// Para correr otro programa: en PROGRAMA se pone el nombre del nuevo .mem y
// VERIFICAR se pone en 0. Asi solo corre hasta que termina y guarda el dump,
// sin revisar los valores de arriba (esos son solo del codigo C).
//////////////////////////////////////////////////////////////////////////////////
module tb_top;
    parameter PROGRAMA = "programa.mem";  // lo que se carga en la memoria
    parameter VERIFICAR = 1;    // 1 revisa los resultados del codigo C, 0 no
    parameter CICLOS_MAX = 10000;

    reg clk, reset;
    integer errores, ciclos;
    reg bucle;            // se pone en 1 si el programa se queda saltando en el mismo lugar
    reg [31:0] pc_fetch;  // direccion de la ultima instruccion que se busco

    // El procesador completo. Lo unico que cambia es el programa que carga.
    top #(.MEMFILE(PROGRAMA)) uut (.clk(clk), .reset(reset));
    always #5 clk = ~clk;

    // Compara un dato con el esperado. Si no coincide, suma un error.
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
        bucle = 0;
        pc_fetch = 32'hFFFFFFFF;
        $display("---- Procesador corriendo %0s ----", PROGRAMA);

        // Dos ciclos con reset para que todo empiece en cero.
        @(negedge clk);
        @(negedge clk);
        reset = 0;

        // Al principio el PC esta en 0; se espera a que avance.
        while (uut.PC == 0 && ciclos < CICLOS_MAX) begin
            @(negedge clk);
            ciclos = ciclos + 1;
        end

        // Ahora se espera el final. Hay dos formas de terminar:
        // con ret el PC regresa a 0, y con un salto a si mismo (j .) se busca
        // la misma instruccion dos veces seguidas.
        while (uut.PC != 0 && !bucle && ciclos < CICLOS_MAX) begin
            @(negedge clk);
            ciclos = ciclos + 1;
            if (uut.uc.fsm_inst.estado == 4'd0) begin   // estado Fetch
                if (uut.PC == pc_fetch)
                    bucle = 1;
                pc_fetch = uut.PC;
            end
        end

        if (ciclos >= CICLOS_MAX) begin
            $display("ERROR: el programa no termino en %0d ciclos", CICLOS_MAX);
            errores = errores + 1;
        end else if (bucle)
            $display("El programa termino en un salto a si mismo (PC=%08h), %0d ciclos", uut.PC, ciclos);
        else
            $display("El programa termino con ret en %0d ciclos", ciclos);

        // Se guarda toda la memoria, que es lo que pide el enunciado.
        uut.mem.dump("dump_memoria.txt");
        $display("Dump guardado en dump_memoria.txt");

        if (VERIFICAR) begin
            comprobar("ciclos del programa", ciclos, 32'd194);
            // Las variables de main, en la pila.
            comprobar("Mem[FE0]: char a = 'b'", uut.mem.RAM[32'hFE0 >> 2], 32'h62000000);
            comprobar("Mem[FE4]: int *r", uut.mem.RAM[32'hFE4 >> 2], 32'h0000C7DF);
            comprobar("Mem[FE8]: int i", uut.mem.RAM[32'hFE8 >> 2], 32'h00000002);
            comprobar("Mem[FEC]: int b", uut.mem.RAM[32'hFEC >> 2], 32'h00000002);
            // al salir de main la pila se devuelve
            comprobar("sp al final", uut.banco.REG[2], 32'h00000000);
        end else
            $display("VERIFICAR=0: no se revisan valores, hay que mirar el dump.");

        $display("Pruebas terminadas, errores: %0d", errores);
        $finish;
    end
endmodule
