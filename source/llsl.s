@--------------------------------------------------------------------------------
@ llsl.s
@--------------------------------------------------------------------------------
@ Implementation of:
@   long long __aeabi_llsl(long long, int)
@--------------------------------------------------------------------------------

    .section .iwram.__aeabi_llsl, "ax", %progbits
    .align 2
    .arm
    .global __aeabi_llsl
    .type __aeabi_llsl STT_FUNC
__aeabi_llsl:
    subs    r3, r2, #32
    rsb     r12, r2, #32
    lslmi   r1, r1, r2
    lslpl   r1, r0, r3
    orrmi   r1, r1, r0, lsr r12
    lsl     r0, r0, r2
    bx      lr
