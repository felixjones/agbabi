/*
===============================================================================

 Support:
    __agbabi_rtc_write8 __agbabi_rtc_reset, __agbabi_rtc_status,
    __agbabi_rtc_time, __agbabi_rtc_ldatetime, __agbabi_rtc_datetime,
    __agbabi_rtc_settime, __agbabi_rtc_setldatetime, __agbabi_rtc_setdatetime

 Copyright (C) 2021-2022 agbabi contributors
 For conditions of distribution and use, see copyright notice in LICENSE.md

===============================================================================
*/

#define CMD_RESET          0x06
#define CMD_STATUS_WRITE   0x46
#define CMD_DATETIME_WRITE 0x26
#define CMD_TIME_WRITE     0x66

#define CMD_STATUS_READ   0xc6
#define CMD_DATETIME_READ 0xa6
#define CMD_TIME_READ     0xe6

    .align 2

    .section .text.__agbabi_rtc_write8, "ax", %progbits
    .thumb_func
    .global __agbabi_rtc_write8
__agbabi_rtc_write8:
    ldr     r3, .Lwrite8_GPIO_PORT_DATA
    lsl     r0, #1

    .set i, 0
    .rept 8
        mov     r2, #2
        and     r2, r0
        add     r1, r2, #4
        add     r2, r1, #1
        strh    r1, [r3]
        strh    r1, [r3]
        strh    r1, [r3]
        strh    r2, [r3]

        .set i, i + 1
        .if i < 8
            lsr     r0, #1
        .endif
    .endr

    bx      lr
    .align 2
.Lwrite8_GPIO_PORT_DATA:
    .long   0x80000c4

    .section .text.__agbabi_rtc_reset, "ax", %progbits
    .thumb_func
    .global __agbabi_rtc_reset
__agbabi_rtc_reset:
    push    {lr}

    ldr     r3, .Lreset_GPIO_PORT_DATA
    ldr     r2, .Lreset_GPIO_PORT_DIRECTION
    mov     r0, #1
    add     r1, r0, #4
    strh    r0, [r3]
    strh    r1, [r3]
    add     r1, r1, #2
    strh    r1, [r2]

    push    {r2, r3}
    mov     r0, #(CMD_RESET)
    bl      __agbabi_rtc_write8
    pop     {r2, r3}

    mov     r0, #1
    add     r1, r0, #4
    strh    r0, [r3]
    strh    r0, [r3]
    strh    r0, [r3]
    strh    r1, [r3]
    add     r1, r1, #2
    strh    r1, [r2]

    push    {r3}
    mov     r0, #(CMD_STATUS_WRITE)
    bl      __agbabi_rtc_write8
    mov     r0, #0x40
    bl      __agbabi_rtc_write8
    pop     {r3}

    mov     r0, #1
    strh    r0, [r3]
    strh    r0, [r3]

    pop     {r0}
    bx      r0
    .align 2
.Lreset_GPIO_PORT_DATA:
    .long   0x80000c4
.Lreset_GPIO_PORT_DIRECTION:
    .long   0x80000c6

    .section .text.__agbabi_rtc_status, "ax", %progbits
    .thumb_func
    .global __agbabi_rtc_status
__agbabi_rtc_status:
    push    {lr}

    ldr     r3, .Lstatus_GPIO_PORT_DATA
    ldr     r2, .Lstatus_GPIO_PORT_DIRECTION
    mov     r0, #1
    add     r1, r0, #4
    strh    r0, [r3]
    strh    r1, [r3]
    add     r1, r1, #2
    strh    r1, [r2]

    push    {r2, r3}
    mov     r0, #(CMD_STATUS_READ)
    bl      __agbabi_rtc_write8
    pop     {r2, r3}

    mov     r1, #5
    strh    r1, [r2]

    // read8
    mov     r2, #4
    mov     r0, #0

    .set i, 0
    .rept 8
        strh    r2, [r3]
        strh    r2, [r3]
        strh    r2, [r3]
        strh    r2, [r3]
        strh    r2, [r3]
        add     r2, r2, #1
        strh    r2, [r3]

        ldrh    r1, [r3]
        lsl     r1, #30
        orr     r0, r1

        .set i, i + 1
        .if i < 8
            sub     r2, r2, #1
            lsr     r0, #1
        .endif
    .endr

    lsr     r0, #24

    mov     r1, #1
    strh    r1, [r3]
    strh    r1, [r3]

    pop     {r1}
    bx      r1
    .align 2
.Lstatus_GPIO_PORT_DATA:
    .long   0x80000c4
.Lstatus_GPIO_PORT_DIRECTION:
    .long   0x80000c6

    .section .text.__agbabi_rtc_time, "ax", %progbits
    .thumb_func
    .global __agbabi_rtc_time
__agbabi_rtc_time:
    push    {lr}

    ldr     r3, .Ltime_GPIO_PORT_DATA
    ldr     r2, .Ltime_GPIO_PORT_DIRECTION
    mov     r0, #1
    add     r1, r0, #4
    strh    r0, [r3]
    strh    r1, [r3]
    add     r1, r1, #2
    strh    r1, [r2]

    push    {r2, r3}
    mov     r0, #(CMD_TIME_READ)
    bl      __agbabi_rtc_write8
    pop     {r2, r3}

    mov     r1, #5
    strh    r1, [r2]

    // read24
    mov     r2, #4
    mov     r0, #0

    .set i, 0
    .rept 23
        strh    r2, [r3]
        strh    r2, [r3]
        strh    r2, [r3]
        strh    r2, [r3]
        strh    r2, [r3]
        add     r2, r2, #1
        strh    r2, [r3]

        ldrh    r1, [r3]
        lsl     r1, #30
        orr     r0, r1

        .set i, i + 1
        .if i < 23
            sub     r2, r2, #1
            lsr     r0, #1
        .endif
    .endr

    lsr     r0, #9

    mov     r1, #1
    strh    r1, [r3]
    strh    r1, [r3]

    lsl     r1, #23
    bic     r0, r1

    pop     {r1}
    bx      r1
    .align 2
.Ltime_GPIO_PORT_DATA:
    .long   0x80000c4
.Ltime_GPIO_PORT_DIRECTION:
    .long   0x80000c6

    .section .text.__agbabi_rtc_datetime, "ax", %progbits
    .thumb_func
    .global __agbabi_rtc_ldatetime
__agbabi_rtc_ldatetime:
    .global __agbabi_rtc_datetime
__agbabi_rtc_datetime:
    push    {lr}

    ldr     r3, .Ldatetime_GPIO_PORT_DATA
    ldr     r2, .Ldatetime_GPIO_PORT_DIRECTION
    b       .Ldatetime_after_GPIO

    .align 2
.Ldatetime_GPIO_PORT_DATA:
    .long   0x80000c4
.Ldatetime_GPIO_PORT_DIRECTION:
    .long   0x80000c6
    .align 2
.Ldatetime_after_GPIO:

    mov     r0, #1
    add     r1, r0, #4
    strh    r0, [r3]
    strh    r1, [r3]
    add     r1, r1, #2
    strh    r1, [r2]

    push    {r2, r3}
    mov     r0, #(CMD_DATETIME_READ)
    bl      __agbabi_rtc_write8
    pop     {r2, r3}

    mov     r1, #5
    strh    r1, [r2]

    // read32
    mov     r2, #4
    mov     r0, #0

    .set i, 0
    .rept 32
        strh    r2, [r3]
        strh    r2, [r3]
        strh    r2, [r3]
        strh    r2, [r3]
        strh    r2, [r3]
        add     r2, r2, #1
        strh    r2, [r3]

        .set i, i + 1
        .if i < 28
            ldrh    r1, [r3]
            lsl     r1, #30
            orr     r0, r1

            lsr     r0, #1
        .endif

        .if i < 32
            sub     r2, r2, #1
        .endif
    .endr

    lsr     r0, #4
    push    {r0}

    // read24
    mov     r2, #4
    mov     r0, #0

    .set i, 0
    .rept 23
        strh    r2, [r3]
        strh    r2, [r3]
        strh    r2, [r3]
        strh    r2, [r3]
        strh    r2, [r3]
        add     r2, r2, #1
        strh    r2, [r3]

        ldrh    r1, [r3]
        lsl     r1, #30
        orr     r0, r1

        .set i, i + 1
        .if i < 23
            sub     r2, r2, #1
            lsr     r0, #1
        .endif
    .endr

    lsr     r0, #9

    mov     r1, #1
    strh    r1, [r3]
    strh    r1, [r3]

    lsl     r1, #23
    bic     r0, r1

    pop     {r1, r2}
    bx      r2

    .section .text.__agbabi_rtc_settime, "ax", %progbits
    .thumb_func
    .global __agbabi_rtc_settime
__agbabi_rtc_settime:
    push    {r0, lr}

    ldr     r3, .Lsettime_GPIO_PORT_DATA
    ldr     r2, .Lsettime_GPIO_PORT_DIRECTION
    mov     r0, #1
    add     r1, r0, #4
    strh    r0, [r3]
    strh    r1, [r3]
    add     r1, r1, #2
    strh    r1, [r2]

    push    {r2, r3}
    mov     r0, #(CMD_TIME_WRITE)
    bl      __agbabi_rtc_write8
    pop     {r2, r3}

    pop     {r0}
    lsl     r0, #1

    .set i, 0
    .rept 23
        mov     r2, #2
        and     r2, r0
        add     r1, r2, #4
        add     r2, r1, #1
        strh    r1, [r3]
        strh    r1, [r3]
        strh    r1, [r3]
        strh    r2, [r3]

        .set i, i + 1
        .if i < 23
            lsr     r0, #1
        .endif
    .endr

    mov     r1, #1
    strh    r1, [r3]
    strh    r1, [r3]

    pop     {r1}
    bx      r1
    .align 2
.Lsettime_GPIO_PORT_DATA:
    .long   0x80000c4
.Lsettime_GPIO_PORT_DIRECTION:
    .long   0x80000c6

    .section .text.__agbabi_rtc_setdatetime, "ax", %progbits
    .thumb_func
    .global __agbabi_rtc_setldatetime
__agbabi_rtc_setldatetime:
    .global __agbabi_rtc_setdatetime
__agbabi_rtc_setdatetime:
    push    {r0, r1, lr}

    ldr     r3, .Lsetdatetime_GPIO_PORT_DATA
    ldr     r2, .Lsetdatetime_GPIO_PORT_DIRECTION
    b       .Lsetdatetime_after_GPIO

    .align 2
.Lsetdatetime_GPIO_PORT_DATA:
    .long   0x80000c4
.Lsetdatetime_GPIO_PORT_DIRECTION:
    .long   0x80000c6
    .align 2
.Lsetdatetime_after_GPIO:

    mov     r0, #1
    add     r1, r0, #4
    strh    r0, [r3]
    strh    r1, [r3]
    add     r1, r1, #2
    strh    r1, [r2]

    push    {r2, r3}
    mov     r0, #(CMD_DATETIME_WRITE)
    bl      __agbabi_rtc_write8
    pop     {r2, r3}

    pop     {r0}
    lsl     r0, #1

    // Set 24 bits of time (repeat the 25th bit 8 times for 32-bit alignment)
    .set i, 0
    .rept 32
        .if i < 24
            mov     r2, #2
            and     r2, r0
            add     r1, r2, #4
            add     r2, r1, #1
        .elseif i == 24
            mov     r1, #6
            mov     r2, #7
        .endif
        strh    r1, [r3]
        strh    r1, [r3]
        strh    r1, [r3]
        strh    r2, [r3]

        .set i, i + 1
        .if i < 23
            lsr     r0, #1
        .endif
    .endr

    pop     {r0}
    lsl     r0, #1

    // Set 27 bits of date (24-bits for date, plus day of week consumes 3 bits)
    .set i, 0
    .rept 27
        mov     r2, #2
        and     r2, r0
        add     r1, r2, #4
        add     r2, r1, #1
        strh    r1, [r3]
        strh    r1, [r3]
        strh    r1, [r3]
        strh    r2, [r3]

        .set i, i + 1
        .if i < 27
            lsr     r0, #1
        .endif
    .endr

    mov     r1, #1
    strh    r1, [r3]
    strh    r1, [r3]

    pop     {r1}
    bx      r1
