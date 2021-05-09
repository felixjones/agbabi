@--------------------------------------------------------------------------------
@ rmemcpy.s
@--------------------------------------------------------------------------------
@ Equivalent to memcpy, but copies in reverse.
@   __agbabi_rmemcpy4
@   __agbabi_rmemcpy
@   (void *dest, const void *src, size_t n)
@ rmemcpy4 dest * src are word-aligned
@ rmemcpy might not be word-aligned
@--------------------------------------------------------------------------------

    .section .iwram.__agbabi_rmemcpy, "ax", %progbits
    .align 2
    .arm
    .global __agbabi_rmemcpy
    .type __agbabi_rmemcpy STT_FUNC
__agbabi_rmemcpy:
    and     r3, r0, #3
    and     r12, r1, #3
    cmp     r3, r12
    add     r0, r0, r2
    add     r1, r1, r2
    bne     .Lunaligned

    and     r12, r2, #3
    sub     r2, r2, r12
    push    {r12,lr}
    mov     lr, pc
    bl      .Lreversecopy
    pop     {r12,lr}
.Lcopy_front:
    subs    r12, r12, #1
    ldrhsb  r3, [r1, #-1]!
    strhsb  r3, [r0, #-1]!
    bhs     .Lcopy_front
    bx      lr

    .section .iwram.__agbabi_rmemcpy4, "ax", %progbits
    .align 2
    .arm
    .global __agbabi_rmemcpy4
    .type __agbabi_rmemcpy4 STT_FUNC
__agbabi_rmemcpy4:
    add     r0, r0, r2
    add     r1, r1, r2

.Lreversecopy:
    @ Copy bytes
    ands    r12, r2, #3
    beq     .Lwordcopy4
.Lcopy:
    subs    r12, r12, #1
    ldrhsb  r3, [r1, #-1]!
    strhsb  r3, [r0, #-1]!
    bhs     .Lcopy

    @ Copy words
.Lwordcopy4:
    mov     r2, r2, lsr #2
    ands    r12, r2, #7
    beq     .Lwordcopy32
.Lcopy4:
    subs    r12, #1
    ldrhs   r3, [r1, #-4]!
    strhs   r3, [r0, #-4]!
    bhs     .Lcopy4

    @ Copy 8 words
.Lwordcopy32:
    movs    r2, r2, lsr #3
    bxeq    lr
    push    {r4-r10}
.Lcopy32:
    ldmdb   r1!, {r3-r10}
    stmdb   r0!, {r3-r10}
    subs    r2, #1
    bne     .Lcopy32
    pop     {r4-r10}
    bx      lr

.Lunaligned:
    subs    r2, r2, #1
    ldrhsb  r3, [r1, #-1]!
    strhsb  r3, [r0, #-1]!
    bhs     .Lunaligned
    bx      lr
