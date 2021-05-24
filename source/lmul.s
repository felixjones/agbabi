@--------------------------------------------------------------------------------
@ lmul.s
@--------------------------------------------------------------------------------
@ Implementation of:
@   long long __aeabi_lmul(long long, long long)
@--------------------------------------------------------------------------------

    .section .iwram.__aeabi_lmul, "ax", %progbits
    .align 2
    .arm
    .global __aeabi_lmul
    .type __aeabi_lmul STT_FUNC
__aeabi_lmul:
    mul     r3, r0, r3
    mla     r1, r2, r1, r3
    umull   r0, r3, r2, r0
    add     r1, r1, r3
    bx      lr
