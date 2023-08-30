@===============================================================================
@
@ Support:
@    __agbabi_m4col_pack2, __agbabi_m4col_unpack2,
@    __agbabi_m4col_pack4, __agbabi_m4col_unpack4
@
@ Copyright (C) 2021-2023 agbabi contributors
@ For conditions of distribution and use, see copyright notice in LICENSE.md
@
@===============================================================================

.syntax unified

    .arm
    .align 2

    .section .iwram.__agbabi_m4col_pack2, "ax", %progbits
    .global __agbabi_m4col_pack2
    .type __agbabi_m4col_pack2, %function
__agbabi_m4col_pack2:
    @ r0 = vram, r1 = source, r2 = number of rows (multiple of 4, non-zero)
    push    {r4-r6}

    @ Mask r12 = {0x00ff00ff}
    mov     r12, #0xff
    orr     r12, r12, r12, lsl #16

.Lpack2_loop:
    @ read 4 pixels of column 0, 1
    ldr     r4, [r1, #160]
    ldr     r3, [r1], #4
    @ r3-r4 = {33221100, 77665544}

    and     r5, r3, r12  @ r5 = {__22__00}
    and     r6, r4, r12  @ r6 = {__66__44}

    @ [r2-r3]{77xx55xx_33xx11xx}
    bic     r3, r12  @ r3 = {33__11__}
    bic     r4, r12  @ r4 = {77__55__}

    @ [r2-r5]{4400_5511_6622_7733}
    orr     r6, r5, r6, lsl #8  @ r6 = {66224400}
    orr     r5, r4, r3, lsr #8  @ r5 = {77335511}
    lsr     r4, r6, #16         @ r4 = {____6622}
    lsr     r3, r5, #16         @ r3 = {____7733}

    strh    r6, [r0], #240
    strh    r5, [r0], #240
    strh    r4, [r0], #240
    strh    r3, [r0], #240

    subs    r2, #4
    bgt     .Lpack2_loop

    pop     {r4-r6}
    bx      lr

    .section .iwram.__agbabi_m4col_unpack2, "ax", %progbits
    .global __agbabi_m4col_unpack2
    .type __agbabi_m4col_unpack2, %function
__agbabi_m4col_unpack2:
    @ r0 = destination, r1 = vram, r2 = number of rows (multiple of 4, non-zero)
    push    {r4-r6}

    @ Mask r12 = {0x00ff00ff}
    mov     r12, #0xff
    orr     r12, r12, r12, lsl #16

.Lunpack2_loop:
    @ read 4 pixels of column 0, 1
    ldrh    r3, [r1], #240
    ldrh    r4, [r1], #240
    ldrh    r5, [r1], #240
    ldrh    r6, [r1], #240
    @ r3-r6 = {____4400, ____5511, ____6622, ____7733}

    orr     r3, r3, r5, lsl #16 @r3 = {66224400}
    orr     r4, r4, r6, lsl #16 @r4 = {77335511}

    and     r5, r3, r12  @ r5 = {__22__00}
    and     r6, r4, r12  @ r6 = {__33__11}

    bic     r3, r12  @ r3 = {66__44__}
    bic     r4, r12  @ r4 = {77__55__}

    orr     r4, r4, r3, lsr #8  @ r4 = {77665544}
    orr     r3, r5, r6, lsl #8  @ r3 = {33221100}

    str     r4, [r0, #160]
    str     r3, [r0], #4

    subs    r2, #4
    bgt     .Lunpack2_loop

    pop     {r4-r6}
    bx      lr

    .section .iwram.__agbabi_m4col_pack4, "ax", %progbits
    .global __agbabi_m4col_pack4
    .type __agbabi_m4col_pack4, %function
__agbabi_m4col_pack4:
    @ r0 = vram, r1 = source, r2 = number of rows (multiple of 4, non-zero)
    push    {r4-r7}

.Lpack4_loop:
    @ read 4 pixels of column 0, 1, 2, 3
    ldr     r7, [r1, #480]
    ldr     r6, [r1, #320]
    ldr     r5, [r1, #160]
    ldr     r4, [r1], #4
    @ r4-r7 = {33221100, 77665544, bbaa9988, ffeeddcc}

    @ row 0
    and     r3, r4, #0xff           @ r3 = {______00}
    and     r12, r5, #0xff
    orr     r3, r3, r12, lsl #8     @ r3 = {____4400}
    and     r12, r6, #0xff
    orr     r3, r3, r12, lsl #16    @ r3 = {__884400}
    orr     r3, r3, r7, lsl #24     @ r3 = {cc884400}
    @ r3 = {cc884400}
    str     r3, [r0], #240

    @ row 1
    and     r3, r5, #0xff00         @ r3 = {____55__}
    and     r12, r4, #0xff00
    orr     r3, r3, r12, lsr #8     @ r3 = {____5511}
    and     r12, r6, #0xff00
    orr     r3, r3, r12, lsl #8     @ r3 = {__995511}
    and     r12, r7, #0xff00
    orr     r3, r3, r12, lsl #16    @ r3 = {dd995511}
    @ r3 = {dd995511}
    str     r3, [r0], #240

    @ row 2
    and     r3, r6, #0xff0000       @ r3 = {__aa____}
    and     r12, r4, #0xff0000
    orr     r3, r3, r12, lsr #16    @ r3 = {__aa__22}
    and     r12, r5, #0xff0000
    orr     r3, r3, r12, lsr #8     @ r3 = {__aaa6622}
    and     r12, r7, #0xff0000
    orr     r3, r3, r12, lsl #8     @ r3 = {eeaa6622}
    @ r3 = {eeaa6622}
    str     r3, [r0], #240

    @ row 3
    and     r3, r7, #0xff000000     @ r3 = {ff______}
    orr     r3, r3, r4, lsr #24     @ r3 = {ff____33}
    and     r12, r5, #0xff000000
    orr     r3, r3, r12, lsr #16    @ r3 = {ff__7733}
    and     r12, r6, #0xff000000
    orr     r3, r3, r12, lsr #8     @ r3 = {ffbb7733}
    @ r3 = {ffbb7733}
    str     r3, [r0], #240

    subs    r2, #4
    bgt     .Lpack4_loop

    pop     {r4-r7}
    bx      lr

    .section .iwram.__agbabi_m4col_unpack4, "ax", %progbits
    .global __agbabi_m4col_unpack4
    .type __agbabi_m4col_unpack4, %function
__agbabi_m4col_unpack4:
    @ r0 = destination, r1 = vram, r2 = number of rows (multiple of 4, non-zero)
    push    {r4-r7}

.Lunpack4_loop:
    @ read 4 pixels of column 0, 1, 2, 3
    ldr     r4, [r1], #240
    ldr     r5, [r1], #240
    ldr     r6, [r1], #240
    ldr     r7, [r1], #240
    @ r4-r7 = {cc884400, dd995511, eeaa6622, ffbb7733}

    @ column 3
    and     r3, r7, #0xff000000     @ r3 = {ff______}
    and     r12, r6, #0xff000000
    orr     r3, r3, r12, lsr #8     @ r3 = {ffee____}
    and     r12, r5, #0xff000000
    orr     r3, r3, r12, lsr #16    @ r3 = {ffeedd__}
    orr     r3, r3, r4, lsr #24     @ r3 = {ffeeddcc}
    @ r3 = {ffeeddcc}
    str     r3, [r0, #480]

    @ column 2
    and     r3, r6, #0xff0000       @ r3 = {__aa____}
    and     r12, r7, #0xff0000
    orr     r3, r3, r12, lsl #8     @ r3 = {bbaa____}
    and     r12, r5, #0xff0000
    orr     r3, r3, r12, lsr #8     @ r3 = {bbaa99__}
    and     r12, r4, #0xff0000
    orr     r3, r3, r12, lsr #16    @ r3 = {bbaa9988}
    @ r3 = {bbaa9988}
    str     r3, [r0, #320]

    @ column 1
    and     r3, r5, #0xff00         @ r3 = {____55__}
    and     r12, r7, #0xff00
    orr     r3, r3, r12, lsl #16    @ r3 = {77__55__}
    and     r12, r6, #0xff00
    orr     r3, r3, r12, lsl #8     @ r3 = {776655__}
    and     r12, r4, #0xff00
    orr     r3, r3, r12, lsr #8     @ r3 = {77665544}
    @ r3 = {77665544}
    str     r3, [r0, #160]

    @ column 0
    and     r3, r4, #0xff           @ r3 = {______00}
    orr     r3, r3, r7, lsl #24     @ r3 = {33____00}
    and     r12, r6, #0xff
    orr     r3, r3, r12, lsl #16    @ r3 = {3322__00}
    and     r12, r5, #0xff
    orr     r3, r3, r12, lsl #8     @ r3 = {33221100}
    @ r3 = {33221100}
    str     r3, [r0], #4

    subs    r2, #4
    bgt     .Lunpack4_loop

    pop     {r4-r7}
    bx      lr
