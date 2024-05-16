// Akhila Narayanan and Manasvini Calmidi
// May 15, 2024
// CSE 469
// Lab 4

// This program counts the number of 1s in a binary number
.global _start
_start:
	MOV R0, #0 // counter
    MOVW R1, 0x071A // last 4 digits of input
	MOVT R1, 0x4DB2 // first 4 digits of input
    MOV R2, #32 // loop counter

FOR:
	CMP   R2, #0      // check that loop counter is > 0
	BLE DONE
    AND   R3, R1, #1 // store LSB of R1 in R3
	CMP   R3, #1     // check that LSB is 1
	ADDEQ R0, R0, #1 // increment counter if LSB is 1
    LSR   R1, R1, #1 // shift R1 by 1 bit
    SUB   R2, R2, #1 // decrement loop counter
    B FOR 
DONE: