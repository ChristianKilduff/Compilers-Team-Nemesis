.text
.globl main
.globl end
.globl print_newline

main:
	.data
	________tmp_str_____0: .asciz "3"
	____tmp_str_____0: .word 	________tmp_str_____0
		________tmp_str_____1: .asciz "2"
	____tmp_str_____1: .word 	________tmp_str_____1
		____space: .asciz " "
	space: .word 	____space
	.text

	.data
	____loop_index____1: .word 0
	.text
	la t0, ____loop_index____1
	li t1, 3
	sw t1, (t0)
	______protected___loop____1:
	la t0, ____loop_index____1
	lw t1, (t0)
	beqz t1, ____return_from______protected___loop____1
	addi t1, t1, -1
	sw t1, (t0)
	lw a0, ____tmp_str_____0
	li    a7, 4
	ecall

	jal ra, print_newline
	.data
	____loop_index____2: .word 0
	.text
	la t0, ____loop_index____2
	li t1, 2
	sw t1, (t0)
	______protected___loop____2:
	la t0, ____loop_index____2
	lw t1, (t0)
	beqz t1, ____return_from______protected___loop____2
	addi t1, t1, -1
	sw t1, (t0)
	lw a0, ____tmp_str_____1
	li    a7, 4
	ecall

	jal ra, print_newline
	j ______protected___loop____2
	____return_from______protected___loop____2:
	j ______protected___loop____1
	____return_from______protected___loop____1:
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