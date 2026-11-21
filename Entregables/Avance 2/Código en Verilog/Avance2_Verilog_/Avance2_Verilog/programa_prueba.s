# Programa de integracion escrito a mano (no es el C compilado del profesor).
# Inicio en 0x0; datos en 0x400. Solo usa instrucciones del proyecto.
# Se desactiva la compresion y se evita el uso de pseudoinstrucciones.
.option norvc
.text
.globl _start
_start:
    addi x2, x0, 1024      # 00: base de datos
    addi x3, x0, 33        # 04
    slli x3, x3, 1         # 08: 66
    andi x3, x3, 15        # 0c: 2
    sw   x3, 0(x2)         # 10: memoria[400] = 2
    lui  x4, 0x12345       # 14
    addi x4, x4, 0x678     # 18: 12345678
    sw   x4, 4(x2)         # 1c
    addi x5, x0, 98        # 20: 'b'
    sb   x5, 5(x2)         # 24: memoria[404] = 12346278
    lw   x6, 4(x2)         # 28
    lw   x7, 0(x2)         # 2c
    addi x8, x0, 0         # 30
    addi x9, x0, 2         # 34
loop:
    addi x8, x8, 1         # 38
    bne  x8, x9, loop      # 3c: tomado y luego no tomado
    bge  x8, x9, skip      # 40: tomado por igualdad
    addi x10, x0, 99       # 44: no se debe ejecutar
skip:
    bge  x0, x8, fail      # 48: no tomado
    addi x10, x0, 7        # 4c
    jal  x1, sub           # 50: retorno = 54
    addi x11, x0, 9        # 54
    jal  x0, done          # 58
fail:
    addi x10, x0, -1       # 5c
    jal  x0, done          # 60
sub:
    addi x12, x1, 1        # 64: destino impar 55
    jalr x13, 0(x12)       # 68: PC = 54, x13 = 6c
    addi x10, x0, -2       # 6c: no se debe ejecutar
    jal  x0, done          # 70
 done:
    addi x14, x0, 1        # 74: marca de finalizacion
halt:
    jal  x0, halt          # 78: bucle de fin
