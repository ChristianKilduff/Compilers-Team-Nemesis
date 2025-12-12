.text
.globl main
.globl end
.globl print_newline

main:
	.data
____PARAM____i_____0: .word 0
		____space: .asciz " "
	space: .word 	____space
	.text

	li t0, 3
	la t1, ____PARAM____i_____0
	sw t0 0(t1)
	jal ra, ____FUNCTION___i
	.data
	b: .space 1600
	count_arr_5:   .word 0
	.text

	
	li t1, 0
	la t0, count_arr_5
	sw t1, 0(t0)
	la t0, b
	la t1, ____RETURN___i_____
	li t2, 1600
	_____copy_loop____5:
	lb t3, 0(t1)
	sb t3, 0(t0)
	addi t0, t0, 1
	addi t1, t1, 1
	addi t2, t2, -1
	bnez t2, _____copy_loop____5
	la t5, count_arr_3
	lw t5, (t5)
	la t4, count_arr_5
	sw t5, (t4)
	
	
	la t0, b
	lw t1, count_arr_5
	li t2, 0 
	
	____print_arr_____loop_6:
	bge t2, t1, ____print_arr_____done_6
	slli t3, t2, 3    # t3 = index * 8 (double size)
	add t3, t0, t3    # t3 = address of name[index]
	fld fa0, 0(t3)    # load double into fa0
	li a7, 3
	ecall
	
	lw a0, space
	li a7, 4
	ecall
	addi t2, t2, 1
	j ____print_arr_____loop_6
	
	____print_arr_____done_6:
	
	jal ra, print_newline
	jal end
____FUNCTION___i:
	addi sp, sp, -8
	sw ra, 4(sp)     # save return address
	sw a0, 0(sp)

	
la t0, ____PARAM____i_____0
	lw t1 (t0)
	la t2, n
	sw t1 (t2)
	.data
	n: .word 0
	.text
	.data
	a: .space 1600
	count_arr_1:   .word 0
	.text

	
	#====
	la t0, count_arr_1
	lw t1, 0(t0)
	la t2, a
	slli t3, t1, 3
	add t3, t2, t3
	.data
	double____0: .double 5.0
	.text
	la t4, double____0
	fld fa0, 0(t4)
	fsd fa0, 0(t3)
	addi t1, t1, 1
	la t0, count_arr_1
	sw t1, 0(t0)
	#_____
	
	
	#====
	la t0, count_arr_1
	lw t1, 0(t0)
	la t2, a
	slli t3, t1, 3
	add t3, t2, t3
	.data
	double____1: .double 6.0
	.text
	la t4, double____1
	fld fa0, 0(t4)
	fsd fa0, 0(t3)
	addi t1, t1, 1
	la t0, count_arr_1
	sw t1, 0(t0)
	#_____
	
	
	#====
	la t0, count_arr_1
	lw t1, 0(t0)
	la t2, a
	slli t3, t1, 3
	add t3, t2, t3
	.data
	double____2: .double 7.0
	.text
	la t4, double____2
	fld fa0, 0(t4)
	fsd fa0, 0(t3)
	addi t1, t1, 1
	la t0, count_arr_1
	sw t1, 0(t0)
	#_____
	
	
	#====
	la t0, count_arr_1
	lw t1, 0(t0)
	la t2, a
	slli t3, t1, 3
	add t3, t2, t3
	.data
	double____3: .double 8.0
	.text
	la t4, double____3
	fld fa0, 0(t4)
	fsd fa0, 0(t3)
	addi t1, t1, 1
	la t0, count_arr_1
	sw t1, 0(t0)
	#_____
	
	.data
	____RETURN___i_____: .space 1600
	count_arr_3:   .word 0
	.text

	
	li t1, 0
	la t0, count_arr_3
	sw t1, 0(t0)
	la t0, ____RETURN___i_____
	la t1, a
	li t2, 1600
	_____copy_loop____4:
	lb t3, 0(t1)
	sb t3, 0(t0)
	addi t0, t0, 1
	addi t1, t1, 1
	addi t2, t2, -1
	bnez t2, _____copy_loop____4
	la t5, count_arr_1
	lw t5, (t5)
	la t4, count_arr_3
	sw t5, (t4)
	
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