# Specs por archivo — Procesador RISC-V RV32I multiciclo

Cada archivo `.md` de esta carpeta es la especificación de **un archivo Verilog**. Dice qué es ese bloque en el diagrama, cuáles son sus entradas y salidas, qué debe hacer y qué debe probar su testbench.

Al inicio de cada spec está el prompt para la IA. Se copia el spec completo y la IA genera el `.v` y su testbench.

| Spec | Genera | Bloque del diagrama |
|---|---|---|
| 01_unidadsigno.md | unidadsigno.v, tbunidadsigno.v | Unidad de signo (Extend) |
| 02_logica_bytes.md | logica_bytes.v, tb_logica_bytes.v | Lógica de escritura por bytes |
| 03_extension_carga.md | extension_carga.v, tb_extension_carga.v | Extensión de carga |
| 04_memoria.md | memoria.v, tb_memoria.v | Memoria |
| 05_banco_registros.md | banco_registros.v, tb_banco_registros.v | Banco de registros |
| 06_alu.md | alu.v, tb_alu.v | ALU |
| 07_registro.md | registro.v, tb_registro.v | PC, OldPC, Instr, Data, A, WriteData, ALUOut |
| 08_muxes.md | mux2.v, mux3.v, mux4.v, tb_muxes.v | AdrSrc, ResultSrc, ALUSrcB, ALUSrcA |
| 09_instr_decoder.md | instr_decoder.v, tb_instr_decoder.v | Instr Decoder |
| 10_alu_decoder.md | alu_decoder.v, tb_alu_decoder.v | ALU Decoder |
| 11_fsm.md | fsm.v, tb_fsm.v | Main FSM |
| 12_pc_write_logic.md | pc_write_logic.v, tb_pc_write_logic.v | PC Write Logic |
| 13_unidad_control.md | unidad_control.v, tb_unidad_control.v | Unidad de control |
| 14_top.md | top.v, tb_top.v | Procesador completo |

**Orden sugerido:** de 01 a 14. Los módulos que unen a otros (13 y 14) van al final, porque necesitan que los demás ya existan.
