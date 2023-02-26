/*
===============================================================================

 POSIX:
    _gettimeofday, settimeofday

 Support:
    __agbabi_rtc_init, __agbabi_rtc_time, __agbabi_rtc_settime,
    __agbabi_rtc_datetime, __agbabi_rtc_setdatetime

 Copyright (C) 2021-2023 agbabi contributors
 For conditions of distribution and use, see copyright notice in LICENSE.md

===============================================================================
*/

#include <agbabi.h>
#include <reent.h>
#include <sys/time.h>

#define RTC_OK      (0x00)
#define RTC_EPOWER  (0x01)
#define RTC_E12HOUR (0x02)
#define RTC_EYEAR   (0x03)
#define RTC_EMON    (0x04)
#define RTC_EDAY    (0x05)
#define RTC_EWDAY   (0x06)
#define RTC_EHOUR   (0x07)
#define RTC_EMIN    (0x08)
#define RTC_ESEC    (0x09)

#define RTC_INTFE   (0x01)
#define RTC_INTME   (0x02)
#define RTC_INTAE   (0x04)
#define RTC_24HOUR  (0x40)
#define RTC_POWER   (0x80)

#define RTC_TEST (0x80)

#define CMD_RESET           (0x06)
#define CMD_DATETIME_WRITE  (0x26)
#define CMD_STATUS_WRITE    (0x46)
#define CMD_TIME_WRITE      (0x66)
#define CMD_DATETIME_READ   (0xa6)
#define CMD_STATUS_READ     (0xc6)
#define CMD_TIME_READ       (0xe6)

typedef unsigned short u16;
typedef volatile u16 vu16;

#define ADDR_IME            ((vu16*) 0x4000208)
#define ADDR_GPIO_PORT_DATA ((vu16*) 0x80000c4)
#define ADDR_GPIO_PORT_DIR  ((vu16*) 0x80000c6)
#define ADDR_GPIO_PORT_CNT  ((vu16*) 0x80000c8)

static unsigned int gpio_read(int n);
static void gpio_write(unsigned int x, int n);

static unsigned int rtc_status(void);
static void rtc_reset(void);

static int bcd_decode(unsigned int x) __attribute__((const));
static unsigned int bcd_encode(int x) __attribute__((const));

#define unlikely(x) __builtin_expect(!!(x), 0)

int __agbabi_rtc_init(void) {
    *ADDR_GPIO_PORT_CNT = 1;
    unsigned int status = rtc_status();

    if (unlikely((status & RTC_POWER) == RTC_POWER || (status & RTC_24HOUR) == 0)) {
        rtc_reset();
    }

    const unsigned int time = __agbabi_rtc_time();

    if (time & RTC_TEST) {
        rtc_reset(); /* Reset to leave test mode */
    }

    status = rtc_status();

    if (unlikely((status & RTC_POWER) == RTC_POWER)) {
        return RTC_EPOWER;
    }

    if (unlikely((status & RTC_24HOUR) == 0)) {
        return RTC_E12HOUR;
    }

    return RTC_OK;
}

unsigned int __agbabi_rtc_time(void) {
    *ADDR_GPIO_PORT_DIR = 0x5;
    *ADDR_GPIO_PORT_DATA = 0x1;
    *ADDR_GPIO_PORT_DATA = 0x5;

    *ADDR_GPIO_PORT_DIR = 0x7;
    gpio_write(CMD_TIME_READ, 8);

    *ADDR_GPIO_PORT_DIR = 0x5;
    unsigned int time = gpio_read(23);
    *ADDR_GPIO_PORT_DATA = 0x1;
    *ADDR_GPIO_PORT_DATA = 0x1;

    return time;
}

void __agbabi_rtc_settime(unsigned int time) {
    *ADDR_GPIO_PORT_DIR = 0x5;
    *ADDR_GPIO_PORT_DATA = 0x1;
    *ADDR_GPIO_PORT_DATA = 0x5;

    *ADDR_GPIO_PORT_DIR = 0x7;
    gpio_write(CMD_TIME_WRITE, 8);

    gpio_write(time, 23);
    *ADDR_GPIO_PORT_DATA = 0x1;
    *ADDR_GPIO_PORT_DATA = 0x1;
}

__agbabi_datetime_t __agbabi_rtc_datetime(void) {
    __agbabi_datetime_t datetime;

    *ADDR_GPIO_PORT_DIR = 0x5;
    *ADDR_GPIO_PORT_DATA = 0x1;
    *ADDR_GPIO_PORT_DATA = 0x5;

    *ADDR_GPIO_PORT_DIR = 0x7;
    gpio_write(CMD_DATETIME_READ, 8);

    *ADDR_GPIO_PORT_DIR = 0x5;
    datetime[0] = gpio_read(32);
    datetime[1] = gpio_read(23);
    *ADDR_GPIO_PORT_DATA = 0x1;
    *ADDR_GPIO_PORT_DATA = 0x1;

    return datetime;
}

void __agbabi_rtc_setdatetime(__agbabi_datetime_t datetime) {
    *ADDR_GPIO_PORT_DIR = 0x5;
    *ADDR_GPIO_PORT_DATA = 0x1;
    *ADDR_GPIO_PORT_DATA = 0x5;

    *ADDR_GPIO_PORT_DIR = 0x7;
    gpio_write(CMD_DATETIME_WRITE, 8);

    gpio_write(datetime[0], 32);
    gpio_write(datetime[1], 23);
    *ADDR_GPIO_PORT_DATA = 0x1;
    *ADDR_GPIO_PORT_DATA = 0x1;
}

unsigned int gpio_read(int n) {
    unsigned int result = 0;

    for (int i = 0; i < n; ++i) {
        __asm__ volatile (
            "lsr     %[res], %[res], #1"            "\n\t"
            "strh    %[b100], [%[GPIO_PORT_DATA]]"  "\n\t"
            "strh    %[b100], [%[GPIO_PORT_DATA]]"  "\n\t"
            "strh    %[b100], [%[GPIO_PORT_DATA]]"  "\n\t"
            "strh    %[b100], [%[GPIO_PORT_DATA]]"  "\n\t"
            "strh    %[b101], [%[GPIO_PORT_DATA]]"  "\n\t"
            "ldrh    r7, [%[GPIO_PORT_DATA]]"       "\n\t"
            "lsl     r7, #30"                       "\n\t"
            "orr     %[res], %[res], r7"
            :   [res]"+l"(result)
            :   [GPIO_PORT_DATA]"l"(ADDR_GPIO_PORT_DATA),
                [b100]"l"(0x4),
                [b101]"l"(0x5)
            :   "r7"
        );
    }

    return result >> (32 - n);
}

void gpio_write(unsigned int x, int n) {
    for (int i = 0; i < n; ++i) {
        const unsigned int bit = (0x1 & x) << 1;

        x >>= 1;

        __asm__ volatile (
            "strh    %[b1x0], [%[GPIO_PORT_DATA]]"  "\n\t"
            "strh    %[b1x0], [%[GPIO_PORT_DATA]]"  "\n\t"
            "strh    %[b1x0], [%[GPIO_PORT_DATA]]"  "\n\t"
            "strh    %[b1x1], [%[GPIO_PORT_DATA]]"
            ::  [GPIO_PORT_DATA]"l"(ADDR_GPIO_PORT_DATA),
                [b1x0]"l"(bit | 0x4),
                [b1x1]"l"(bit | 0x5)
        );
    }
}

unsigned int rtc_status(void) {
    *ADDR_GPIO_PORT_DIR = 0x5;
    *ADDR_GPIO_PORT_DATA = 0x1;
    *ADDR_GPIO_PORT_DATA = 0x5;

    *ADDR_GPIO_PORT_DIR = 0x7;
    gpio_write(CMD_STATUS_READ, 8);

    *ADDR_GPIO_PORT_DIR = 0x5;
    unsigned int status = gpio_read(8);
    *ADDR_GPIO_PORT_DATA = 0x1;
    *ADDR_GPIO_PORT_DATA = 0x1;

    return status;
}

void rtc_reset(void) {
    *ADDR_GPIO_PORT_DIR = 0x5;
    *ADDR_GPIO_PORT_DATA = 0x1;
    *ADDR_GPIO_PORT_DATA = 0x5;

    *ADDR_GPIO_PORT_DIR = 0x7;
    gpio_write(CMD_RESET, 8);

    *ADDR_GPIO_PORT_DATA = 0x1;
    *ADDR_GPIO_PORT_DATA = 0x1;
    *ADDR_GPIO_PORT_DATA = 0x1;
    *ADDR_GPIO_PORT_DATA = 0x5;

    *ADDR_GPIO_PORT_DIR = 0x7;
    gpio_write(CMD_STATUS_WRITE, 8);
    gpio_write(0x40, 8);

    *ADDR_GPIO_PORT_DATA = 0x1;
    *ADDR_GPIO_PORT_DATA = 0x1;
}

int _gettimeofday(struct timeval* __restrict__ tv, __attribute__((unused)) void* __restrict__ tz) {
    __agbabi_datetime_t datetime;

    const u16 ime = *ADDR_IME;

    *ADDR_IME = 0;
    datetime = __agbabi_rtc_datetime();
    *ADDR_IME = ime;

    struct tm time;
    time.tm_year = bcd_decode(datetime[0] & 0xff) + (2000 - 1900);
    time.tm_mon = bcd_decode((datetime[0] >> 8) & 0xff) - 1;
    time.tm_mday = bcd_decode((datetime[0] >> 16) & 0xff);
    time.tm_wday = bcd_decode((datetime[0] >> 24) & 0xff);

    time.tm_hour = bcd_decode(datetime[1] & 0xff);
    time.tm_min = bcd_decode((datetime[1] >> 8) & 0xff);
    time.tm_sec = bcd_decode((datetime[1] >> 16) & 0xff);

    time.tm_yday = 0;
    time.tm_isdst = 0;

    tv->tv_usec = 0;
    tv->tv_sec = mktime(&time);
    return 0;
}

int settimeofday(const struct timeval* tv, __attribute__((unused)) const struct timezone* tz) {
    const struct tm* tmptr = gmtime(&tv->tv_sec);

    const __agbabi_datetime_t datetime = {
        bcd_encode(tmptr->tm_year - (2000 - 1900)) | ((bcd_encode(tmptr->tm_mon) + 1) << 8) | (bcd_encode(tmptr->tm_mday) << 16) | (bcd_encode(tmptr->tm_wday) << 24),
        bcd_encode(tmptr->tm_hour) | (bcd_encode(tmptr->tm_min) << 8) | (bcd_encode(tmptr->tm_sec) << 16)
    };

    const u16 ime = *ADDR_IME;
    *ADDR_IME = 0;
    __agbabi_rtc_setdatetime(datetime);
    *ADDR_IME = ime;

    return 0;
}

int bcd_decode(unsigned int x) {
    return (int) ((x & 0xf) + ((x >> 4) * 10));
}

unsigned int bcd_encode(int x) {
    return ((unsigned int) x % 10u) | (((unsigned int) x / 10u) << 4u);
}

#if defined(__DYNAMIC_REENT__)

int _gettimeofday_r(__attribute__((unused)) struct _reent* __restrict__ reent, struct timeval* __restrict__ tv, void* __restrict__ tz) {
    return _gettimeofday(tv, tz);
}

#endif
