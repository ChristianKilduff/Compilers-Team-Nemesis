.text
.globl main
.globl end
.globl print_newline

main:
	.data
	x: .word 4
	.text
	.data
	y: .word 6
	.text
	la t0, x
	lw t0, (t0)
	la t1, y
	lw t1, (t1)
	blt t0, t1, ____IF____protected___Conditional____1
	call ____ELSE____protected___Conditional____1
	____IF____protected___Conditional____1: 
	la t1, x
	lw t2, 0(t1)
	addi a0, t2, 0
	li    a7, 1
	ecall
	.data
	pstr0: .asciz " is less than "
	.text
	la    a0, 	pstr0
	li    a7, 4
	ecall

	la t1, y
	lw t2, 0(t1)
	addi a0, t2, 0
	li    a7, 1
	ecall
	call ____AFTER____protected___Conditional____1
	____ELSE____protected___Conditional____1: 
	la t1, x
	lw t2, 0(t1)
	addi a0, t2, 0
	li    a7, 1
	ecall
	.data
	pstr1: .asciz " is greater than or equal to "
	.text
	la    a0, 	pstr1
	li    a7, 4
	ecall

	la t1, y
	lw t2, 0(t1)
	addi a0, t2, 0
	li    a7, 1
	ecall
	____AFTER____protected___Conditional____1: 
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