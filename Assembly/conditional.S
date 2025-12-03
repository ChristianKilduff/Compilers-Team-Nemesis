.text
.globl main
.globl end



main:

    # input
    .data
	msg: .asciz "input: "
	.text

    la    a0, 	msg
	li    a7, 4
	ecall

    li a7, 5 # reads int to a0
    ecall

    # input less than or equal to 4
    li t0, 4 # int for condition
    ble a0, t0, true
    j false

true:
    .data
	ltemsg: .asciz "is less than or equal to 4"
	.text

    la    a0, 	ltemsg
    li t0, 4
	li    a7, 4
	ecall

false:
.data
	gtmsg: .asciz "is greater than 4"
	.text

    la    a0, 	gtmsg
	li    a7, 4
	ecall
end:
    # print new line
    li    a0, '\n'
	li    a7, 11
    ecall
    
	li    a0, 0     # Load the exit code (e.g., 0 for success) into a0
	li    a7, 93    # Load the Exit2 syscall number into a7
	ecall        # Execute the system call to exit