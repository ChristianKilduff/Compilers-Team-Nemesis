.text
.globl main
.globl end
.globl print_newline

main:
	.data
	____ARRAY0____ELEMENT____0: .double 1.0
	.text
	.data
	____ARRAY0____ELEMENT____1: .double 2.2
	.text
	.data
	____ARRAY0____ELEMENT____2: .double 3.0
	.text
	.data
	i: .word 2
	.text
	.data
	b: .word 0
	.text
	la t0, i
	lw t1 (t0)
	la t2, b
	sw t1 (t2)
	.data
	x: .double 0.0
	.text
	la t0, ____ARRAY0____ELEMENT____1
	fld fa0 (t0)
	la t2, x
	fsd fa0 (t2)
	la t0, ____ARRAY0____ELEMENT____0
	fld fa0, (t0)
	li a7, 3
	ecall
	.data
	pstr0: .asciz " "
	.text
	la    a0, 	pstr0
	li    a7, 4
	ecall

	la t0, ____ARRAY0____ELEMENT____1
	fld fa0, (t0)
	li a7, 3
	ecall
	.data
	pstr1: .asciz " "
	.text
	la    a0, 	pstr1
	li    a7, 4
	ecall

	la t0, ____ARRAY0____ELEMENT____2
	fld fa0, (t0)
	li a7, 3
	ecall
	.data
	pstr2: .asciz " "
	.text
	la    a0, 	pstr2
	li    a7, 4
	ecall

	call print_newline
	la t0, x
	fld fa0, (t0)
	li a7, 3
	ecall
	call print_newline
	jal end

print_newline:
	li    a0, '\n'
	li    a7, 11
	ecall
	ret
end:
	# print new line
	call print_newline

	li    a0, 0     # Load the exit code (e.g., 0 for success) into a0
	li    a7, 93    # Load the Exit2 syscall number into a7
	ecall        # Execute the system call to exit