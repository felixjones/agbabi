@--------------------------------------------------------------------------------
@ memmove.s
@--------------------------------------------------------------------------------
@ Implementations of:
@   __aeabi_memmove8, __aeabi_memmove4 and __aeabi_memmove
@   (void *dest, const void *src, size_t n)
@ memmove8 is an alias of memmove4
@ memmove4 dest & src are word-aligned
@ __agbabi_memmove2 dest & src are half-word-aligned
@--------------------------------------------------------------------------------

    .section .iwram.__aeabi_memmove, "ax", %progbits
    .align 2
    .arm
    .global __aeabi_memmove
    .type __aeabi_memmove STT_FUNC
__aeabi_memmove:
    cmp     r0, r1
    .extern __agbabi_rmemcpy
    bgt     __agbabi_rmemcpy
    .extern __aeabi_memcpy
    b       __aeabi_memcpy

    .global __aeabi_memmove8
    .type __aeabi_memmove8 STT_FUNC
__aeabi_memmove8:
    .global __aeabi_memmove4
    .type __aeabi_memmove4 STT_FUNC
__aeabi_memmove4:
    cmp     r0, r1
    .extern __agbabi_rmemcpy4
    bgt     __agbabi_rmemcpy4
    .extern __aeabi_memcpy4
    b       __aeabi_memcpy4

    .global __agbabi_memmove2
    .type __agbabi_memmove2 STT_FUNC
__agbabi_memmove2:
    cmp     r0, r1
    .extern __agbabi_rmemcpy2
    bgt     __agbabi_rmemcpy2
    .extern __agbabi_memcpy2
    b       __agbabi_memcpy2

    .section .iwram.memmove, "ax", %progbits
    .align 2
    .arm
    .global memmove
    .type memmove STT_FUNC
memmove:
    push    {r0, lr}
    cmp     r0, r1
    bgt     __agbabi_rmemcpy
    b       __aeabi_memcpy
    pop     {r0, lr}
    bx      lr
