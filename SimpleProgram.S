.text
.globl main
.globl end
.globl print_newline

main:
	li t1, 5
	bgt t0,t1,____IF____protected___Conditional____1
	call ____ELSE____protected___Conditional____1
	____IF____protected___Conditional____1: 
	call ____AFTER____protected___Conditional____1
	____ELSE____protected___Conditional____1: 
	li t1, 3
	ble t0,t1,____IF____protected___Conditional____2
	call ____ELSE____protected___Conditional____2
	____IF____protected___Conditional____2: 
	call ____AFTER____protected___Conditional____2
	____ELSE____protected___Conditional____2: 
	____AFTER____protected___Conditional____2: 
	____AFTER____protected___Conditional____1: 
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