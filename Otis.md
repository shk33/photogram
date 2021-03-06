# Reporte de Programa: Sumador con display

<br>
<br>
<br>
### Asignatura: Arquitectura de Computadoras
### Profesor: Otilio Santos Aguilar
### Alumno: Miguel Eduardo Coronel Segovia
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>
<br>

## Propósito del Programa
Leer un número del puerto A entre el 0 y 7, luego sumarle dos y por último desplegar el resultado en un display de 7 segmentos conectado al puerto B.

## Tabla de Entradas y Salidas
| Entrada (A<sub>2</sub>, A<sub>1</sub>, A<sub>0</sub>)      | Salida(Hex)        | Salida (B<sub>7</sub>, B<sub>6</sub>, ... B<sub>1</sub>,B<sub>0</sub>) |
| ------------- |:-------------:|:-------------:|
| 000           | 0x24      | 0010 0100 |
| 001           | 0x30      | 0011 0000 |
| 010           | 0x19      | 0001 1001 |
| 011           | 0x12      | 0000 0010 |
| 100           | 0x02      | 0111 1101 |
| 101           | 0x38      | 0011 1000 |
| 110           | 0x00      | 0000 0000 |
| 111           | 0x10      | 0001 0000 |

<br>
<br>
<br>
<br>
<br>
## Código del Programa
``` Assembly 
  

    LIST P=18F4550              ; Usando un PIC18F4550
    RADIX  HEX                  ; Usando notación hexadecimal por defecto
;---------------------------------------------------------------------------------

    #include p18f4550.inc

; CONFIG1L
  CONFIG  PLLDIV = 5            ; PLL Prescaler Selection bits (Divide by 5 (20 MHz oscillator input))
  CONFIG  CPUDIV = OSC1_PLL2    ; System Clock Postscaler Selection bits ([Primary Oscillator Src: /1][96 MHz PLL Src: /2])
  CONFIG  USBDIV = 2            ; USB Clock Selection bit (used in Full-Speed USB mode only; UCFG:FSEN = 1) (USB clock source comes from the 96 MHz PLL divided by 2)

; CONFIG1H
  CONFIG  FOSC = HS             ; Oscillator Selection bits (HS oscillator (HS))
  CONFIG  FCMEN = ON            ; Fail-Safe Clock Monitor Enable bit (Fail-Safe Clock Monitor enabled)
  CONFIG  IESO = OFF            ; Internal/External Oscillator Switchover bit (Oscillator Switchover mode disabled)

; CONFIG2L
  CONFIG  PWRT = ON             ; Power-up Timer Enable bit (PWRT enabled)
  CONFIG  BOR = OFF             ; Brown-out Reset Enable bits (Brown-out Reset disabled in hardware and software)
  CONFIG  BORV = 0              ; Brown-out Reset Voltage bits (Maximum setting 4.59V)
  CONFIG  VREGEN = ON           ; USB Voltage Regulator Enable bit (USB voltage regulator enabled)

; CONFIG2H
  CONFIG  WDT = OFF             ; Watchdog Timer Enable bit (WDT disabled (control is placed on the SWDTEN bit))
  CONFIG  WDTPS = 1             ; Watchdog Timer Postscale Select bits (1:1)

; CONFIG3H
  CONFIG  CCP2MX = ON           ; CCP2 MUX bit (CCP2 input/output is multiplexed with RC1)
  CONFIG  PBADEN = OFF          ; PORTB A/D Enable bit (PORTB<4:0> pins are configured as digital I/O on Reset)
  CONFIG  LPT1OSC = OFF         ; Low-Power Timer 1 Oscillator Enable bit (Timer1 configured for higher power operation)
  CONFIG  MCLRE = ON            ; MCLR Pin Enable bit (MCLR pin enabled; RE3 input pin disabled)

; CONFIG4L
  CONFIG  STVREN = OFF          ; Stack Full/Underflow Reset Enable bit (Stack full/underflow will not cause Reset)
  CONFIG  LVP = OFF             ; Single-Supply ICSP Enable bit (Single-Supply ICSP disabled)
  CONFIG  ICPRT = OFF           ; Dedicated In-Circuit Debug/Programming Port (ICPORT) Enable bit (ICPORT disabled)
  CONFIG  XINST = OFF           ; Extended Instruction Set Enable bit (Instruction set extension and Indexed Addressing mode disabled (Legacy mode))

; CONFIG5L
  CONFIG  CP0 = OFF             ; Code Protection bit (Block 0 (000800-001FFFh) is not code-protected)
  CONFIG  CP1 = OFF             ; Code Protection bit (Block 1 (002000-003FFFh) is not code-protected)
  CONFIG  CP2 = OFF             ; Code Protection bit (Block 2 (004000-005FFFh) is not code-protected)
  CONFIG  CP3 = OFF             ; Code Protection bit (Block 3 (006000-007FFFh) is not code-protected)

; CONFIG5H
  CONFIG  CPB = OFF             ; Boot Block Code Protection bit (Boot block (000000-0007FFh) is not code-protected)
  CONFIG  CPD = OFF             ; Data EEPROM Code Protection bit (Data EEPROM is not code-protected)

; CONFIG6L
  CONFIG  WRT0 = OFF            ; Write Protection bit (Block 0 (000800-001FFFh) is not write-protected)
  CONFIG  WRT1 = OFF            ; Write Protection bit (Block 1 (002000-003FFFh) is not write-protected)
  CONFIG  WRT2 = OFF            ; Write Protection bit (Block 2 (004000-005FFFh) is not write-protected)
  CONFIG  WRT3 = OFF            ; Write Protection bit (Block 3 (006000-007FFFh) is not write-protected)

; CONFIG6H
  CONFIG  WRTC = OFF            ; Configuration Register Write Protection bit (Configuration registers (300000-3000FFh) are not write-protected)
  CONFIG  WRTB = OFF            ; Boot Block Write Protection bit (Boot block (000000-0007FFh) is not write-protected)
  CONFIG  WRTD = OFF            ; Data EEPROM Write Protection bit (Data EEPROM is not write-protected)

; CONFIG7L
  CONFIG  EBTR0 = OFF           ; Table Read Protection bit (Block 0 (000800-001FFFh) is not protected from table reads executed in other blocks)
  CONFIG  EBTR1 = OFF           ; Table Read Protection bit (Block 1 (002000-003FFFh) is not protected from table reads executed in other blocks)
  CONFIG  EBTR2 = OFF           ; Table Read Protection bit (Block 2 (004000-005FFFh) is not protected from table reads executed in other blocks)
  CONFIG  EBTR3 = OFF           ; Table Read Protection bit (Block 3 (006000-007FFFh) is not protected from table reads executed in other blocks)

; CONFIG7H
  CONFIG  EBTRB = OFF           ; Boot Block Table Read Protection bit (Boot block (000000-0007FFh) is not protected from table reads executed in other blocks)

;-------------------------------------------------------------------------------
    ORG 0x20            ; Comenzando el programa en la dirección 20h
    goto configuracion  ; Saltando a la etiqueta llamada configuracion
;--------------------------------------------------------------------------------
;Tabla para los numeros en el display ánodo común
;Salida por el puerto A
decoder:
  addwf PCL,F,0     ; PCL + W -> PCL
  retlw b'01111110' ; Representacion del numero 0 (No se usa)
  retlw b'00110000' ; Representacion del numero 1 (No se usa)
  retlw 0x5B        ; Representacion del numero 2
  retlw 0x4F        ; Representacion del Numero 3
  retlw 0x66        ; Representacion del Numero 4
  retlw 0x6D        ; Representacion del Numero 5
  retlw 0x7D        ; Representacion del Numero 6
  retlw 0x47        ; Representacion del Numero 7
  retlw 0x7F        ; Representacion del Numero 8
  retlw 0x6F        ; Representacion del Numero 9
;--------------------------------------------------------------------------------
;Configuro la puerta A como entrada
configuracion:
    movlw  b'00000111'  ; o .255 o d'255'en vez de 0xff para binario b'11111111'
    movwf  TRISA,0      ; Configurando el puerto A como entrada 
    movlw  0x0F         ; Cargo a W el valor 0Fh
    movwf  ADCON1,0     ; Muevo 15 al registro ADCON1 (para modificarlo como digital)
    movlw  0x07         ; Cargo a W el valor 07h
    movwf  CMCON,0      ; Se desactiva el comparador analogico 
;--------------------------------------------------------------------------------
;Configuro la Puerta B como salida
    movlw  b'00000000'  ; Cargo a W el valor 07h
    movwf  TRISB,0      ; Se configura el puerto B como entrada
;---------------------------------------------------------------------------------
;Programa
    backup equ 0x00     ; Declarando una variable llamada backup y poniendola en la direccion 00h
    clrf backup         ; Seteando 0 a la variable backup
main:
    movf   PORTA,W,0    ; Leemos puerto A PORTA -> W
    andlw  b'00000111'  ; filtro
    addlw .2            ; W + 2 -> W
    movwf backup,0      ; W -> backup

    call display        ; Llamando ala función display

    movwf LATB,0        ; W -> LATB
    goto main           ; Ciclando infinitamente el programa

;--------------------------------------------------------------------------------
display:
    rlncf backup,W,0    ; 2(backup) -> W
    call decoder        ; Llama a la función decoder
    return              ; return
    
END

```

## Lógica del Programa

Primero le decimos al programa que inicie en la dirección 20h para evitar escribir
en los vectores de interrupciones.
Luego le decimos que salte a la etiqueta 'configuracion'

``` Assembly 
  ORG 0x20            ; Comenzando el programa en la dirección 20h
  goto configuracion  ; Saltando a la etiqueta llamada configuracion
```

En la etiqueta 'configuracion' hacemos lo siguiente:
* Configuramos el puerto A como entrada 
* Desactivamos el comparador analógico 

``` Assembly 
configuracion:
    movlw  b'00000111'  ; o .255 o d'255'en vez de 0xff para binario b'11111111'
    movwf  TRISA,0      ; Configurando el puerto A como entrada 
    movlw  0x0F         ; Cargo a W el valor 0Fh
    movwf  ADCON1,0     ; Muevo 15 al registro ADCON1 (para modificarlo como digital)
    movlw  0x07         ; Cargo a W el valor 07h
    movwf  CMCON,0      ; Se desactiva el comparador analogico 
```

* Configuramos el puerto B como salida

``` Assembly 
;Configuro la Puerta B como salida
    movlw  b'00000000'  ; Cargo a W el valor 07h
    movwf  TRISB,0      ; Se configura el puerto B como entrada
```
* Declaramos una variable llamada backup y se inicializa con 0

``` Assembly 
    backup equ 0x00     ; Declarando una variable llamada backup y poniendola en la direccion 00h
    clrf backup         ; Seteando 0 a la variable backup
```

* Luego nuestro programa llega hasta la etiqueta 'main'.
En ella primero leemos por el puerto A y colocamos el valor en W

``` Assembly 
main:
    movf   PORTA,W,0    ; Leemos puerto A PORTA -> W
```

Luego aplicamos un filtro a W con una operación 'AND', porque sólo nos interesa los tres primeros bits menos significativos

``` Assembly 
    andlw  b'00000111'  ; filtro
```

Luego al valor que le acabamos de aplicar el filtro le sumamos dos.

``` Assembly 
  addlw .2            ; W + 2 -> W
```
<br>
<br>
Luego el valor que está en W lo guardamos en una variable de respaldo llamado 'backup'

``` Assembly 
  movwf backup,0      ; W -> backup
```

LLamamos a la función 'display'

``` Assembly 
  call display        ; Llamando a la función display
```

En la función 'display' hacemos lo siguente:
* Multiplicamos el valor de W por 2, usando una rotación, la razón de esto se debe a que el PC aumenta de dos en dos porque las instrucciones son de 2 Bytes
* Luego se llama a la función 'decoder'

``` Assembly
  display:
    rlncf backup,W,0    ; 2(backup) -> W
    call decoder        ; Llama a la función decoder
    return 
```

En la función 'decoder' hacemos lo siguente:
* Le sumamos al PCL el valor que se encuetra en W y el resultado lo dejamos en PCL, al realizar esta suma el PC salta a la instruccion correspondiente al número que queremos desplegar.
* La respresentación del número es por ánodo común, es decir, el valor 0 prende un segmento y el valor 1 apaga un segmento.
* La instrucción 'retlw' regresa de una función y carga el valor que le indicamos a W.

``` Assembly 
  decoder:
  addwf PCL,F,0     ; PCL + W -> PCL
  retlw b'01111110' ; Representacion del numero 0 (No se usa)
  retlw b'00110000' ; Representacion del numero 1 (No se usa)
  retlw 0x5B        ; Representacion del numero 2
  retlw 0x4F        ; Representacion del Numero 3
  retlw 0x66        ; Representacion del Numero 4
  retlw 0x6D        ; Representacion del Numero 5
  retlw 0x7D        ; Representacion del Numero 6
  retlw 0x47        ; Representacion del Numero 7
  retlw 0x7F        ; Representacion del Numero 8
  retlw 0x6F        ; Representacion del Numero 9
```

Regresando en la etiqueta 'main', sacamos el valor de W por el puerto B

``` Assembly 
  movwf LATB,0        ; W -> LATB
  goto main           ; Ciclando infinitamente el programa
```

Finalmente hacemos un 'goto main' para ciclar infinítamente el programa y así siempre escuchar por el puerto A.

``` Assembly 
  goto main           ; Ciclando infinítamente el programa
```