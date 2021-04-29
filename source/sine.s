@--------------------------------------------------------------------------------
@ sine.s
@--------------------------------------------------------------------------------
@ Fast fixed-point sine approximation
@ Returns a Q29 fixed-point result from a given 16-bit signed binary angle
@ Taken from coranac.com/2009/07/sines by Jasper "cearn" Vijn
@ Modified for libagbabi
@--------------------------------------------------------------------------------

#define QN  ( 13 )
#define QA  ( 12 )
#define QP  ( 15 )
#define QR  ( 2 * QN - QP )

    .section .iwram.__agbabi_sin, "ax", %progbits
    .align 2
    .arm
    .global __agbabi_sin
    .type __agbabi_sin STT_FUNC
__agbabi_sin:
    mov     r0, r0, lsl #( 30 - QN )
    teq     r0, r0, lsl #1
    rsbmi   r0, r0, #( 1 << 31 )
    mov     r0, r0, asr #( 30 - QN )
    mul     r1, r0, r0
    mov     r1, r1, asr #( QR )
    rsb     r1, r1, #( 3 << QP )
    mul     r0, r1, r0
    bx      lr
