@--------------------------------------------------------------------------------
@ lasr.s
@--------------------------------------------------------------------------------
@ Implementation of:
@   long long __aeabi_lasr(long long, int)
@--------------------------------------------------------------------------------

    .section .iwram.__aeabi_lasr, "ax", %progbits
    .align 2
    .arm
    .global __aeabi_lasr
    .type __aeabi_lasr STT_FUNC
__aeabi_lasr:
    subs    r3, r2, #32
    rsb     r12, r2, #32
    lsrmi   r0, r0, r2
    asrpl   r0, r1, r3
    orrmi   r0, r0, r1, lsl r12
    asr     r1, r1, r2
    bx      lr
