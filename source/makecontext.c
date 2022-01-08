/*
===============================================================================

 POSIX:
    makecontext

 Support:
    __agbabi_makecontext

 Copyright (C) 2021-2022 agbabi contributors
 For conditions of distribution and use, see copyright notice in LICENSE.md

===============================================================================
*/

#include <errno.h>
#include <stdarg.h>
#include <sys/ucontext.h>

#define REGISTER_ARGS 4

#undef errno
extern int errno;

void __agbabi_popcontext();

void __agbabi_makecontext(ucontext_t* ucp, void(*func)(), int argc, ...) {
    _Static_assert(sizeof(void*) == 4 && sizeof(int) == 4, "Requires sizeof(void*) and sizeof(int) to be 4 bytes");

    if (argc * sizeof(int) > ucp->uc_stack.ss_size - REGISTER_ARGS * sizeof(int)) {
        errno = ENOMEM;
        return;
    }
    errno = 0;

    unsigned int* funcstack = (unsigned int*) (ucp->uc_stack.ss_sp + ucp->uc_stack.ss_size);

    // Push link context onto stack
    funcstack -= 1;
    *funcstack = (unsigned int) ucp->uc_link;

    if (argc > REGISTER_ARGS) {
        funcstack -= (argc - REGISTER_ARGS);
    }

    ucp->uc_mcontext.arm_sp = (unsigned int) funcstack;
    ucp->uc_mcontext.arm_lr = (unsigned int) __agbabi_popcontext;
    ucp->uc_mcontext.arm_pc = (unsigned int) func;
    ucp->uc_mcontext.arm_cpsr = (ucp->uc_mcontext.arm_pc & 1 ? 0x3f : 0x1f);

    va_list vl;
    va_start(vl, argc);

    int reg;
    unsigned int* regptr = &ucp->uc_mcontext.arm_r0;

    for (reg = 0; reg < argc && reg < REGISTER_ARGS; ++reg) {
        *regptr++ = va_arg(vl, unsigned int);
    }

    for (; reg < argc; ++reg) {
        *funcstack++ = va_arg(vl, unsigned int);
    }

    va_end(vl);
}

#ifndef NO_POSIX
void makecontext(ucontext_t* ucp, void(*func)(), int argc, ...) __attribute__((alias("__agbabi_makecontext")));
#endif
