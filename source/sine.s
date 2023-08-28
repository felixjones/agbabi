@===============================================================================
@
@ Support:
@    __agbabi_sin
@
@ Taken from coranac.com/2009/07/sines by Jasper "cearn" Vijn
@ Modified for libagbabi
@
@===============================================================================

.syntax unified

    .arm
    .align 2

    .section .iwram.__agbabi_sin, "ax", %progbits
    .global __agbabi_sin
    .type __agbabi_sin, %function
__agbabi_sin:
    lsl     r0, r0, #17
    teq     r0, r0, lsl #1
    rsbmi   r0, r0, #0x80000000
    asr     r0, r0, #17
    mul     r1, r0, r0
    asr     r1, r1, #11
    rsb     r1, r1, #0x18000
    mul     r0, r1, r0
    bx      lr
