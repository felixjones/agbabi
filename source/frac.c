/*
===============================================================================

 Support:
    __agbabi_frac128_tostr

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
                return;
            }
        }
    }
    *str = 0;
    return str;
}
