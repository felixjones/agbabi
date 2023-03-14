@===============================================================================
@
@ Support:
@    __agbabi_sqrt
@
@ Taken from pertinentdetail.org/sqrt by Wilco Dijkstra
@ Modified for libagbabi
@
@===============================================================================

    .arm
    .align 2

    .section .iwram.__agbabi_sqrt, "ax", %progbits
    .global __agbabi_sqrt
    .type __agbabi_sqrt, %function
__agbabi_sqrt:
    mov     r1, #3 << 30
    mov     r2, #1 << 30

    @ Jump forward if input is within 1/2/3 bytes
    @ 8-bit check
    movs    r3, r0, lsr #8
    addeq   pc, pc, #(48 * 3) + 12
    @ 16-bit check
    movs    r3, r0, lsr #16
    addeq   pc, pc, #(48 * 2) + 4
    @ 24-bit check
    movs    r3, r0, lsr #24
    addeq   pc, pc, #(48 * 1) - 4

    .set i, 0
    .rept 16
        cmp     r0, r2, ror #2 * i
        subhs   r0, r0, r2, ror #2 * i
        adc     r2, r1, r2, lsl #1
        .set i, i + 1
    .endr

    bic     r0, r2, #3 << 30
    bx      lr
