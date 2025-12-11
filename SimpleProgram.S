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
	n: .word 0
	.text
	.data
	pstr0: .asciz "input the array size"
	.text
	la    a0, 	pstr0
	li    a7, 4
	ecall

	jal ra, print_newline
	li a7, 5
	ecall
	la t0, n
	sw a0 (t0)
	___CHECK______protected___loop____0:
	la t0, n
	lw t0, (t0)
	li t1, 0
	ble t0, t1, ______protected___loop____0
	jal ra, ____return_from______protected___loop____0
	______protected___loop____0: 
	.data
	pstr1: .asciz "Array size n must be positive. Try again"
	.text
	la    a0, 	pstr1
	li    a7, 4
	ecall

	jal ra, print_newline
	li a7, 5
	ecall
	la t0, n
	sw a0 (t0)
	jal ra, ___CHECK______protected___loop____0
	____return_from______protected___loop____0:
	.data
	listA: .space 400
	count_arr_1:   .word 0
	.text

	
	#====
	la t0, count_arr_1
	lw t1, 0(t0)
	la t2, listA
	slli t3, t1, 3
	add t3, t2, t3
	.data
	double____0: .double 0.0
	.text
	la t4, double____0
	fld fa0, 0(t4)
	fsd fa0, 0(t3)
	addi t1, t1, 1
	la t0, count_arr_1
	sw t1, 0(t0)
	#_____
	
	
	li t1, 0
	la t0, count_arr_1
	sw t1, 0(t0)
	.data
	i: .word 0
	.text
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