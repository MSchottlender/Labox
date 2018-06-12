#include <avr/io.h>
.global main
.EXTERN angulo

;.dseg
.section .data
.org 0x300
ejes: .byte 5

;.cseg
.section .text
main:
SETUP: ;Esta parte (hasta BEGIN_ADC se puede poner en el main y solo hacer una vez)
	;ldi r16, 0x00	;Pongo en read los analog
	;out DDRB, r16 ;Aca estan los analog 0, 1 y 2
	ldi r16, 0x87 
	sts ADCSRA, r16 ;Enciendo el ADC y uso una frecuencia de actualizacion de Ck/128=125KHz
BEGIN_ADC:
	ldi r16, 0xC0 ;Esto implica que la AREF es interna (2,56 V), que se usan los bits 0-9 del ADC y (por el momento)
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
	tst r17 ;es un contador para fijarse si ya paso por Y
	brne Z_AXIS
Y_AXIS:
	lds r16,ADCL
	sts 0x300,r16
	lds r16,ADCH
	sts 0x301,r16
	ldi r16, 0xC1 ;Mantiene lo del AREF y la convencion de bits, pero usa el bit 1 (para el eje z)
	sts ADMUX, r16
	ldi r17, 0x01 ;Para que ponga los proximos datos en Z
	rjmp READ_ADC
Z_AXIS:
	lds r16,ADCL
	sts 0x302,r16
	lds r16,ADCH
	sts 0x303,r16
	rcall angulo
	lds r16, 0x304
	rjmp READ_ADC
	ret ;En 0x304 queda guardado el angulo obtenido






