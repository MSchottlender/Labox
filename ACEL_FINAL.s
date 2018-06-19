
/*
 * Assembler1.s
 *
 * Created: 8/6/2018 19:21:25
 *  Author: marti
 */ 

#include <avr/io.h>
.global main
.EXTERN angulo

;.dseg
.section .data
.org 0x300
ejes: .byte 10

;.cseg
.section .text
main:
call USART_Init
SETUP: ;Esta parte (hasta BEGIN_ADC se puede poner en el main y solo hacer una vez)
	ldi r16, 0x87 
	sts ADCSRA, r16 ;Enciendo el ADC y uso una frecuencia de actualizacion de Ck/128=125KHz
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
	rjmp BEGIN_ADC_1



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




