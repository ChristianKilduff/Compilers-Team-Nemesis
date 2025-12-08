.text
.globl main
.globl end
.globl print_newline

main:
	.data
	n: .word 0
	.text
	.data
	steps: .word 0
	.text
	.data
	max_val: .word 0
	.text
	call ______protected___loop____0
	addi t0, t0, 1
	bgt t0, t1, ____return_from______protected___loop____0
	li t1, max_val
	bgt t0,t1,____IF____protected___Conditional____1
	call ____ELSE____protected___Conditional____1
	____IF____protected___Conditional____1: 
	li t0, n
	la t1, max_val
	sw t0, 0(t1)
	call ____AFTER____protected___Conditional____1
	____ELSE____protected___Conditional____1: 
	____AFTER____protected___Conditional____1: 
	li t1, 0
	bne t0,t1,____IF____protected___Conditional____2
	call ____ELSE____protected___Conditional____2
	____IF____protected___Conditional____2: 
	li t0, n / 2
	la t1, n
	sw t0, 0(t1)
	call ____AFTER____protected___Conditional____2
	____ELSE____protected___Conditional____2: 
	li t0, 3 * n + 1
	la t1, n
	sw t0, 0(t1)
	____AFTER____protected___Conditional____2: 
	li t0, steps + 1
	la t1, steps
	sw t0, 0(t1)
	call ______protected___loop____0
	____return_from______protected___loop____0:
	li t1, max_val
	bgt t0,t1,____IF____protected___Conditional____3
	call ____ELSE____protected___Conditional____3
	____IF____protected___Conditional____3: 
	li t0, n
	la t1, max_val
	sw t0, 0(t1)
	call ____AFTER____protected___Conditional____3
	____ELSE____protected___Conditional____3: 
	____AFTER____protected___Conditional____3: 
	.data
	pstr0: .asciz "steps = "
	.text
	la    a0, 	pstr0
	li    a7, 4
	ecall

	call print_newline
	.data
	pstr1: .asciz "max = "
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
	# print new line
	call print_newline

	li    a0, 0     # Load the exit code (e.g., 0 for success) into a0
	li    a7, 93    # Load the Exit2 syscall number into a7
	ecall        # Execute the system call to exit