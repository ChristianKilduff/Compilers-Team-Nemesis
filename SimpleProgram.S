.text
.globl main
.globl end
.globl print_newline

main:
	li t0, 4
	li t1, 3
	bgt t0,t1,____IF____protected___Conditional____1
	call ____ELSE____protected___Conditional____1
	____IF____protected___Conditional____1: 
	li t1, 7
	bgt t0,t1,____IF____protected___Conditional____2
	call ____ELSE____protected___Conditional____2
	____IF____protected___Conditional____2: 
	.data
	pstr0: .asciz "6"
	.text
	la    a0, 	pstr0
	li    a7, 4
	ecall

	call print_newline
	call ____AFTER____protected___Conditional____2
	____ELSE____protected___Conditional____2: 
	.data
	pstr1: .asciz "99"
	.text
	la    a0, 	pstr1
	li    a7, 4
	ecall

	call print_newline
	____AFTER____protected___Conditional____2: 
	.data
	pstr2: .asciz "4"
	.text
	la    a0, 	pstr2
	li    a7, 4
	ecall

	call print_newline
	call ____AFTER____protected___Conditional____1
	____ELSE____protected___Conditional____1: 
	li t1, 2
	bgt t0,t1,____IF____protected___Conditional____3
	call ____ELSE____protected___Conditional____3
	____IF____protected___Conditional____3: 
	.data
	pstr3: .asciz "3"
	.text
	la    a0, 	pstr3
	li    a7, 4
	ecall

	call print_newline
	call ____AFTER____protected___Conditional____3
	____ELSE____protected___Conditional____3: 
	li t1, 1
	bgt t0,t1,____IF____protected___Conditional____4
	call ____ELSE____protected___Conditional____4
	____IF____protected___Conditional____4: 
	.data
	pstr4: .asciz "2"
	.text
	la    a0, 	pstr4
	li    a7, 4
	ecall

	call print_newline
	call ____AFTER____protected___Conditional____4
	____ELSE____protected___Conditional____4: 
	.data
	pstr5: .asciz "1"
	.text
	la    a0, 	pstr5
	li    a7, 4
	ecall

	call print_newline
	____AFTER____protected___Conditional____4: 
	____AFTER____protected___Conditional____3: 
	____AFTER____protected___Conditional____1: 
	.data
	pstr6: .asciz "done"
	.text
	la    a0, 	pstr6
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