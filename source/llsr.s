@--------------------------------------------------------------------------------
@ llsr.s
@--------------------------------------------------------------------------------
@ Implementation of:
@   long long __aeabi_llsr(long long, int)
@--------------------------------------------------------------------------------

    .section .iwram.__aeabi_llsr, "ax", %progbits
    .align 2
    .arm
    .global __aeabi_llsr
    .type __aeabi_llsr STT_FUNC
__aeabi_llsr:
    subs    r3, r2, #32
    rsb     r12, r2, #32
    lsrmi   r0, r0, r2
    lsrpl   r0, r1, r3
    orrmi   r0, r0, r1, lsl r12
    lsr     r1, r1, r2
    bx      lr
