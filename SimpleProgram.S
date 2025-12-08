.text
.globl main
.globl end
.globl print_newline

main:
	.data
	x_tmp____protected: .asciz "hello"
	x: .word x_tmp____protected
	.text
	.data
	tmpStr_1: .asciz "hello world"
	.text
	la t0,x
	la t1, tmpStr_1
	sw t1, (t0)
	lw a0, x
	li a7, 4
	ecall
	jal end

print_newline:
	li    a0, '\n'
	li    a7, 11
	ecall
	ret
end:
	# print new line
	call print_newline

	li    a0, 0     # Load the exit code (e.g., 0 for success) into a0
	li    a7, 93    # Load the Exit2 syscall number into a7
	ecall        # Execute the system call to exit