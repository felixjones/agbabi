/*
===============================================================================

 ABI:
    __aeabi_memcpy, __aeabi_memcpy4, __aeabi_memcpy8
 Standard:
    memcpy
 Support:
    __agbabi_memcpy2, __agbabi_memcpy1

 Copyright (C) 2021-2022 agbabi contributors
 For conditions of distribution and use, see copyright notice in LICENSE.md

===============================================================================
*/

// Test lowest two bits, clobbering \reg
// Use mi for low bit, cs for high bit
.macro joaobapt_test reg
    movs    \reg, \reg, lsl #31
.endm

// Branches depending on lowest two bits, clobbering \reg
// b_mi = low bit case, b_cs = high bit case
.macro joaobapt_switch reg, b_mi, b_cs
    joaobapt_test \reg
    bmi     \b_mi
    bcs     \b_cs
.endm

// Branches depending on alignment of \a and \b, clobbering \scratch
// b_byte = off-by-byte case, b_half = off-by-half case
.macro align_switch a, b, scratch, b_byte, b_half
    eor     \scratch, \a, \b
    joaobapt_switch \scratch, \b_byte, \b_half
.endm

    .arm
    .align 2

    .section .iwram.__aeabi_memcpy, "ax", %progbits
    .global __aeabi_memcpy
__aeabi_memcpy:
    // >6-bytes is roughly the threshold when byte-by-byte copy is slower
    cmp     r2, #6
    ble     __agbabi_memcpy1

    align_switch r0, r1, r12, __agbabi_memcpy1, .Lcopy_halves

    // Check if r0 (or r1) needs word aligning
    rsbs     r3, r0, #4
    joaobapt_test r3

    // Copy byte head to align
    ldrmib  r3, [r1], #1
    strmib  r3, [r0], #1
    submi   r2, r2, #1
    // r0, r1 are now half aligned

    // Copy half head to align
    ldrcsh  r3, [r1], #2
    strcsh  r3, [r0], #2
    subcs   r2, r2, #2
    // r0, r1 are now word aligned

    .global __aeabi_memcpy8
__aeabi_memcpy8:
    .global __aeabi_memcpy4
__aeabi_memcpy4:
    // Word aligned, 32-byte copy
    movs    r12, r2, lsr #5
    beq     .Lcopy_words

    // Subtract r12 * 32-bytes from r2
    sub     r2, r2, r12, lsl #5

    push    {r4-r10}
.Lloop_32:
    ldmia   r1!, {r3-r10}
    stmia   r0!, {r3-r10}
    subs    r12, r12, #1
    bne     .Lloop_32
    pop     {r4-r10}
    // < 32 bytes remaining to be copied

    // Early out for large 32-byte copies
    cmp     r2, #0
    bxeq    lr

.Lcopy_words:
    movs    r12, r2, lsr #2
    beq     .Lcopy_halves
.Lloop_4:
    ldr     r3, [r1], #4
    str     r3, [r0], #4
    subs    r12, r12, #1
    bne     .Lloop_4

    // Copy byte & half tail
    joaobapt_test r2
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

    .global __agbabi_memcpy2
__agbabi_memcpy2:
    subs    r2, r2, #2
    ldrhsh  r3, [r1], #2
    strhsh  r3, [r0], #2
    bgt     __agbabi_memcpy2
    bxeq    lr

    // Copy byte tail
    adds    r2, r2, #1
    ldreqb  r3, [r1]
    streqb  r3, [r0]
    bx      lr

    .global __agbabi_memcpy1
__agbabi_memcpy1:
    subs    r2, r2, #1
    ldrhsb  r3, [r1], #1
    strhsb  r3, [r0], #1
    bgt     __agbabi_memcpy1
    bx      lr

    .section .iwram.memcpy, "ax", %progbits
    .global memcpy
memcpy:
    push    {r0, lr}
    bl      __aeabi_memcpy
    pop     {r0, lr}
    bx      lr
