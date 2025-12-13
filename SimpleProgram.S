.text
.globl main
.globl end
.globl print_newline

main:
	.data
	____space: .asciz " "
	space: .word 	____space
	.text

	
	.data
	count_arr_list:   .word 0
	list: .space 1600
	.text

	
	#====
	la t0, count_arr_list
	lw t1, 0(t0)
	la t2, list
	slli t3, t1, 2
	add t3, t2, t3
	li t4, 0
	sw t4, 0(t3)
	addi t1, t1, 1
	la t0, count_arr_list
	sw t1, 0(t0)
	#_____
	
	
	#====
	la t0, count_arr_list
	lw t1, 0(t0)
	la t2, list
	slli t3, t1, 2
	add t3, t2, t3
	li t4, 1
	sw t4, 0(t3)
	addi t1, t1, 1
	la t0, count_arr_list
	sw t1, 0(t0)
	#_____
	
	
	#====
	la t0, count_arr_list
	lw t1, 0(t0)
	la t2, list
	slli t3, t1, 2
	add t3, t2, t3
	li t4, 2
	sw t4, 0(t3)
	addi t1, t1, 1
	la t0, count_arr_list
	sw t1, 0(t0)
	#_____
	
	.data
	v: .word 23
	.text
	.data
	i: .word 2
	.text
	la t0, i
	lw t0, (t0)
	addi t0, t0, -1
	la t1, count_arr_list
	lw t2, 0(t1)
	addi t2, t2, -1
	la   t3, list
	______remove_loop_______0:
	bge  t0, t2, _____DONE_____REMOVE_____1
	slli t4, t0, 2
	add  t5, t3, t4
	lw t6, 4(t5)
	sw t6, 0(t5)
	addi t0, t0, 1
	j ______remove_loop_______0
	_____DONE_____REMOVE_____1:
	sw   t2, 0(t1)
	
	la t0, list
	lw t1, count_arr_list
	li t2, 0 
	
	____print_arr_____loop_2:
	bge t2, t1, ____print_arr_____done_2
	slli t3, t2, 2    # t3 = index * 4 (word size)
	add t3, t0, t3    # t3 = address of arr[index]
	lw a0, 0(t3)      # load integer into a0
	li a7, 1
	ecall
	
	lw a0, space
	li a7, 4
	ecall
	addi t2, t2, 1
	j ____print_arr_____loop_2
	
	____print_arr_____done_2:
	
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