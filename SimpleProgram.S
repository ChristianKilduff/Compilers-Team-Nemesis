main:
	.data
pstr0: .asciz "x"
.text
la    a0, pstr0
li    a7, 4
ecall
