;
; servo_prueba1.asm
;
; Created: 15/6/2018 12:30:43
; Author : camis
;

.include "M2560def.inc" 
.equ baudrate = 103
.equ	B_S3003 =1000
.equ	A_s3003 =17


.include "avr_macros.inc"
.include "M2560def.inc" 
.dseg
	.def	AUX		=	R16
	.def	PWML	=	R30
	.def	PWMH	=	R31

.cseg
	.org INT_VECTORS_SIZE
	LDI r16,HIGH(RAMEND)	;Inicializo Stack Pointer
	OUT SPh, r16
	LDI r16, LOW(RAMEND)
	OUT SPl, r16
	ldi r18, low(B_S3003)
	ldi r19, high(B_S3003)
	ldi r20, A_S3003
	rjmp INICIO


INICIO:
	
	call USART_Init			;Función que inicializa los registros para USART
	call configure_pwm
	
main:

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
	call set_pwm_cinco
	rjmp main

USART_Init:
;Setting the baud rate, setting frame format and enabling the Transmitter or the
;Receiver depending on the usage.
	push r16
	push r17

	ldi r16, LOW(baudrate)		;Baud rate = 9600 (8 MHz, System clock)
	ldi r17, HIGH(baudrate)		;Baud rate = 9600
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
	call set_pwm_cinco
	ret