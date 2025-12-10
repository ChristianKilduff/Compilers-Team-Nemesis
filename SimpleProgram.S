	.data
	space_tmp____protected: .asciz " "
	space: .word space_tmp____protected
	.text
.text
.globl main
.globl end
.globl print_newline

main:
	.data
	a: .word 1
	.text
	.data
	b: .word 2
	.text
	.data
	c: .word 0
	.text
	la t2, c
	la t0, a
	la t1, b
	lw t0, 0(t0)
	lw t1, 0(t1)
	div t3, t0, t1
	sw t3, (t2)
	la t1, c
	lw t2, 0(t1)
	addi a0, t2, 0
	li    a7, 1
	ecall
	jal ra, print_newline
	jal end

print_newline:
	addi sp, sp, -8
	sw ra, 4(sp)     # save return address
	sw a0, 0(sp)     # save n
	li    a0, '\n'
	li    a7, 11
	ecall
	lw ra, 4(sp)       # restore ra
	lw a0, 0(sp)
	addi sp, sp, 8
	ret
end:
	# print new line
	jal ra, print_newline

	li    a0, 0     # Load the exit code (e.g., 0 for success) into a0
	li    a7, 93    # Load the Exit2 syscall number into a7
	ecall        # Execute the system call to exit