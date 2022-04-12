/*
===============================================================================

 Support:
    __agbabi_frac10, __agbabi_bcd128

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

    // Compiled from Clang with _BitInt
    .section .iwram.__agbabi_bcd128, "ax", %progbits
    .global __agbabi_bcd128
__agbabi_bcd128:
    push    {r4-r11, lr}
    sub     sp, sp, #44
    ldr     r7, [sp, #80]
    mov     r12, #0
    str     r12, [sp, #36]
    str     r12, [sp, #32]
    str     r12, [sp, #28]
    str     r12, [sp, #24]

    cmp     r12, r7, lsl #2
    beq     .Lbcd128_loop_bits

    lsl     r4, r7, #2
    rsb     r11, r4, #128
    rsb     r8, r4, #64
    rsbs    r12, r4, #96
    str     r4, [sp]
    rsb     lr, r11, #32
    rsb     r9, r11, #64
    lsr     r6, r2, lr
    lsr     r5, r1, r9
    orr     r10, r6, r3, lsl r11
    rsb     r6, r8, #32
    lsr     r6, r0, r6
    lslpl   r10, r2, r12
    cmp     lr, #0
    movpl   r5, #0
    orr     r6, r6, r1, lsl r8
    rsbs    r7, r4, #32
    rsb     r4, r9, #32
    lsl     r8, r0, r8
    lslpl   r6, r0, r7
    cmp     r11, #64
    orrlo   r6, r10, r5
    cmp     r11, #0
    mov     r10, #0x0f600000
    mov     r5, #30
    moveq   r6, r3
    lsr     r3, r0, r9
    cmp     lr, #0
    orr     r10, r10, #0xf0000000
    orr     r3, r3, r1, lsl r4
    lsl     r4, r2, r11
    lsrpl   r3, r1, lr
    cmp     r12, #0
    movpl   r4, #0
    cmp     r7, #0
    mov     r7, #0
    movpl   r8, #0
    cmp     r11, #64
    orrlo   r8, r4, r3
    cmp     r11, #0
    lsl     r3, r0, r11
    moveq   r8, r2
    cmp     r12, #0
    lsr     r2, r0, lr
    movpl   r3, #0
    cmp     r11, #64
    orr     lr, r2, r1, lsl r11
    movhs   r3, r7
    cmp     r12, #0
    lslpl   lr, r0, r12
    cmp     r11, #64
    ldr     r11, .LCPI0_1
    add     r0, sp, #24
    mov     r12, #0x60000000
    movhs   lr, r7

.LBB0_2:
    str     lr, [sp, #4]
    lsr     r9, r6, #31
    mov     lr, #0
    str     r7, [sp, #8]
    str     r3, [sp, #12]
    str     r8, [sp, #16]
    str     r6, [sp, #20]

.Lbcd128_loop_words:
    ldr     r8, [r0, lr, lsl #2]
    and     r7, r9, #0x00000001
    ldr     r2, .LCPI0_0
    mvn     r4, #159 // 0xffffff60
    mov     r9, #0
    and     r6, r8, #0x0000000f
    and     r3, r5, r8, lsr #7
    orr     r6, r7, r6, lsl #1
    and     r7, r5, r8, lsr #3
    cmp     r6, #9
    orrhi   r7, r7, #1
    cmp     r7, #9
    orrhi   r3, r3, #1
    lsl     r1, r3, #8
    cmp     r3, #9
    addhi   r1, r2, r3, lsl #8
    lsl     r2, r7, #4
    cmp     r7, #9
    addhi   r2, r4, r7, lsl #4
    cmp     r6, #9
    mov     r4, #0x00f60000
    subhi   r6, r6, #10
    cmp     r3, #9
    orr     r4, r4, #0xff000000
    orr     r2, r2, r6
    orr     r1, r2, r1
    and     r2, r5, r8, lsr #11
    orrhi   r2, r2, #1
    lsl     r3, r2, #12
    cmp     r2, #9
    addhi   r3, r11, r2, lsl #12
    and     r2, r5, r8, lsr #15
    orrhi   r2, r2, #1
    orr     r1, r1, r3
    lsl     r3, r2, #16
    cmp     r2, #9
    addhi   r3, r4, r2, lsl #16
    and     r2, r5, r8, lsr #19
    mov     r4, #0xf6000000
    orrhi   r2, r2, #1
    orr     r1, r1, r3
    lsl     r3, r2, #20
    cmp     r2, #9
    addhi   r3, r10, r2, lsl #20
    and     r2, r5, r8, lsr #23
    orrhi   r2, r2, #1
    orr     r1, r1, r3
    lsl     r3, r2, #24
    cmp     r2, #9
    addhi   r3, r4, r2, lsl #24
    and     r2, r5, r8, lsr #27
    orrhi   r2, r2, #1
    orr     r1, r1, r3
    cmp     r2, #9
    lsl     r3, r2, #28
    addhi   r3, r12, r2, lsl #28
    movhi   r9, #1
    orr     r1, r1, r3
    str     r1, [r0, lr, lsl #2]
    add     lr, lr, #1
    cmp     lr, #4
    bne     .Lbcd128_loop_words

    ldr     r1, [sp, #4]
    ldr     r3, [sp, #12]
    ldr     r2, [sp, #16]
    ldr     r7, [sp, #8]
    lsl     r6, r1, #1
    add     r7, r7, #1
    orr     lr, r6, r3, lsr #31
    lsl     r6, r2, #1
    lsl     r3, r3, #1
    orr     r8, r6, r1, lsr #31
    ldr     r1, [sp, #20]
    lsl     r6, r1, #1
    ldr     r1, [sp]
    orr     r6, r6, r2, lsr #31
    cmp     r7, r1
    bne     .LBB0_2
    add     r3, sp, #28
    ldr     r12, [sp, #24]
    ldm     r3, {r1, r2, r3}
    b       .Lbcd128_return

.Lbcd128_loop_bits:
    mov     r1, #0
    mov     r2, #0
    mov     r3, #0

.Lbcd128_return:
    mov     r0, r12
    add     sp, sp, #44
    pop     {r4-r11, lr}
    bx      lr

.LCPI0_0:
    .long   0xfffff600
.LCPI0_1:
    .long   0xffff6000
