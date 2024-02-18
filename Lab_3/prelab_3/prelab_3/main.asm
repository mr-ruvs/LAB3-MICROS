//***************************************************************************
// Universidad del Valle de Guatemala
// IE2023: Programación de Microcontroladores
// Autor: Ruben Granados
// Proyecto: prelab3
// Hardware: ATMEGA328P
// Created: 12/02/2024
//***************************************************************************
// Encabezado
//***************************************************************************
.include "M328PDEF.inc"
.cseg
.def cont_4b = R20
.org 0x0000
	jmp MAIN		; vector reset

.org 0x0006			; vector de ISR: PCINT0
	jmp ISR_PCINT0

MAIN:
//***************************************************************************
// Stack
	LDI R16, LOW(RAMEND)
	OUT SPL, R16
	LDI R17, HIGH(RAMEND)
	OUT SPH, R17
//***************************************************************************
// CONFIGURACION
//***************************************************************************
SETUP:
	sbi DDRB, PB5								; output
	cbi PORTB, PB5								; off

	//ldi R16, (1 << PD2)|(1 << PD3)|(1 << PD4)	
	LDI R16, 0b0011_1111
	out DDRD, R16								; outputs
	
	sbi PORTB, PB0		; pullup
	cbi DDRB, PB0		; input

	sbi PORTB, PB1		; pullup
	cbi DDRB, PB1		; input

	ldi R16, (1 << PCINT1)|(1 << PCINT0)
	sts PCMSK0, R16		; habilitar PCINT en PCINT0 y PCINT1

	ldi R16, (1 << PCIE0)
	sts PCICR, R16		; habilitar ISR PCINT[7:0] (registro de control)

	sei					; habilitar interrupciones globales

	ldi cont_4b, 0
	ldi R21, 0
//***************************************************************************
// GENERAL
//***************************************************************************
LOOP:
	mov R21, cont_4b
	lsl R21
	lsl R21
	out PORTD, R21
	jmp LOOP
//***************************************************************************
// ISR INT0
//***************************************************************************
ISR_PCINT0:
	push R16			; guardar en pila
	in R16, SREG
	push R16

	in R18, PINB
	
	sbrc R18, PB0
	jmp CHECKPB1
	inc cont_4b
	cpi cont_4b, 16
	brne SALIR
	ldi cont_4b, 0
	jmp SALIR

CHECKPB1:
	sbrc R18, PB1
	jmp SALIR
	dec cont_4b
	brne SALIR
	ldi cont_4b, 15

SALIR:
	sbi PINB, PB5		; toggle de PB5
	sbi PCIFR, PCIF0	; bandera ISR PCINT0 OFF

	pop R16				; obtener valores
	out SREG, R16
	pop R16
	reti


	

	