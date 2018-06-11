/*
 * Assembler1.s
 *
 * Created: 10/6/2018 15:59:04
 *  Author: camis
 */ 

 
#include <avr/io.h>
.global main
.extern cvalue
	


;.dseg
.section .data
.org 0x400
;ejes: .byte 5

;.cseg
.section .text

main:
call USART_Init			;Función que inicializa los registros para USART
SETUP: ;Esta parte (hasta BEGIN_ADC se puede poner en el main y solo hacer una vez)
	;ldi r16, 0x00	;Pongo en read los analog
	;out DDRB, r16 ;Aca estan los analog 0, 1 y 2
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
	sts 0x400,r16
	lds r16,ADCH
	sts 0x401,r16
	rcall cvalue
	lds r16, 0x402
	call USART_Transmit
	rjmp READ_ADC

USART_Init:
;Setting the baud rate, setting frame format and enabling the Transmitter or the
;Receiver depending on the usage.
	push r16
	push r17
	ldi r16,lo8(103);Baud rate = 9600 (8 MHz, System clock)
	ldi r17,hi8(103);Baud rate = 9600
	; Set baud rate to UBRR0
	sts UBRR0H, r17		;utilizo STS en vez de OUT, ya que las direcciones estan en "extended I/O"
	sts UBRR0L, r16

	; Enable receiver and transmitter
	ldi r16, (1<<RXEN0)|(1<<TXEN0)
	sts UCSR0B, r16

	; Set frame format: 8data, 1stop bit
	ldi r16, (0<<USBS0)|(3<<UCSZ00)
	sts UCSR0C, r16

	pop r17
	pop r16
	RET

USART_Transmit:
;	 r16	;Data
	push r17	;Flags check
	

check_transmit_buffer_empty:
	; Wait for empty transmit buffer
	lds r17, UCSR0A
	sbrs r17, UDRE0
	rjmp check_transmit_buffer_empty

	; Put data (r16) into buffer, sends the data
	sts UDR0,r16	;Dato cargado antes de la función

	pop r17
	RET