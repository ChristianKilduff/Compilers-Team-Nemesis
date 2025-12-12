.text
.globl main
.globl end
.globl print_newline

main:
	.data
____PARAM____print_array_____1: .word 0
		____space: .asciz " "
	space: .word 	____space
	.text

	.data
	list: .space 1600
	count_arr_3:   .word 0
	.text

	
	#====
	la t0, count_arr_3
	lw t1, 0(t0)
	la t2, list
	slli t3, t1, 3
	add t3, t2, t3
	.data
	double____1: .double 1.0
	.text
	la t4, double____1
	fld fa0, 0(t4)
	fsd fa0, 0(t3)
	addi t1, t1, 1
	la t0, count_arr_3
	sw t1, 0(t0)
	#_____
	
	
	#====
	la t0, count_arr_3
	lw t1, 0(t0)
	la t2, list
	slli t3, t1, 3
	add t3, t2, t3
	.data
	double____2: .double 2.0
	.text
	la t4, double____2
	fld fa0, 0(t4)
	fsd fa0, 0(t3)
	addi t1, t1, 1
	la t0, count_arr_3
	sw t1, 0(t0)
	#_____
	
	
	#====
	la t0, count_arr_3
	lw t1, 0(t0)
	la t2, list
	slli t3, t1, 3
	add t3, t2, t3
	.data
	double____3: .double 3.0
	.text
	la t4, double____3
	fld fa0, 0(t4)
	fsd fa0, 0(t3)
	addi t1, t1, 1
	la t0, count_arr_3
	sw t1, 0(t0)
	#_____
	
	
	#====
	la t0, count_arr_3
	lw t1, 0(t0)
	la t2, list
	slli t3, t1, 3
	add t3, t2, t3
	.data
	double____4: .double 4.0
	.text
	la t4, double____4
	fld fa0, 0(t4)
	fsd fa0, 0(t3)
	addi t1, t1, 1
	la t0, count_arr_3
	sw t1, 0(t0)
	#_____
	
	
	li t0, 2
	la t1, ____PARAM____print_array_____1
	sw t0 0(t1)
	jal ra, ____FUNCTION___print_array
	jal end
____FUNCTION___print_array:
	addi sp, sp, -8
	sw ra, 4(sp)     # save return address
	sw a0, 0(sp)

	

	
la t0, ____PARAM____print_array_____1
	lw t1 (t0)
	la t2, p_n
	sw t1 (t2)
	.data
	p_list: .space 1600
	count_arr_1:   .word 0
	.text

	.data
	p_n: .word 0
	.text
	
	la t0, p_list
	lw t1, count_arr_1
	li t2, 0 
	
	____print_arr_____loop_0:
	bge t2, t1, ____print_arr_____done_0
	slli t3, t2, 3    # t3 = index * 8 (double size)
	add t3, t0, t3    # t3 = address of name[index]
	fld fa0, 0(t3)    # load double into fa0
	li a7, 3
	ecall
	
	lw a0, space
	li a7, 4
	ecall
	addi t2, t2, 1
	j ____print_arr_____loop_0
	
	____print_arr_____done_0:
	
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