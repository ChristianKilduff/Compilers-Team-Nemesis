.text
.globl main
.globl end
.globl print_newline

main:
	.data
	pstr0: .asciz "x"
	.text
	la    a0, 	pstr0
	li    a7, 4
	ecall

	call print_newline
	call ______protected___for____0
	____return_from______protected___for____0:
	.data
	pstr3: .asciz "done"
	.text
	la    a0, 	pstr3
	li    a7, 4
	ecall

	call print_newline
	jal end
____start______protected___for____0: 
		li t0, 0 # stores in t0 which may and likely will overide other things
	call ______protected___for____0
______protected___for____0: 
	li t1, 2
	addi t0, t0, 1
	bgt t0, t1, ____return_from______protected___for____0
	call ____return_from______protected___for____0
	.data
	pstr1: .asciz "4"
	.text
	la    a0, 	pstr1
	li    a7, 4
	ecall

	call print_newline
	.data
	pstr2: .asciz "7"
	.text
	la    a0, 	pstr2
	li    a7, 4
	ecall

	call print_newline

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