.text
.globl main
.globl end
.globl print_newline

main:
	.data
	________tmp_str_____0: .asciz ""
	____tmp_str_____0: .word 	________tmp_str_____0
		________tmp_str_____2: .asciz "Hello, "
	____tmp_str_____2: .word 	________tmp_str_____2
		________tmp_str_____3: .asciz "total = "
	____tmp_str_____3: .word 	________tmp_str_____3
		________tmp_str_____4: .asciz "savings = "
	____tmp_str_____4: .word 	________tmp_str_____4
		____space: .asciz " "
	space: .word 	____space
	.text

	
	.data
	name: .word ____tmp_str_____0
	.text
	
	.data
	income: .double 0.0
	.text
	.data
	rent: .double 0.0
	.text
	.data
	food: .double 0.0
	.text
	.data
	fun: .double 0.0
	.text
	.data 
	input_space_____1 : .space 200 
	.text
	li a7, 8
	 la a0, input_space_____1
	li a1, 200
	ecall
	la t0, name
	la t1, input_space_____1
	sw t1, (t0)
	li a7, 7
	ecall
	la t0, income
	fsd fa0 (t0)
	li a7, 7
	ecall
	la t0, rent
	fsd fa0 (t0)
	li a7, 7
	ecall
	la t0, food
	fsd fa0 (t0)
	li a7, 7
	ecall
	la t0, fun
	fsd fa0 (t0)
	.data
	total: .double 0
	.text
	la t0, rent
	fld fa0, 0(t0)
	la t1, food
	fld fa1, 0(t1)
	la t2, total
	fadd.d fa2, fa0, fa1
	fsd fa2, (t2)
	la t0, total
	fld fa0, 0(t0)
	la t1, fun
	fld fa1, 0(t1)
	la t2, total
	fadd.d fa2, fa0, fa1
	fsd fa2, (t2)
	.data
	savings: .double 0
	.text
	la t0, income
	fld fa0, 0(t0)
	la t1, total
	fld fa1, 0(t1)
	la t2, savings
	fsub.d fa2, fa0, fa1
	fsd fa2, (t2)
	lw a0, ____tmp_str_____2
	li    a7, 4
	ecall

	lw a0, name
	li a7, 4
	ecall
	jal ra, print_newline
	lw a0, ____tmp_str_____3
	li    a7, 4
	ecall

	la t0, total
	fld fa0, (t0)
	li a7, 3
	ecall
	jal ra, print_newline
	lw a0, ____tmp_str_____4
	li    a7, 4
	ecall

	la t0, savings
	fld fa0, (t0)
	li a7, 3
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