main:
    # --------------------------
    # Allocate stack space (8 bytes)
    # --------------------------
    addi sp, sp, -8        # make room for x and y

    # --------------------------
    # x = 3
    # --------------------------
    li t0, 3               # t0 = x
    sw t0, 0(sp)           # store x at stack[0]

    # --------------------------
    # y = 4
    # --------------------------
    li t1, 4               # t1 = y
    sw t1, 4(sp)           # store y at stack[4]

    # --------------------------
    # Load y from stack and print it
    # --------------------------
    lw t2, 4(sp)           # t2 = y
    mv a0, t2              # move y into a0 for printing
    li a7, 1               # ecall: print integer
    ecall

    # --------------------------
    # Deallocate stack
    # --------------------------
    addi sp, sp, 8

    # return
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
	ecall 