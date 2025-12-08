.text
.globl main
.globl end
.globl print_newline

main:
	.data
	____ARRAY0____ELEMENT____0: .word 1
	.text
	.data
	____ARRAY0____ELEMENT____1: .word 2
	.text
	.data
	____ARRAY0____ELEMENT____2: .word 3
	.text
	.data
	x: .word 4
	.text
	.data
	____ARRAY0____ELEMENT____3: .word 1
	.text
	.data
	l: .word 3
	.text
	la t1, l
	lw t2, 0(t1)
	addi a0, t2, 0
	li    a7, 1
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