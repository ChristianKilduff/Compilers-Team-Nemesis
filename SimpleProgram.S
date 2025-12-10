	.data
	space_tmp____protected: .asciz " "
	space: .word space_tmp____protected
	.text
	.data
	____PARAM____read_array_____0: .word 0
	.text
.text
.globl main
.globl end
.globl print_newline

main:
	.data
	param_list: .space 400
	count_arr_1:   .word 0
	.text

	
	#====
	la t0, count_arr_1
	lw t1, 0(t0)
	la t2, param_list
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
	
	li t0, 4
	la t1, ____PARAM____read_array_____0
	sw t0 0(t1)
	jal ____FUNCTION___read_array
	
	la t0, param_list
	lw t1, count_arr_1
	li t2, 0 
	
	loop:
	bge t2, t1, done  # if index >= count, exit loop
	slli t3, t2, 3    # t3 = index * 8 (double size)
	add t3, t0, t3    # t3 = address of name[index]
	fld fa0, 0(t3)    # load double into fa0
	li a7, 3
	ecall
	
	la t5, space
	lw a0, (t5)
	li a7, 4
	ecall
	addi t2, t2, 1
	j loop
	
	done:
	
	jal ra, print_newline
	jal end
____FUNCTION___read_array:
	addi sp, sp, -8
	sw ra, 4(sp)     # save return address
	sw a0, 0(sp)

	
la t0, ____PARAM____read_array_____0
	lw t1 (t0)
	la t2, n
	sw t1 (t2)
	.data
	n: .word 0
	.text
	
	li t1, 0
	la t0, count_arr_1
	sw t1, 0(t0)
	.data
	pstr0: .asciz "Input "
	.text
	la    a0, 	pstr0
	li    a7, 4
	ecall

	la t1, n
	lw t2, 0(t1)
	addi a0, t2, 0
	li    a7, 1
	ecall
	.data
	pstr1: .asciz " doubles:"
	.text
	la    a0, 	pstr1
	li    a7, 4
	ecall

	jal ra, print_newline
	.data
	____loop_index____1: .word 0
	.text
	la t0, ____loop_index____1
	la t2, n
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
	la t2, param_list
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