;
; Interruption_switch.asm
;
; Created: 13/6/2018 17:52:31
; Author : camis
;


.include "M2560def.inc" 

.dseg
.def AUX = r16
.def AUX1 = r17

.cseg

rjmp main
.org INT0addr
jmp interrupt
.org INT_VECTORS_SIZE

main:

sei		;seteo el flag I del SREG para habilitar las interrupciones
ldi AUX, 0x01
out EIMSK, AUX	;habilito la interrupcion INT0
ldi AUX, 0x02
sts EICRA, AUX	;configuro que la interrupcion se habilite en flanco ascendente
ldi AUX, 0x00
out EIFR, AUX	;limpio las banderas que indican que una interrupcion se lleva a cabo

cbi DDRC, 6		;coloco a PC6 como salida (digital pin 31)
rjmp main


interrupt:

in AUX1, SREG
push AUX1
push AUX

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

pop AUX
pop AUX1
out SREG, AUX1

reti
