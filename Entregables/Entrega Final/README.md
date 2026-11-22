# Integracion RV32I multiciclo

Los archivos `top.v` y `tb_top.v` siguen las conexiones de `14_top.md`.
El top solo tiene `clk` y `reset`; usa los otros 15 modulos de `Design_Sources`.
La memoria se instancia como `mem` y carga un programa en hexadecimal
(1024 palabras de 32 bits). El archivo se escoge con el parametro `MEMFILE`
del top; si no se indica otro, carga `programa.mem`, que es el programa
principal (el codigo C del enunciado). `programa_ejemplo.mem` es un programa de ejemplo.

## Vivado
1. Agregar los 16 archivos de `Design_Sources` como Design Sources.
2. Agregar los 17 archivos de `Simulation_Sources` como Simulation Sources.
3. Agregar `programa.mem` y `programa_ejemplo.mem` como Memory Initialization File (Add Sources).
   Si XSim no encuentra el archivo, copiarlo a su directorio de trabajo
   (normalmente `<proyecto>.sim/sim_1/behav/xsim/`) y volver a simular.
4. Seleccionar `top` como Design Top y el testbench a correr como Simulation Top
   (clic derecho > Set as Top). Antes de cambiar de testbench, cerrar la simulacion abierta.
5. Run Behavioral Simulation > Run All. Cada testbench termina solo con `$finish`.
6. Revisar la consola (al final sale `Pruebas terminadas, errores: 0`) y el dump en el directorio de trabajo.

## Programa en C
`programa.mem` es el codigo C del enunciado compilado con
`riscv32-unknown-elf-gcc` (36 instrucciones, una palabra de 32 bits por linea,
inicio en 0). Es el programa principal: el top lo carga si no se le indica otro.
Se corre con `tb_top.v`. El programa corre hasta que `main` termina con `ret`
(el PC vuelve a 0) y despues se genera `dump_memoria.txt`.
Esperado: 194 ciclos; memoria[FE0h]=62000000h (a='b'), memoria[FE4h]=0000C7DFh (r),
memoria[FE8h]=2 (i), memoria[FECh]=2 (b); sp=0 al salir de `main`.
Para otro programa compilado: agregar su `.mem`, poner su nombre en el parametro
`PROGRAMA` de `tb_top.v` y `VERIFICAR` en 0. Solo cambia el archivo que se
carga en la memoria; el procesador no se toca. El testbench para cuando el programa
vuelve con `ret` o queda en un salto a si mismo, y guarda el dump.
No usar `VERIFICAR_EJEMPLO=0` de `tb_top_ejemplo.v` para esto: corre una cantidad fija de
ciclos y, si el programa termina con `ret`, vuelve a empezar y el dump queda a medias.

## Programa de ejemplo
`programa_ejemplo.s` documenta un ejemplo de integracion, escrito a mano y distinto
al codigo C. Se ensamblo para RV32I sin instrucciones comprimidas, con inicio en 0,
y su hexadecimal esta en `programa_ejemplo.mem`. Se corre con `tb_top_ejemplo.v`,
que le pasa ese archivo al top con `MEMFILE`.
Se prueba ADDI, ANDI, SLLI, LW, SW, SB, LUI, JAL, JALR, BGE y BNE;
las ramas se toman y no se toman, y JALR recibe un destino impar.
Esperado: PC=78h en 107 ciclos; x3=2, x5=62h, x6=12346278h, x8=2, x10=7, x11=9,
x13=6ch, x14=1; memoria[400h]=2, memoria[404h]=12346278h. Se genera `dump_memoria_ejemplo.txt`.

## Validacion
Los 17 testbenches se ejecutaron con Icarus Verilog (`iverilog -g2005`) y todos
terminan con `errores: 0`. El dump del programa en C coincide con los valores del
codigo C (a='b', r=C7DFh, i=2, b=2) y con el de un simulador de referencia en
Python que ejecuta el mismo `programa.mem`.
