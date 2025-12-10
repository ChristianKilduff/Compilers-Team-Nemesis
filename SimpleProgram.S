.text
.globl main
.globl end
.globl print_newline

main:
	.data
	z: .double 5.0
	.text
	la t0,DOUBLE_0
	fld  fa0, (t0)
	la t0, z
	fsd fa0, (t0)
	la t0, z
	fld fa0, (t0)
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