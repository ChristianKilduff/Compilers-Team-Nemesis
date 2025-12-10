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
	n: .double 0.0
	.text
	li a7, 7
	ecall
	la t0, n
	fsd fa0 (t0)
	.data
	steps: .double 0.0
	.text
	.data
	max_val: .double 0.0
	.text
	la t0, n
	fld fa0 (t0)
	la t2, max_val
	fsd fa0 (t2)
	.data
	one: .double 1.0
	.text
	.data
	two: .double 2.0
	.text
	.data
	three: .double 3.0
	.text
	___CHECK______protected___loop____0:
	la t0, n
	fld fa0, (t0)
	la t1, one
	fld fa1, (t1)
	feq.d t2, fa0, fa1
	bnez t2, ______protected___loop____0
	jal ra, ____return_from______protected___loop____0
	______protected___loop____0: 
	la t0, n
	fld fa0, (t0)
	la t1, max_val
	fld fa1, (t1)
	fgt.d t2, fa0, fa1
	bnez t2, ____IF____protected___Conditional____1
	call ____ELSE____protected___Conditional____1
	____IF____protected___Conditional____1: 
	la t0, n
	fld fa0 (t0)
	la t2, max_val
	fsd fa0 (t2)
	call ____AFTER____protected___Conditional____1
	____ELSE____protected___Conditional____1: 
	____AFTER____protected___Conditional____1: 
	.data
	m: .double 0.0
	.text
	la t0, m
	fld fa0, (t0)
	.data
	tmp_d_______1: .double 0.0
	.text
	la t0, tmp_d_______1
	fld fa1, (t0)
	fne.d t2, fa0, fa1
	bnez t2, ____IF____protected___Conditional____2
	call ____ELSE____protected___Conditional____2
	____IF____protected___Conditional____2: 
	la t2, n
	la t0, n
	la t1, two
	fld fa0, 0(t0)
	fld fa1, 0(t1)
	fdiv.d fa2, fa0, fa1
	fsd fa2, (t2)
	call ____AFTER____protected___Conditional____2
	____ELSE____protected___Conditional____2: 
	la t2, n
	la t0, three
	la t1, n
	fld fa0, 0(t0)
	fld fa1, 0(t1)
	fmul.d fa2, fa0, fa1
	fsd fa2, (t2)
	la t2, n
	la t0, n
	la t1, one
	fld fa0, 0(t0)
	fld fa1, 0(t1)
	fadd.d fa2, fa0, fa1
	fsd fa2, (t2)
	____AFTER____protected___Conditional____2: 
	la t2, steps
	la t0, steps
	la t1, one
	fld fa0, 0(t0)
	fld fa1, 0(t1)
	fadd.d fa2, fa0, fa1
	fsd fa2, (t2)
	jal ra, ___CHECK______protected___loop____0
	____return_from______protected___loop____0:
	la t0, n
	fld fa0, (t0)
	la t1, max_val
	fld fa1, (t1)
	fgt.d t2, fa0, fa1
	bnez t2, ____IF____protected___Conditional____3
	call ____ELSE____protected___Conditional____3
	____IF____protected___Conditional____3: 
	la t0, n
	fld fa0 (t0)
	la t2, max_val
	fsd fa0 (t2)
	call ____AFTER____protected___Conditional____3
	____ELSE____protected___Conditional____3: 
	____AFTER____protected___Conditional____3: 
	.data
	pstr0: .asciz "steps = "
	.text
	la    a0, 	pstr0
	li    a7, 4
	ecall

	la t0, steps
	fld fa0, (t0)
	li a7, 3
	ecall
	jal ra, print_newline
	.data
	pstr1: .asciz "max = "
	.text
	la    a0, 	pstr1
	li    a7, 4
	ecall

	la t0, max_val
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