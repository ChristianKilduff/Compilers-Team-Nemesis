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
   .data
	pstr1: .asciz "x"
	.text
	la    a0, 	pstr1
	li    a7, 4
	ecall
   call print_newline
	jal end

print_newline:
	li    a0, '\n'
	li    a7, 11
	ecall
	ret
end:
	li    a0, 0     # Load the exit code (e.g., 0 for success) into a0
	li    a7, 93    # Load the Exit2 syscall number into a7
	ecall        # Execute the system call to exit