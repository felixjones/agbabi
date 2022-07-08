/*
===============================================================================

 Support:
    __agbabi_fiq_memcpy4, __agbabi_fiq_memcpy4x4

 Copyright (C) 2021-2022 agbabi contributors
 For conditions of distribution and use, see copyright notice in LICENSE.md

===============================================================================
*/

    .global __agbabi_fiq_memcpy4
__agbabi_fiq_memcpy4:
    push    {r4-r7}
    mrs     r3, cpsr

    // Enter FIQ mode
    bic     r12, r3, #0x1f
    orr     r12, #0x11
    msr     cpsr, r12
    msr     spsr, r3

.Lloop_48:
    subs    r2, r2, #48
    ldmgeia r1!, {r3-r14}
    stmgeia r0!, {r3-r14}
    bgt     .Lloop_48

    // Exit FIQ mode
    mrs     r3, spsr
    msr     cpsr, r3
    pop     {r4-r7}

    adds    r2, r2, #48
    bxeq    lr

.Lcopy_words:
    tst     r2, #4
    blt     .Lcopy_halves
.Lloop_4:
    subs    r2, r2, #4
    ldrge   r3, [r1], #4
    strge   r3, [r0], #4
    bgt     .Lloop_4
    bxeq    lr

    // Copy byte & half tail
    // JoaoBapt test 3-bytes
    movs    r2, r2, lsl #31
    // Copy half
    ldrcsh  r3, [r1], #2
    strcsh  r3, [r0], #2
    // Copy byte
    ldrmib  r3, [r1]
    strmib  r3, [r0]
    bx      lr

.Lcopy_halves:
    // Copy byte head to align
    tst     r0, #1
    ldrneb  r3, [r1], #1
    strneb  r3, [r0], #1
    subne   r2, r2, #1
    // r0, r1 are now half aligned

.Lloop_2:
    subs    r2, r2, #2
    ldrgeh  r3, [r1], #2
    strgeh  r3, [r0], #2
    bgt     .Lloop_2
    bxeq    lr

    // Copy byte tail
    adds    r2, r2, #1
    ldreqb  r3, [r1]
    streqb  r3, [r0]
    bx      lr

    .global __agbabi_fiq_memcpy4x4
__agbabi_fiq_memcpy4x4:
    push    {r4-r10}
    cmp     r2, #48
    ble     .Lcopy_tail

    // Enter FIQ mode
    mrs     r3, cpsr
    bic     r12, r3, #0x1f
    orr     r12, #0x11
    msr     cpsr, r12
    msr     spsr, r3

.Lloop_48:
    subs    r2, r2, #48
    ldmgeia r1!, {r3-r14}
    stmgeia r0!, {r3-r14}
    bgt     .Lloop_48

    // Exit FIQ mode
    mrs     r3, spsr
    msr     cpsr, r3

.Lcopy_tail:
    // JoaoBapt test 48-bytes
    movs    r2, r2, lsl #27
    ldmcsia r1!, {r3-r10}
    stmcsia r0!, {r3-r10}
    ldmmiia r1!, {r3-r6}
    stmmiia r0!, {r3-r6}

    pop     {r4-r10}
    bx      lr
