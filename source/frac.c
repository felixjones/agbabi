/*
===============================================================================

 Support:
    __agbabi_frac128_tostr, __agbabi_lsl128, __agbabi_mul128_2, __agbabi_bcd128

 Copyright (C) 2021-2022 agbabi contributors
 For conditions of distribution and use, see copyright notice in LICENSE.md

===============================================================================
*/

#define MIN(X, Y)   ((X) < (Y) ? (X) : (Y))

char* __agbabi_frac_bcd128_tostr(char* str, unsigned int precision, unsigned int __attribute__((__vector_size__(16))) frac) {
    unsigned int limit, words = 4, zeroTail = 0;

    for (unsigned int ii = 0; ii < 4; ++ii) {
        for (limit = MIN(precision, (8 * (ii + 1))); zeroTail < limit; ++zeroTail) {
            if ((frac[ii] >> ((zeroTail - (8 * ii)) * 4)) & 0xf) {
                ii = 4;
                break;
            }
        }
    }

    --precision;
    while (words--) {
        for (limit = (words * 8); precision >= limit; --precision) {
            unsigned char nibble = (frac[words] >> ((precision - limit) * 4)) & 0xf;
            *str++ = '0' + nibble;
            if (precision == zeroTail) {
                *str = 0;
                return str;
            }
        }
    }
    *str = 0;
    return str;
}

unsigned int __attribute__((__vector_size__(16))) __agbabi_lsl128(unsigned int __attribute__((__vector_size__(16))) x, unsigned int shift) {
    unsigned int wordShift = shift % 32;

    int offHi = (int) shift / 32;
    int offLo = offHi + 1;

    int n = 4;
    while (n--) {
        const int idxHi = n - offHi;
        const int idxLo = n - offLo;

        unsigned int xn = 0;
        if (idxHi >= 0) {
            xn |= x[idxHi] << wordShift;
            if (idxLo >= 0 && wordShift) {
                xn |= x[idxLo] >> (32 - wordShift);
            }
        }
        x[n] = xn;
    }
    return x;
}

unsigned int __attribute__((__vector_size__(16))) __agbabi_mul128_2(unsigned int __attribute__((__vector_size__(16))) x) {
    int n = 4;
    while (n--) {
        const int idxLo = n - 1;

        unsigned int xn = 0;
        xn |= x[n] << 1;
        if (idxLo >= 0) {
            xn |= x[idxLo] >> 31;
        }
        x[n] = xn;
    }
    return x;
}

unsigned int __attribute__((__vector_size__(16))) __agbabi_bcd128(unsigned int __attribute__((__vector_size__(16))) x, unsigned int precision) {
    const unsigned int msb32 = 1U << 31U;

    unsigned int __attribute__((__vector_size__(16))) b = {};
    const unsigned int bits = precision * 4;

    x = __agbabi_lsl128(x, 128 - bits);

    unsigned int ii;
    for (ii = 0; ii < bits; ++ii) {
        unsigned int carry = (x[3] & msb32) != 0;
        x = __agbabi_mul128_2(x);

        for (int jj = 0; jj < 4; ++jj) {
            const unsigned int data = b[jj];

            unsigned int nib0 = ((data >> 0) & 0xf) * 2 + carry;
            carry = nib0 > 9;
            if (carry) {
                nib0 -= 10;
            }

            unsigned int nib1 = ((data >> 4) & 0xf) * 2 + carry;
            carry = nib1 > 9;
            if (carry) {
                nib1 -= 10;
            }

            unsigned int nib2 = ((data >> 8) & 0xf) * 2 + carry;
            carry = nib2 > 9;
            if (carry) {
                nib2 -= 10;
            }

            unsigned int nib3 = ((data >> 12) & 0xf) * 2 + carry;
            carry = nib3 > 9;
            if (carry) {
                nib3 -= 10;
            }

            unsigned int nib4 = ((data >> 16) & 0xf) * 2 + carry;
            carry = nib4 > 9;
            if (carry) {
                nib4 -= 10;
            }

            unsigned int nib5 = ((data >> 20) & 0xf) * 2 + carry;
            carry = nib5 > 9;
            if (carry) {
                nib5 -= 10;
            }

            unsigned int nib6 = ((data >> 24) & 0xf) * 2 + carry;
            carry = nib6 > 9;
            if (carry) {
                nib6 -= 10;
            }

            unsigned int nib7 = ((data >> 28) & 0xf) * 2 + carry;
            carry = nib7 > 9;
            if (carry) {
                nib7 -= 10;
            }

            b[jj] = nib0 | (nib1 << 4) | (nib2 << 8) | (nib3 << 12)
                    | (nib4 << 16) | (nib5 << 20) | (nib6 << 24) | (nib7 << 28);
        }
    }

    return b;
}
