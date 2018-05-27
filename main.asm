.nolist
.include "main.inc"
.include "MACROS.inc"
.include "MPU\MPU.inc"
.include "MPU\I2C_MPU.inc"
.include "BLUETOOTH\BLUETOOTH.inc"
.include "TIMER\TIMER.inc"
.list

.dseg
raw_accel_data:		.byte 6
raw_gyro_data:		.byte 6
scaled_accel_data:	.byte 6			
scaled_gyro_data:	.byte 6
accel_angles:		.byte 4
gyro_angles:		.byte 4
filtered_angles:	.byte 4
TEMPORAL:			.byte 12



.cseg
.org 0x00
	jmp RESET
.org OC1Aaddr
	jmp	ISR_1mS
.org OVF1addr
	jmp	ISR_OVERFLOW_TIMER1
.org URXCaddr 		
	jmp	ISR_USART_RX_COMPLETE
.org UDREaddr		
	jmp	ISR_USART_READY


.org INT_VECTORS_SIZE
RESET:
	outi16		SP, RAMEND
	rcall		INIT
	sei
/*	sbi			LEDS_PORT, LED_ON*/
	delay1ms	100


MAIN:
	rcall		GET_MPU_RAW_DATA
	rcall		GET_MPU_SCALED_DATA
	rcall		GET_FILTERED_ANGLES

	rcall		SEND_COMMAND

	delay1ms	7

	rjmp		MAIN

INIT:
/*	rcall		PORTS_INIT*/
	rcall		USART_INIT
	rcall		TIMER_INIT
	rcall		I2C_INIT
	rcall		MPU_INIT
	ret
	
/*PORTS_INIT:
	outi		DDRC, (1<<LED_ON)|(1<<LED_TIMER)|(1<<LED_ERROR)|(1<<LED_TX)
	outi		LEDS_PORT, 0
	outi		DDRB, (1<<LED_FORWARD)|(1<<LED_BACKWARD)
	outi		DDRD, (1<<LED_RIGHT)|(1<<LED_LEFT)
	outi		COMMAND_PORT_Y, 0
	outi		COMMAND_PORT_X, 0
	ret*/

SEND_COMMAND:
	ldi16		X, filtered_angles
	clr			TX_CHAR												;USO CHAR para almacenar el caracter que voy a mandar por bluetooth

_SEND_COMMAND_Y:													;EJE Y (ADELANTE O ATRAS)
	ld16		A, X												;Cargo en AH:AL el pitch
	ldi16		B, -ANGLE_TRIGGER*100								;Si el angulo es menor a -(angulo de disparo), entonces tiene que ir para atras
	cp16		A, B
	brlt		_SEND_COMMAND_Y_BACKWARD		
	ldi16		B, ANGLE_TRIGGER*100								;Si el angulo es menor a (angulo de disparo), entonces tiene que quedarse quieto (en pitch)
	cp16		A, B
	brlt		_SEND_COMMAND_Y_STAY

_SEND_COMMAND_Y_FORWARD:											;Si no es ninguna de las anteriores, tiene que acelerar
/*	cbi			COMMAND_PORT_Y, LED_BACKWARD
	sbi			COMMAND_PORT_Y, LED_FORWARD*/
	ldi			TEMP, 'A'
	mov			TX_CHAR, TEMP
	rjmp		_SEND_COMMAND_X										;Me fijo que onda en roll
_SEND_COMMAND_Y_BACKWARD:
/*	cbi			COMMAND_PORT_Y, LED_FORWARD
	sbi			COMMAND_PORT_Y, LED_BACKWARD*/
	ldi			TEMP, 'R'
	mov			TX_CHAR, TEMP
	rjmp		_SEND_COMMAND_X
_SEND_COMMAND_Y_STAY:
/*	cbi			COMMAND_PORT_Y, LED_FORWARD
	cbi			COMMAND_PORT_Y, LED_BACKWARD*/
	ldi			TEMP, 'Q'
	mov			TX_CHAR, TEMP

_SEND_COMMAND_X:
	ld16		A, X												;Cargo en AH:AL el roll
	ldi16		B, -ANGLE_TRIGGER*100								;Misma secuencia que para pitch
	cp16		A, B
	brlt		_SEND_COMMAND_X_RIGHT	
	ldi16		B, ANGLE_TRIGGER*100
	cp16		A, B
	brlt		_SEND_COMMAND_X_STAY

_SEND_COMMAND_X_LEFT:
/*	cbi			COMMAND_PORT_X, LED_RIGHT
	sbi			COMMAND_PORT_X, LED_LEFT*/
	ldi			TEMP, '<'
	add			TX_CHAR, TEMP
_SEND_COMMAND_X_RIGHT:
/*	cbi			COMMAND_PORT_X, LED_LEFT
	sbi			COMMAND_PORT_X, LED_RIGHT*/
	ldi			TEMP, '>'
	add			TX_CHAR, TEMP
_SEND_COMMAND_X_STAY:
/*	cbi			COMMAND_PORT_X, LED_LEFT
	cbi			COMMAND_PORT_X, LED_RIGHT*/
	ldi			TEMP, '='
	add			TX_CHAR, TEMP
_SEND_COMMAND_DONE:
	call		BLUETOOTH_SEND
	ret

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;TABLA ARCOTANGENTE
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
.equ	TAN_TABLE_RESOLUTION = 2
.equ	TAN_TABLE_ELEMENTS = 45

.org	0x500
tan_table: .dw 0, 3, 7, 10, 14, 17, 21, 25, 28, 32, 36, 40, 44, 48, 53, 57, 62, 67, 72, 78, 83, 90, 96, 103, 111, 119, 128, 137, 148, 160, 173, 188, 205, 224, 247, 274, 307, 348, 401, 470, 567, 711, 951, 1430, 2863 					;ESTO ES UNA TABLA DE TANGENTES MULTIPLICADAS POR 100 (SIN COMA), LOS ANGULOS DE 5 EN 5: 0, 5º, 10º, ...., 85º 

.nolist
.include "TIMER\TIMER.asm"
.include "BLUETOOTH\BLUETOOTH.asm"
.include "MATH\MATH.asm"
.include "MPU\I2C_MPU.asm"
.include "MPU\MPU.asm"
.list
