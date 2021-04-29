@--------------------------------------------------------------------------------
@ oam.s
@--------------------------------------------------------------------------------
@ AGB OAM + affine matrices weaving functions
@   __agbabi_oamcpy
@   __agbabi_oamset
@   (void *dest, const void *srcA, const void *srcB, size_t n)
@ oamcpy weaves 3 half words of srcA (word aligned) with half words of srcB, writing into dest
@ oamset is similar, but will only weave the first 3 half words of srcA with the first 4 of srcB
@ n is expected to be a multiple of 3+1 half words (8 bytes)
@--------------------------------------------------------------------------------

    .section .iwram.__agbabi_oamcpy, "ax", %progbits
    .align 2
    .arm
    .global __agbabi_oamcpy
    .type __agbabi_oamcpy STT_FUNC
__agbabi_oamcpy:
    push    {r4-r11,r14}

    and     r12, r3, #0x18
    movs    r3, r3, lsr #5
    beq     .Lcopy8

.Lcopy32:
    ldr     r4, [r1], #4
    ldrh    r5, [r1], #4
    ldr     r14, [r2], #2
    orr     r5, r14, lsl #16

    ldr     r6, [r1], #4
    ldrh    r7, [r1], #4
    ldr     r14, [r2], #2
    orr     r7, r14, lsl #16

    ldr     r8, [r1], #4
    ldrh    r9, [r1], #4
    ldr     r14, [r2], #2
    orr     r9, r14, lsl #16

    ldr     r10, [r1], #4
    ldrh    r11, [r1], #4
    ldr     r14, [r2], #2
    orr     r11, r14, lsl #16

    stmia   r0!, {r4-r11}
    subs    r3, r3, #1
    bne     .Lcopy32

.Lcopy8:
    subs    r12, r12, #8
    ldrhs   r4, [r1], #4
    ldrhsh  r5, [r1], #4
    ldrhs   r14, [r2], #2
    orrhs   r5, r14, lsl #16
    stmhs   r0!, {r4-r5}
    bhs     .Lcopy8

    pop     {r4-r11,r14}
    bx      lr

    .section .iwram.__agbabi_oamset, "ax", %progbits
    .align 2
    .arm
    .global __agbabi_oamset
    .type __agbabi_oamset STT_FUNC
__agbabi_oamset:
    push    {r4-r5,r14}

    ldr     r4, [r1], #4
    ldrh    r5, [r1], #4

    and     r12, r3, #0x18
    movs    r3, r3, lsr #5
    beq     .Lset8

    push    {r6-r11}

    mov     r6, r4
    mov     r7, r5
    mov     r8, r4
    mov     r9, r5
    mov     r10, r4
    mov     r11, r5

    ldrh    r14, [r2]
    orr     r5, r14, lsl #16
    ldrh    r14, [r2, #2]
    orr     r7, r14, lsl #16
    ldrh    r14, [r2, #4]
    orr     r9, r14, lsl #16
    ldrh    r14, [r2, #6]
    orr     r11, r14, lsl #16

.Lset32:
    stmia   r0!, {r4-r11}
    subs    r3, r3, #1
    bne     .Lset32

    pop    {r6-r11}

.Lset8:
    subs    r12, r12, #8
    lslhs   r5, r5, #16
    lsrhs   r5, r5, #16
    ldrhs   r14, [r2], #2
    orrhs   r5, r14, lsl #16
    stmhs   r0!, {r4-r5}
    bhs     .Lset8

    pop     {r4-r5,r14}
    bx      lr
