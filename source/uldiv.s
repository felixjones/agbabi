@===============================================================================
@
@ ABI:
@    __aeabi_uldivmod
@ Support:
@    __agbabi_uldiv, __agbabi_unsafe_uldivmod
@
@ Taken with permission from github.com/JoaoBaptMG/gba-modern (2020-11-17)
@ Modified for libagbabi
@
@===============================================================================

    .arm
    .align 2

    @ Source code adapted from the 32-bit/32-bit routine to work with 64-bit numerators
    @ Original source code in https://www.chiark.greenend.org.uk/~theom/riscos/docs/ultimate/a252div.txt
    @ r0:r1: the numerator / r2:r3: the denominator
    @ after it, r0:r1 has the quotient and r2:r3 has the modulo
    .section .iwram.__aeabi_uldivmod, "ax", %progbits
    .align 2
    .arm
    .global __aeabi_uldivmod
    .type __aeabi_uldivmod, %function
__aeabi_uldivmod:
    @ Fallthrough

    .global __agbabi_uldiv
    .type __agbabi_uldiv, %function
__agbabi_uldiv:
    @ Check if the high word of the denominator is zero
    cmp     r3, #0
    .extern __agbabi_uluidiv
    beq     __agbabi_uluidiv
    @ Fallthrough

    .global __agbabi_unsafe_uldivmod
    .type __agbabi_unsafe_uldivmod, %function
__agbabi_unsafe_uldivmod:
    @ Check if the denominator is greater than the numerator and exit early if so
    cmp     r1, r3
    cmpeq   r0, r2
    blo     .LzeroQuotient

    @ The fact that r3 != 0 gives us a nice optimization
    @ Since the quotient will then be 32-bit, we only need to use a
    @ 96-bit "numerator train", and it will finish nicely in 32 iterations
    push    {r4-r5}                 @ reserve space
    rsbs    r4, r2, #0              @ negate the denominator
    mov     r2, r1                  @ move the "numerator train" into place
    rsc     r1, r3, #0              @ negate with carry, to do the right task

    @ Now, we have r0:r2:r3 (in that order) is the "numerator train", with the
    @ remainder arriving in r2:r3 and the quotient in r0
    @ r4:r1 (in that order) is the denominator
    @ Build counter for optimization
    mov     r5, #30                 @ first guess on difference
    mov     r3, r2, lsr #2

    @ Iterate four times to get the counter up to 4-bit precision
    cmn     r1, r3, lsr #14     @ if denom <= (r1 >> 12)
    subge   r5, r5, #16         @ then -denom >= -(r1 >> 12)
    movge   r3, r3, lsr #16

    cmn     r1, r3, lsr #6
    subge   r5, r5, #8
    movge   r3, r3, lsr #8

    cmn     r1, r3, lsr #2
    subge   r5, r5, #4
    movge   r3, r3, lsr #4

    cmn     r1, r3
    subge   r5, r5, #2
    movge   r3, r3, lsr #2

    @ shift the rest of the numerator by the counter
    mov     r2, r2, lsl r5          @ r1 << r3
    rsb     r5, r5, #32
    orr     r2, r2, r0, lsr r5      @ r1 << r3 | (r0 >> (32-r3))
    rsb     r5, r5, #32
    mov     r0, r0, lsl r5          @ r0 << r3 - correctly set up
    adds    r0, r0, r0              @ bump r0 a first time

    @ dynamically jump to the exact copy of the iteration
    add     r5, r5, r5, lsl #3      @ multiply by 9
    add     pc, pc, r5, lsl #2      @ jump
    mov     r0, r0                  @ pipelining issues

    .rept 32                        @ any attempt at optimising those 9 instructions would be appreciated
    adcs    r2, r2, r2              @ (don't forget to update the multiplier up there, if you do manage it)
    adc     r3, r3, r3              @ this should be uncoupled in two additions like that
    adds    r2, r2, r4              @ because we can have a double-carry problem
    adcs    r3, r3, r1
    bcs     1f
    subs    r2, r2, r4
    sbc     r3, r3, r1
    adds    r0, r0, #0              @ this will clear the carry flag
1:
    adcs    r0, r0, r0              @ so it can be correctly used here
    .endr

    @ from here, r0 = quotient, r2:r3 = remainder
    @ so it's just a matter of setting r1 = 0
    pop     {r4-r5}
    mov     r1, #0
    bx      lr

.LzeroQuotient:
    @ n < d, so quot = 0 and rem = n
    mov     r2, r0
    mov     r3, r1
    mov     r0, #0
    mov     r1, #0
    bx      lr
