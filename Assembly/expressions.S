.data
x:      .double 1.0       # Initial value
factor: .double 5.0       # Constant factor

.text
.globl main
main:
    # Load x and factor
    la t0, x
    fld fa0, (t0)           # fa0 = x
    la t1, factor
    fld fa1, (t1)         # fa1 = 5.0

    # Multiply x * factor
    fmul.d f2, fa0, fa1      # f2 = fa0 * fa1
    # Store result back to x
    fsd f2, (t0)

    # Print the result
    fmv.d fa0, f2          # Move f2 into fa0 for ecall
    li a7, 3               # ecall = print double
    ecall

    # Exit program
    li a7, 10
    ecall
