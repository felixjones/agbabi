/*
===============================================================================

 Support:
    __agbabi_coro_resume, __agbabi_coro_yield, __agbabi_coro_pop

 Copyright (C) 2021-2022 agbabi contributors
 For conditions of distribution and use, see copyright notice in LICENSE.md

===============================================================================
*/

#define AGBABI_CO_OFFSETOF_ARM_R4 0
#define AGBABI_CO_OFFSETOF_ARM_R5 4
#define AGBABI_CO_OFFSETOF_ARM_R6 8
#define AGBABI_CO_OFFSETOF_ARM_R7 12
#define AGBABI_CO_OFFSETOF_ARM_R8 16
#define AGBABI_CO_OFFSETOF_ARM_R9 20
#define AGBABI_CO_OFFSETOF_ARM_R10 24
#define AGBABI_CO_OFFSETOF_ARM_R11 28
#define AGBABI_CO_OFFSETOF_ARM_SP 32
#define AGBABI_CO_OFFSETOF_ARM_LR 36

#define AGBABI_CORO_OFFSETOF_SUSPEND 0
#define AGBABI_CORO_OFFSETOF_CONTEXT 40
#define AGBABI_CORO_OFFSETOF_ALIVE 80

    .arm
    .align 2

    .section .iwram.__agbabi_coro_resume, "ax", %progbits
    .global __agbabi_coro_resume
__agbabi_coro_resume:
    push    {lr}
    ldr     lr, =.Lcoro_yielded

    // Suspend current context
    mov     r1, r0
    stmia   r1!, {r4-r11, sp, lr}

    // Load coro context
    ldmia   r1, {r4-r11, sp, lr}

    // r0 should still contain agbabi_coro_t*
    bx      lr

.Lcoro_yielded:
    // r0 should contain yield value
    pop     {lr}
    bx      lr

    .section .iwram.__agbabi_coro_yield, "ax", %progbits
    .global __agbabi_coro_yield
__agbabi_coro_yield:
    // Suspend current context
    add     r2, r0, #(AGBABI_CORO_OFFSETOF_CONTEXT)
    stmia   r2, {r4-r11, sp, lr}

    // Load suspend context
    ldmia   r0, {r4-r11, sp, lr}

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

    // Clear "alive" flag
    mov     r2, #0
    str     r2, [r1, #AGBABI_CORO_OFFSETOF_ALIVE]

    mov     r2, sp

    // Load suspend context
    ldmia   r1!, {r4-r11, sp, lr}

    // Write sp into context sp
    str     r2, [r1, #AGBABI_CO_OFFSETOF_ARM_SP]

    // Write __agbabi_coro_pop into context lr
    ldr     r2, =__agbabi_coro_pop
    str     r2, [r1, #AGBABI_CO_OFFSETOF_ARM_LR]

    bx      lr
