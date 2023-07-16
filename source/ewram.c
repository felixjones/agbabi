/*
===============================================================================

 Support:
    __agbabi_poll_ewram

 Copyright (C) 2021-2023 agbabi contributors
 For conditions of distribution and use, see copyright notice in LICENSE.md

===============================================================================
*/

#include <stddef.h>

#define EWRAM_TEST_LEN 8
#define FRAC_PI 0x243f

typedef unsigned short u16;
typedef volatile u16 vu16;

#define ADDR_EWRAM  ((vu16*) 0x2000000)
#define ADDR_IME    ((vu16*) 0x4000208)

typedef unsigned int u32;
typedef volatile u32 vu32;

#define ADDR_MEMCNT ((vu32*) 0x4000800)

void __agbabi_memcpy2(void* dest, const void* src, size_t n);

int __agbabi_poll_ewram(void) {
    register u32 checksum __asm("r0");
    __asm__ volatile (
        "swi     0xD << ((1f - . == 4) * -16)" "\n\t"
        "1:"
        : [res]"=l"(checksum)
        :: "r1", "r3"
    );

    if (checksum != 0xBAAE187F) {
        return 0;
    }

    const u16 ime = *ADDR_IME;
    u16 memory[EWRAM_TEST_LEN];

    // Save EWRAM
    int result;
    *ADDR_IME = 0;
    __agbabi_memcpy2(memory, (const void*) ADDR_EWRAM, sizeof(memory));
    *ADDR_MEMCNT = 0x0E000020;

    for (u32 i = 0; i < EWRAM_TEST_LEN; ++i) {
        const u16 test = memory[i] + FRAC_PI;

        ADDR_EWRAM[i] = test;
        if (ADDR_EWRAM[i] != test) {
            result = 0;
            goto cleanup;
        }
    }
    result = 1;

cleanup:
    // Restore EWRAM
    *ADDR_MEMCNT = 0x0D000020;
    __agbabi_memcpy2((void*) ADDR_EWRAM, memory, sizeof(memory));
    *ADDR_IME = ime;
    return result;
}
