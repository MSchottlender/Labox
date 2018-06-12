
/*
 * Assembler2.s
 *
 * Created: 11/6/2018 11:33:48
 *  Author: camis
 */ 

  
#include <avr/io.h>
.global main
.extern Sensor_c


;.dseg
.section .data
.org 0x400

;.cseg
.section .text

main:
call USART_Init			;Función que inicializa los registros para USART

SETUP: ;Esta parte (hasta BEGIN_ADC se puede poner en el main y solo hacer una vez)
	ldi r16, 0x00	;Pongo en read los analog
	out DDRF, r16 ;Aca estan los analog 0, 1 y 2
	ldi r16, 0x87 
	sts ADCSRA, r16 ;Enciendo el ADC y uso una frecuencia de actualizacion de Ck/128=125KHz
BEGIN_ADC:
	ldi r16, 0xC9 ;Esto implica que la AREF es interna (2,56 V), que se usan los bits 0-9 del ADC y (por el momento)
	sts ADMUX, r16;que se usa el bit 0. RECOMENDADO USAR CAPACITOR DE 100nF PARA MEJORAR PRECISION
READ_ADC:
	ldi r18,0x40 ;(Con el or le agrega unicamente el pin para la conversion)
	lds r19,ADCSRA
	or r18,r19
	sts	ADCSRA,r18 ;Hace la conversion
KEEP_POLING:
	lds r18,ADCSRA
	sbrs r18,4; Me fijo si el ADIF esta set y si lo esta pasa a transferir los datos
	rjmp KEEP_POLING
	subi r18,0x08 ;Vuelvo el ADIF a 0
	sts ADCSRA,r18
CURRENT:
	lds r16,ADCL
	sts 0x400,r16	; Coloco el valor low en la posición de memoria 0x400
	lds r16,ADCH
	sts 0x401,r16	; Coloco el valor low en la posición de memoria 0x401
	rcall Sensor_c	; Transformo el valor obtenido a un valor de corriente
	lds r16, 0x402	; Guardo el valor de corriente en la posición 0x402
	call USART_Transmit		; Transmito el valor mediante puerto serie
	rjmp READ_ADC	; Vuelvo a obtener un dato

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