@--------------------------------------------------------------------------------
@ memset.s
@--------------------------------------------------------------------------------
@ Implementations of:
@   __aeabi_memset8, __aeabi_memset4 and __aeabi_memset
@   (void *dest, size_t n, int c)
@ memset8 is an alias of memset4
@ memset4 dest is word-aligned
@ memset might not be word-aligned
@ __agbabi_wordset4 sets words (does not reduce to lowest byte)
@   __aeabi_memclr8, __aeabi_memclr4 and __aeabi_memclr
@   (void *dest, size_t n)
@ memclr8 is an alias of memclr4
@ memclr4 dest is word-aligned, calls __agbabi_wordset4 with value 0
@ memclr might not be word-aligned, calls memset with value 0
@--------------------------------------------------------------------------------

    .section .iwram.__aeabi_memset, "ax", %progbits
    .align 2
    .arm
    .global __aeabi_memclr
    .type __aeabi_memclr STT_FUNC
__aeabi_memclr:
    mov     r2, #0
    b       .LskipShifts

    .global __aeabi_memset
    .type __aeabi_memset STT_FUNC
__aeabi_memset:
    mov     r2, r2, lsl #24
    orr     r2, r2, r2, lsr #8
    orr     r2, r2, r2, lsr #16

.LskipShifts:
    @ JoaoBapt carry & sign bit test
    rsb     r3, r0, #4
    movs    r3, r3, lsl #31
    @ Set half and byte head
    strmib  r2, [r0], #1
    submi   r1, r1, #1
    strcsh  r2, [r0], #2
    subcs   r1, r1, #2
    b       __agbabi_wordset4

    .global __aeabi_memclr8
    .type __aeabi_memclr8 STT_FUNC
__aeabi_memclr8:
    .global __aeabi_memclr4
    .type __aeabi_memclr4 STT_FUNC
__aeabi_memclr4:
    mov     r2, #0
    b       __agbabi_wordset4

    .global __aeabi_memset8
    .type __aeabi_memset8 STT_FUNC
__aeabi_memset8:
    .global __aeabi_memset4
    .type __aeabi_memset4 STT_FUNC
__aeabi_memset4:
    mov     r2, r2, lsl #24
    orr     r2, r2, r2, lsr #8
    orr     r2, r2, r2, lsr #16

    .global __agbabi_wordset4
    .type __agbabi_wordset4 STT_FUNC
__agbabi_wordset4:
    @ Set 8 words
    movs    r12, r1, lsr #5
    beq     .Lskip32
    lsl     r3, r12, #5
    sub     r1, r1, r3
    push    {r4-r9}
    mov     r3, r2
    mov     r4, r2
    mov     r5, r2
    mov     r6, r2
    mov     r7, r2
    mov     r8, r2
    mov     r9, r2
.LsetWords8:
    stmia   r0!, {r2-r9}
    subs    r12, r12, #1
    bne     .LsetWords8
    pop     {r4-r9}
.Lskip32:

    @ Set words
    movs    r12, r1, lsr #2
.LsetWords:
    subs    r12, r12, #1
    strhs   r2, [r0], #4
    bhs     .LsetWords

    @ Set half and byte tail
    movs    r3, r1, lsl #31
    strcsh  r2, [r0], #2
    strmib  r2, [r0]
    bx      lr

    .global memset
    .type memset STT_FUNC
memset:
    mov     r3, r1
    mov     r1, r2
    mov     r2, r3
    push    {r0, lr}
    bl      __aeabi_memset
    pop     {r0, lr}
    bx      lr
