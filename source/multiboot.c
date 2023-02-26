/*
===============================================================================

 Support:
    __agbabi_multiboot

 Copyright (C) 2021-2023 agbabi contributors
 For conditions of distribution and use, see copyright notice in LICENSE.md

===============================================================================
*/

#include <agbabi.h>
#include <errno.h>

#undef errno
extern int errno;

typedef unsigned char u8;
typedef unsigned short u16;
typedef volatile u16 vu16;
typedef unsigned int u32;
typedef volatile u32 vu32;

#define REG_SIOCNT      (*(vu16*) 0x4000128)
#define REG_RCNT        (*(vu16*) 0x4000134)

#define ADDR_SIOMULTI01  ((vu32*) 0x4000120)
#define ADDR_SIOMULTI23  ((vu32*) 0x4000124)
#define ADDR_SIOMLT_SEND ((vu16*) 0x400012A)

#define CLOCK_INTERNAL  (0x0001)
#define MHZ_2           (0x0002)
#define OPPONENT_SO_HI  (0x0004)
#define SIO_START       (0x0080)
#define MULTIPLAY_MODE  (0x2000)

typedef u16 __attribute__((vector_size(sizeof(u16) * 4))) mb_result_type;

static mb_result_type mb_send(int data);

int __agbabi_multiboot(const __agbabi_multiboot_t* param) {
    REG_RCNT = 0;
    REG_SIOCNT = CLOCK_INTERNAL | MHZ_2 | MULTIPLAY_MODE;

    if (REG_SIOCNT & OPPONENT_SO_HI) {
        errno = EACCES; /* We are no the host */
        return 1;
    }

    int clients = 0;

    for (int attempts = 0; attempts < 16; ++attempts) {
        for (int sends = 0; sends < 16; ++sends) {
            const mb_result_type response = mb_send(0x6200);

            for (int i = 1; i < 4; ++i) {
                if ((response[i] & 0xfff0) == 0x7200) {
                    clients |= response[i];
                }
            }
        }

        if (clients) {
            break;
        }

        __asm__ volatile ("nop");
    }

    clients &= 0x000f;

    if (!clients) {
        errno = ETIMEDOUT;
        return 1;
    }

    if (param->clients_connected && param->clients_connected(clients)) {
        errno = ECANCELED;
        return 1;
    }

    mb_result_type response = mb_send(0x6100 | clients);

    int errors = 0;
    for (int i = 1; i < 4; ++i) {
        const int cbit = 1 << i;

        if ((clients & cbit) && response[i] != (0x7200 | cbit)) {
            errors |= cbit;
        }
    }

    if (errors) {
        errno = EINVAL; /* Received invalid responses */
        return 1;
    }

    const u16* rom16 = (const u16*) param->header;
    for (int halves = 0; halves < 0x60; ++halves) {
        response = mb_send(*rom16++);

        errors = 0;
        for (int i = 1; i < 4; ++i) {
            const int cbit = 1 << i;

            if ((clients & cbit) && response[i] != (((0x60 - halves) << 8) | cbit)) {
                errors |= cbit;
            }
        }

        if (errors) {
            errno = EINVAL; /* Received invalid responses */
            return 1;
        }

        if (param->header_progress && param->header_progress(halves)) {
            errno = ECANCELED;
            return 1;
        }
    }

    response = mb_send(0x6200);

    errors = 0;
    for (int i = 1; i < 4; ++i) {
        const int cbit = 1 << i;

        if ((clients & cbit) && response[i] != cbit) {
            errors |= cbit;
        }
    }

    if (errors) {
        errno = EINVAL; /* Received invalid responses */
        return 1;
    }

    response = mb_send(0x6200 | clients);

    errors = 0;
    for (int i = 1; i < 4; ++i) {
        const int cbit = 1 << i;

        if ((clients & cbit) && response[i] != (0x7200 | cbit)) {
            errors |= cbit;
        }
    }

    if (errors) {
        errno = EINVAL; /* Received invalid responses */
        return 1;
    }

    int sendMask = clients;
    u8 data[4] = { 0x11, 0xff, 0xff, 0xff };

    const int paletteCmd = 0x6300 | (param->palette & 0xff);
    while (sendMask) {
        response = mb_send(paletteCmd);

        for (int i = 1; i < 4; ++i) {
            const int cbit = 1 << i;

            if ((clients & cbit) && (response[i] & 0xff00) == 0x7300) {
                data[i] = response[i] & 0xffu;
                sendMask &= ~(1 << i);
            }
        }

        if (param->palette_progress && param->palette_progress(sendMask)) {
            errno = ECANCELED;
            return 1;
        }
    }

    data[0] = (u8) (data[0] + data[1] + data[2] + data[3]);

    response = mb_send(0x6400 | data[0]);
    errors = 0;
    for (int i = 1; i < 4; ++i) {
        const int cbit = 1 << i;

        if ((clients & cbit) && (response[i] & 0xff00) != 0x7300) {
            errors |= cbit;
        }
    }

    if (errors) {
        errno = EINVAL; /* Received invalid responses */
        return 1;
    }

    if (param->accept && param->accept()) {
        errno = ECANCELED;
        return 1;
    }

    typedef struct {
        u32 reserved_0[5];
        u8 handshake_data;
        u8 padding;
        u16 handshake_timeout;
        u8 probe_count;
        u8 client_data[3];
        u8 palette_data;
        u8 response_bit;
        u8 client_bit;
        u8 reserved_1;
        const void* boot_srcp;
        const void* boot_endp;
        const void* masterp;
        const void* reserved_2[3];
        u32 system_work_2[4];
        u8 send_flag;
        u8 probe_target_bit;
        u8 check_wait;
        u8 server_type;
    } MultiBootParam;

    MultiBootParam mbp = (MultiBootParam) {0};

    mbp.handshake_data = data[0];
    mbp.client_data[0] = data[1];
    mbp.client_data[1] = data[2];
    mbp.client_data[2] = data[3];
    mbp.palette_data = (u8) param->palette;
    mbp.client_bit = (u8) clients;
    mbp.boot_srcp = param->begin;
    mbp.boot_endp = param->end;

    /* MultiBoot */
    int res;
    __asm__ volatile (
        "mov     r0, %[mbp]"                    "\n\t"
        "mov     r1, #0"                        "\n\t"
        "swi     0x25 << ((1f - . == 4) * -16)" "\n\t"
        "1:"                                    "\n\t"
        "mov     %[res], r0"
        : [res]"=l"(res)
        : [mbp]"l"(&mbp)
        : "r0", "r1", "r3"
    );

    if (res) {
        errno = ECONNABORTED;
        return 1;
    }

    return 0;
}

mb_result_type mb_send(int data) {
    __asm__ volatile (
        "strh    %[data], [%[SIOMLT_SEND]]"
        ::  [SIOMLT_SEND]"l"(ADDR_SIOMLT_SEND),
            [data]"l"(data)
    );

    REG_SIOCNT |= SIO_START;

    while (REG_SIOCNT & SIO_START) {}

    union {
        u32 reg[2];
        mb_result_type vec;
    } result;

    __asm__ volatile (
        "ldr     %[res0], [%[SIOMULTI01]]"   "\n\t"
        "ldr     %[res1], [%[SIOMULTI23]]"
        :   [res0]"=l"(result.reg[0]),
            [res1]"=l"(result.reg[1])
        :   [SIOMULTI01]"l"(ADDR_SIOMULTI01),
            [SIOMULTI23]"l"(ADDR_SIOMULTI23)
    );

    return result.vec;
}
