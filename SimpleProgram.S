.text
.globl main
.globl end
.globl print_newline

main:
	.data
	name_tmp____protected: .asciz ""
	name: .word name_tmp____protected
	.text
	.data
	income: .double 0.0
	.text
	.data
	rent: .double 0.0
	.text
	.data
	food: .double 0.0
	.text
	.data
	fun: .double 0.0
	.text
	.data 
	tmp_input_space: .space 200 
	.text
	li a7, 8
	 la a0, tmp_input_space
	li a1, 200
	ecall
	la t0, name
	la t1, tmp_input_space
	sw t1, (t0)
	li a7, 5
	ecall
	la t0, income
	sw a0 (t0)
	li a7, 5
	ecall
	la t0, rent
	sw a0 (t0)
	li a7, 5
	ecall
	la t0, food
	sw a0 (t0)
	li a7, 5
	ecall
	la t0, fun
	sw a0 (t0)
	la t0, rent
    fld ft0,(t0)
la t0, food
    fld ft0,(t0)
    fadd.d   ft0, ft0  ft1
	la t0, rent
    fld ft0,(t0)
la t0, food
    fld ft0,(t0)
la t0, fun
    fld ft0,(t0)
    fadd.d   ft0, ft0  ft1
	.data
	total: .double la t0, rent
    fld ft0,(t0)
la t0, food
    fld ft0,(t0)
la t0, fun
    fld ft0,(t0)

	.text
	la t0, income
    fld ft0,(t0)
la t0, total
    fld ft0,(t0)
    fsub.d   ft0, ft0  ft1
	.data
	savings: .double la t0, income
    fld ft0,(t0)
la t0, total
    fld ft0,(t0)

	.text
	.data
	pstr0: .asciz "Hello, "
	.text
	la    a0, 	pstr0
	li    a7, 4
	ecall

	lw a0, name
	li a7, 4
	ecall
	.data
	pstr1: .asciz "total = "
	.text
	la    a0, 	pstr1
	li    a7, 4
	ecall

	la t0, total
	fld fa0, (t0)
	li a7, 3
	ecall
	.data
	pstr2: .asciz "savings = "
	.text
	la    a0, 	pstr2
	li    a7, 4
	ecall

	la t0, savings
	fld fa0, (t0)
	li a7, 3
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