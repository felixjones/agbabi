/*
===============================================================================

 C header file for agbabi

 Copyright (C) 2021-2022 agbabi contributors
 For conditions of distribution and use, see copyright notice in LICENSE.md

===============================================================================
*/

#ifndef _AGBABI_H_
#define _AGBABI_H_
#ifdef __cplusplus
extern "C" {
#endif

#include <limits.h>
#include <stddef.h>
#include <sys/ucontext.h>

/// Copies n bytes from src to dest (forward)
/// Assumes dest and src are 2-byte aligned
/// \param dest Destination address
/// \param src Source address
/// \param n Number of bytes to copy
void __agbabi_memcpy2(void *__restrict__ dest, const void *__restrict__ src, size_t n);

/// Fills dest with n bytes of c
/// Assumes dest is 4-byte aligned
/// \param dest Destination address
/// \param n Number of bytes to set
/// \param c Value to set
void __agbabi_wordset4(void *dest, size_t n, int c);

/// Copies n bytes from src to dest (backwards)
/// \param dest Destination address
/// \param src Source address
/// \param n Number of bytes to copy
void __agbabi_rmemcpy(void *__restrict__ dest, const void *__restrict__ src, size_t n);

/// Copies n bytes from src to dest (backwards)
/// Assumes dest and src are 2-byte aligned
/// \param dest Destination address
/// \param src Source address
/// \param n Number of bytes to copy
void __agbabi_rmemcpy2(void *__restrict__ dest, const void *__restrict__ src, size_t n);

/// Copies n bytes from src to dest (backwards)
/// Assumes dest and src are 4-byte aligned
/// \param dest Destination address
/// \param src Source address
/// \param n Number of bytes to copy
void __agbabi_rmemcpy4(void *__restrict__ dest, const void *__restrict__ src, size_t n);

/// Unsigned 64-bit / 32-bit -> 64-bit division
/// \param numerator
/// \param denominator
/// \return quotient
unsigned long long __agbabi_uluidiv(unsigned long long numerator, unsigned int denominator);

/// Fixed-point sine approximation
/// \param x 16-bit binary angle measurement
/// \return 32-bit signed fixed point (Q29) between -1 and +1
int __agbabi_sin(int x);

/// Reads the current machine context into ucp
/// \param ucp Pointer to context structure
/// \return 0
int __agbabi_getcontext(ucontext_t *ucp);

/// Sets the current machine context to ucp
/// \param ucp Pointer to context structure
/// \return Does not return
int __agbabi_setcontext(const ucontext_t *ucp) __attribute__((noreturn));

/// Writes current context into oucp, and switches to ucp
/// \param oucp Output address for current context
/// \param ucp Context to swap to
/// \return Although technically this does not return, it will appear to return 0 when switching to oucp
int __agbabi_swapcontext(ucontext_t *__restrict__ oucp, const ucontext_t *__restrict__ ucp);

/// Modifies context pointer to by ucp to invoke func with __agbabi_setcontext
/// Before invoking, the caller must allocate a new stack for
/// this context and assign its address to ucp->uc_stack, and define
/// a successor context and assign its address to ucp->uc_link.
/// \param ucp Pointer to context structure
/// \param func Function to invoke with __agbabi_setcontext
/// \param argc Number of arguments passed to func
/// \param ... List of arguments to be passed to func
void __agbabi_makecontext(ucontext_t* ucp, void(*func)(), int argc, ...);

/// Empty IRQ handler that simply acknowledges raised IRQs
void __agbabi_irq_empty();

/// Nested IRQ handler that calls __agbabi_irq_uproc with the raised IRQ flags
void __agbabi_irq_user();

/// User procedure called by __agbabi_irq_user
extern void(*__agbabi_irq_uproc)(short irqFlags);

typedef enum agbabi_rtc_err_t {
    agbabi_rtc_OK = 0,
    agbabi_rtc_EPOWER = 1,
    agbabi_rtc_E12HOUR = 2,
    agbabi_rtc_EYEAR = 3,
    agbabi_rtc_EMON = 4,
    agbabi_rtc_EDAY = 5,
    agbabi_rtc_EWDAY = 6,
    agbabi_rtc_EHOUR = 7,
    agbabi_rtc_EMIN = 8,
    agbabi_rtc_ESEC = 9,

    agbabi_rtc_ERR_SZ = INT_MAX
} agbabi_rtc_err_t;

/// Initialize GPIO pins for RTC
/// \return agbabi_rtc_err_t error code (0 for success)
int __agbabi_rtc_init();

typedef enum agbabi_rtc_stat_t {
    agbagbi_rtc_INTFE = 0x01,
    agbagbi_rtc_INTME = 0x02,
    agbagbi_rtc_INTAE = 0x04,
    agbagbi_rtc_24HOUR = 0x40,
    agbagbi_rtc_POWER = 0x80,

    agbabi_rtc_STAT_SZ = INT_MAX
} agbabi_rtc_stat_t;

/// Get the status flags of the RTC
/// \return bitmask of agbabi_rtc_stat_t
int __agbabi_rtc_status();

/// Resets RTC (also switches to 24-hour mode)
void __agbabi_rtc_reset();

typedef enum agbabi_rtc_time_t {
    agbagbi_rtc_TEST = 0x80,

    agbabi_rtc_TIME_SZ = INT_MAX
} agbabi_rtc_time_t;

/// Get the current, raw time from the RTC
/// If RTC is in TEST mode: agbagbi_rtc_TEST will be set
/// \return Raw time in BCD
int __agbabi_rtc_time();

/// Get the current, raw date & time from the RTC as a long long
/// \return lower 32-bits = raw time in BCD, upper 32-bits = raw date in BCD
long long __agbabi_rtc_ldatetime();

/// Writes lowest 8 bits of n to RTC
/// \param n data to write (lowest 8 bits used)
void __agbabi_rtc_write8(int n);

/// Set the Hour, Minute, Second
/// \param time raw BCD (second, minute, hour)
void __agbabi_rtc_settime(int time);

/// Set the time and date
/// \param datetime lower 32-bits = raw BCD time, upper 32-bits = raw BCD date
void __agbabi_rtc_setldatetime(long long datetime);

typedef struct agbabi_co_context_t {
    unsigned int arm_sp;
    unsigned int arm_lr;
} agbabi_co_context_t;

typedef struct agbabi_coro_t {
    agbabi_co_context_t context;
    int alive;
} agbabi_coro_t;

/// Initialises a coro struct to call a given coroutine
/// \param coro pointer to coro struct to initialize
/// \param sp_top the TOP of the stack for this coroutine (stack grows down!)
/// \param coproc procedure to call as a coroutine
void __agbabi_coro_make(agbabi_coro_t* coro, void* sp_top, int(*coproc)(agbabi_coro_t*));

/// Starts/resumes a given coroutine
/// When coroutine returns, the coro->alive flag is set to 0
/// \param coro coroutine to start/resumt
/// \return integer value from coroutine
int __agbabi_coro_resume(agbabi_coro_t* coro);

/// Yields a given value of a coroutine back to caller
/// \param coro coroutine that is yielding
/// \param value returned to caller
void __agbabi_coro_yield(agbabi_coro_t* coro, int value);

#if defined __has_attribute
#if __has_attribute(__vector_size__)

/// Unsigned 32-bit division and modulo
/// Check for divide by zero is not performed
/// \param numerator
/// \param denominator
/// \return [quotient, remainder]
unsigned int __attribute__((__vector_size__(8))) __agbabi_unsafe_uidivmod(unsigned int numerator, unsigned int denominator);

/// Unsigned 64-bit division and modulo
/// Check for divide by zero is not performed
/// \param numerator
/// \param denominator
/// \return [quotient, remainder]
unsigned long long __attribute__((__vector_size__(16))) __agbabi_unsafe_uldivmod(unsigned long long numerator, unsigned long long denominator);

/// Unsigned 64-bit / 32-bit -> 64-bit division and modulo
/// \param numerator
/// \param denominator
/// \return [quotient, remainder]
unsigned long long __attribute__((__vector_size__(16))) __agbabi_uluidivmod(unsigned long long numerator, int denominator);

/// Unsigned 64-bit / 32-bit -> 64-bit division and modulo
/// Check for divide by zero is not performed
/// \param numerator
/// \param denominator
/// \return [quotient, remainder]
unsigned long long __attribute__((__vector_size__(16))) __agbabi_unsafe_uluidivmod(unsigned long long numerator, int denominator);

/// Get the current, raw date & time from the RTC
/// \return [raw time in BCD, raw date in BCD]
int __attribute__((__vector_size__(8))) __agbabi_rtc_datetime();

/// Set the time and date
/// \param datetime [raw BCD time, raw BCD date]
void __agbabi_rtc_setdatetime(int __attribute__((__vector_size__(8))) datetime);

#endif
#endif

#ifdef __cplusplus
}
#endif
#endif // _AGBABI_H_
