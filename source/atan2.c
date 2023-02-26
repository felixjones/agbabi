/*
===============================================================================

 Support:
    __agbabi_atan2

 Taken from https://www.coranac.com/documents/arctangent/ by Jasper "cearn" Vijn
 Modified for libagbabi

===============================================================================
*/

#include <agbabi.h>

#define unlikely(x) __builtin_expect(!!(x), 0)

typedef unsigned int vec4u __attribute__((vector_size(sizeof(unsigned int) * 4)));

/* Returns vector to keep x and y inputs in r0, r1 for more efficient codegen */
inline __attribute__((always_inline, const)) vec4u to_octant(int x, int y) {
    unsigned int octant = 0;

    if (y < 0) {
        x = -x;
        y = -y;
        octant = 0x4000;
    }

    if (x <= 0) {
        const int temp = x;

        x = y;
        y = -temp;
        octant |= 0x2000;
    }

    if (x <= y) {
        const int temp = y - x;

        x += y;
        y = temp;
        octant |= 0x1000;
    }

    return (vec4u) {(unsigned int) x, (unsigned int) y, octant};
}

unsigned int __attribute__((section(".iwram.__agbabi_atan2"))) __agbabi_atan2(int x, int y) {
    if (unlikely(y == 0)) {
        return x >= 0 ? 0 : 0x4000;
    }

    const vec4u x_y_phi = to_octant(x, y);
    const int temp = (int) __agbabi_unsafe_uidivmod(x_y_phi[1] << 15, x_y_phi[0])[0];
    const int temp2 = (-temp * temp) >> 15;
    int dphi = 0x0470;

    dphi = 0x1029 + ((temp2 * dphi) >> 15);
    dphi = 0x1F0B + ((temp2 * dphi) >> 15);
    dphi = 0x364C + ((temp2 * dphi) >> 15);
    dphi = 0xA2FC + ((temp2 * dphi) >> 15);
    dphi = (dphi * temp) >> 15;

    return x_y_phi[2] + (unsigned int) ((dphi + 4) >> 3);
}
