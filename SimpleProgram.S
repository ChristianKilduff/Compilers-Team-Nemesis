.text
.globl main
.globl end
.globl print_newline

main:
	.data
____PARAM____read_array_____0: .word 0
		________tmp_str_____1: .asciz "Input "
	____tmp_str_____1: .word 	________tmp_str_____1
		________tmp_str_____2: .asciz " doubles:"
	____tmp_str_____2: .word 	________tmp_str_____2
	____PARAM____print_array_____1: .word 0
		____space: .asciz " "
	space: .word 	____space
	.text

	.data
	list: .space 400
	count_arr_7:   .word 0
	.text

	
	#====
	la t0, count_arr_7
	lw t1, 0(t0)
	la t2, list
	slli t3, t1, 3
	add t3, t2, t3
	.data
	double____3: .double 1.0
	.text
	la t4, double____3
	fld fa0, 0(t4)
	fsd fa0, 0(t3)
	addi t1, t1, 1
	la t0, count_arr_7
	sw t1, 0(t0)
	#_____
	
	
	#====
	la t0, count_arr_7
	lw t1, 0(t0)
	la t2, list
	slli t3, t1, 3
	add t3, t2, t3
	.data
	double____4: .double 2.0
	.text
	la t4, double____4
	fld fa0, 0(t4)
	fsd fa0, 0(t3)
	addi t1, t1, 1
	la t0, count_arr_7
	sw t1, 0(t0)
	#_____
	
	
	#====
	la t0, count_arr_7
	lw t1, 0(t0)
	la t2, list
	slli t3, t1, 3
	add t3, t2, t3
	.data
	double____5: .double 3.0
	.text
	la t4, double____5
	fld fa0, 0(t4)
	fsd fa0, 0(t3)
	addi t1, t1, 1
	la t0, count_arr_7
	sw t1, 0(t0)
	#_____
	
	
	#====
	la t0, count_arr_7
	lw t1, 0(t0)
	la t2, list
	slli t3, t1, 3
	add t3, t2, t3
	.data
	double____6: .double 4.0
	.text
	la t4, double____6
	fld fa0, 0(t4)
	fsd fa0, 0(t3)
	addi t1, t1, 1
	la t0, count_arr_7
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
	p_list: .space 400
	count_arr_5:   .word 0
	.text

	.data
	p_n: .word 0
	.text
	.data
	i_p: .word 1
	.text
	.data
	v: .double 0.0
	.text
	.data
	____loop_index____2: .word 0
	.text
	la t0, ____loop_index____2
	la t2, p_n
	lw t1, (t2)
	sw t1, (t0)
	______protected___loop____2:
	la t0, ____loop_index____2
	lw t1, (t0)
	beqz t1, ____return_from______protected___loop____2
	addi t1, t1, -1
	sw t1, (t0)
	la t0, v
	lw t1, i_p
	addi t1, t1, -1
	
	la t2, p_list
	slli t3, t1, 3
	add t3, t2, t3
	fld fa0, (t3)
	fsd fa0, (t0)
	la t0, v
	fld fa0, (t0)
	li a7, 3
	ecall
	jal ra, print_newline
	la t0, i_p
	lw t0, 0(t0)
	li t1, 1
	la t2, i_p
	add t3, t0, t1
	sw t3, (t2)
	j ______protected___loop____2
	____return_from______protected___loop____2:
	lw ra, 4(sp) # restore ra
	lw a0, 0(sp)
	addi sp, sp, 8
	ret
____FUNCTION___read_array:
	addi sp, sp, -8
	sw ra, 4(sp)     # save return address
	sw a0, 0(sp)

	
la t0, ____PARAM____read_array_____0
	lw t1 (t0)
	la t2, r_n
	sw t1 (t2)
	.data
	r_n: .word 0
	.text
	.data
	r_list: .space 400
	count_arr_1:   .word 0
	.text

	
	#====
	la t0, count_arr_1
	lw t1, 0(t0)
	la t2, r_list
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
	lw a0, ____tmp_str_____1
	li    a7, 4
	ecall

	la t1, r_n
	lw t2, 0(t1)
	addi a0, t2, 0
	li    a7, 1
	ecall
	lw a0, ____tmp_str_____2
	li    a7, 4
	ecall

	jal ra, print_newline
	.data
	____loop_index____1: .word 0
	.text
	la t0, ____loop_index____1
	la t2, r_n
	lw t1, (t2)
	sw t1, (t0)
	______protected___loop____1:
	la t0, ____loop_index____1
	lw t1, (t0)
	beqz t1, ____return_from______protected___loop____1
	addi t1, t1, -1
	sw t1, (t0)
	.data
	i: .double 0.0
	.text
	li a7, 7
	ecall
	la t0, i
	fsd fa0 (t0)
	
	#====
	la t0, count_arr_1
	lw t1, 0(t0)
	la t2, r_list
	slli t3, t1, 3
	add t3, t2, t3
	la t4, i
	fld fa0, (t4)
	fsd fa0, 0(t3)
	addi t1, t1, 1
	la t0, count_arr_1
	sw t1, 0(t0)
	#_____
	
	j ______protected___loop____1
	____return_from______protected___loop____1:
	.data
	____RETURN____read_array____: .space 400
	count_arr_3:   .word 0
	.text

	
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