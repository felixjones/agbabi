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

void __agbabi_coro_make(agbabi_coro_t* coro, void* sp_top, int(*coproc)(agbabi_coro_t*)) {
    unsigned int* stack = (unsigned int*) sp_top;
    stack -= 2; // Allocate space on stack for pointer to self, and entry procedure
    stack[0] = (unsigned int) coro;
    stack[1] = (unsigned int) coproc;

    coro->context.arm_sp = (unsigned int) stack;
    coro->context.arm_lr = (unsigned int) __agbabi_coro_pop;
    coro->alive = 1; // Set alive flag (ready to start)
}
