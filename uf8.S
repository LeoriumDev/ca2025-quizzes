.data
# CLZ
mask1: .word 0x0000FFFF
mask2: .word 0x00FFFFFF
mask3: .word 0x0FFFFFFF
mask4: .word 0x3FFFFFFF
mask5: .word 0x7FFFFFFF

bin1:  .word 0x0000FFFF     # expected return value from clz: 16
bin2:  .word 0xFFFFFFFF     # expected return value from clz: 0
bin3:  .word 0x7FFFFFFF     # expected return value from clz: 1

# DEC
byte1: .word 0x000000FF     # expected return value from dec: 1015792
byte2: .word 0x00000055     # expected return value from dec: 656
byte3: .word 0x00000007     # expected return value from dec: 7

# ENC
bin4:  .word 0x12345678     # expected return value from enc: 248
bin5:  .word 0x55553333     # expected return value from enc: 250
bin6:  .word 0x01010101     # expected return value from enc: 242
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

    li a0, 10               # Newline, '\n'
    li a7, 11               # Print char
    ecall

    # =====================
    # uf8_encode
    # =====================

    # === Testcase bin4 ===
    lw a0, bin4             # Load the test binary into register a0
    jal ra, enc             # Jump-and-link to the 'dec' function for encoding to uf8

    li a7, 1                # Print integer
    ecall

    li a0, 10               # Newline, '\n'
    li a7, 11               # Print char
    ecall

    # === Testcase bin5 ===
    lw a0, bin5             # Load the test binary into register a0
    jal ra, enc             # Jump-and-link to the 'eec' function for encoding to uf8

    li a7, 1                # Print integer
    ecall

    li a0, 10               # Newline, '\n'
    li a7, 11               # Print char
    ecall

    # === Testcase bin6 ===
    lw a0, bin6             # Load the test binary into register a0
    jal ra, enc             # Jump-and-link to the 'enc' function for encoding to uf8

    li a7, 1                # Print integer
    ecall

    li a0, 10               # Newline, '\n'
    li a7, 11               # Print char
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

# Encode uint32_t to uf8 (return value is saved at a0)
# a0: Input argument
enc:
    li t0, 16               # Load 16 to t0 for performing early-return
    bltu a0, t0, e_ret_enc  # if (value < 16)

    addi sp, sp, -16        # Allocate stack space to store local variables

    sw a0, 12(sp)           # Save a0's data to stack to prevent data loss
    sw s0, 8(sp)            # Save s0's data to stack to prevent data loss
    mv s0, ra               # Save ra to s0
    jal ra, clz             # Call CLZ function, return value is saved at a0
    mv t0, a0               # lz = clz(value), t0 represents lz
    lw a0, 12(sp)           # Restore value from the stack (a0 is the argument)
    mv ra, s0               # Restore value from s0
    lw s0, 8(sp)            # Restore value from the stack
    addi sp, sp, 16         # Deallocate stack space

    li t1, 31               # Load 31 to t1 for computing msb = 31 - a0
    sub t0, t1, t0          # Perform msb = 31 - a0 and save the result to t0, t0 now represents msb

    li t1, 0                # uint8_t exponent = 0; (t1)
    li t2, 0                # uint32_t overflow = 0; (t2)

    li t3, 5                # Load 5 to t3 for perfoming if (msb >= 5)
    bgeu t0, t3, ge_5       # Perform msb >= 5

exact_exp:
    # a0 = value, t0 = msb, t1 = exponent, t2 = overflow
    li t3, 15               # Load 5 to t3 for perfoming inverse of (exponent < 15)
    bgeu t1, t3, mant       # when while (exponent < 15) is false jump to mant
    slli t3, t2, 1          # next_overflow = (overflow << 1)
    addi t3, t3, 16         # next_overflow = next_overflow + 16
    bltu a0, t3, mant       # if (value < next_overflow) then break
    mv t2, t3               # overflow = next_overflow
    addi t1, t1, 1          # exponent++
    j exact_exp

mant:
    sub t3, a0, t2          # mantissa = (value - overflow)
    srl t3, t3, t1          # mantissa = mantissa >> exponent
    slli t4, t1, 4          # t1 = (exponent << 4)
    or a0, t3, t4           # (exponent << 4) | mantissa
    li t3, 0xFF             # Make a bitmask that mask the least significant byte
    and a0, a0, t3          # AND it with a0 to make sure no garbage values remain
    ret
    
e_ret_enc:
    ret                     # early return

ge_5:
    # a0 = value, t0 = msb, t1 = exponent, t2 = overflow

    li t3, 4                # Load 4 to t3 for subtraction
    sub, t1, t0, t3         # exponent = msb - 4;

    li t3, 15               # Load 4 to t3 for comparison
    bleu t1, t3, uf8_ovf    # Invert if (exponent > 15), if less than or equals to 15 jump pass next line.
    li t1, 15               # exponent = 15

uf8_ovf:
    li t3, 16               # Load 16 to t4 for bit manipulation
    sll t4, t3, t1          # t3 = (16 << exponent)
    sub t2, t4, t3          # overflow = (16 << exponent) - 16;

uf8_est_off:
    bleu t1, x0, ret_msb    # Invert (exponent > 0)
    bgeu a0, t2, ret_msb    # Invert (value < overflow)
    addi t2, t2, -16        # overflow = (overflow - 16)
    srli t2, t2, 1          # overflow >>= 1
    addi t1, t1, -1         # exponent--
    j uf8_est_off

ret_msb:
    j exact_exp