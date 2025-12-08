.text
.globl main
.globl end
.globl print_newline

main:
	.data
	x: .word 3
	.text
	.data
	y: .word 3
	.text
	___CHECK______protected___loop____0:
	la t0, x
	lw t0, (t0)
	la t1, y
	lw t1, (t1)
	bge t0, t1, ______protected___loop____0
	call ____return_from______protected___loop____0
	______protected___loop____0: 
	.data
	pstr0: .asciz "looping"
	.text
	la    a0, 	pstr0
	li    a7, 4
	ecall

	call print_newline
	call ___CHECK______protected___loop____0
	____return_from______protected___loop____0:
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