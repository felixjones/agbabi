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
/// \param irqFlags Raised IRQ flags bitmask
extern void(*__agbabi_irq_uproc)(short irqFlags);

/// Multiboot protocol state flags
/// \param agbabi_mb_WAIT Wait requested for clients to connect. Callback should delay before returning. (data = number of attempts)
/// \param agbabi_mb_CONNECTED Available clients are connected (data = client bitmask)
/// \param agbabi_mb_HEADER Sending header (data = bytes sent)
/// \param agbabi_mb_PALETTE Sending palette (data = pending client bitmask)
/// \param agbabi_mb_MULTIBOOT Calling BIOS Multiboot (data = 0)
typedef enum agbabi_mb_stat_t {
    agbabi_mb_WAIT = 0,
    agbabi_mb_CONNECTED,
    agbabi_mb_HEADER,
    agbabi_mb_PALETTE,
    agbabi_mb_MULTIBOOT,

    agbabi_mb_STAT_SZ = INT_MAX
} agbabi_mb_stat_t;

/// User callback used in agbabi_mb_param_t
/// \param stat Current agbabi_mb_stat_t state
/// \param data Accompanying data for agbabi_mb_stat_t state
/// \param void* User pointer sent to callback
/// \return 1 to cancel Multiboot, 0 to continue
typedef int(*agbabi_mb_callback_t)(int stat, int data, void* uptr);

/// Structure containing options for __agbabi_multiboot
/// \param srcp Address of data to send
/// \param srclen Byte length of data
/// \param client_mask Bitmask of clients to send to (1 << ID, 0xF for all clients)
/// \param palette Byte palette (must have bits 0x81 set)
/// \param callback Function pointer of type agbabi_mb_callback_t (Required)
/// \param uptr User pointer to send to agbabi_mb_callback_t
typedef struct agbabi_mb_param_t {
    const void* srcp;
    size_t srclen;
    int client_mask;
    int palette;
    agbabi_mb_callback_t callback;
    void* uptr;
} agbabi_mb_param_t;

typedef enum agbabi_mb_err_t {
    agbabi_mb_SUCCESS = 0,
    agbabi_mb_CANCELLED = 1,
    agbabi_mb_NOT_HOST = 2,
    agbabi_mb_TIMEOUT = 3,
    agbabi_mb_FAIL_ACK = 4, // top 16-bits is mask of failed clients
    agbabi_mb_FAIL_HEADER = 5, // top 16-bits is mask of failed clients
    agbabi_mb_FAIL_PALETTE = 6, // top 16-bits is mask of failed clients
    agbabi_mb_FAIL_MULTIBOOT = 7,

    agbabi_mb_ERR_SZ = INT_MAX
} agbabi_mb_err_t;

/// Performs Multiboot program sending protocol
/// Interrupts must be disabled before this call
/// A callback is used to signal current state this can be used to temporarily enable interrupts or switch contexts
/// The callback is expected to implement a timed delay for state "agbabi_mb_WAIT"
/// \param param Pointer to agbabi_mb_param_t
/// \return Error code describing what problem was encountered (0 is success)
int __agbabi_multiboot(const agbabi_mb_param_t* param);

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

#endif
#endif

#ifdef __cplusplus
}
#endif
#endif // _AGBABI_H_
