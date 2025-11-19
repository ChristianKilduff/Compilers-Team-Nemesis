# ====================================================
# Simple Print Example
# 
# Does a few things. Prints out a number (to illustrate)
# Reads in two numbers and prints out the sum of them.
# Also shows how to make a subroutine call.
#
# Author: Christian Duncan
# ====================================================
    .data
msg1: .asciz "Enter a number.\n"
msg2: .asciz "Enter a second number.\n"

    .text
    .globl main
    .globl end
    .globl print_newline

main:
    # printInt(10) # Just as an example
    li    a0, 10
    li    a7, 1
    ecall

    # print print new line
    call print_newline

    # print a string # Msg 1
    la    a0, msg1
    li    a7, 4
    ecall
    
    # Read Int
    li    a7, 5
    ecall

    addi  a1, a0, 0

    # print a string # Msg 2
    la    a0, msg2
    li    a7, 4
    ecall
    
    # Read Int
    li    a7, 5
    ecall

    add   a0, a0, a1
    li    a7, 1
    ecall

    # print a new line
    call print_newline
    
    jal end

# An example of a simple subroutine
print_newline:
    li    a0, '\n'
    li    a7, 11
    ecall
    ret

end:
    li    a0, 0     # Load the exit code (e.g., 0 for success) into a0
    li    a7, 93    # Load the Exit2 syscall number into a7
    ecall        # Execute the system call to exit