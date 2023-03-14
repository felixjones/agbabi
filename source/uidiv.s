@===============================================================================
@
@ ABI:
@    __aeabi_uidiv, __aeabi_uidivmod
@ Support:
@    __agbabi_unsafe_uidivmod
@
@ Taken with permission from github.com/JoaoBaptMG/gba-modern (2020-11-17)
@ Modified for libagbabi
@
@===============================================================================

    .arm
    .align 2

    .section .iwram.__aeabi_uidivmod, "ax", %progbits
    .global __aeabi_uidivmod
    .type __aeabi_uidivmod, %function
__aeabi_uidivmod:
    @ Fallthrough

    .global __aeabi_uidiv
    .type __aeabi_uidiv, %function
__aeabi_uidiv:

    @ Check for division by zero
    cmp     r1, #0
    .extern __aeabi_idiv0
    beq     __aeabi_idiv0
    @ Fallthrough

    .global __agbabi_unsafe_uidivmod
    .type __agbabi_unsafe_uidivmod, %function
__agbabi_unsafe_uidivmod:
    @ If n < d, just bail out as well
    cmp     r0, r1    @ n, d
    movlo   r1, r0    @ mod = n
    movlo   r0, #0    @ quot = 0
    bxlo    lr

    @ Move the denominator to r2 and start to build a counter that
    @ counts the difference on the number of bits on each numerator
    @ and denominator
    @ From now on: r0 = quot/num, r1 = mod, r2 = denom, r3 = counter
    mov     r2, r1
    mov     r3, #28             @ first guess on difference
    mov     r1, r0, lsr #4      @ r1 = num >> 4

    @ Iterate three times to get the counter up to 4-bit precision
    cmp     r2, r1, lsr #12
    suble   r3, r3, #16
    movle   r1, r1, lsr #16

    cmp     r2, r1, lsr #4
    suble   r3, r3, #8
    movle   r1, r1, lsr #8

    cmp     r2, r1
    suble   r3, r3, #4
    movle   r1, r1, lsr #4

    @ shift the numerator by the counter and flip the sign of the denom
    mov     r0, r0, lsl r3
    adds    r0, r0, r0
    rsb     r2, r2, #0

    @ dynamically jump to the exact copy of the iteration
    add     r3, r3, r3, lsl #1      @ counter *= 3
    add     pc, pc, r3, lsl #2      @ jump
    mov     r0, r0                  @ pipelining issues

    @ here, r0 = num << (r3 + 1), r1 = num >> (32-r3), r2 = -denom
    @ now, the real iteration part
    .rept 32
    adcs    r1, r2, r1, lsl #1
    sublo   r1, r1, r2
    adcs    r0, r0, r0
    .endr

    @ and then finally quit
    @ r0 = quotient, r1 = remainder
    bx      lr
