.include "M328def.inc"
extern angulo

.dseg
.org 0x300
ejes .byte 5

.cseg
SETUP: ;Esta parte (hasta BEGIN_ADC se puede poner en el main y solo hacer una vez)
	ldi r16, 0	;Pongo en read los analog
	out DDRF, r16 ;Aca estan los analog 0, 1 y 2
	ldi r16, 0x87 
	out ADCSRA, r16 ;Enciendo el ADC y uso una frecuencia de actualizacion de Ck/128=125KHz
BEGIN_ADC:
	ldi r16, 0x00 ;Esto implica que la AREF es externa (3,3 V), que se usan los bits 0-9 del ADC y (por el momento)
	out ADCMUX, r16;que se usa el bit 0
READ_ADC:
	sbi	ADCSRA,ADSC ;Hace la conversion
KEEP_POLING:
	sbis ADCSRA,ADIF
	rjmp KEEP_POLING
	sbi	ADCSRA,ADIF
	tst r17
	brne Z_AXIS
Y_AXIS:
	in r16,ADCL
	sts 0x300,r16
	in r16,ADCH
	sts 0x301,r16
	ldi r16, 0x01 ;Mantiene lo del AREF y la convencion de bits, pero usa el bit 1 (para el eje z)
	out ADCMUX, r16
	ldi r17, 0x01 ;Para que ponga los proximos datos en Z
	rjmp READ_ADC
Z_AXIS:
	in r16,ADCL
	sts 0x302,r16
	in r16,ADCH
	sts 0x303,r16
	rcall angulo
	ret ;En 0x304 queda guardado el angulo obtenido
