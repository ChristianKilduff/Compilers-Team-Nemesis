	.data
	____PARAM____add_____0: .word 0
	.text
	.data
	____PARAM____add_____1: .word 0
	.text
.text
.globl main
.globl end
.globl print_newline

main:
	li t0, 1
	la t1, ____PARAM____add_____0
	sw t0 0(t1)
	li t0, 11
	la t1, ____PARAM____add_____1
	sw t0 0(t1)
	jal ____FUNCTION___add
	.data
	pstr1: .asciz "hello"
	.text
	la    a0, 	pstr1
	li    a7, 4
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
	x: .word 0
	.text
	.data
	y: .word 0
	.text
	la t0, x
	lw t0, (t0)
	la t1, y
	lw t1, (t1)
	bgt t0, t1, ____IF____protected___Conditional____1
	call ____ELSE____protected___Conditional____1
	____IF____protected___Conditional____1: 
	la t1, x
	lw t2, 0(t1)
	addi a0, t2, 0
	li    a7, 1
	ecall
	jal ra, print_newline
	lw ra, 4(sp) # restore ra
	lw a0, 0(sp)
	addi sp, sp, 8
	ret
	call ____AFTER____protected___Conditional____1
	____ELSE____protected___Conditional____1: 
	la t1, y
	lw t2, 0(t1)
	addi a0, t2, 0
	li    a7, 1
	ecall
	jal ra, print_newline
	____AFTER____protected___Conditional____1: 
	.data
	pstr0: .asciz "done"
	.text
	la    a0, 	pstr0
	li    a7, 4
	ecall

	jal ra, print_newline
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