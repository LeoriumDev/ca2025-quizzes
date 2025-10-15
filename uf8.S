.data
mask: .word 0x7FFFFFFF # first bit is zero
bin: .word 0x0000FFFF # expected return value from clz: 16
bin2: .word 0xFFFFFFFF # expected return value from clz: 0
bin3: .word 0x7FFFFFFF # expected return value from clz: 1

.text
    .globl main
main:
    # Testcase - bin
    lw a0, bin # Load the test argument into register a0
    jal ra, clz # Jump-and-link to the 'clz' function for counting leading zeros

    li a7, 1 # Print values returned from clz
    ecall


    # Newline, '\n' ASCII code (10_dec)
    li a0, 10 
    li a7, 11
    ecall


    # Testcase - bin2
    lw a0, bin2 # Load the test argument into register a0
    jal ra, clz # Jump-and-link to the 'clz' function for counting leading zeros
    
    li a7, 1 # Print values returned from clz
    ecall


    # Newline, '\n' ASCII code (10_dec)
    li a0, 10

    li a7, 11 # Print char
    ecall


    # Testcase - bin3
    lw a0, bin3 # Load the test argument into register a0
    jal ra, clz # Jump-and-link to the 'clz' function for counting leading zeros

    li a7, 1 # Print values returned from clz
    ecall


    # Exit the program
    li a7, 10
    ecall

# Counting Leading Zeros, return value is save at a0
clz:
    addi s0, x0, 0 # Set s0 (saved register) to 0, served as a variable for counting leading zeros
clz1:
    lw s1, mask # Load the bit-mask for determing MSB is 1 to s1
    or s2, a0, s1 # Use the bit-mask to filter out all bits except the MSB and save it to s2
    beq s1, s2, inc # Compare the MSB of a0 (s2) with the bit-mask (s1), branch to inc if they are equivalent 
trailing:
    slli a0, a0, 1 # Left Shift a0 by 1
    addi s3, x0, 0 # Set s3 to 0, served as a determing value for whether function ended (bin is zero)
    beq a0, s3, end # If bin is zero, then jump to end
    jal x0, clz1 # Jump to clz for next iteration
inc:
    addi s0, s0, 1 # Increment s0 (clz counter) by 1
    jal x0, trailing # Jump to trailing for bit shifting for comparing next bit
end:
    add a0, x0, s0 # Save clz counter to a0
    ret # return from function clz