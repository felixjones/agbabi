@===============================================================================
@
@ Support:
@    __agbabi_uluidiv, __agbabi_uluidivmod, __agbabi_unsafe_uluidivmod
@
@ Taken with permission from github.com/JoaoBaptMG/gba-modern (2020-11-17)
@ Modified for libagbabi
@
@===============================================================================

    .arm
    .align 2

    @ Source code adapted from the 32-bit/32-bit routine to work with 64-bit numerators
    @ Original source code in https://www.chiark.greenend.org.uk/~theom/riscos/docs/ultimate/a252div.txt
    @ r0:r1: the numerator / r2: the denominator
    @ after it, r0:r1 has the quotient and r2 has the modulo. r3 = 0 to be compatible with uldivmod
    .section .iwram.__agbabi_uluidivmod, "ax", %progbits
    .global __agbabi_uluidivmod
    .type __agbabi_uluidivmod, %function
__agbabi_uluidivmod:
    @ Fallthrough

    .global __agbabi_uluidiv
    .type __agbabi_uluidiv, %function
__agbabi_uluidiv:

    @ Check for division by zero
    cmp     r2, #0
    .extern __aeabi_ldiv0
    beq     __aeabi_ldiv0
    @ Fallthrough

    .global __agbabi_unsafe_uluidivmod
    .type __agbabi_unsafe_uluidivmod, %function
__agbabi_unsafe_uluidivmod:
    @ If the second word is 0, just do normal 32x32 division
    cmp     r1, #0
    beq     .LbridgeTo32

    @ Move the denominator to r3 and start to build a counter that
    @ counts the difference on the number of bits on the high side
    @ of the numerator and the denominator
    @ From now on: r0 = quot0/num0, r1 = quot1/num1, r2 = remainder, r3 = -denom, r4 = counter
    push    {r4}
    rsb     r3, r2, #0
    mov     r4, #28             @ first guess on difference
    mov     r2, r1, lsr #4      @ r2 = high(num) >> 4

    @ Iterate three times to get the counter up to 4-bit precision
    cmn     r3, r2, lsr #12     @ if denom <= (r1 >> 12)
    subge   r4, r4, #16         @ then -denom >= -(r1 >> 12)
    movge   r2, r2, lsr #16

    cmn     r3, r2, lsr #4
    subge   r4, r4, #8
    movge   r2, r2, lsr #8

    cmn     r3, r2
    subge   r4, r4, #4
    movge   r2, r2, lsr #4

    @ shift the numerator by the counter
    @ the trick here not to use a lot of registers is to do it with care
    mov     r1, r1, lsl r4          @ r1 << r4
    rsb     r4, r4, #32
    orr     r1, r1, r0, lsr r4      @ r1 << r4 | (r0 >> (32-r4))
    rsb     r4, r4, #32
    mov     r0, r0, lsl r4          @ r0 << r4 - correctly set up
    adds    r0, r0, r0              @ bump r0 a first time
    adcs    r1, r1, r1

    @ dynamically jump to the exact copy of the iteration
    add     pc, pc, r4, lsl #4      @ jump
    mov     r0, r0                  @ pipelining issues

    @ here, r0:r1 = num << (r4 + 1), r2 = num >> (32 - r4), r3 = -denom
    @ now, the real iteration part
    .rept 64
    adcs    r2, r3, r2, lsl #1
    subcc   r2, r2, r3
    adcs    r0, r0, r0
    adcs    r1, r1, r1
    .endr

    @ and then finally quit
    @ r0:r1 = quotient, r2 = remainder
    pop     {r4}
    mov     r3, #0                  @ for compatibility with the 64vs64 division
    bx      lr

.LbridgeTo32:
    mov     r1, r2          @ move the denominator to the actual position
    push    {lr}            @ prepare to call the subroutine
    .extern __agbabi_unsafe_uidivmod
    bl      __agbabi_unsafe_uidivmod  @ call the 32x32 routine
    pop     {lr}            @ pop the link register
    mov     r2, r1          @ move the remainder to the desired location
    mov     r1, #0          @ zero-out the most significant words
    mov     r3, #0          @ same for the remainder
    bx      lr              @ and quit
