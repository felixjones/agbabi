@--------------------------------------------------------------------------------
@ ldiv.s
@--------------------------------------------------------------------------------
@ Provides an implementation of signed 64-bit division
@ Taken with permission from github.com/JoaoBaptMG/gba-modern (2021-05-23)
@ Modified for libagbabi
@--------------------------------------------------------------------------------

@ r0:r1: the numerator / r2:r3: the denominator
@ after it, r0:r1 has the quotient and r2:r3 has the modulo
    .section .iwram.__aeabi_ldivmod, "ax", %progbits
    .align 2
    .arm
    .global __aeabi_ldivmod
    .type __aeabi_ldivmod STT_FUNC
__aeabi_ldivmod:

    .global __aeabi_ldiv
    .type __aeabi_ldiv STT_FUNC
__aeabi_ldiv:
    @ Test division by zero
    cmp     r3, #0
    cmpeq   r2, #0
    .extern __aeabi_ldiv0
    beq     __aeabi_ldiv0

    @ Move the lr to r12 and make the numbers positive
    mov     r12, lr

    @ bit 28 is whether the numerator is negative
    cmp     r1, #0
    orrlt   r12, #1 << 28
    bge     .LnumeratorIsPositive
    rsbs    r0, r0, #0
    rsc     r1, r1, #0
.LnumeratorIsPositive:

    @ bit 31 is whether the denominator is negative
    cmp     r3, #0
    orrlt   r12, #1 << 31
    bge     .LdenominatorIsPositive
    rsbs    r2, r2, #0
    rsc     r3, r3, #0

.LdenominatorIsPositive:
    @ Check if the high register of the denominator is zero
    cmp     r3, #0
    adreq   lr, .skipRoutinePastZero
    .extern __agbabi_unsafe_uluidiv
    beq     __agbabi_unsafe_uluidiv

    @ Call the unsigned division
    .extern __agbabi_unsafe_uldiv
    bl      __agbabi_unsafe_uldiv

.skipRoutinePastZero:
    @ This moves "numerator is negative" to overflow flag and
    @ "denominator is negative" to sign flag
    msr     cpsr_f, r12

    @ The quotient should be negated only if exactly one (but not zero or two)
    @ of the numerator and/or denominator were negative, so that means N!=V
    @ that's why we use the lt condition here
    bge     .LquotientShouldBePositive
    rsbs    r0, r0, #0
    rsc     r1, r1, #0
    msr     cpsr_f, r12     @ move the flags again
.LquotientShouldBePositive:

    @ The modulo should only be negated if the numerator was negative, so if V=1
    bvc     .LremainderShouldBePositive
    rsbs    r2, r2, #0
    rsc     r3, r3, #0
.LremainderShouldBePositive:

    @ Erase the sign bits from the return address, and return
    bic     r12, #0xF << 28
    bx      r12
