/*
===============================================================================

 Support:
    __agbabi_coro_resume, __agbabi_coro_yield, __agbabi_coro_pop

 Copyright (C) 2021-2022 agbabi contributors
 For conditions of distribution and use, see copyright notice in LICENSE.md

===============================================================================
*/

#define AGBABI_CORO_OFFSETOF_ALIVE 8

    .arm
    .align 2

    .section .iwram.__agbabi_coro_resume, "ax", %progbits
    .global __agbabi_coro_resume
__agbabi_coro_resume:
    push    {r4-r11}
    mov     r1, sp
    mov     r2, lr

    ldmia   r0, {sp, lr}
    pop     {r4-r11}
    stmia   r0, {r1-r2}

    bx      lr

    .section .iwram.__agbabi_coro_yield, "ax", %progbits
    .global __agbabi_coro_yield
__agbabi_coro_yield:
    push    {r4-r11}
    mov     r2, sp
    mov     r3, lr

    ldmia   r0, {sp, lr}
    pop     {r4-r11}
    stmia   r0, {r2-r3}

    // Move yield value into r0 and return
    mov     r0, r1
    bx      lr

    .section .iwram.__agbabi_coro_pop, "ax", %progbits
    .global __agbabi_coro_pop
__agbabi_coro_pop:
    ldmia   sp, {r0-r1}

    // Set "alive" flag
    mov     r2, #1
    str     r2, [r0, #(AGBABI_CORO_OFFSETOF_ALIVE)]

    mov     lr, pc
    bx      r1
    ldr     r1, [sp]
    // r0 contains return value
    // r1 points to agbabi_coro_t*

    // Clear "alive" flag
    mov     r3, #0
    str     r3, [r1, #AGBABI_CORO_OFFSETOF_ALIVE]

    // Allocate space for storing r4-r11
    sub     r2, sp, #32
    ldr     r3, =__agbabi_coro_pop

    // Load suspend context
    ldmia   r1, {sp, lr}
    pop     {r4-r11}
    stmia   r1, {r2-r3}

    bx      lr
