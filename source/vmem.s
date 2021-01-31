@--------------------------------------------------------------------------------
@ vmem.s
@--------------------------------------------------------------------------------
@ Put 16bit values into dest, which is incremented by stride.
@   __agbabi_vmemput2
@   (void *dest, const void *src, size_t n, ptrdiff_t stride)
@ Get 16bit values from src, which is incremented by stride
@   __agbabi_vmemget2
@   (void *dest, const void *src, size_t n, ptrdiff_t stride)
@ vmemput, vmemget dest & src are half-word-aligned
@--------------------------------------------------------------------------------

    .section .iwram, "ax", %progbits
    .align 2
    .arm
    .global __agbabi_vmemput2
    .type __agbabi_vmemput2 STT_FUNC
__agbabi_vmemput2:
    subs    r2, r2, #2
    bxcc    lr
    ldrsh   r12, [r1], #2
    strh    r12, [r0], r3
    b       __agbabi_vmemput2

    .global __agbabi_vmemget2
    .type __agbabi_vmemget2 STT_FUNC
__agbabi_vmemget2:
    subs    r2, r2, #2
    bxcc    lr
    ldrsh   r12, [r1], r3
    strh    r12, [r0], #2
    b       __agbabi_vmemget2
