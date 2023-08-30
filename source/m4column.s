@===============================================================================
@
@ Support:
@    __agbabi_m4col_pack4, __agbabi_m4col_unpack4
@
@ Copyright (C) 2021-2023 agbabi contributors
@ For conditions of distribution and use, see copyright notice in LICENSE.md
@
@===============================================================================

.syntax unified

    .arm
    .align 2

    .section .iwram.__agbabi_m4col_pack4, "ax", %progbits
    .global __agbabi_m4col_pack4
    .type __agbabi_m4col_pack4, %function
__agbabi_m4col_pack4:
    @ r0 = vram, r1 = source, r2 = number of rows (multiple of 4, non-zero)
    push    {r4-r7}

.Lpack_4_rows:
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
    bgt     .Lpack_4_rows

    pop     {r4-r7}
    bx      lr

    .section .iwram.__agbabi_m4col_unpack4, "ax", %progbits
    .global __agbabi_m4col_unpack4
    .type __agbabi_m4col_unpack4, %function
__agbabi_m4col_unpack4:
    @ r0 = destination, r1 = vram, r2 = number of rows (multiple of 4, non-zero)
    push    {r4-r7}

.Lunpack_4_rows:
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
    bgt     .Lunpack_4_rows

    pop     {r4-r7}
    bx      lr
