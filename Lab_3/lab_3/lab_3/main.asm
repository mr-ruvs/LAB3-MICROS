//***************************************************************************
// Universidad del Valle de Guatemala
// IE2023: Programación de Microcontroladores
// Autor: Ruben Granados
// Proyecto: 
// Hardware: ATMEGA328P
// Created: 13/02/2024
//***************************************************************************
// Lab 3
//***************************************************************************
/*
Setup:
	LDI R16, 0b0011_1000	;	PB
	OUT	DDRB, R16			;	set PB as OUTPUT
	ldi R16, 0b1111_1111	;	PC
	out DDRC, R16
	ldi R16, 0b1000_0011
	out DDRD, R16
Loop:
	SBI PORTB, PB5			;	on
	SBI PORTB, PB4			;	on
	SBI PORTB, PB3
	SBI PORTC, PC0			;	on
	SBI PORTC, PC1			;	on
	SBI PORTC, PC2
	SBI PORTC, PC3
	SBI PORTC, PC4
	SBI PORTC, PC5
	SBI PORTD, PD7
	RJMP Loop
*/
.include "M328PDEF.inc"
.cseg
.def cont1s = R20		; puede ser variable
.def cont_disp = R22
.org 0x00
	jmp SETUP		; vector reset

.org 0x0020			; vector 
	jmp ISR_TIMER0_OVF
//***************************************************************************
// CONFIGURACION
//***************************************************************************

T7S: .DB 0x3F,0x06,0x5B,0x4F,0X66,0X6D,0X7D,0X07,0X7F,0X6F,0X77,0X7C,0X39,0X5E,0X79,0X71

SETUP:
//
//***************************************************************************
// Stack
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R17, HIGH(RAMEND)
	OUT SPH, R17
//**************************************************	
	LDI R16, 0b0011_1000	;	PB
	OUT	DDRB, R16			;	set PB as OUTPUT
	ldi R16, 0b1111_1111	;	PC
	out DDRC, R16
	ldi R16, 0b1000_0011
	out DDRD, R16

	ldi R18, 0					; T7S
	ldi cont_disp, 0			; valor inicial
	ldi R19, 15					;	limite
	ldi ZH, HIGH(T7S << 1)
	ldi ZL, LOW(T7S << 1)
	add ZL, R18
	lpm R18, Z

	call Init_T0		; inicializar Timer0
	sei					; habilitar interrupciones globales
	ldi cont1s, 0
//***************************************************************************
LOOP:
	mov R18, cont_disp			; para llamar la lista
	ldi ZH, HIGH(T7S << 1)
	ldi ZL, LOW(T7S << 1)
	add ZL, R18
	lpm R18, Z					; almacenar el valor de la lista

	sbrc R18, PC6
	sbi PIND, PD7
	sbrs R18, PC6
	cbi PORTD, PD7
	out PORTC, R18				; mostrar en el display
	sbi PORTB, PB4		; seg
	sbi PORTB, PB3		; minutos
	

	cpi cont1s, 100
	brne LOOP
	clr cont1s

	sbi PINB, PB5
	
	cpse cont_disp, R19
	call AUMENTAR
	ldi cont_disp, 0


	rjmp LOOP
//***************************************************************************
// TIMER0
//***************************************************************************
Init_T0:
	ldi R16, (1 << CS02)|(1 << CS00)	;config prescaler 1024
	out TCCR0B, R16
	ldi R16, 99							;valor desbordamiento
	out TCNT0, R16						; valor inicial contador
	ldi R16, (1 << TOIE0)
	sts TIMSK0, R16
	ret
//***************************************************************************
// ISR Timer 0 Overflow
//***************************************************************************
ISR_TIMER0_OVF:
	push R16				; guardar en pila R16
	in R16, sreg
	push R16				; guardar en pila SREG
//**************************
	ldi R16, 99				; cargar el valor de desbordamiento
	out TCNT0, R16			; cargar valor inicial
	sbi TIFR0, TOV0			; borrar bandra TOV0
	inc cont1s					; incrementar contador 10 ms
//**************************
	pop R16					; obtener SREG
	out sreg, R16			; restaurar valor antiguo SREG
	pop R16					; obtener valor R16
	reti
//***************************************************************************
AUMENTAR:
	inc cont_disp
	rjmp LOOP
