# Spec — `memoria.v`

> **Prompt para la IA:** Crea el archivo Verilog y su testbench siguiendo exactamente esta especificación. No agregues puertos ni cambies nombres.

## Qué es en el diagrama
Es la **memoria unificada**: guarda las instrucciones y los datos. Su dirección viene del mux **AdrSrc**; **WE** es la señal **MemWrite** de la FSM; **BE** y **WD** vienen de la lógica de escritura por bytes. **ReadData** va al registro **Instr** y al bloque **Extensión de carga**.

## Entradas y salidas
| Señal | Dir. | Ancho | Descripción |
|---|---|---|---|
| `MEMFILE` | parámetro | texto | Archivo hex del programa; por defecto "" (no carga) |
| `clk` | entrada | 1 | Reloj |
| `WE` | entrada | 1 | Permiso de escritura |
| `BE` | entrada | [3:0] | Bytes a escribir |
| `Adr` | entrada | [31:0] | Dirección en bytes |
| `WD` | entrada | [31:0] | Dato a escribir |
| `ReadData` | salida | [31:0] | Palabra leída |

## Qué debe hacer
- 1024 palabras de 32 bits (`reg [31:0] RAM [0:1023]`), es decir 4 KB, direcciones 0x000 a 0xFFF.
- Al inicio (`initial`): pone todas las palabras en 0 y, si MEMFILE no es "", carga el archivo con `$readmemh`.
- Lectura combinacional: `ReadData = RAM[Adr[11:2]]`.
- Escritura en el flanco de subida: si WE = 1, para cada byte n (0 a 3) con BE[n] = 1 se copia el byte n de WD al byte n de `RAM[Adr[11:2]]`. Los demás bytes se quedan igual.
- Task `dump(archivo)`, solo para simulación (entre `synthesis translate_off/on`): crea el archivo, escribe la línea `Direccion de memoria    Valor en hexadecimal` y luego una línea por palabra: `0x<dirección en bytes, 8 dígitos hex>              0x<valor, 8 dígitos hex>`.

## Testbench
Archivo `tb_memoria.v`. Reloj de 10 ns. Una task `escribir(dir, BE, dato)` pone las entradas en el flanco de bajada con WE = 1 y lo baja en el siguiente flanco de bajada. Una task `leer(dir, esperado)` pone WE = 0, espera 1 ns y compara.

1. Leer 0x000 → 00000000 y 0x004 → 00000000.
2. Escribir 11223344 en 0x100 con BE 1111 → leer 11223344.
3. Escribir 62626262 en 0x200 (BE 0001) → 00000062; en 0x201 (BE 0010) → 00006262; en 0x202 (BE 0100) → 00626262; en 0x203 (BE 1000) → 62626262.
4. Con WE = 0, poner BE 1111 y WD FFFFFFFF en 0x100 y pasar un flanco → sigue 11223344.
5. Llamar `uut.dump("dump_memoria.txt")`.

## Reglas para el código
- Verilog 2005, para Vivado 2025.2 (device xc7a35tcpg236-1).
- Un módulo por archivo; el archivo se llama igual que el módulo.
- Usar exactamente los nombres de módulo y de señales de este documento, porque son los del diagrama.
- Lógica combinacional con `always @(*)` y `=`; lógica secuencial con `always @(posedge clk)` y `<=`.
- Todo `case` combinacional lleva `default` y todas las salidas se asignan en todos los casos (sin latches).
- Encabezado al inicio con: nombre del módulo, descripción, entradas y salidas.
- Comentarios en español, cortos y en tercera persona ("se usa", "se calcula"), como los escribiría una persona.
- El testbench es autoverificable: usa una task que compara la salida con el valor esperado, imprime `OK` o `ERROR` con los valores, cuenta los errores y al final imprime `Pruebas terminadas, errores: N` y hace `$finish`. La instancia del módulo se llama `uut`.
