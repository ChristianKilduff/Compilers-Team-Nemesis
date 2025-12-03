.text
.globl main
.globl end



main:

init_while:
    li t1, 2 # condition, !=t1
    .data
	msg2: .asciz "input x, if x==2 program ends: "
	.text
while:
	la    a0, 	msg2
	li    a7, 4
	ecall

    li a7, 5 # reads int to a0
    ecall

    # branch (repeat) if not equal to 2
    bne t1, a0, while


init_for:
    # initialize
    li t0, 0 # (i)
    li t1, 10 # end number

# loop body
for:
    # print t0 (i)
    mv a0, t0   # put t0 into a0
    addi a0, a0, 1 # add 1 to print 1-10 not 0-9
    li a7, 1    # print integer
    ecall
    # print space
    li a0, ' ' 
    li a7, 11
    ecall


    # increment
    addi t0, t0, 1
    # if t0 equal to t1 (i!=10) loop
    bne t0, t1, for

end:
    # print new line
    li    a0, '\n'
	li    a7, 11
    ecall
    
	li    a0, 0     # Load the exit code (e.g., 0 for success) into a0
	li    a7, 93    # Load the Exit2 syscall number into a7
	ecall        # Execute the system call to exit