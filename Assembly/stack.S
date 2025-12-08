

.text
.globl main
main:
    # initializing int
    .data
    i : .word 0
    .text

    # set a variable
    # x = 55
    li t0, 55
    la t1, i
    sw t0, 0(t1)


    # load 
    la t1, i
    lw t2, 0(t1)     

    # print
    addi a0, t2, 0
    li    a7, 1
    ecall

    call print_newline

    .data
    d: .dword 0        # allocate 8 bytes for a double, initialized to 0
    .text

    # store fa0 into memory
    li fa0, 3.3
    la   t0, d
    fsd  fa0, 0(t0)     # store double into d

    # load it back and print
    fld  fa0, 0(t0)
    li   a7, 3          # PrintDouble syscall (RARS)
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
	ecall 