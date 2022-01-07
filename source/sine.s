/*
===============================================================================

 Support:
    __agbabi_sin

 Taken from coranac.com/2009/07/sines by Jasper "cearn" Vijn
 Modified for libagbabi

===============================================================================
*/

#define QN  ( 13 )
#define QP  ( 15 )
#define QR  ( 2 * QN - QP )

    .arm
    .align 2

    .section .iwram.__agbabi_sin, "ax", %progbits
    .global __agbabi_sin
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
