/*
===============================================================================

 POSIX:
    _gettimeofday, settimeofday

 Support:
    __agbabi_rtc_init

 Copyright (C) 2021-2022 agbabi contributors
 For conditions of distribution and use, see copyright notice in LICENSE.md

===============================================================================
*/

#include <agbabi.h>

typedef unsigned short u16;
typedef volatile u16 vu16;

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
    int status = __agbabi_rtc_status();
    if ((status & agbagbi_rtc_POWER) || (status & agbagbi_rtc_24HOUR) == 0) {
        __agbabi_rtc_reset();
    }

    const int time = __agbabi_rtc_time();
    if (time & agbagbi_rtc_TEST) {
        __agbabi_rtc_reset(); // Reset to leave test mode
    }

    status = __agbabi_rtc_status();

    if (__builtin_expect(status & agbagbi_rtc_POWER, 0)) {
        return agbabi_rtc_EPOWER;
    }

    if (!__builtin_expect(status & agbagbi_rtc_24HOUR, agbagbi_rtc_24HOUR)) {
        return agbabi_rtc_E12HOUR;
    }

    const long long datetime = __agbabi_rtc_ldatetime();

    if (__builtin_expect(TM_YEAR(datetime) > 0x9f || TM_YEAR_UNIT(datetime) > 9, 1)) {
        return agbabi_rtc_EYEAR;
    }

    if (__builtin_expect(TM_MONTH(datetime) == 0 || TM_MONTH(datetime) > 0x1f || TM_MONTH_UNIT(datetime) > 9, 1)) {
        return agbabi_rtc_EMON;
    }

    if (__builtin_expect(TM_DAY(datetime) == 0 || TM_DAY(datetime) > 0x3f || TM_DAY_UNIT(datetime) > 9, 1)) {
        return agbabi_rtc_EDAY;
    }

    if (__builtin_expect((TM_WDAY(datetime) & 0xf8) || TM_WDAY_UNIT(datetime) > 6, 1)) {
        return agbabi_rtc_EWDAY;
    }

    if (__builtin_expect(TM_HOUR(datetime) > 0x2f || TM_HOUR_UNIT(datetime) > 9, 1)) {
        return agbabi_rtc_EHOUR;
    }

    if (__builtin_expect(TM_MIN(datetime) > 0x5f || TM_MIN_UNIT(datetime) > 9, 1)) {
        return agbabi_rtc_EMIN;
    }

    if (__builtin_expect(TM_SEC(datetime) > 0x5f || TM_SEC_UNIT(datetime) > 9, 1)) {
        return agbabi_rtc_ESEC;
    }

    return agbabi_rtc_OK;
}

#ifndef NO_POSIX

#include <sys/time.h>

#define BCD_DECODE(X) (((X) & 0xfu) + (((X) >> 4u) * 10u))
#define BCD_ENCODE(X) (((X) % 10) + (((X) / 10) << 4))

#define MAKE_YEAR(X)  (((long long) (X)) << 32)
#define MAKE_MONTH(X) (((long long) (X)) << 40)
#define MAKE_DAY(X)   (((long long) (X)) << 48)
#define MAKE_WDAY(X)  (((long long) (X)) << 56)
#define MAKE_HOUR(X)  (((long long) (X)) << 0)
#define MAKE_MIN(X)   (((long long) (X)) << 8)
#define MAKE_SEC(X)   (((long long) (X)) << 16)

#define REG_IME ((vu16*) 0x4000208)

int _gettimeofday(struct timeval* __restrict__ tv, __attribute__((unused)) struct timezone* tz) {
    const int ime = *REG_IME;
    *REG_IME = 0;
    const long long datetime = __agbabi_rtc_ldatetime();
    *REG_IME = ime;

    struct tm time;
    time.tm_year = BCD_DECODE(TM_YEAR(datetime)) + (2000 - 1900);
    time.tm_mon = BCD_DECODE(TM_MONTH(datetime)) - 1;
    time.tm_mday = BCD_DECODE(TM_DAY(datetime));

    time.tm_hour = BCD_DECODE(TM_HOUR(datetime));
    time.tm_min = BCD_DECODE(TM_MIN(datetime));
    time.tm_sec = BCD_DECODE(TM_SEC(datetime));

    time.tm_wday = BCD_DECODE(TM_WDAY(datetime));
    time.tm_yday = 0;
    time.tm_isdst = 0;

    tv->tv_usec = 0;
    tv->tv_sec = mktime(&time);
    return 0;
}

#if defined(__DEVKITARM__)
int _gettimeofday_r(__attribute__((unused)) void* __restrict__ reent, struct timeval* __restrict__ tv, __attribute__((unused)) struct timezone* tz) {
    return _gettimeofday(tv, tz);
}
#endif

int settimeofday(const struct timeval* __restrict__ tv, __attribute__((unused)) const struct timezone* __restrict__ tz) {
    const struct tm* tmptr = gmtime(&tv->tv_sec);

    const int year = BCD_ENCODE(tmptr->tm_year - (2000 - 1900));
    const int mon = BCD_ENCODE(tmptr->tm_mon) + 1;
    const int mday = BCD_ENCODE(tmptr->tm_mday);

    const int wday = BCD_ENCODE(tmptr->tm_wday);

    const int hour = BCD_ENCODE(tmptr->tm_hour);
    const int min = BCD_ENCODE(tmptr->tm_min);
    const int sec = BCD_ENCODE(tmptr->tm_sec);

    const long long datetime = MAKE_YEAR(year) | MAKE_MONTH(mon) | MAKE_DAY(mday) |
            MAKE_WDAY(wday) | MAKE_HOUR(hour) | MAKE_MIN(min) | MAKE_SEC(sec);

    const int ime = *REG_IME;
    *REG_IME = 0;
    __agbabi_rtc_setldatetime(datetime);
    *REG_IME = ime;

    return 0;
}

#endif
