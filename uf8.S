.data
# CLZ
mask1: .word 0x0000FFFF
mask2: .word 0x00FFFFFF
mask3: .word 0x0FFFFFFF
mask4: .word 0x3FFFFFFF
mask5: .word 0x7FFFFFFF
bin1:  .word 0x0000FFFF      # expected return value from clz: 16
bin2:  .word 0xFFFFFFFF      # expected return value from clz: 0
bin3:  .word 0x7FFFFFFF      # expected return value from clz: 1

# DEC
byte1: .word 0x000000FF      # expected return value from dec: 1015792
byte2: .word 0x00000055      # expected return value from dec: 656
byte3: .word 0x00000007      # expected return value from dec: 7 
.text
    .globl main
main:
    # =====================
    # CLZ
    # =====================

    # === Testcase bin1 ===
    lw a0, bin1             # Load the test argument into register a0
    jal ra, clz             # Jump-and-link to the 'clz' function for counting leading zeros

    li a7, 1                # Print values returned from clz
    ecall

    li a0, 10               # Newline, '\n'
    li a7, 11               # Print char
    ecall

    # === Testcase bin2 ===
    lw a0, bin2             # Load the test argument into register a0
    jal ra, clz             # Jump-and-link to the 'clz' function for counting leading zeros
    
    li a7, 1                # Print values returned from clz
    ecall

    li a0, 10               # Newline, '\n'
    li a7, 11               # Print char
    ecall

    # === Testcase bin3 ===
    lw a0, bin3             # Load the test argument into register a0
    jal ra, clz             # Jump-and-link to the 'clz' function for counting leading zeros

    li a7, 1                # Print values returned from clz
    ecall

    li a0, 10               # Newline, '\n'
    li a7, 11               # Print char
    ecall

    # =====================
    # uf8_decode
    # =====================

    # === Testcase byte1 ===
    lw a0, byte1            # Load the test byte into register a0
    jal ra, dec             # Jump-and-link to the 'dec' function for decoding uf8

    li a7, 1                # Print integer
    ecall

    li a0, 10               # Newline, '\n'
    li a7, 11               # Print char
    ecall

    # === Testcase byte2 ===
    lw a0, byte2            # Load the test byte into register a0
    jal ra, dec             # Jump-and-link to the 'dec' function for decoding uf8

    li a7, 1                # Print integer
    ecall

    li a0, 10               # Newline, '\n'
    li a7, 11               # Print char
    ecall

    # === Testcase byte3 ===
    lw a0, byte3            # Load the test byte into register a0
    jal ra, dec             # Jump-and-link to the 'dec' function for decoding uf8

    li a7, 1                # Print integer
    ecall

    # Exit
    li a7, 10
    ecall

# Count Leading Zeros (return value is saved at a0)
# a0: Input argument
clz:
    beq a0, x0, check_zero  # Check a0 == 0; if true, jump to check_zero for early return

    addi sp, sp, -24        # Allocate stack space for local variables
    sw s5, 20(sp)           # Save for use afterwards
    sw s4, 16(sp)           # Save for use afterwards
    sw s3, 12(sp)           # Save for use afterwards
    sw s2, 8(sp)            # Save for use afterwards
    sw s1, 4(sp)            # Save for use afterwards
    sw s0, 0(sp)            # Save for use afterwards
    
    li s0, 0                # Set s0 = 0 for counting leading zeros
    lw s1, mask1            # Load the bitmask to register
    lw s2, mask2            # Load the bitmask to register
    lw s3, mask3            # Load the bitmask to register
    lw s4, mask4            # Load the bitmask to register
    lw s5, mask5            # Load the bitmask to register

check_16:
    bleu a0, s1, less_16    # Check if a0 <= 0x0000FFFF; if true, jump to less_16
check_8:
    bleu a0, s2, less_8     # Check if a0 <= 0x00FFFFFF; if true, jump to less_8
check_4:
    bleu a0, s3, less_4     # Check if a0 <= 0x0FFFFFFF; if true, jump to less_4
check_2:
    bleu a0, s4, less_2     # Check if a0 <= 0x3FFFFFFF; if true, jump to less_2
check_1:
    bleu a0, s5, less_1     # Check if a0 <= 0x7FFFFFFF; if true, jump to less_1

    j return_clz            # Jump to return_clz for restoring saved register and returning to the caller

less_16:
    addi s0, s0, 16         # s0 += 16
    slli a0, a0, 16         # a0 <<= 16
    j check_8

less_8:
    addi s0, s0, 8          # s0 += 8
    slli a0, a0, 8          # a0 <<= 8
    j check_4

less_4:
    addi s0, s0, 4          # s0 += 4
    slli a0, a0, 4          # a0 <<= 4
    j check_2

less_2:
    addi s0, s0, 2          # s0 += 2
    slli a0, a0, 2          # a0 <<= 2
    j check_1

less_1:
    addi s0, s0, 1          # s0 += 1
    slli a0, a0, 1          # a0 <<= 1

return_clz:
    mv a0, s0               # Save s0 (counter) to a0

    lw s0, 0(sp)            # Restore the original data
    lw s1, 4(sp)            # Restore the original data
    lw s2, 8(sp)            # Restore the original data
    lw s3, 12(sp)           # Restore the original data
    lw s4, 16(sp)           # Restore the original data
    lw s5, 20(sp)           # Restore the original data

    addi sp, sp, 24         # Deallocate stack space
    ret                     # Return to the caller

check_zero:
    li a0, 32               # Set a0 = 32
    ret                     # Return to the caller

# Decode uf8 to uint32_t (return value is saved at a0)
# a0: Input argument
dec:
    mv t0, a0               # Save a0 (argument) for calculating exponent
    srli t0, t0, 4          # Save exponent (fl >> 4) to t0

    andi a0, a0, 0x0f       # Perform (fl & 0x0f)
    sll a0, a0, t0          # Perform (fl & 0x0f) << (fl >> 4)
    
    li t1, 15               # Save constant to t1 for calculating (15 - (fl >> 4))
    sub t0, t1, t0          # Perform (15 - (fl >> 4)) and save the result to t0

    li t1, 0x7FFF           # Save constant to t1 for calculating (0x7FFF >> (15 - (fl >> 4)))
    srl t0, t1, t0          # Perform (0x7FFF >> (15 - (fl >> 4))) and save it to t0

    slli t0, t0, 4          # Perform ((0x7FFF >> (15 - (fl >> 4))) << 4)
    add a0, a0, t0          # Add up a0 and t0 and save to a0
    ret