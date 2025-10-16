#include <stdint.h>
#include <stdio.h>

typedef uint8_t uf8;

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

void print_bin(uint32_t bin) {
    for (int i = 31; i >= 0; i--) {
        char b = (bin >> i & 0x1) == 0x1 ? '1' : '0';
        putchar(b);
    }
    putchar('\n');
}

int main(void) {
    uint8_t testcase = 0x07;
    print_bin(uf8_decode(testcase));
    printf("%d\n", uf8_decode(testcase));

    print_bin(uf8_decode_simple(testcase));
    printf("%d\n", uf8_decode_simple(testcase));
    return 0;
}