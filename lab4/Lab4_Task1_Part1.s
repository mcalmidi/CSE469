.text
.align=2

.global _start
_start:
	
	mov r0, #4
	mov r1, #5
	add r2, r0, r1
	add r3, r0, r1
	add r3, r3, r2
	sub r3, r3, #3
	str r3, [r0, #0x9C]
S:
	B S
.end