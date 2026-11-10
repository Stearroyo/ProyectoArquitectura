# Spec — `pc_write_logic.v`

> **Prompt para la IA:** Crea el archivo Verilog y su testbench siguiendo exactamente esta especificación. No agregues puertos ni cambies nombres.

## Qué es en el diagrama
Es el bloque **PC Write Logic** del diagrama, abajo a la izquierda: "PCUpdate OR (Branch AND Cond)". Recibe **PCUpdate** y **Branch** de la unidad de control, y **funct3** y las banderas **Z, N, V, C** de la ALU. Su salida **PCWrite** habilita el registro **PC**.

## Entradas y salidas
| Señal | Dir. | Ancho | Descripción |
|---|---|---|---|
| `PCUpdate` | entrada | 1 | De la FSM: actualizar el PC siempre |
| `Branch` | entrada | 1 | De la FSM: es un salto condicional |
| `funct3` | entrada | [2:0] | Instr[14:12]: tipo de branch |
| `Z`, `N`, `V`, `C` | entrada | 1 cada una | Banderas de la ALU |
| `PCWrite` | salida | 1 | Habilitación del registro PC |

## Qué debe hacer
Bloque combinacional. Primero se calcula la condición `Cond` según `funct3`:

| funct3 | Branch | Cond (salta si…) |
|---|---|---|
| 000 | beq | Z |
| 001 | bne | NOT Z |
| 100 | blt | N XOR V |
| 101 | bge | NOT (N XOR V) |
| 110 | bltu | NOT C |
| 111 | bgeu | C |
| otro | — | 0 |

Luego: `PCWrite = PCUpdate OR (Branch AND Cond)`.

- El programa solo usa bne y bge; los demás se incluyen porque el bloque recibe las 4 banderas, incluida C.

## Testbench
Archivo `tb_pc_write_logic.v`. Pruebas de 10 ns:
1. PCUpdate = 1, Branch = 0 → PCWrite = 1 (sin importar las banderas).
2. PCUpdate = 0, Branch = 0 → PCWrite = 0.
3. Branch = 1 con bne: Z = 0 → 1; Z = 1 → 0.
4. Branch = 1 con bge: N = 0, V = 0 → 1; N = 1, V = 0 → 0; N = 1, V = 1 → 1.
5. Branch = 1 con beq, blt, bltu y bgeu: un caso que salta y uno que no, para cada uno.
6. Branch = 1 con funct3 = 010 → 0.

## Reglas para el código
- Verilog 2005, para Vivado 2025.2 (device xc7a35tcpg236-1).
- Un módulo por archivo; el archivo se llama igual que el módulo.
- Usar exactamente los nombres de módulo y de señales de este documento, porque son los del diagrama.
- Lógica combinacional con `always @(*)` y `=`; lógica secuencial con `always @(posedge clk)` y `<=`.
- Todo `case` combinacional lleva `default` y todas las salidas se asignan en todos los casos (sin latches).
- Encabezado al inicio con: nombre del módulo, descripción, entradas y salidas.
- Comentarios en español, cortos y en tercera persona ("se usa", "se calcula"), como los escribiría una persona.
- El testbench es autoverificable: usa una task que compara la salida con el valor esperado, imprime `OK` o `ERROR` con los valores, cuenta los errores y al final imprime `Pruebas terminadas, errores: N` y hace `$finish`. La instancia del módulo se llama `uut`.
