/*
===============================================================================

 POSIX:
    _gettimeofday

 Support:
    __agbabi_rtc_init

 Copyright (C) 2021-2022 agbabi contributors
 For conditions of distribution and use, see copyright notice in LICENSE.md

===============================================================================
*/

#include <agbabi.h>

typedef unsigned short u16;
typedef volatile u16 vu16;

#define GPIO_PORT_READ_ENABLE ((vu16*) 0x80000c8)

#define TM_YEAR(X)       (((X) >> 32) & 0xff)
#define TM_YEAR_UNIT(X)  ((TM_YEAR(X) >> 0) & 0x0f)
#define TM_MONTH(X)      (((X) >> 40) & 0xff)
#define TM_MONTH_UNIT(X) ((TM_MONTH(X) >> 0) & 0x0f)
#define TM_DAY(X)        (((X) >> 48) & 0xff)
#define TM_DAY_UNIT(X)   ((TM_DAY(X) >> 0) & 0x0f)
#define TM_WDAY(X)       (((X) >> 56) & 0xff)
#define TM_WDAY_UNIT(X)  ((TM_WDAY(X) >> 0) & 0x0f)
#define TM_HOUR(X)       (((X) >> 0) & 0xff)
#define TM_HOUR_UNIT(X)  ((TM_HOUR(X) >> 0) & 0x0f)
#define TM_MIN(X)        (((X) >> 8) & 0xff)
#define TM_MIN_UNIT(X)   ((TM_MIN(X) >> 0) & 0x0f)
#define TM_SEC(X)        (((X) >> 16) & 0xff)
#define TM_SEC_UNIT(X)   ((TM_SEC(X) >> 0) & 0x0f)

int __agbabi_rtc_init() {
    *GPIO_PORT_READ_ENABLE = 1;

    int status = __agbabi_rtc_status();
    if ((status & agbagbi_rtc_POWER) || (status & agbagbi_rtc_24HOUR) == 0) {
        __agbabi_rtc_reset();
    }

    const int time = __agbabi_rtc_time();
    if (time & agbagbi_rtc_TEST) {
        __agbabi_rtc_reset(); // Reset to leave test mode
    }

    status = __agbabi_rtc_status();

    int error = 0;
    if (status & agbagbi_rtc_POWER) {
        error = agbabi_rtc_EPOWER;
        goto init_error;
    }

    if ((status & agbagbi_rtc_24HOUR) == 0) {
        error = agbabi_rtc_E12HOUR;
        goto init_error;
    }

    const long long int datetime = __agbabi_rtc_ldatetime();

    if (TM_YEAR(datetime) > 0x9f || TM_YEAR_UNIT(datetime) > 9 ) {
        error = agbabi_rtc_EYEAR;
        goto init_error;
    }

    if (TM_MONTH(datetime) == 0 || TM_MONTH(datetime) > 0x1f || TM_MONTH_UNIT(datetime) > 9) {
        error = agbabi_rtc_EMON;
        goto init_error;
    }

    if (TM_DAY(datetime) == 0 || TM_DAY(datetime) > 0x3f || TM_DAY_UNIT(datetime) > 9) {
        error = agbabi_rtc_EDAY;
        goto init_error;
    }

    if ((TM_WDAY(datetime) & 0xf8) || TM_WDAY_UNIT(datetime) > 6) {
        error = agbabi_rtc_EWDAY;
        goto init_error;
    }

    if (TM_HOUR(datetime) > 0x2f || TM_HOUR_UNIT(datetime) > 9) {
        error = agbabi_rtc_EHOUR;
        goto init_error;
    }

    if (TM_MIN(datetime) > 0x5f || TM_MIN_UNIT(datetime) > 9) {
        error = agbabi_rtc_EMIN;
        goto init_error;
    }

    if (TM_SEC(datetime) > 0x5f || TM_SEC_UNIT(datetime) > 9) {
        error = agbabi_rtc_ESEC;
        goto init_error;
    }

    return 0;

init_error:
    *GPIO_PORT_READ_ENABLE = 0;
    return error;
}

#ifndef NO_POSIX

#include <sys/time.h>

#define bcd_decode(x) (((x) & 0xfu) + (((x) >> 4u) * 10u))
#define REG_IME ((vu16*) 0x4000208)

int _gettimeofday(struct timeval* __restrict__ tv, void* __restrict__ tz) {
    const int ime = *REG_IME;
    *REG_IME = 0;
    const long long int datetime = __agbabi_rtc_ldatetime();
    *REG_IME = ime;

    struct tm time;
    time.tm_year = bcd_decode(TM_YEAR(datetime)) + (2000u - 1900u);
    time.tm_mon = bcd_decode(TM_MONTH(datetime)) - 1;
    time.tm_mday = bcd_decode(TM_DAY(datetime));

    time.tm_hour = bcd_decode(TM_HOUR(datetime));
    time.tm_min = bcd_decode(TM_MIN(datetime));
    time.tm_sec = bcd_decode(TM_SEC(datetime));

    time.tm_wday = bcd_decode(TM_WDAY(datetime));
    time.tm_yday = 0;
    time.tm_isdst = 0;

    tv->tv_usec = 0;
    tv->tv_sec = mktime(&time);
    return 0;
}

#endif
