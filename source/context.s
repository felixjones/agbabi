/*
===============================================================================

 POSIX:
    getcontext, setcontext, swapcontext

 Support:
    __agbabi_getcontext, __agbabi_setcontext, __agbabi_swapcontext, __agbabi_popcontext

 Copyright (C) 2021-2022 agbabi contributors
 For conditions of distribution and use, see copyright notice in LICENSE.md

===============================================================================
*/

#include <sys/ucontext.h>

    .arm
    .align 2

    .section .iwram.__agbabi_getcontext, "ax", %progbits
#ifndef NO_POSIX
    .global getcontext
getcontext:
#endif
    .global __agbabi_getcontext
__agbabi_getcontext:
    // Save r0
    str     r0, [r0, #(UCONTEXT_OFFSETOF_UC_MCONTEXT + MCONTEXT_OFFSETOF_ARM_R0)]

    // Save r1-r12
    add     r0, r0, #(UCONTEXT_OFFSETOF_UC_MCONTEXT + MCONTEXT_OFFSETOF_ARM_R1)
    stmia   r0, {r1-r12, sp, lr}

    // Load cpsr and pc
    mrs     r1, cpsr
    sub     r2, lr, #8

    // Test lr for thumb flag
    tst     lr, #1
    orrne   r1, r1, #0x20   // Mix with cpsr thumb flag
    addne   r2, r2, #4      // Adjust thumb PC

    // Save cpsr and pc
    str     r1, [r0, #(MCONTEXT_OFFSETOF_ARM_CPSR - MCONTEXT_OFFSETOF_ARM_R1)]
    str     r2, [r0, #(MCONTEXT_OFFSETOF_ARM_PC - MCONTEXT_OFFSETOF_ARM_R1)]

    // Return 0 = success
    mov     r0, #0
.Lbx_lr:
    bx      lr

    .section .iwram.__agbabi_setcontext, "ax", %progbits
#ifndef NO_POSIX
    .global setcontext
setcontext:
#endif
    .global __agbabi_setcontext
__agbabi_setcontext:
    // Enter target mode (IRQ disabled, ARM mode forced)
    ldr     r2, [r0, #(UCONTEXT_OFFSETOF_UC_MCONTEXT + MCONTEXT_OFFSETOF_ARM_CPSR)]
    orr     r1, r2, #0x80
    bic     r1, r1, #0x20
    msr     cpsr, r1

    // Restore r3-r12
    add     r0, r0, #(UCONTEXT_OFFSETOF_UC_MCONTEXT + MCONTEXT_OFFSETOF_ARM_R3)
    ldmia   r0, {r3-r12}

    // Restore sp, lr
    ldr     sp, [r0, #(MCONTEXT_OFFSETOF_ARM_SP - MCONTEXT_OFFSETOF_ARM_R3)]
    ldr     lr, [r0, #(MCONTEXT_OFFSETOF_ARM_LR - MCONTEXT_OFFSETOF_ARM_R3)]

    // Enter undef mode (IRQ still disabled)
    msr     cpsr, #0x9b

    // Restore cpsr into undef spsr
    msr     spsr, r2

    // Restore pc into undef lr
    ldr     lr, [r0, #(MCONTEXT_OFFSETOF_ARM_PC - MCONTEXT_OFFSETOF_ARM_R3)]

    // Restore r0-r2
    sub     r0, r0, #(MCONTEXT_OFFSETOF_ARM_R3 - MCONTEXT_OFFSETOF_ARM_R0)
    ldmia   r0, {r0-r2}

    // pc = undef lr, cpsr = undef spsr
    movs    pc, lr

    .section .iwram.__agbabi_swapcontext, "ax", %progbits
#ifndef NO_POSIX
    .global swapcontext
swapcontext:
#endif
    .global __agbabi_swapcontext
__agbabi_swapcontext:
    push    {r0-r1, lr}
    bl      __agbabi_getcontext
    pop     {r0-r1, lr}

    // Return 0 = success
    mov     r2, #0
    str     r2, [r0, #(UCONTEXT_OFFSETOF_UC_MCONTEXT + MCONTEXT_OFFSETOF_ARM_R0)]

    str     sp, [r0, #(UCONTEXT_OFFSETOF_UC_MCONTEXT + MCONTEXT_OFFSETOF_ARM_SP)]
    str     lr, [r0, #(UCONTEXT_OFFSETOF_UC_MCONTEXT + MCONTEXT_OFFSETOF_ARM_LR)]
    ldr     r2, =.Lbx_lr
    str     r2, [r0, #(UCONTEXT_OFFSETOF_UC_MCONTEXT + MCONTEXT_OFFSETOF_ARM_PC)]

    mov     r0, r1
    b       __agbabi_setcontext

    .section .iwram.__agbabi_popcontext, "ax", %progbits
    .global __agbabi_popcontext
__agbabi_popcontext:
    pop     {r0}
    cmp     r0, #0
    bne     __agbabi_setcontext
    .extern _exit
    ldr     r1, =_exit
    bx      r1
