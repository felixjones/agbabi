/*
===============================================================================

 Support:
    __agbabi_frac10

 Copyright (C) 2021-2022 agbabi contributors
 For conditions of distribution and use, see copyright notice in LICENSE.md

===============================================================================
*/

    .arm
    .align 2

    .section .iwram.__agbabi_frac10, "ax", %progbits
    .global __agbabi_frac10
__agbabi_frac10:
    push    {r4-r7, r11, lr}
    // Clear 3 upper words of result
    mov     r12, #0
    mov     r2, #0
    mov     r3, #0

    // We multiply by 5 to convert to decimal
    mov     lr, #5
.Lfrac10_loop:
    cmp     r1, #0
    beq     .Lfrac10_return

    // {r0, r12, r2, r3} *= 5
    umull   r4, r5, r2, lr
    umull   r6, r2, r0, lr
    umull   r0, r7, r12, lr
    add     r3, r3, r3, lsl #2
    adds    r12, r0, r2
    mov     r0, r6
    adcs    r2, r4, r7
    adc     r3, r5, r3

    sub     r1, r1, #1
    b       .Lfrac10_loop
.Lfrac10_return:
    mov     r1, r12
    // result = {r0, r1, r2, r3}
    pop     {r4-r7, r11, lr}
    bx      lr
