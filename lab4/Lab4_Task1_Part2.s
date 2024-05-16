// Akhila Narayanan and Manasvini Calmidi
// May 15, 2024
// CSE 469
// Lab 4

// This code calculates the factorial of a number
.global _start
_start:
	
	MOV r0, #5
LOOP:
	PUSH {LR}
	CMP R0, #1
	BGT ELSE
	MOV R0, #1
	MOV PC, LR
ELSE:
	SUB R0, R0, #1
	BL LOOP
	POP {LR}
	MUL R0, R1, R0
	MOV PC, LR
	.end