/*
===============================================================================

 Support:
    __agbabi_coro_make

 Copyright (C) 2021-2022 agbabi contributors
 For conditions of distribution and use, see copyright notice in LICENSE.md

===============================================================================
*/

#include <agbabi.h>

void __agbabi_coro_pop();

void __agbabi_coro_make(agbabi_coro_t* __restrict__ coro, void* __restrict__ sp_top, int(*coproc)(agbabi_coro_t*)) {
    // AAPCS wants stack to be aligned to 8 bytes
    unsigned int alignedTop = ((unsigned int) sp_top) & ~0x7;

    unsigned int* stack = (unsigned int*) alignedTop;
    // Allocate space for storing r4-r12 (r12 for alignment)
    stack -= 12; // Allocate space on stack for pointer to lr, self, and entry procedure
    stack[9] = (unsigned int) __agbabi_coro_pop;
    stack[10] = (unsigned int) coro;
    stack[11] = (unsigned int) coproc;

    coro->arm_sp = (unsigned int) stack;
    coro->joined = 0; // Clear joined flag (ready to start)
}
