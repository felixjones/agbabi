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

#include <stddef.h>

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
