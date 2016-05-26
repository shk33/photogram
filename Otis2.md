# Reporte de Programa: Comunicacion RS232

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
Utilizar la Comunicación RS232 para prender o apagar el display de 7 segmentos.

## Tabla de Entradas y Salidas
En un inicio el display de 7 segmentos se encuentra encendido.

| Entrada (Teclado)       | Estado del Display        | 
| ------------- |:-------------:|
| Se presiona cualquier tecla           | Apagado      |
| Se presiona cualquier Tecla           | Encendido    |

## Cálculo del valor de BGR
Datos:
La tarjeta tiene un cristal de 20Mhz. (FOSC = 20,000,000)

La comunicación es en modo asíncrono y con 8 bits.

Desired Baud Rate = 9,600

Bits de Configuración

| SYNC | BRG16       | BRGH  | BAUD RATE FORMULA | Fórmula Despejada para n
| ------------- |:-------------:|:-------------:| :-------------:| :-------------:|
| 0 | 0 | 1 | FOSC /[16 (n + 1)] = BAUD RATE | n = ((FOSC/BAUD RATE)/16) -1 

<br>
<br>
<br>
<br>

n = ((FOSC/BAUD RATE)/16) -1 
n = ((20,000,000/9,600)/16) -1  
n = 129

Calculated Baud Rate con 129 = 20,000,000/(16(129+1)) = 9,765

Error = (Calculated Baud Rate – Desired Baud Rate)/Desired Baud Rate = (9,765 - 9,600)/9600 = 1.71 % de Error

El valor de BGR calculado es de 129, que nos da un BAUD RATE de 9,765, con un error de 1.71%

## Código del Programa
``` Assembly 
  
list p=18f4550    ;list directive to define processor
#include <p18f4550.inc> ;processor specific definitions
    
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

;----------------------------------------------------------------------------
;Constantes

SPBRG_VAL EQU .129    ;Pone el baud rate a 9600 para un cristal de  20Mhz

;----------------------------------------------------------------------------
;Definición de Bits

GotNewData  EQU 0   ;bit que indica si se recibe un nuevo dato

;----------------------------------------------------------------------------
;Variables

    CBLOCK  0x000
    Flags             ;byte para guardar las banderas
    Port_output       ;byte para enviar al puerto D
    ENDC

;----------------------------------------------------------------------------

    ORG     0x0000    ;Empieza en la direciión 0x00

ResetCode:  bra Main    ;Salta al inicio del programa

;----------------------------------------------------------------------------
;La rutina principal checa si se ha recibido un nuevo dato, en caso de que suceda
;se llama a la función CheckReceivedData

Main:   
    rcall   SetupSerial ;Configura el puerto Serial
    rcall   SetUpPort   ;Configura el puerto de Salida
    rcall   InitVar     ;Inicializa variables
    rcall   SendToPort  ;Enviamos un valor por el puerto D

MainLoop: 
    rcall  ReceiveSerial     ;Llama a la función que checa si se recibió un nuevo dato
    btfsc  Flags,GotNewData  ;Checa el bit que indica si se recibio un nuevo dato
    rcall  CheckReceivedData ;Si se recibe un nuevo dato entonces se llama a CheckReceivedData
    bcf    Flags,GotNewData  ;Volvemos a colocar en cero el bit que indica si recibimos un nuevo dato

    rcall  SendToPort       ;Mandamos por el puerto D

    bra    MainLoop            ;Regresa a MainLoop

;----------------------------------------------------------------------------
;Verifica si se recibió un dato, si no entonces se hace return

ReceiveSerial:  
    btfss PIR1,RCIF ;Checa si se recibio un dato, verificando el bit RCIF
    return          ;return si no hay dato recibido

    movf  RCREG,W        ;Obtenemos el dato del Registro EUSART Recepción
    bsf Flags,GotNewData ;Indicamos en el bit GotNewData que se recibió un dato

    return

;----------------------------------------------------------------------------
;Configura el puerto Serial

SetupSerial:  
    movlw 0xc0      ;configura los bits TRIS para TX y RX
    iorwf TRISC,F   ;Lo movemos a TRISC
    movlw SPBRG_VAL ;Configura el valor de SPBRG
    movwf SPBRG     ;Movemos el valor al registro SPBRG
    movlw 0x25      ;High baud rate (0010 0101)
    movwf TXSTA     ;Activamos que sea a alta frecuencia
    movlw 0x90      ;Activamos el puerto serial
    movwf RCSTA     
    movlw 0x00      ;Configuramos el registro BAUDCON
    movwf BAUDCON
    clrf  Flags     ;Colocamos todas las banderas en cero
    return
    

;----------------------------------------------------------------------------
;-----Configuro la Puerta D como salida
SetUpPort:
    movlw  0x0f
    movwf  0xC1,0        ;Muevo 15 al registro ADCON1 (para modificarlo como digital)
    movlw  0x07
    movwf  0xB4,0        ;Se desactiva el comparador analogico 
    movlw  b'00000000'
    movwf  TRISD,0       ;Se configura el puerto como SALIDA
    return

SendToPort:
    movf  Port_output, W  ;Recuperamos el valor que debemos sacar del byte Port_output
    movwf LATD,0          ;W -> LATB, Lo sacamos por el puerto D
    return

CheckReceivedData:
    movf  Port_output, W, 0   ;Port_output -> W, Carga el contenido de Port_output a W 
    sublw 0x00                ;Checa si es 0, 0 = Apagar Display else Prende display
    bz    DisplayOff          ;Si es cero mueve a etiqueta DisplayOff
    bra   DisplayOn           ;Si es distinto de cero mueve a etiqueta DisplayOn

DisplayOn:
    movlw  0x00            ;Movemos el valor 00 que indica todos los segmentos prendidos del Display
    movwf  Port_output, 0  ; Variable de Salida en la direccion Port_output
    return
    
DisplayOff:
    movlw  0xFF            ; Movemos el valor FF que indica todos los segmentos apagados del Display
    movwf  Port_output, 0  ; Variable de Salida en la direccion Port_output
    return 
    
InitVar:        
    movlw  0x00             ; Movemos el valor 00 que indica todos los segmentos prendidos del Display
    movwf  Port_output, 0   ; Variable de Salida en Port_output
    return

;----------------------------------------------------------------------------

    END

```