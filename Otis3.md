# Reporte de Programa: Lector de Temperatura

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
Este programa lee la temperatura del Sensor DS18B20 a través del Puerto D en el Pin 0, dicha temperatura se manda a través del puerto serial, este puerto a su vez está conectado a una tarjeta de red la cual manda el dato de la temperatura a una red. El dato que se encuentra en la red puede ser leído creando un socket a la dirección IP de la tarjeta de red.
 
## Características usadas del PIC18F4550
* Uso del puerto D como entrada y como salida para comunicarse con la única línea del sensor DS18B20
* Manejo de Interrupciones con el módulo Timer Modulo 0
* Transmisión por el puerto serial

## Configuración de las interrupciones para el manejo TMR0
Se necesita un contador de tiempo para lograr hacer las esperas de tiempo que el sensor DS18B20 requiere.

En las inicializaciones de nuestro código, al principio desactivamos todas las interrupciones.

``` Assembly
    CLRF  INTCON      ;**Desactivo todas las interrupciones al inicio del programa**
```

Luego configuramos el Timer 0 con las siguientes características:
* Habilitamos el Timer0
* Configuramos el Timer0 como un contador de 8 bits
* Colocamos el valor del Pre-escalador del Timer0 a 1:4

``` Assembly
    MOVLW   b'11000001' ;**Configuro el Time Module0
    MOVWF   T0CON
```

A lo largo de nuestro programa usaremos la función 'RETARD', la cual nos permite esperar el tiempo que se le cargue al registro TMR0, esta rutina se encarga de habilitar las interrupciones configurando el registro INTCON, esta rutina acaba cuando el Bit 0 del registro BAND está en 1, al final de la rutina se desactivan de nuevo las interrupciones.

``` Assembly 
  RETARD:
    MOVWF TMR0    ;**Cargo TMR0 con el valor de W**
    MOVLW B'10100000' ;**Habilitar Bits de Interrupciones t de TMR0
    MOVWF INTCON    ;**Muevo el byte de configuración a INTCON**
    TIMEOVER: 
      BTFSS BAND, 0 ;**Pregunto si se desbordó TMR0 (terminó el retardo)**
      GOTO  TIMEOVER  ;**Si no, vuelve a preguntar**
      BCF BAND, 0 ;**Coloco la bandera en 0**
      CLRF  INTCON    ;**Desactivo interrupción por TMR0**
      RETLW 0
```

El Registro BAND es un registro que se definió al principio del programa.

``` Assembly
  BAND  EQU 0X26  ;**Bandera para finalizar los retardos**
```
La bandera se coloca en 1 (indicando que el Timer0 ya se desbordó) en la rutina de interrupción:

``` Assembly
  ORG 0x0008 
    GOTO  ISR
```

Rutina ISR
``` Assembly 
  ISR:  ;**Cuando desborda TMR0 se activa esta interrupción**
  CLRF    INTCON      ;**Desactivo las interrupciones**
  BSF   BAND, 0   ;**Coloco la bandera en 1**
  
  RETFIE                                  ;**Regresa de la interrupción**

```


## Cálculo del valor de BGR
Debido a que se usa transmisión por el puerto serial entonces debemos configurar el valor de BGR.

Datos:
La tarjeta tiene un cristal de 20Mhz. (FOSC = 20,000,000)

La comunicación es en modo asíncrono y con 8 bits.

Desired Baud Rate = 9,600

Bits de Configuración

| SYNC | BRG16       | BRGH  | BAUD RATE FORMULA | Fórmula Despejada para n
| ------------- |:-------------:|:-------------:| :-------------:| :-------------:|
| 0 | 0 | 1 | FOSC /[16 (n + 1)] = BAUD RATE | n = ((FOSC/BAUD RATE)/16) -1 

n = ((FOSC/BAUD RATE)/16) -1 
n = ((20,000,000/9,600)/16) -1  
n = 129

Calculated Baud Rate con 129 = 20,000,000/(16(129+1)) = 9,765

Error = (Calculated Baud Rate – Desired Baud Rate)/Desired Baud Rate = (9,765 - 9,600)/9600 = 1.71 % de Error

El valor de BGR calculado es de 129, que nos da un BAUD RATE de 9,765, con un error de 1.71%

## Configuración para usar la transmisión serial

El puerto C del PIC18F4550 en sus pines 7 y 6 son usados para la transmisión serial, configuramos esos pines con el registro TRISC.

Luego colocamos el valor de BAUD RATE préviamente calculado en el registro SPBRG, la comunicación es asíncrona, configuramos el envio de sólo un bit de parada y deshabilitamos enviar el 9° bit.

``` Assembly
  SETUPSERIALPORT:  
  movlw 0xc0    ;**Setea los bits  TX y RX de TRIS (1100 0000)
  iorwf TRISC,F         ;**Aplicando Filtro para no afectar otras configuraciones
  movlw SPBRG_VAL ;**Setea el baud rate
  movwf SPBRG           ;**Mueve el valor de la configuración a SPBRG_VAL
  movlw 0x25    ;**High baud rate (0010 0101)
  movwf TXSTA           ;**Mueve el valor de configuración a TXSTA
  movlw 0x90    ;**Habilita el puerto serial
  movwf RCSTA   ;**Mueve el valor de configuración a RCSTA
  movlw   0x00            ;**Configura Baudcon
  movwf   BAUDCON   ;**Mueve el valor de configuración a BAUDCON
  return  
```

## Funcionamiento del sensor de temperatura DS18B20
El sensor de temperatura DS18B20 cuenta con sólo una línea para la comunicación. Por defecto, la temperatura se componene de 12 bits organizados de la siguiente manera en 2 Bytes de la memoria del sensor. La temperatura está en grados centigrados.

Byte 1

| 2<sup>3</sup>| 2<sup>2</sup> | 2<sup>1</sup>| 2<sup>0</sup> | 2<sup>-1</sup> | 2<sup>-2</sup>  | 2<sup>-3</sup> | 2<sup>-4</sup> |
| --- |:---:|:---:|:---:|:---:|:---:|:---:|:---:|
|Bit 7 |Bit 6 |Bit 5 |Bit 4 |Bit 3 |Bit 2 |Bit 1 |Bit 0 |

Byte 2

| S | S | S | S | S | 2<sup>6</sup>  | 2<sup>5</sup> | 2<sup>4</sup> |
| --- |:---:|:---:|:---:|:---:|:---:|:---:|:---:|
|Bit 7 |Bit 6 |Bit 5 |Bit 4 |Bit 3 |Bit 2 |Bit 1 |Bit 0 |

### Protocolo para acceder al DS18B20

* Inicialización: Se envía el pulso de Reset y se espera un pulso de presencia.
* Comandos de las funciones ROM: Usados para acceder a las memorias ROM de los sensores conectados a la misma línea.
* Comandos de la funciones de Memoria: Usados para acceder a la memoria (Scratchpad) del sensor.

### Flujo de interacciones entre el PIC18F4550 y el DS18B20

1. Envío de Pulsos para la inicialización de la comunicación
La comunicación sólo empezará cuando las dos siguiente acciones sucedan: 
  * El DS18B20 envía un pulso de Reset
  * El PIC18F4550 envía un pulso de presencia
2. Acceso a las funciones de memoria ROM:
  * El PIC18F4550 manda a ejecutar la función SKIPROM del sensor DS18B20, porque sólo hay un sensor conectado a la línea.
3. Comandos de la funciones de Memoria
  * El PIC18F4550 manda a ejecutar la función CONVERT para indicar al sensor que almacene la temperatura en su memoria.
4. Envío de Pulsos para volver a inicializar la comunicación
  * El DS18B20 envía un pulso de Reset
  * El PIC18F4550 envía un pulso de presencia
5. Acceso a las funciones de memoria ROM:
  * El PIC18F4550 manda a ejecutar la función SKIPROM del sensor DS18B20, porque sólo hay un sensor conectado a la línea.
6. Comandos de la funciones de Memoria
  * El PIC18F4550 manda ejecutar la función READ SCRATCHPAD para indicar al sensor que envie bit por bit de la temperatura.
7. Enviar pulsos para finalizar la comunicación.
  * El DS18B20 envía un pulso de Reset
  * El PIC18F4550 envía un pulso de presencia
8. Volver al Paso 1 


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

SPBRG_VAL EQU .129  ;**Setea el baud rate para 9600 for 20Mhz clock

READROM   EQU 0X33    ;**Lee el codigo de 64 bits que posee el DS18S20***
READSCRAT EQU 0XBE  ;**Lee la temperatura obtenida del bloc de notas del DS18S20. Comienza enviando el menos significativo de TEMP hasta los 8 bits de POLARD****
CONVERT   EQU 0X44  ;**Inicia la conversion de Temp. (El dato se guarda en el scratchpad del DS18B20)***
SKIPROM   EQU 0XCC  ;**Direcciona los dispositivos DS18B20
SRCHROM   EQU 0xF0  ;**Hace una busqueda en la ROM**

IOBYTE    EQU 0X20  ;**Almaceno temporal de datos recibidos**
CONTA   EQU 0X22    ;**Contador para decrementar al enviar/recibir bits ***
POLARID   EQU 0X23  ;**Registro que va a indicar si la temperatura es positiva o negativa***
TEMP    EQU 0X24  ;**Temperatura recibida**
PDBYTE    EQU 0X25  ;**Registro de detección de pulso**
BAND    EQU 0X26  ;**Bandera para finalizar los retardos**
REG1    EQU 0X29
REG2    EQU 0X30
REG3    EQU 0X31
CONT4   EQU 0X32

;----------------------------------------------------------------------------
;Bit Definitions
PULSO   EQU 0X00  ;**Es el pin 0 del PORTD*** 

;----------------------------------------------------------------------------

    ORG     0x0000    ;place code at reset vector

    GOTO  Main    ;go to beginning of program

;----------------------------------------------------------------------------
;Interrupción de Alta Prioridad

    ORG 0x0008
HighIntCode:  
    GOTO  ISR

;----------------------------------------------------------------------------
;Interrupción de Baja Prioridad

    ORG 0x0018    ;place code at interrupt vector
LowIntCode: 
    GOTO  ISR

;----------------------------------------------------------------------------
Main:   
    CALL    SETUPPICPORT
    CALL  SETUPSERIALPORT ;set up serial port
    
    ;***********Iniciallización de Registros****************
    CLRF  IOBYTE            
    CLRF  CONTA     ;***INICIALIZAMOS TODOS LOS REGISTROS EN 0 ****
    CLRF  TEMP
    CLRF  PDBYTE
    CLRF  POLARID
    CLRF  BAND
    CLRF    CONT4
    
    ;***********Iniciallización de Registros para RETARDOLARGO****************
    MOVLW D'255'       ;***Si es 0 le cargamos el valor nuevamente***
    MOVWF REG1  
    MOVLW D'7'       ;***Si es 0 le cargamos el valor nuevamente***
    MOVWF REG2  
    MOVLW D'161'       ;***Si es 0 le cargamos el valor nuevamente***
    MOVWF REG3
    
    ;***********Iniciallización de configuraciones de Interrupciones****************
    CLRF  INTCON      ;**Desactivo todas las interrupciones al inicio del programa**
    MOVLW   b'11000001' ;**COnfiguro el Time Module0
    MOVWF   T0CON
    
MainLoop: 
  CALL  ENVIARPULSOS  ;**Función para iniciar los pulsos de presencia**
  BTFSS   PDBYTE,0  ;**1 = Si se detecta el pulso de presencia del Sensor**
  GOTO  MainLoop  ;**Sin presencia vuelvo a empezar**
  
  MOVLW SKIPROM   ;**Me direcciono con el dispositivo**
  CALL  TRANSMITIRASENSOR ;**Transmito bits de direccionamiento al sensor DS18B20**
  
  MOVLW CONVERT           ;**Pido al DS18S20 que convierta la temperatura que posee**
  CALL  TRANSMITIRASENSOR ;**Transmito los bits de conversi?n de temperatura**
  
  MOVLW D'221'    ;**Espero 70uS**
  CALL  RETARD    
  
  CALL    ENVIARPULSOS  ;**Env?o pulsos de presencia**
  
  MOVLW SKIPROM   ;**Me direcciono con el dispositivo**
  CALL  TRANSMITIRASENSOR   ;**Transmito bits de direccionamiento**
  
  MOVLW   READSCRAT     ;**Envio bits para leer la Temp del ds18s20**                                 
    CALL    TRANSMITIRASENSOR   ;**Envío el comando de lectura (scratchpad)**  
    NOP
  
  CALL    RECEPCION ;**Recibo la Temperatura**                          
    MOVF  IOBYTE, W ;**Muevo el contenido del registro que recibi? los bits a W**
  MOVWF   TEMP          ;**Guardo la Temperatura recibida en TEMP**              
  
  CALL    RECEPCION     ;**Recibo el signo de la temperatura**
  MOVF  IOBYTE, W       ;**
  MOVWF POLARID       ;**Muevo el signo recibido a POLARID**
  
  CALL  ENVIARPULSOS  ;**Envio los pulsos de presencia, para finalizar las peticiones**
  
  CALL  ACTEMP    ;**Acomodo los bits de ambos bytes para poder obtener la temperatura
  MOVF  TEMP,   W       ;**
  CALL    TRANSMITESERIAL ;**MANDA LA TEMP A PUERTO SERIAL
  
  CALL  RETARDOLARGO  ;**Retardo de un segundo entre lectura y lectura**
  GOTO  MainLoop

;----------------------------------------------------------------------------
;Transmite el byte WREG cuando el registro de transmisión está vacio
TRANSMITESERIAL:
  BTFSS PIR1,TXIF ;**Checo si el transmisor está ocupado
  BRA $-2   ;**Espera hasta que el transmisor deje de estar ocupado
  MOVWF TXREG   ;**Transmite el dato
  RETURN

ENVIARPULSOS: ;*********** SE ENVIA EL PULSO DE PRESENCIA ESPERANDO UNA RESPUESTA POR PARTE DEL DS18S20*****

  CALL  PULSO_ON  ;**Envío el pulso de presencia**
  NOP
  CLRF  PDBYTE    ;**Limpia el registro de detección de pulsos**
  NOP
  CALL  PULSO_OFF ;**RB0 como salida***
  MOVLW D'6'
  CALL  RETARD    ;**Espero 500uS**
  CALL  PULSO_ON  ;**RB0 como entrada***
  MOVLW D'221'
  CALL  RETARD    ;**Espero 70uS***
    ACA:  
  BTFSS PORTD,  PULSO ;**Pregunto si llegó el pulso del DS18S20 (si detecta presencia del PIC)***
  GOTO  ACA   ;**Si no recibe su respuesta, vuelvo a preguntar***
  BSF PDBYTE, 0 ;**Si llega el pulso del sensor, pongo la bandera en 1*** 
  MOVLW D'56'   
  CALL  RETARD    ;**Espero 400uS**
  RETLW 0
  
;*************************************************************************************************************
;***** PULSO ON Y OFF SON PARA ENVIAR/RECIBIR LAS SEÑALES QUE NECESITAMOS PARA COMUNICARNOS CON EL DS18S20****
;*************************************************************************************************************

PULSO_ON:
  BSF   PORTD,  PULSO ;**Pongo RB0 en 1 ***
  BSF   TRISD,  PULSO ;**Pongo RB0 como salida y genera el pulso ***    
  RETLW 0 

PULSO_OFF:
  BCF   PORTD,  PULSO ;**Pongo RB0 en 0 ***
  BCF   TRISD,  PULSO ;**Pongo RB0 como salida**
  RETLW 0
  
RECEPCION:        ;**Bit leído del DS18S20 es almacenado en IOBYTE**

  MOVLW D'8'                    ;**Número de iteraciones que se darán
  MOVWF CONTA     ;**Contador = 8 para limitar la cantidad de bits que voy a recibir**

    RXBIT:
  CALL    PULSO_OFF ;***RB0 como salida y luego se esperan 5us**
  NOP                             ;**Espero 1us**
  NOP       ;**Espero 1us**
  NOP       ;**Espero 1us**
  NOP       ;**Espero 1us**
  NOP       ;**Espero 1us**
  NOP       ;**Espero 1us**
  
  CALL    PULSO_ON  ;**Envío pulso de presencia y espero 4uS**
    NOP                             ;**Espero 1us**
  NOP                             ;**Espero 1us**
  NOP                             ;**Espero 1us**
    NOP                             ;**Espero 1us**
  
  BCF       STATUS, C ;**Coloco el valor de Carry en 0**
  BTFSC     PORTD,  PULSO   ;**Checo el valor del puerto B
  BSF       STATUS, C ;**Si el valor del puerto B es 1, entonces colocamos la bandera de Carry en 1**
  RRCF    IOBYTE, F ;**Roto un bit a la derecha a través de Carry del byte IOBYTE**
  
  MOVLW         D'231'          ;** **
  CALL    RETARD    ;**Espero 50uS para terminar de realizar la tarea anterior**
  
  CALL    PULSO_ON        ;
  DECFSZ          CONTA,  F ;**Decremento el contador en una unidad, si no es cero vuelvo a empezar**
  GOTO    RXBIT   ;**Vuelvo a empezar hasta que se haya agotado el contador**
  
  RETLW 0

TRANSMITIRASENSOR:      ;**Función para enviar Bits al Sensor DS18B20**
  
  MOVWF IOBYTE                  ;**Movemos la instrucción que se encuentra en W al regsitro IOBYTE**
  MOVLW D'8'                    ;**Movemos el valor de 8 a W**
  MOVWF CONTA     ;**Contador = 8, usado para sólo transmitir 8 bits al sensor**

    TXBIT:
  CALL    PULSO_OFF ;***RB0 como salida**
  NOP                             ;**Espero 1us**
  NOP                             ;**Espero 1us**
  NOP       ;**Espero 1us (Para Mantener la línea baja 3uS)**
  RRCF    IOBYTE, F ;**Roto un lugar hacia la derecha a través del carry**
  BTFSC   STATUS, C ;**Checa si el bit menos significativo de IOBYTE es 0 o 1**
  BSF   TRISD,  PULSO ;**Si es 1, pongo PULSO en 1, si no simplemente lo dejo bajo**
  MOVLW   D'226'          ;**Muevo 226 a W**
  CALL    RETARD    ;**Se mantiene el estado de la línea por 60uS**
  CALL    PULSO_ON  ;**Lanzo la línea para Pullup**
  NOP       ;**Espero 1us**
  NOP       ;**Espero 1us**
  DECFSZ    CONTA,  F ;**Decrementa el contador en una uno, salta si es cero**
  GOTO    TXBIT   ;**Regresar hasta agotar el contador**
  RETLW 0
  
;*************************************************************************************************************
;***** RUTINAS DE RETARDO (ESPERA)****
;*************************************************************************************************************
RETARD:
    MOVWF TMR0    ;**Cargo TMR0 con el valor de W**
    MOVLW B'10100000' ;**Habilitar Bits de Interrupciones t de TMR0
    MOVWF INTCON    ;**Muevo el byte de configuración a INTCON**
    TIMEOVER: 
    BTFSS BAND, 0 ;**Pregunto si se desbordó TMR0 (terminó el retardo)**
    GOTO  TIMEOVER  ;**Si no, vuelve a preguntar**
    BCF BAND, 0 ;**Coloco la bandera en 0**
    CLRF  INTCON    ;**Desactivo interrupción por TMR0**
    RETLW 0
    
RETARDOLARGO:
    MOVLW D'0'    ;**512 uS por cada desborde de TMR0
    MOVWF TMR0    ;**Cargo TMR0 con el tiempo necesario**
    MOVLW B'10100000' 
    MOVWF INTCON    ;**Activa la interrupción por TMR0**
    AQUI13: 
    BTFSS BAND, 0 ;**Pregunto si desborda TMR0 (termina el retardo)**
    GOTO  AQUI13    ;**Si no, vuelvo a preguntar**
    BCF BAND, 0 ;**Coloco la bandera en 0**
    CLRF  INTCON    ;**Desactivo interrupción por TMR0**
    
    DECFSZ  REG1, F       ;**Decrementa el valor de REG1 salta si es cero
    GOTO  RETARDOLARGO    ;**Si no, vuelve a RETARDOLARGO
    MOVLW D'255'          ;**Muevo (1111 1111)
    MOVWF REG1            ;**Lo cargo al regsitro REG1

    DECFSZ  REG2, F      ;**Decrementa el valor de REG2 salta si es cero
    GOTO  RETARDOLARGO   ;**Si no, vuelve a RETARDOLARGO
    MOVLW D'7'           ;**Mueve 0000 0111 a W
    MOVWF REG2           ;**Carga el valor a REG2

    AQUI2:    
    MOVLW D'0'    ;**512 uS por cada desborde de TMR0
    MOVWF TMR0    ;**Cargo TMR0 con el tiempo necesario**
    MOVLW B'10100000' ;**Valor para activar las interrupciones por TMR0
    MOVWF INTCON    ;**Activo la interrupción por TMR0**
    AQUI3:  
    BTFSS BAND, 0 ;**Pregunto si desbordó TMR0 (terminó el retardo)**
    GOTO  AQUI3   ;**Si no, vuelvo a preguntar**
    BCF BAND, 0 ;**Coloco la bandera en 0**
    CLRF  INTCON    ;**Desactivo interrupción por TMR0**  
  
    DECFSZ  REG3, 1       ;**Decremento el reg3 en una unidad***
    GOTO  AQUI2   ;***Si no es 0 vuelvo a comenzar***
    MOVLW D'161'        ;**Si es 0 le cargamos el valor nuevamente**
    MOVWF REG3            ;**Mueve el valor a REG3
    RETLW 0

;*************************************************************************************************************
;***** RUTINAS DE CONFIGURACION INICIALES****
;*************************************************************************************************************
;Set up serial port.
SETUPSERIALPORT:  
  movlw 0xc0    ;**Setea los bits  TX y RX de TRIS (1100 0000)
  iorwf TRISC,F         ;**Aplicando Filtro para no afectar otras configuraciones
  movlw SPBRG_VAL ;**Setea el baud rate
  movwf SPBRG           ;**Mueve el valor de la configuración a SPBRG_VAL
  movlw 0x25    ;**High baud rate (0010 0101)
  movwf TXSTA           ;**Mueve el valor de configuración a TXSTA
  movlw 0x90    ;**Habilita el puerto serial
  movwf RCSTA   ;**Mueve el valor de configuración a RCSTA
  movlw   0x00            ;**Configura Baudcon
  movwf   BAUDCON   ;**Mueve el valor de configuración a BAUDCON
  return
    

;----------------------------------------------------------------------------
;-----Configuro la Puerta D como salida
SETUPPICPORT:
  movlw  0x0f
  movwf  0xC1,0        ;**Muevo 15 al registro ADCON1 (para modificarlo como digital)
  movlw  0x07
  movwf  0xB4,0        ;**Se desactiva el comparador analogico
  clrf   PORTD         ;**Pongo ceros en la salida del puerto D
  movlw  b'00000010'
  movwf  TRISD,0       ;**Se configura el puerto como SALIDA
  return

  
ACTEMP:
  MOVLW D'3'      ;cargo el contador con 3
  MOVWF CONT4

    RRE:
  BCF STATUS,  C    ;limpio el bit de carry (para evitar conflictos)
  RRCF  POLARID, 1    ;roto temp un lugar a traves del carry
  BTFSS STATUS,  C    ;pregunto si carry = 1
  GOTO  CARRY0      ;carry = 0
  BCF STATUS, C   ;limpio el bit de carry (para evitar conflictos)
  RRCF  TEMP,   1   ;muevo el bit a la izquierda
  BSF TEMP, 7   ;cargo el bit7 con 1
  
    DEC:
  DECFSZ  CONT4,  F   ;decremento contador hasta llegar a 0
  GOTO  RRE     ;sino termino de decrementar, vuelvo a realizar la acci?n
  RETLW 0 

    CARRY0:
  BCF STATUS,   C
  RRCF  TEMP,   1   ;muevo el bit a la izquierda
  BCF TEMP, 7   ;cargo el bit0 con 1
  GOTO  DEC
;*************************************************************************************************************
;***** SERVICIO DE INTERRUPCIÓN****
;*************************************************************************************************************
ISR:  ;**Cuando desborda TMR0 se activa esta interrupción**
  CLRF    INTCON      ;**Desactivo las interrupciones**
  BSF   BAND, 0   ;**Coloco la bandera en 1**
  
  RETFIE                                  ;**Regresa de la interrupción**

END

```