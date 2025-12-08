.text
.globl main
.globl end

main:

    # initialize
    li t0, 0 # (i)
    li t1, 10 # end number

# loop body
loop____1:
    # print t0 (i)
    mv a0, t0   # put t0 into a0
    li a7, 1    # print integer
    ecall


    # increment
    addi t0, t0, 1
    # if t0 equal to t1 (i!=10) loop
    bne t0, t1, loop____1
    jal end
 

end:
    # print new line
    li    a0, '\n'
	li    a7, 11
    ecall
    
	li    a0, 0     # Load the exit code (e.g., 0 for success) into a0
	li    a7, 93    # Load the Exit2 syscall number into a7
	ecall        # Execute the system call to exit