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
	income: .double 0.0
	.text
	.data
	rate: .double 0.0
	.text
	.data
	tax: .double 0.0
	.text
	.data
	net: .double 0.0
	.text
	li a7, 7
	ecall
	la t0, income
	fsd fa0 (t0)
	la t0, income
	fld fa0, (t0)
	.data
	tmp_d_______1: .double 10000.0
	.text
	la t0, tmp_d_______1
	fld fa1, (t0)
	flt.d t2, fa0, fa1
	bnez t2, ____IF____protected___Conditional____1
	call ____ELSE____protected___Conditional____1
	____IF____protected___Conditional____1: 
	.data
	DOUBLE_1: .double 0.0
	.text
	la t0,DOUBLE_1
	fld  fa0, (t0)
	la t0, rate
	fsd fa0, (t0)
	la t0, rate
	fld fa0, (t0)
	call ____AFTER____protected___Conditional____1
	____ELSE____protected___Conditional____1: 
	la t0, income
	fld fa0, (t0)
	.data
	tmp_d_______3: .double 40000.0
	.text
	la t0, tmp_d_______3
	fld fa1, (t0)
	flt.d t2, fa0, fa1
	bnez t2, ____IF____protected___Conditional____2
	call ____ELSE____protected___Conditional____2
	____IF____protected___Conditional____2: 
	.data
	DOUBLE_3: .double 10.0
	.text
	la t0,DOUBLE_3
	fld  fa0, (t0)
	la t0, rate
	fsd fa0, (t0)
	la t0, rate
	fld fa0, (t0)
	call ____AFTER____protected___Conditional____2
	____ELSE____protected___Conditional____2: 
	la t0, income
	fld fa0, (t0)
	.data
	tmp_d_______5: .double 80000.0
	.text
	la t0, tmp_d_______5
	fld fa1, (t0)
	flt.d t2, fa0, fa1
	bnez t2, ____IF____protected___Conditional____3
	call ____ELSE____protected___Conditional____3
	____IF____protected___Conditional____3: 
	.data
	DOUBLE_5: .double 20.0
	.text
	la t0,DOUBLE_5
	fld  fa0, (t0)
	la t0, rate
	fsd fa0, (t0)
	la t0, rate
	fld fa0, (t0)
	call ____AFTER____protected___Conditional____3
	____ELSE____protected___Conditional____3: 
	.data
	DOUBLE_6: .double 30.0
	.text
	la t0,DOUBLE_6
	fld  fa0, (t0)
	la t0, rate
	fsd fa0, (t0)
	la t0, rate
	fld fa0, (t0)
	____AFTER____protected___Conditional____3: 
	____AFTER____protected___Conditional____2: 
	____AFTER____protected___Conditional____1: 
	.data
	div: .double 0.01
	.text
	la t2, tax
	la t0, rate
	la t1, div
	
	fld fa0, 0(t0)
	fld fa1, 0(t1)
	fmul.d fa2, fa0, fa1
	fsd fa2, (t2)
	la t2, tax
	la t0, tax
	la t1, income
	
	fld fa0, 0(t0)
	fld fa1, 0(t1)
	fmul.d fa2, fa0, fa1
	fsd fa2, (t2)
	.data
	n: .double -1.0
	.text
	.data
	DOUBLE_7: .double 0.0
	.text
	la t0,DOUBLE_7
	fld  fa0, (t0)
	la t0, net
	fsd fa0, (t0)
	la t0, net
	fld fa0, (t0)
	la t2, net
	la t0, tax
	la t1, n
	
	fld fa0, 0(t0)
	fld fa1, 0(t1)
	fmul.d fa2, fa0, fa1
	fsd fa2, (t2)
	la t2, net
	la t0, income
	la t1, net
	
	fld fa0, 0(t0)
	fld fa1, 0(t1)
	fadd.d fa2, fa0, fa1
	fsd fa2, (t2)
	.data
	pstr0: .asciz "income "
	.text
	la    a0, 	pstr0
	li    a7, 4
	ecall

	la t0, income
	fld fa0, (t0)
	li a7, 3
	ecall
	jal ra, print_newline
	.data
	pstr1: .asciz "rate "
	.text
	la    a0, 	pstr1
	li    a7, 4
	ecall

	la t0, rate
	fld fa0, (t0)
	li a7, 3
	ecall
	jal ra, print_newline
	.data
	pstr2: .asciz "tax = "
	.text
	la    a0, 	pstr2
	li    a7, 4
	ecall

	la t0, tax
	fld fa0, (t0)
	li a7, 3
	ecall
	jal ra, print_newline
	.data
	pstr3: .asciz "net = "
	.text
	la    a0, 	pstr3
	li    a7, 4
	ecall

	la t0, net
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