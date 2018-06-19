
/*
 * Assembler1.s
 *
 * Created: 8/6/2018 19:21:25
 *  Author: marti
 */ 

 /***** QUEDA: MODIFICAR LOS IN/OUT POR SFR (PARA C) Y DESMACRIZAR LOS MACROS ****/

#include <avr/io.h>
#include <avr/iom2560.h>
#include "macros.s"
.global main
.EXTERN angulo

 ;Aca irian los .equ (no se si son defines)
#define baudrate  103
#define	B_S3003 1000
#define	A_s3003 17
#define	B_SG90 1050
#define	A_SG90 11


;.dseg
.section .data
#define	AUX		R16
#define	PWML	R30
#define	PWMH	R31
.org 0x300
ejes: .byte 10

;.cseg
.section .text
.org INT_VECTORS_SIZE
	LDI r16,HIGH(RAMEND)	;Inicializo Stack Pointer
	OUT SPh, r16
	LDI r16, LOW(RAMEND)
	OUT SPl, r16
call USART_Init
call SETUP_ADC
call int_setup
call configure_pwm

main:
call acel
call main_pwm
rjmp main


SETUP_ADC: ;Esta parte (hasta BEGIN_ADC se puede poner en el main y solo hacer una vez)
	ldi r16, 0x87 
	sts ADCSRA, r16 ;Enciendo el ADC y uso una frecuencia de actualizacion de Ck/128=125KHz

acel:
BEGIN_ADC_1:
	clr r17
	ldi r16,0x01 ;Esto es para pasarle al .c que esta en el primer acelerometro
	sts 0X304,r16
	ldi r16, 0xC0 ;Esto implica que la AREF es interna (2,56 V), que se usan los bits 0-9 del ADC y (por el momento)
	sts ADMUX, r16;que se usa el bit 0. RECOMENDADO USAR CAPACITOR DE 100nF PARA MEJORAR PRECISION
READ_ADC_1:
	ldi r18,0x40 ;(Con el or le agrega unicamente el pin para la conversion)
	lds r19,ADCSRA
	or r18,r19
	sts	ADCSRA,r18 ;Hace la conversion
KEEP_POLING_1:
	lds r18,ADCSRA
	sbrs r18,4; Me fijo si el ADIF esta set y si lo esta pasa a transferir los datos
	rjmp KEEP_POLING_1
	subi r18,0x08 ;Vuelvo el ADIF a 0
	sts ADCSRA,r18
	tst r17 ;es un contador para fijarse si ya paso por Y
	brne Z_AXIS_1
Y_AXIS_1:
	lds r16,ADCL
	sts 0x300,r16
	lds r16,ADCH
	sts 0x301,r16
	ldi r16, 0xC1 ;Mantiene lo del AREF y la convencion de bits, pero usa el bit 1 (para el eje z)
	sts ADMUX, r16
	ldi r17, 0x01 ;Para que ponga los proximos datos en Z
	rjmp READ_ADC_1
Z_AXIS_1:
	lds r16,ADCL
	sts 0x302,r16
	lds r16,ADCH
	sts 0x303,r16
	rcall angulo
	lds r21, 0x305 ;Aca sale el angulo de 1
	;call USART_Transmit
	call DELAY_20MS ; LALALALALALALA
BEGIN_ADC_2:
	clr r17
	ldi r16,0x02 ;Esto es para pasarle al .c que esta en el segundo acelerometro
	sts 0X304,r16
	ldi r16, 0xC2 ;Esto implica que la AREF es interna (2,56 V), que se usan los bits 0-9 del ADC y se usa el bit 2.
	sts ADMUX, r16
READ_ADC_2:
	ldi r18,0x40 ;(Con el or le agrega unicamente el pin para la conversion)
	lds r19,ADCSRA
	or r18,r19
	sts	ADCSRA,r18 ;Hace la conversion
KEEP_POLING_2:
	lds r18,ADCSRA
	sbrs r18,4; Me fijo si el ADIF esta set y si lo esta pasa a transferir los datos
	rjmp KEEP_POLING_2
	subi r18,0x08 ;Vuelvo el ADIF a 0
	sts ADCSRA,r18
	tst r17 ;es un contador para fijarse si ya paso por Y
	brne Z_AXIS_2
Y_AXIS_2:
	lds r16,ADCL
	sts 0x300,r16
	lds r16,ADCH
	sts 0x301,r16
	ldi r16, 0xC3 ;Mantiene lo del AREF y la convencion de bits, pero usa el bit 3 (para el eje z)
	sts ADMUX, r16
	ldi r17, 0x01 ;Para que ponga los proximos datos en Z
	rjmp READ_ADC_2
Z_AXIS_2:
	lds r16,ADCL
	sts 0x302,r16
	lds r16,ADCH
	sts 0x303,r16
	rcall angulo
	lds r22, 0x305 ;Aca sale el angulo de 2
	;call USART_Transmit
	call DELAY_20MS ; LALALALALALALA
BEGIN_ADC_3:
	clr r17
	ldi r16,0x03 ;Esto es para pasarle al .c que esta en el tercer acelerometro
	sts 0X304,r16
	ldi r16, 0xC4 ;Esto implica que la AREF es interna (2,56 V), que se usan los bits 0-9 del ADC y que se usa el bit 4.
	sts ADMUX, r16;
READ_ADC_3:
	ldi r18,0x40 ;(Con el or le agrega unicamente el pin para la conversion)
	lds r19,ADCSRA
	or r18,r19
	sts	ADCSRA,r18 ;Hace la conversion
KEEP_POLING_3:
	lds r18,ADCSRA
	sbrs r18,4; Me fijo si el ADIF esta set y si lo esta pasa a transferir los datos
	rjmp KEEP_POLING_3
	subi r18,0x08 ;Vuelvo el ADIF a 0
	sts ADCSRA,r18
	tst r17 ;es un contador para fijarse si ya paso por Y
	brne Z_AXIS_3
Y_AXIS_3:
	lds r16,ADCL
	sts 0x300,r16
	lds r16,ADCH
	sts 0x301,r16
	ldi r16, 0xC5 ;Mantiene lo del AREF y la convencion de bits, pero usa el bit 5 (para el eje z)
	sts ADMUX, r16
	ldi r17, 0x01 ;Para que ponga los proximos datos en Z
	rjmp READ_ADC_3
Z_AXIS_3:
	lds r16,ADCL
	sts 0x302,r16
	lds r16,ADCH
	sts 0x303,r16
	rcall angulo
	lds r23, 0x305 ;Aca sale el angulo de 3
	;call USART_Transmit
	call DELAY_20MS ; LALALALALALALA
BEGIN_ADC_4:
	clr r17
	ldi r16,0x04 ;Esto es para pasarle al .c que esta en el primer acelerometro
	sts 0X304,r16
	ldi r16, 0xC6 ;Esto implica que la AREF es interna (2,56 V), que se usan los bits 0-9 del ADC y que se usa el bit 6.
	sts ADMUX, r16
READ_ADC_4:
	ldi r18,0x40 ;(Con el or le agrega unicamente el pin para la conversion)
	lds r19,ADCSRA
	or r18,r19
	sts	ADCSRA,r18 ;Hace la conversion
KEEP_POLING_4:
	lds r18,ADCSRA
	sbrs r18,4; Me fijo si el ADIF esta set y si lo esta pasa a transferir los datos
	rjmp KEEP_POLING_4
	subi r18,0x08 ;Vuelvo el ADIF a 0
	sts ADCSRA,r18
	tst r17 ;es un contador para fijarse si ya paso por Y
	brne Z_AXIS_4
Y_AXIS_4:
	lds r16,ADCL
	sts 0x300,r16
	lds r16,ADCH
	sts 0x301,r16
	ldi r16, 0xC7 ;Mantiene lo del AREF y la convencion de bits, pero usa el bit 7 (para el eje z)
	sts ADMUX, r16
	ldi r17, 0x01 ;Para que ponga los proximos datos en Z
	rjmp READ_ADC_4
Z_AXIS_4:
	lds r16,ADCL
	sts 0x302,r16
	lds r16,ADCH
	sts 0x303,r16
	rcall angulo
	lds r24, 0x305 ;Aca sale el angulo de 4
	;call USART_Transmit
	call DELAY_20MS ; LALALALALALALA
ret



USART_Init:		; Seteo de la transmision y recepcion mediante puerto serie
	push r16	; Guardo r16 y r17 en el stack para que no perder el valor que poseen
	push r17
	ldi r16,lo8(103) ; Baud rate = 9600 (8 MHz)
	ldi r17,hi8(103)
	sts UBRR0H, r17	; Guardo el Baudrate en UBRR0	
	sts UBRR0L, r16	; Utilizo STS en vez de OUT, ya que las direcciones estan en "extended I/O"

	; Habilito el receptor y transmisor
	ldi r16, (1<<RXEN0)|(1<<TXEN0)
	sts UCSR0B, r16

	; Seteamos el formato del puerto serie: 8 data, 1 stop bit
	ldi r16, (0<<USBS0)|(3<<UCSZ00)
	sts UCSR0C, r16

	pop r17		; Recuperamos los valores guardados de r16 y r17
	pop r16
	RET

USART_Transmit:
	push r17	; Guardo el valor de r17 en el stack para poder utilizarlo (Flags check)
	

check_transmit_buffer_empty:	; Espero a que el buffer de transmision se vacie
	lds r17, UCSR0A
	sbrs r17, UDRE0
	rjmp check_transmit_buffer_empty

	sts UDR0,r16	; Dato cargado antes de la función

	pop r17		; Recupero el valor anterior de r17
	RET


	;DELAY 20ms

DELAY_20MS:
	ldi r16,150
	ldi r17,160
	ldi r18,2
	Loop:
		dec r16
		brne Loop
		dec r17
		brne Loop
		dec r18
		brne Loop
	nop
	clr r16
	clr r17
	clr r18
	ret

/*********** INTERRUPCION ************/

int_setup:

rjmp int_main
.org INT0addr
jmp interrupt
.org INT_VECTORS_SIZE


int_main:

sei		;seteo el flag I del SREG para habilitar las interrupciones
ldi r16, 0x01
out EIMSK, r16	;habilito la interrupcion INT0
ldi AUX, 0x02
sts EICRA, r16	;configuro que la interrupcion se habilite en flanco ascendente
ldi AUX, 0x00
out EIFR, r16	;limpio las banderas que indican que una interrupcion se lleva a cabo

cbi DDRC, 6		;coloco a PC6 como salida (digital pin 31)
ret


interrupt:

in r17, SREG
push r17
push r16

sbi PORTC, 6	;prendo el LED

    ldi  r18, 41	;Delay de medio segundo
    ldi  r19, 150
    ldi  r20, 128
L1: dec  r20
    brne L1
    dec  r19
    brne L1
    dec  r18
    brne L1
	
cbi PORTC, 6	;apago el LED

pop r16
pop r17
out SREG, r17

reti

/**************************** SERVO *************************************/
	
main_pwm:

	call USART_Receive
	call USART_Transmit
	cpi R16,'1'
	breq Abierto
	call Cerrado
	
	rjmp main

Abierto:
	ldi r17,180; Inicio el ancho de pulso en 1ms
	call Transformar_angulo
	call set_pwm_uno
	call set_pwm_dos
	call set_pwm_tres
	call set_pwm_cuatro
	ldi r17, 90
	call Transformar_angulo_pulgar
	call set_pwm_cinco
	rjmp main

	
USART_Receive:
	push r17

check_receive_data_completition:
	; Wait for data to be received
	lds r17, UCSR0A
	sbrs r17, RXC0
	rjmp check_receive_data_completition

	; Get and return received data from buffer
	lds r16, UDR0
	
	
	pop r17
	RET
		
configure_pwm: ; Primero seteo el T/C para que se resetee cada 20ms y que hasta que encuentre OCR1B este en 1 (Ancho de pulso variable para el servo)

	; Fast PWM (WGM[3:0] = 15) y en modo non-inverting para el registro OC1B, lo limpia cuando matchea y lo setea de vuelta en BOTTOM
	ldi r16, 0xFF

	sbi DDRB,6   ; Pongo como salida el pin OC1B por donde va a salir la señal del PWM pin 12
	sts DDRH,r16 ; Pongo como salida el pin OC4B y OC4C por donde va a salir la señal del PWM pin 7 y 8
	sts DDRL,r16 ; Pongo como salida el pin OC5B y OC5C por donde va a salir la señal del PWM pin 45 y 44



	;;;;;;;;;;;;;;;;;;CONFIG SERVO 1: pin 12, OC1B;;;;;;;;;;;;;;
	input AUX,TCCR1A
	ori AUX,(1<<COM1B1)|(1<<WGM11)|(1<<WGM10) ; Set en modo non-inverting, WGM11 y WGM10 en 1 para setear el modo Fast PWM
	output TCCR1A,AUX

	input AUX,TCCR1B
	ori AUX,(1<<WGM13)|(1<<WGM12) ; Set en modo Fast PWM, el contador se resetea cuando llega a OCR1A
	ori AUX, (1<<CS11) ; Set prescaler en 8
	output TCCR1B,AUX

	; Poniendo el prescaler en 8, y con una frecuencia de 16MHz,contar hasta 40000 tarda 20ms
	; 40000/(16Mega/8) = 0.02
	ldi PWMH, HIGH (40000)
	ldi PWML, LOW (40000) 
	output OCR1AH,PWMH
	output OCR1AL,PWML
	;;;;;;;;;;;;;;;;;;CONFIG SERVO 2: pin 7, OC4B;;;;;;;;;;;;;;
	
	input AUX,TCCR4A
	ori AUX,(1<<COM4B1)|(1<<WGM41)|(1<<WGM40) ; Set en modo non-inverting, WGM41 y WGM40 en 1 para setear el modo Fast PWM
	output TCCR4A,AUX

	input AUX,TCCR4B
	ori AUX,(1<<WGM43)|(1<<WGM42) ; Set en modo Fast PWM, el contador se resetea cuando llega a OCR4A
	ori AUX, (1<<CS41) ; Set prescaler en 8
	output TCCR4B,AUX

	; Poniendo el prescaler en 8, y con una frecuencia de 16MHz,contar hasta 40000 tarda 20ms
	; 40000/(16Mega/8) = 0.02
	ldi PWMH, HIGH (40000)
	ldi PWML, LOW (40000) 
	output OCR4AH,PWMH
	output OCR4AL,PWML

	;;;;;;;;;;;;;;;;;;CONFIG SERVO 3: pin 8, OC4C;;;;;;;;;;;;;;
	
	input AUX,TCCR4A
	ori AUX,(1<<COM4C1)|(1<<WGM41)|(1<<WGM40) ; Set en modo non-inverting, WGM41 y WGM40 en 1 para setear el modo Fast PWM
	output TCCR4A,AUX

	;;;;;;;;;;;;;;;;;;CONFIG SERVO 4: pin 45, OC5B;;;;;;;;;;;;;;
	
	input AUX,TCCR5A
	ori AUX,(1<<COM5B1)|(1<<WGM51)|(1<<WGM50) ; Set en modo non-inverting, WGM31 y WGM30 en 1 para setear el modo Fast PWM
	output TCCR5A,AUX

	input AUX,TCCR5B
	ori AUX,(1<<WGM53)|(1<<WGM52) ; Set en modo Fast PWM, el contador se resetea cuando llega a OCR3A
	ori AUX, (1<<CS51) ; Set prescaler en 8
	output TCCR5B,AUX

	; Poniendo el prescaler en 8, y con una frecuencia de 16MHz,contar hasta 40000 tarda 20ms
	; 40000/(16Mega/8) = 0.02
	ldi PWMH, HIGH (40000)
	ldi PWML, LOW (40000) 
	output OCR5AH,PWMH
	output OCR5AL,PWML

	;;;;;;;;;;;;;;;;;;CONFIG SERVO 5: pin 44, OC5C;;;;;;;;;;;;;;
	input AUX,TCCR5A
	ori AUX,(1<<COM5C1)|(1<<WGM51)|(1<<WGM50) ; Set en modo non-inverting, WGM31 y WGM30 en 1 para setear el modo Fast PWM
	output TCCR5A,AUX


	;;;;;Inicializo todos los servos abiertos;;;;;
	ldi PWMH, HIGH(3000)
	ldi PWML, LOW(3000) ; Inicio el ancho de pulso en 1ms
	call set_pwm_uno	;A esta funcion se la llama cada vez que se quiera modificar el ancho de pulso
	call set_pwm_dos
	call set_pwm_tres
	call set_pwm_cuatro
	call set_pwm_cinco
	;ldi PWMH, HIGH(3000)
	;ldi PWML, LOW(3000)
	;call set_pwm_cinco
	ret
  
  
set_pwm_uno: ; El registro OCR1B es el que determina el ancho de pulso. Con esta funcion actualizo ese registro con lo que hay en PWMH/L

	output OCR1BH,PWMH
	output OCR1BL,PWML
	ret

set_pwm_dos: ; El registro OCR1B es el que determina el ancho de pulso. Con esta funcion actualizo ese registro con lo que hay en PWMH/L

	output OCR4BH,PWMH
	output OCR4BL,PWML
	ret


set_pwm_tres: ; El registro OCR1B es el que determina el ancho de pulso. Con esta funcion actualizo ese registro con lo que hay en PWMH/L


	output OCR4CH,PWMH
	output OCR4CL,PWML
	ret
	
set_pwm_cuatro: ; El registro OCR1B es el que determina el ancho de pulso. Con esta funcion actualizo ese registro con lo que hay en PWMH/L


	output OCR5BH,PWMH
	output OCR5BL,PWML
	ret
	
set_pwm_cinco: ; El registro OCR1B es el que determina el ancho de pulso. Con esta funcion actualizo ese registro con lo que hay en PWMH/L

	output OCR5CH,PWMH
	output OCR5CL,PWML
	ret

Transformar_angulo:

	ldi r18, low(B_S3003)
	ldi r19, high(B_S3003)
	ldi r20, A_S3003	
	mul r17, r20
	add	r0, r18
	adc r1, r19
	mov PWMH, r1
	mov PWML, r0
	ret
	
Transformar_angulo_pulgar:
	
	ldi r18, low(B_SG90)
	ldi r19, high(B_SG90)
	ldi r20, A_SG90
	mul r17, r20
	add	r0, r18
	adc r1, r19
	mov PWMH, r1
	mov PWML, r0
	ret

Cerrado:
	ldi r17,0; Inicio el ancho de pulso en 1ms
	call Transformar_angulo
	call set_pwm_uno
	call set_pwm_dos
	call set_pwm_tres
	call set_pwm_cuatro
	call Transformar_angulo_pulgar
	call set_pwm_cinco
	ret

