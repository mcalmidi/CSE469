// Akhila Narayanan and Manasvini Calmidi
// May 15, 2024
// CSE 469
// Lab 4

// This program adds two floating point numbers
.global _start
_start:

MOVW R0, #0x0000
MOVT R0, #0x3FC0 // float 1 = 1.5
MOVW R1, #0x0000
MOVT R1, #0x4000 // float 2 = 2.0

// Mask and shift down the 2 exponents.
MOVW R2, #0x0000
MOVT R2, #0x7F80 // Exponent mask

AND R3, R0, R2 // AND R0 with mask
AND R4, R1, R2 // AND R1 with mask
LSR R3, R3, #23 // right shift so float 1's LSBs are exponent bits
LSR R4, R4, #23 // right shift so float 2's LSBs are exponent bits

// Mask the two fractions and append leading 1’s to form the mantissas.
MOVW R2, #0xFFFF
MOVT R2, #0x007F // Fraction mask

AND R5, R0, R2 // AND R0 with mask
AND R6, R1, R2 // AND R1 with mask

MOVW R2, #0x0000
MOVT R2, #0x0080 // Mantissa Leading 1 mask

ORR R5, R5, R2 // Append leading 1 to mantissa of float 1
ORR R6, R6, R2 // Append leading 1 to mantissa of float 2

// Compare the exponents by subtracting the smaller from the larger. 
// Set the exponent of the result to be the larger of the exponents.
CMP R3, R4
MOVGT R7, R3 // if R3 is larger, we save R3's exponent
MOVLE R7, R4 // if R4 is larger (or equal), we save R4's exponent

// Right shift the mantissa of the smaller number by the difference between 
// exponents to align the two mantissas.
CMP R3, R4
MOVGT R8, R6 // if float 1 has larger exponent, store float 2 mantissa
MOVLE R8, R5 // if float 2 has larger (or equal) exponent, we save float 1 mantissa

CMP R3, R4
SUBGT R9, R3, R4 // store diff between exponents (R3 > R4)
SUBLE R9, R4, R3 // store diff between exponents (R3 <= R4)

LSR R8, R8, R9 // right shift smaller mantissa by exponent diff

// Sum the mantissas.
CMP R3, R4
ADDGT R10, R8, R5 // sum shifted smaller mantissa with non-shifted mantissa
ADDLE R10, R8, R6

// Normalize the result, i.e., if the sum overflows, right shift by 1 and increment 
// the exponent by 1. Rounding. 
MOVW R2, #0x0000
MOVT R2, #0x0100 // Threshold
AND R11, R10, R2 // clear summed mantissa to see if 24th bit is 1
CMP R11, #0
ADDNE R7, R7, #1 // if 24th bit is 1, add 1 to exponent
LSRNE R10, R10, #1 // if 24th bit is 1, right shift mantissa by 1 (less precise)

// Strip the leading 1 off the resulting mantissa,
MOVW R2, #0xFFFF // leading 1 mask
MOVT R2, #0xFF7F
AND R10, R10, R2

// merge the exponent and mantissa bits. (no need to worry about sign because result is always positive = 0)
LSL R12, R7, #23 // left shift exponent to correct location
ORR R10, R10, R12 // merge exponent with mantissa