;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;MULTIPLICACIONES
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
MUL_16x16:		
		push32	A				;GUARDO AH y AL EN EL STACK

		clr		SIGN
		clr		ZERO

		sbrc	AH, 7
		rcall	NEG_16
            
        mul		AH,BH            ;Multiply high bytes AHxBH
        movw	ANSHH:ANSHL,R1:R0 ;Move two-byte result into answer
        mul		AL,BL            ;Multiply low bytes ALxBL
        movw	ANSH:ANSL,R1:R0 ;Move two-byte result into answer
        mul		AH,BL            ;Multiply AHxBL
        add		ANSH,R0          ;Add result to answer
        adc		ANSHL,R1          ;
        adc		ANSHH,ZERO        ;Add the Carry Bit

        mul		BH,AL            ;Multiply BHxAL
        add		ANSH,R0          ;Add result to answer
        adc		ANSHL,R1          ;
        adc		ANSHH,ZERO        ;Add the Carry Bit

		
		mov32	A, ANS
		sbrc	SIGN, 0			;miro si hubo cambio de signo
		rcall	NEG_32
		mov32	ANS, A


		pop32	A				;RECUPERO AH Y AL
		ret

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;SIGNOS
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
NEG_16:
		push	TEMP
		clr		ZERO
		com		AL
		com		AH
		clc
		clr		TEMP
		ldi		TEMP, 1
		add		AL, TEMP		
		adc		AH, ZERO
		inc		SIGN
		pop		TEMP
		ret

NEG_32:
		push	TEMP
		clr		ZERO
		com		AL
		com		AH
		com		AHL
		com		AHH
		clc
		clr		TEMP
		ldi		TEMP, 1
		add		AL, TEMP		
		adc		AH, ZERO
		adc		AHL, ZERO
		adc		AHH, ZERO
		inc		SIGN
		pop		TEMP
		ret

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;DIVISIONES
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DIV_16384:
		push			COUNTER
		mov32			ANS, A	
		clr				ANSL
		ldi				COUNTER, 14
_DIV_16384_LOOP:
		div32_by_2		ANS
		dec				COUNTER
		brne			_DIV_16384_LOOP

		pop				COUNTER
		ret

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
DIV_32x32:												
		push			TEMP
		push			COUNTER
		push32			A
		clr				SIGN
		sbrc			AHH, 7
		rcall			NEG_32
		mov32			ANS, A
		clc
		clr32			REM			
		ldi				COUNTER, 33				;Load bit counter
_DIV_32x32_LOOP:  
		rol32			ANS					;Shift the answer to the left
        dec				COUNTER				;Decrement Counter
        breq			_DIV_32x32_DONE		;Exit if 32 bits done
		rol32			REM					;Shift remainder to the left
		sub32			REM, B				;Try to subtract divisor from remainder
        brcc			_DIV_32x32_SKIP		;If the result was negative then
		add32			REM, B				;reverse the subtraction to try again
        clc									;Clear Carry Flag so zero shifted into A 
        rjmp			_DIV_32x32_LOOP		;Loop Back
_DIV_32x32_SKIP:   
		sec									;Set Carry Flag to be shifted into A
        rjmp			_DIV_32x32_LOOP
_DIV_32x32_DONE:
		mov32			A, ANS	
		sbrc			SIGN, 0
		rcall			NEG_32
		mov32			ANS, A	
		pop32			A
		pop				COUNTER	
		pop				TEMP
		ret

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;POTENCIAS Y RAICES
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
POW_16:
		sbrc	AH, 7
		rcall	NEG_16
		
		movw	BH:BL, AH:AL
		rcall	MUL_16x16
		ret

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SQRT_32:
		push		COUNTER
		push32		A
		clr32		REM
		clr32		ANS
        ldi			COUNTER, 16			;Set Loop Counter to sixteen 
_SQRT_32_LOOP: 
		mul32_by_2	ANS
		mul32_by_2	A
		rol32		REM
		mul32_by_2	A
		rol32		REM
		cp32		ANS, REM			;Compare Root to Remainder      
        brcc		_SQRT_32_SKIP       ;If Remainder less or equal than Root
        inc			ANSL				;Increment Root 
		sub32		REM, ANS
        inc			ANSL				;Increment Root 
_SQRT_32_SKIP: 
        dec			COUNTER				;Decrement Loop Counter 
        brne		_SQRT_32_LOOP		;Check if all bits processed 
		div32_by_2	ANS
		pop32		A
		pop			COUNTER
		RET

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;ARCOTANGENTE
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ARCTG_32:											;TIENE QUE COMPARAR EL OPERADOR CON LOS ELEMENTOS DE LA TABLA HASTA QUE ALGUN ELEMENTO SEA MAYOR AL OPERADOR O EL OPERADOR SEA MAYOR AL ULTIMO ELEMENTO 
		push			COUNTER
		push32			A
		clr				COUNTER
		clr32			ANS
		clr				SIGN
		sbrc			AHH, 7 
		rcall			NEG_32			

		ldi16			Z, 2*tan_table
_ARCTG_32_LOOP:
		lpm16			B, Z
		fill			B
		cp32			A, B							;si el elemento de la tabla es mayor o igual, entonces ya casi tengo el angulo
		brlo			_ARCTG_32_DONE		
		inc				COUNTER
		cpi				COUNTER, TAN_TABLE_ELEMENTS		;comparo el contador con la cantidad de elementos de la tabla. Si el contador es mayor a la cantidad de elementos, es porq el angulo es mayor al ultimo elemento
		brlo			_ARCTG_32_LOOP

_ARCTG_32_DONE:										;aca es donde finalmente se calcula el angulo
		ldi				TEMP, TAN_TABLE_RESOLUTION
		mul				COUNTER, TEMP
		movw			AH:AL, R1:R0
		sbrc			SIGN, 0
		rcall			NEG_16
		movw			ANSH:ANSL, AH:AL
		pop32			A
		pop				COUNTER
		ret

;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;RUTINAS PARA LOS ANGULOS DEL MPU
;------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
GET_FILTERED_ANGLES:	
	rcall		GET_ACCEL_ANGLES
	rcall		GET_GYRO_ANGLES
	ldi16		X, accel_angles+2
	ldi16		Y, gyro_angles
	ldi16		Z, filtered_angles
	ldi			COUNTER, 2
_GET_FILTERED_ANGLES_LOOP:
	ld16		A, X				
	ldi16		B, 200
	rcall		MUL_16x16
	push32		ANS

	ld16		A, Y				;angulo giroscopo / 100

	ldi16		B, 98
	rcall		MUL_16x16
	
	pop32		A					;recupero 200*alfa y le sumo 98*theta
	add32		A, ANS

	ldi32		B, 100
	rcall		DIV_32x32

	st16		Z, ANS				;guardo el resultado
	ldi16		X, accel_angles
	dec			COUNTER
	brne		_GET_FILTERED_ANGLES_LOOP
	ret


GET_ACCEL_ANGLES:
	ldi16		X, scaled_accel_data
	ldi16		Y, TEMPORAL
	ldi			COUNTER, 3
_GET_ACCEL_ANGLES_LOOP1:	
	ld16		A, X
	rcall		POW_16
	st32		Y, ANS
	dec			COUNTER
	brne		_GET_ACCEL_ANGLES_LOOP1

	ldi16		X, scaled_accel_data

;X
	ldi16		Y, TEMPORAL+4
	ld32		A, Y
	ld32		B, Y
	add32		A, B
	rcall		SQRT_32
	push32		ANS

	ld16		A, X
	ldi16		B, 100
	rcall		MUL_16x16
	mov32		A, ANS
	pop32		B
	rcall		DIV_32x32
	mov32		A, ANS
	rcall		ARCTG_32
	movw		AH:AL, ANSH:ANSL
	rcall		NEG_16
	rcall		SKIP_90
	cpi			TEMP, 1
	breq		SKIP
	ldi16		Y, accel_angles
	st16		Y, A						;cargo arctg(-ax/sqrt(ay^2+az^2))	en la primer posicion de accel_angles
SKIP:
;Y
	ldi16		Y, TEMPORAL
	ld32		A, Y
	ldi16		Y, TEMPORAL+8
	ld32		B, Y
	add32		A, B
	rcall		SQRT_32
	push32		ANS

	ld16		A, X
	ldi16		B, 100
	rcall		MUL_16x16
	mov32		A, ANS
	pop32		B
	rcall		DIV_32x32
	mov32		A, ANS
	rcall		ARCTG_32
	ldi16		Y, accel_angles+2			;cargo arctg(ay/sqrt(ax^2+az^2))	en el 3 byte de accel_angles
	st16		Y, ANS
	ret

SKIP_90:
	push16		A
	sbrc		AH, 7
	rcall		NEG_16
	ldi16		B, 90
	cp16		A, B
	breq		SKIP_90_TRUE
	pop16		A
	ldi			TEMP, 0
	ret
SKIP_90_TRUE:
	pop16		A
	ldi			TEMP, 1
	ret

GET_GYRO_ANGLES:
	ldi16		X, scaled_gyro_data
	ldi16		Y, filtered_angles 
	ldi16		Z, gyro_angles
	ldi			COUNTER, 2

_GET_GYRO_ANGLES_LOOP:
	ld16		A, X						;cargo el dato del giroscopo escalado en A

	ld16		B, Y						;cargo el angulo previo (x100) en B
	add16		A, B						;sumo el angulo previo (x100) + el dato del giroscopo escalado

	st16		Z, A
	dec			COUNTER
	brne		_GET_GYRO_ANGLES_LOOP

	ret
