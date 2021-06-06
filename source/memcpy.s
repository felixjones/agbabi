@--------------------------------------------------------------------------------
@ memcpy.s
@--------------------------------------------------------------------------------
@ Implementations of:
@   __aeabi_memcpy8, __aeabi_memcpy4 and __aeabi_memcpy
@   (void *dest, const void *src, size_t n)
@ memcpy8 is an alias of memcpy4
@ memcpy4 dest & src are word-aligned
@ __agbabi_memcpy2 dest & src are half-word-aligned
@--------------------------------------------------------------------------------

    .section .iwram.__aeabi_memcpy, "ax", %progbits
    .align 2
    .arm
    .global __aeabi_memcpy
    .type __aeabi_memcpy STT_FUNC
__aeabi_memcpy:
    @ Check pointer alignment
    eor     r3, r1, r0
    @ JoaoBapt carry & sign bit test
    movs    r3, r3, lsl #31
    bmi     .Lcopy1
    bcs     .Lcopy2

.Lcopy4:
    @ Copy half and byte head
    rsb     r3, r0, #4
    movs    r3, r3, lsl #31
    ldrmib  r3, [r1], #1
    strmib  r3, [r0], #1
    submi   r2, r2, #1
    ldrcsh  r3, [r1], #2
    strcsh  r3, [r0], #2
    subcs   r2, r2, #2

    .global __aeabi_memcpy8
    .type __aeabi_memcpy8 STT_FUNC
__aeabi_memcpy8:
    .global __aeabi_memcpy4
    .type __aeabi_memcpy4 STT_FUNC
__aeabi_memcpy4:
    @ Copy 8 words
    movs    r12, r2, lsr #5
    beq     .Lskip32
    lsl     r3, r12, #5
    sub     r2, r2, r3
    push    {r4-r10}
.LcopyWords8:
    ldmia   r1!, {r3-r10}
    stmia   r0!, {r3-r10}
    subs    r12, r12, #1
    bne     .LcopyWords8
    pop     {r4-r10}
.Lskip32:

    @ Copy words
    movs    r12, r2, lsr #2
.LcopyWords:
    subs    r12, r12, #1
    ldrhs   r3, [r1], #4
    strhs   r3, [r0], #4
    bhs     .LcopyWords

    @ Copy half and byte tail
    movs    r3, r2, lsl #31
    ldrcsh  r3, [r1], #2
    strcsh  r3, [r0], #2
    ldrmib  r3, [r1]
    strmib  r3, [r0]
    bx      lr

.Lcopy2:
    @ Copy byte head
    tst     r0, #1
    ldrneb  r3, [r1], #1
    strneb  r3, [r0], #1
    subne   r2, r2, #1

    .global __agbabi_memcpy2
    .type __agbabi_memcpy2 STT_FUNC
__agbabi_memcpy2:
    @ Copy halves
    movs    r12, r2, lsr #1
.LcopyHalves:
    subs    r12, r12, #1
    ldrhsh  r3, [r1], #2
    strhsh  r3, [r0], #2
    bhs     .LcopyHalves

    @ Copy byte tail
    tst     r2, #1
    ldrneb  r3, [r1]
    strneb  r3, [r0]
    bx      lr

.Lcopy1:
    subs    r2, r2, #1
    ldrhsb  r3, [r1], #1
    strhsb  r3, [r0], #1
    bhs     .Lcopy1
    bx      lr

    .global memcpy
    .type memcpy STT_FUNC
memcpy:
    push    {r0, lr}
    bl      __aeabi_memcpy
    pop     {r0, lr}
    bx      lr
