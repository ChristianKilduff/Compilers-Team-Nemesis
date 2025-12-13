.text
.globl main
.globl end
.globl print_newline

main:
	.data
____PARAM____add_____0: .word 0
	____PARAM____add_____1: .word 0
	____RETURN___add_____: .word 0
	x: .word 0
	y: .word 0
		____space: .asciz " "
	space: .word 	____space
	.text

	.data
	p: .word 0
	.text
	li t0, 1
	la t1, ____PARAM____add_____0
	sw t0 0(t1)
	li t0, 2
	la t1, ____PARAM____add_____1
	sw t0 0(t1)
	jal ra, ____FUNCTION___add
	la t0, ____RETURN___add_____
	lw t1 (t0)
	la t2, p
	sw t1 (t2)
	
	la t1, p
	lw t2, 0(t1)
	addi a0, t2, 0
	li    a7, 1
	ecall
	jal ra, print_newline
	jal end
____FUNCTION___add:
	addi sp, sp, -8
	sw ra, 4(sp)     # save return address
	sw a0, 0(sp)

	la t0, ____PARAM____add_____0
	lw t1 (t0)
	la t2, x
	sw t1 (t2)
	
	la t0, ____PARAM____add_____1
	lw t1 (t0)
	la t2, y
	sw t1 (t2)
		.data
	s: .word 0
	.text
	la t0, x
	lw t0, 0(t0)
	la t1, y
	lw t1, 0(t1)
	la t2, s
	add t3, t0, t1
	sw t3, (t2)
	la t0, s
	lw t1 (t0)
	la t2, ____RETURN___add_____
	sw t1 (t2)
	
	lw ra, 4(sp) # restore ra
	lw a0, 0(sp)
	addi sp, sp, 8
	ret
	lw ra, 4(sp) # restore ra
	lw a0, 0(sp)
	addi sp, sp, 8
	ret

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