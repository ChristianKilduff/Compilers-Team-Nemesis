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
	list: .space 400
	count_arr_1:   .word 0
	.text

	
	#====
	la t0, count_arr_1
	lw t1, 0(t0)
	la t2, list
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
	
	
	#====
	la t0, count_arr_1
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
	la t0, count_arr_1
	sw t1, 0(t0)
	#_____
	
	
	la t0, list
	lw t1, count_arr_1
	li t2, 0 
	
	loop_2:
	bge t2, t1, done_2
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
	j loop_2
	
	done_2:
	
	jal ra, print_newline
	
	li t1, 0
	la t0, count_arr_1
	sw t1, 0(t0)
	
	la t0, list
	lw t1, count_arr_1
	li t2, 0 
	
	loop_3:
	bge t2, t1, done_3
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
	j loop_3
	
	done_3:
	
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