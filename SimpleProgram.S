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
	a: .double 5.0
	.text
	.data
	b: .double -1.0
	.text
	.data
	r: .double 0
	.text
	la t2, r
	la t0, a
	la t1, b
	
	fld fa0, 0(t0)
	fld fa1, 0(t1)
	fmul.d fa2, fa0, fa1
	fsd fa2, (t2)
	la t2, r
	la t0, a
	la t1, b
	
	fld fa0, 0(t0)
	fld fa1, 0(t1)
	fmul.d fa2, fa0, fa1
	fsd fa2, (t2)
	la t0, r
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