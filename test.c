#include <stdint.h>
#include <stdio.h>

typedef uint8_t uf8;

static inline unsigned clz(uint32_t x)
{
    int n = 32, c = 16;
    do {
        uint32_t y = x >> c;
        if (y) {
            n -= c;
            x = y;
        }
        c >>= 1;
    } while (c);
    return n - x;
}

static inline unsigned clz_simple(uint32_t x)
{
    if (x == 0) return 32;
    char n = 0;
    if (x <= 0x0000FFFF) { n += 16; x <<= 16; }
    if (x <= 0x00FFFFFF) { n += 8; x <<= 8; }
    if (x <= 0x0FFFFFFF) { n += 4; x <<= 4; }
    if (x <= 0x3FFFFFFF) { n += 2; x <<= 2; }
    if (x <= 0x7FFFFFFF) { n += 1; x <<= 1; }
    return n;
}

uint32_t uf8_decode(uf8 fl)
{
    uint32_t mantissa = fl & 0x0f;
    uint8_t exponent = fl >> 4;
    uint32_t offset = (0x7FFF >> (15 - exponent)) << 4;
    return (mantissa << exponent) + offset;
}

uint32_t uf8_decode_simple(uf8 fl)
{
    return ((fl & 0x0f) << (fl >> 4)) + ((0x7FFF >> (15 - (fl >> 4))) << 4);
}

uf8 uf8_encode(uint32_t value)
{
    /* Use CLZ for fast exponent calculation */
    if (value < 16)
        return value;

    /* Find appropriate exponent using CLZ hint */
    int lz = clz(value);
    int msb = 31 - lz;

    /* Start from a good initial guess */
    uint8_t exponent = 0;
    uint32_t overflow = 0;

    if (msb >= 5) {
        /* Estimate exponent - the formula is empirical */
        exponent = msb - 4;
        if (exponent > 15)
            exponent = 15;

        /* Calculate overflow for estimated exponent */
        for (uint8_t e = 0; e < exponent; e++)
            overflow = (overflow << 1) + 16;

        /* Adjust if estimate was off */
        while (exponent > 0 && value < overflow) {
            overflow = (overflow - 16) >> 1;
            exponent--;
        }
    }

    /* Find exact exponent */
    while (exponent < 15) {
        uint32_t next_overflow = (overflow << 1) + 16;
        if (value < next_overflow)
            break;
        overflow = next_overflow;
        exponent++;
    }

    uint8_t mantissa = (value - overflow) >> exponent;
    return (exponent << 4) | mantissa;
}

void print_bin(uint32_t bin) {
    for (int i = 31; i >= 0; i--) {
        char b = (bin >> i & 0x1) == 0x1 ? '1' : '0';
        putchar(b);
    }
    putchar('\n');
}

int main(void) {
    uint8_t testcase1 = 0x07;
    print_bin(uf8_decode(testcase1));
    printf("%d\n", uf8_decode(testcase1));

    print_bin(uf8_decode_simple(testcase1));
    printf("%d\n", uf8_decode_simple(testcase1));

    uint32_t testcase2 = 0x01010101;
    print_bin(uf8_encode(testcase2));
    printf("%d\n", uf8_encode(testcase2));
    return 0;
}