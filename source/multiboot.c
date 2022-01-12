/*
===============================================================================

 Support:
    __agbabi_multiboot

 Copyright (C) 2021-2022 agbabi contributors
 For conditions of distribution and use, see copyright notice in LICENSE.md

===============================================================================
*/

#include <agbabi.h>

typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef volatile u16 vu16;

#define REG_SIOMULTI0   ((vu16*) 0x4000120)
#define REG_SIOMULTI1   ((vu16*) 0x4000122)
#define REG_SIOMULTI2   ((vu16*) 0x4000124)
#define REG_SIOMULTI3   ((vu16*) 0x4000126)
#define REG_SIOCNT      ((vu16*) 0x4000128)
#define REG_SIOMLT_SEND ((vu16*) 0x400012A)
#define REG_RCNT        ((vu16*) 0x4000134)

#define CLOCK_INTERNAL  (1)
#define MHZ_2           (2)
#define OPPONENT_SO_HI  (4)
#define SIO_START       (128)
#define MULTIPLAY_MODE  (8192)

#define MB_MODE_MULTI   (1)

#define MB_CLIENT1  (2)
#define MB_CLIENT2  (4)
#define MB_CLIENT3  (8)

typedef struct MultiBootParam {
    u32 reserved1[5];
    u8 handshake_data;
    u8 padding;
    u16 handshake_timeout;
    u8 probe_count;
    u8 client_data[3];
    u8 palette_data;
    u8 response_bit;
    u8 client_bit;
    u8 reserved2;
    const void* boot_srcp;
    const void* boot_endp;
    const void* masterp;
    const void* reserved3[3];
    u32 system_work2[4];
    u8 sendflag;
    u8 probe_target_bit;
    u8 check_wait;
    u8 server_type;
} MultiBootParam;

static void __agbabi_mb_send(int data, int* response);
static int MultiBoot(MultiBootParam* mb, u32 mode) __attribute__((naked));

int __agbabi_multiboot(const agbabi_mb_param_t* param) {
    *REG_RCNT = 0;
    *REG_SIOCNT = CLOCK_INTERNAL | MHZ_2 | MULTIPLAY_MODE;

    if (*REG_SIOCNT & OPPONENT_SO_HI) {
        return agbabi_mb_NOT_HOST;
    }

    int response[4];
    int clientMask = 0;

    for (int attempts = 0; attempts < 16; ++attempts) {
        for (int sends = 0; sends < 16; ++sends) {
            __agbabi_mb_send(0x6200, response);

            if ((response[1] & 0xfff0) == 0x7200) clientMask |= (response[1] & 0xf);
            if ((response[2] & 0xfff0) == 0x7200) clientMask |= (response[2] & 0xf);
            if ((response[3] & 0xfff0) == 0x7200) clientMask |= (response[3] & 0xf);
        }

        if (clientMask) {
            break;
        } else if (param->callback(agbabi_mb_WAIT, attempts, param->uptr)) {
            return agbabi_mb_CANCELLED;
        }
    }

    if (!clientMask) {
        return agbabi_mb_TIMEOUT;
    }

    if (param->callback(agbabi_mb_CONNECTED, clientMask, param->uptr)) {
        return agbabi_mb_CANCELLED;
    }

    clientMask &= param->client_mask;

    __agbabi_mb_send(0x6100 | clientMask, response);
    int clientErrors = 0;
    if ((clientMask & MB_CLIENT1) && response[1] != (0x7200 | MB_CLIENT1)) clientErrors |= (agbabi_mb_FAIL_ACK | 0x10000);
    if ((clientMask & MB_CLIENT2) && response[2] != (0x7200 | MB_CLIENT2)) clientErrors |= (agbabi_mb_FAIL_ACK | 0x20000);
    if ((clientMask & MB_CLIENT3) && response[3] != (0x7200 | MB_CLIENT3)) clientErrors |= (agbabi_mb_FAIL_ACK | 0x40000);
    if (clientErrors) return clientErrors;

    const u16* rom16 = (const u16*) param->srcp;
    for (int halves = 0; halves < 0x60; ++halves) {
        __agbabi_mb_send(*rom16++, response);
        clientErrors = 0;
        if ((clientMask & MB_CLIENT1) && response[1] != ((0x60 - halves) << 8 | MB_CLIENT1)) clientErrors |= (agbabi_mb_FAIL_HEADER | 0x10000);
        if ((clientMask & MB_CLIENT2) && response[2] != ((0x60 - halves) << 8 | MB_CLIENT2)) clientErrors |= (agbabi_mb_FAIL_HEADER | 0x20000);
        if ((clientMask & MB_CLIENT3) && response[3] != ((0x60 - halves) << 8 | MB_CLIENT3)) clientErrors |= (agbabi_mb_FAIL_HEADER | 0x40000);
        if (clientErrors) return clientErrors;

        if (param->callback(agbabi_mb_HEADER, halves, param->uptr)) {
            return agbabi_mb_CANCELLED;
        }
    }

    __agbabi_mb_send(0x6200, response);
    clientErrors = 0;
    if ((clientMask & MB_CLIENT1) && response[1] != MB_CLIENT1) clientErrors |= (agbabi_mb_FAIL_ACK | 0x10000);
    if ((clientMask & MB_CLIENT2) && response[2] != MB_CLIENT2) clientErrors |= (agbabi_mb_FAIL_ACK | 0x20000);
    if ((clientMask & MB_CLIENT3) && response[3] != MB_CLIENT3) clientErrors |= (agbabi_mb_FAIL_ACK | 0x40000);
    if (clientErrors) return clientErrors;

    __agbabi_mb_send(0x6200 | clientMask, response);
    clientErrors = 0;
    if ((clientMask & MB_CLIENT1) && response[1] != (0x7200 | MB_CLIENT1)) clientErrors |= (agbabi_mb_FAIL_PALETTE | 0x10000);
    if ((clientMask & MB_CLIENT2) && response[2] != (0x7200 | MB_CLIENT2)) clientErrors |= (agbabi_mb_FAIL_PALETTE | 0x20000);
    if ((clientMask & MB_CLIENT3) && response[3] != (0x7200 | MB_CLIENT3)) clientErrors |= (agbabi_mb_FAIL_PALETTE | 0x40000);
    if (clientErrors) return clientErrors;

    int sendMask = clientMask;
    u8 data[4] = { 0x11, 0xff, 0xff, 0xff };
    const int paletteCmd = 0x6300 | param->palette;
    while (sendMask) {
        __agbabi_mb_send(paletteCmd, response);

        if ((clientMask & MB_CLIENT1) && (response[1] & 0xff00) == 0x7300) {
            data[1] = response[1];
            sendMask &= ~MB_CLIENT1;
        }

        if ((clientMask & MB_CLIENT2) && (response[2] & 0xff00) == 0x7300) {
            data[2] = response[2];
            sendMask &= ~MB_CLIENT2;
        }

        if ((clientMask & MB_CLIENT3) && (response[3] & 0xff00) == 0x7300) {
            data[3] = response[3];
            sendMask &= ~MB_CLIENT3;
        }

        if (param->callback(agbabi_mb_PALETTE, sendMask, param->uptr)) {
            return agbabi_mb_CANCELLED;
        }
    }

    data[0] += data[1] + data[2] + data[3];
    __agbabi_mb_send(0x6400 | data[0], response);
    clientErrors = 0;
    if ((clientMask & MB_CLIENT1) && (response[1] & 0xff00) != 0x7300) clientErrors |= (agbabi_mb_FAIL_ACK | 0x10000);
    if ((clientMask & MB_CLIENT2) && (response[2] & 0xff00) != 0x7300) clientErrors |= (agbabi_mb_FAIL_ACK | 0x20000);
    if ((clientMask & MB_CLIENT3) && (response[3] & 0xff00) != 0x7300) clientErrors |= (agbabi_mb_FAIL_ACK | 0x40000);
    if (clientErrors) return clientErrors;

    if (param->callback(agbabi_mb_MULTIBOOT, 0, param->uptr)) {
        return agbabi_mb_CANCELLED;
    }

    MultiBootParam mbp = (MultiBootParam){0};

    mbp.handshake_data = data[0];
    mbp.client_data[0] = data[1];
    mbp.client_data[1] = data[2];
    mbp.client_data[2] = data[3];
    mbp.palette_data = param->palette;
    mbp.client_bit = clientMask;
    mbp.boot_srcp = (const void*) rom16;
    mbp.boot_endp = (const void*) ((ptrdiff_t)param->srcp + param->srclen);

    if (MultiBoot(&mbp, MB_MODE_MULTI) ) {
        return agbabi_mb_FAIL_MULTIBOOT;
    }

    return agbabi_mb_SUCCESS;
}

static void __agbabi_mb_send(int data, int* response) {
    *REG_SIOMLT_SEND = data;
    *REG_SIOCNT |= SIO_START;

    while (*REG_SIOCNT & SIO_START) {}

    response[0] = *REG_SIOMULTI0;
    response[1] = *REG_SIOMULTI1;
    response[2] = *REG_SIOMULTI2;
    response[3] = *REG_SIOMULTI3;
}

static int MultiBoot(MultiBootParam* mb, u32 mode) {
#ifndef __thumb__
    __asm__(
        "swi\t#0x250000\n\t"
        "bx\tlr"
    );
#else
    __asm__(
        "swi\t#0x25\n\t"
        "bx\tlr"
    );
#endif
}
