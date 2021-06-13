# agbabi
## AGB Application Binary Interface
GBA optimized library functions for common operations.

Includes implementations for various [aeabi functions](https://developer.arm.com/documentation/ihi0043/latest/).

Originally created as an optional utility library for [gba-toolchain](https://github.com/felixjones/gba-toolchain) projects.

# C string byte functions

## memcpy
Calls `__aeabi_memcpy` and returns dest.
```c
void* memcpy(void *restrict dest, const void *restrict src, size_t count);
```
Compilers sometimes replace memory-copying loops with a call to `memcpy`.

## memset
Calls `__aeabi_memset` and returns dest.
```c
void* memset( void *dest, int ch, size_t count );
```
Compilers sometimes replace memory-clearing loops with a call to `memset`.

## memmove
Calls either `__agbabi_rmemcpy` or `__aeabi_memcpy` and returns dest.
```c
void* memmove(void *dest, const void *src, size_t count);
```
Compilers sometimes replace overlapping memory-copying loops with a call to `memmove`.

# aeabi helper functions
## Integer (32/32 → 32) division functions
The 32-bit integer division functions return the quotient in r0 or both quotient and remainder in {r0, r1}.    
`__value_in_regs` is a hypothetical macro that instructs `struct` members to be passed by register.
```c
int __aeabi_idiv(int numerator, int denominator);
unsigned __aeabi_uidiv(unsigned numerator, unsigned denominator);

typedef struct { int quot; int rem; } idiv_return;
typedef struct { unsigned quot; unsigned rem; } uidiv_return;

__value_in_regs idiv_return __aeabi_idivmod(int numerator, int denominator);
__value_in_regs uidiv_return __aeabi_uidivmod(unsigned numerator, unsigned denominator);
```
The division functions take the numerator and denominator in that order.

## Integer (64/64 → 64) division functions
The 64-bit integer division functions return the quotient across {r0, r1} or both quotient and remainder in {r0, r1} and {r2, r3}.    
`__value_in_regs` is a hypothetical macro that instructs `struct` members to be passed by register.
```c
long long __aeabi_ldiv(long long numerator, long long denominator);
unsigned long long __aeabi_uldiv(unsigned long long numerator, unsigned long long denominator);

typedef struct { long long quot; long long rem; } ldiv_return;
typedef struct { unsigned long long quot; long long unsigned rem; } uldiv_return;

__value_in_regs ldiv_return __aeabi_ldivmod(long long numerator, long long denominator);
__value_in_regs uldiv_return __aeabi_uldivmod(unsigned long long numerator, unsigned long long denominator);
```
The division functions take the numerator and denominator in that order.

## Integer (64×64 → 64) multiplication function
Long long implementation of integer multiplication.    
The 64-bit multiplication function returns the result across {r0, r1}.
```c
long long __aeabi_lmul(long long a, long long b);
```

## Integer 64 bit-shift functions
Long long implementations of arithmetic shift right, logical shift left and logical shift right.    
The 64-bit shift functions return the result across {r0, r1}.
```c
long long __aeabi_lasr(long long x, int n);
long long __aeabi_llsl(long long x, int n);
long long __aeabi_llsr(long long x, int n);
```

## Memory copying, clearing, and setting
### Memory copying
Memcpy-like helper functions are needed to implement structure assignment.
```c
void __aeabi_memcpy8(void *dest, const void *src, size_t n);
void __aeabi_memcpy4(void *dest, const void *src, size_t n);
void __aeabi_memcpy(void *dest, const void *src, size_t n);
void __aeabi_memmove8(void *dest, const void *src, size_t n);
void __aeabi_memmove4(void *dest, const void *src, size_t n);
void __aeabi_memmove(void *dest, const void *src, size_t n);
```
These functions work like the ANSI C memcpy and memmove functions. However, `__aeabi_memcpy4` and `__aeabi_memcpy8` both assume that both of its arguments are 4-byte aligned.

Compilers can replace calls to `memcpy` with calls to one of these functions if they can deduce that the constraints are satisfied. For example, any `memcpy` whose return value is ignored can be replaced with `__aeabi_memcpy`. If the copy is between 4-byte-aligned pointers it can be replaced with `__aeabi_memcpy4`, and so on.

The `size_t` argument does not need to be a multiple of 4 for the 4/8-byte aligned versions, which allows copies with a non-constant size to be specialized according to source and destination alignment.

### Memory clearing and setting
In similar deference to run-time efficiency we define reduced forms of `memset` and `memclr`.
```c
void __aeabi_memset8(void *dest, size_t n, int c);
void __aeabi_memset4(void *dest, size_t n, int c);
void __aeabi_memset(void *dest, size_t n, int c);
void __aeabi_memclr8(void *dest, size_t n);
void __aeabi_memclr4(void *dest, size_t n);
void __aeabi_memclr(void *dest, size_t n);
```
The `memclr` functions simplify a very common special case of `memset`, namely the one in which `c = 0` and the memory is being cleared to all zeroes.

The `size_t` argument does not need to be a multiple of 4 for the 4/8-byte aligned versions, which allows clears and sets with a non-constant size to be specialized according to the destination alignment.

# agbabi helper functions
## Unsafe integer (32/32 → 32) division function
An unsafe implementation of `__aeabi_uidivmod` that skips the divide by zero check.    
`__value_in_regs` is a hypothetical macro that instructs `struct` members to be passed by register.
```c
typedef struct { unsigned quot; unsigned rem; } uidiv_return;

__value_in_regs uidiv_return __agbabi_unsafe_uidiv(unsigned numerator, unsigned denominator);
```
`__aeabi_idiv0` is not called in this situation. The quotient and remainder of a divide by zero is not defined.

## Unsafe integer (64/64 → 64) division function
An unsafe implementation of `__aeabi_uldivmod` that skips the divide by zero check.    
The denominator must have a non-zero hi-word (greater than `0xffffffff`).    
`__value_in_regs` is a hypothetical macro that instructs `struct` members to be passed by register.
```c
typedef struct { unsigned long long quot; unsigned long long rem; } uldiv_return;

__value_in_regs uldiv_return __agbabi_unsafe_uldiv(unsigned long long numerator, unsigned long long denominator);
```
`__aeabi_idiv0` is not called in this situation. The quotient and remainder of a divide by zero is not defined.

## Integer (64/32 → 64) division functions
The 64-bit/32-bit integer division functions return the quotient in {r0, r1} or both quotient and remainder in {r0, r1} and {r2}. {r3} is cleared to zero.    
`__value_in_regs` is a hypothetical macro that instructs `struct` members to be passed by register.
```c
unsigned long long __agbabi_uluidiv(unsigned long long numerator, unsigned denominator);

typedef struct { unsigned long long quot; unsigned rem; unsigned zero } uluidiv_return;

__value_in_regs uluidiv_return __agbabi_uluidivmod(unsigned long long numerator, unsigned denominator);
```
The division functions take the numerator and denominator in that order.

### Unsafe integer (64/32 → 64) division
An unsafe implementation of `__agbabi_uluidiv` that skips the divide by zero check.    
`__value_in_regs` is a hypothetical macro that instructs `struct` members to be passed by register.
```c
typedef struct { unsigned long long quot; unsigned rem; unsigned zero } uluidiv_return;

__value_in_regs uluidiv_return __agbabi_unsafe_uluidiv(unsigned long long numerator, unsigned denominator);
```
`__aeabi_idiv0` is not called in this situation. The quotient and remainder of a divide by zero is not defined.

## Fixed-point sine approximation
An implementation of sine that does not use look-up-tables.
```c
int __agbabi_sin(int x);
```
Argument `x` is treated as a signed 16-bit binary angle measurement between -32,768 and +32,767 (-360 and +360 in degrees, -2π and +2π in radians).

The return value is a 32-bit signed fixed-point integer between with 29 fractional bits. In fixed-point, it ranges between -1 and +1 (-536870912 and +536870911 as a 32-bit signed integer).

## Memory copying, clearing, and setting
### 16-bit memcpy
Used by `__aeabi_memcpy` for cases where either `dest` or `src` are half-aligned.
```c
void __agbabi_memcpy2(void *dest, const void *src, size_t n);
```
`__agbabi_memcpy2` assumes that both of its arguments are 2-byte aligned. This is ideal for VRAM 

### 16-bit memmove
Used by `__aeabi_memmove` for cases where either `dest` or `src` are half-aligned.
```c
void __agbabi_memmove2(void *dest, const void *src, size_t n);
```
`__agbabi_memmove2` assumes that both of its arguments are 2-byte aligned. This is ideal for VRAM

### Reverse memory copying
Used by `__aeabi_memmove` for reverse-copying in cases where `dest > src`.
```c
void __agbabi_rmemcpy4(void *dest, const void *src, size_t n);
void __agbabi_rmemcpy2(void *dest, const void *src, size_t n);
void __agbabi_rmemcpy(void *dest, const void *src, size_t n);
```
`__agbabi_rmemcpy4` assumes that both of its arguments are 4-byte aligned.    
`__agbabi_rmemcpy2` assumes that both of its arguments are 2-byte aligned.

The `size_t` argument does not need to be a multiple of 4 or 2 for the 4-byte or 2-byte aligned versions, which allows copies with a non-constant size to be specialized according to source and destination alignment.

### Memory setting
The full 32-bits of `c` are copied into `dest`, which is assumed to be 4-byte aligned.
```c
void __agbabi_wordset4(void *dest, size_t n, int c);
```
If the `size_t` argument is not a multiple of 4, the low bytes of `c` will be copied into the remaining space.

## Context switching
User-level context switching based on the POSIX context control C library.
```c
#include <sys/ucontext.h>
```
`ucontext_t` type is a structure that has the following fields:
```c
typedef struct ucontext_t {
    struct ucontext_t *uc_link;
    stack_t uc_stack;
    mcontext_t uc_mcontext;
} ucontext_t;
```
### Context get/set
```c
int __agbabi_getcontext(ucontext_t *ucp);
int __agbabi_setcontext(const ucontext_t *ucp);
```
`__agbabi_getcontext` initializes the structure pointed to by `ucp` to the currently active context. A successful call returns 0.

`__agbabi_setcontext` restores the user context pointed to by `ucp`. A successful call does not return. The context should have been obtained by a call of `__agbabi_getcontext`, or `__agbabi_makecontext`.

If the context was obtained by a call of `__agbabi_getcontext`, program execution continues as if this call just returned.

If the context was obtained by a call of `__agbabi_makecontext`, program execution continues by a call to the function `func` specified as the second argument of that call to `__agbabi_makecontext`. When the function `func` returns, we continue with the `uc_link` member of the structure `ucp` specified as the first argument of that call to `__agbabi_makecontext`. When this member is `NULL` the program exits by a call to `_exit`.

### Context make/swap
```c
void __agbabi_makecontext(ucontext_t *ucp, void (*func)(), int argc, ...);
int __agbabi_swapcontext(ucontext_t *oucp, const ucontext_t *ucp);
```
The `__agbabi_makecontext` function modifies the context pointed to by `ucp` (which was obtained from a call to `__agbabi_getcontext`). Before invoking `__agbabi_makecontext`, the caller must allocate a new stack for this context and assign its address to `ucp->uc_stack`, and define a successor context and assign its address to `ucp->uc_link`.

When this context is later activated (using `__agbabi_setcontext` or `__agbabi_swapcontext`) the function `func` is called, and passed the series of integer (`int`) arguments that follow `argc`; the caller must specify the number of these arguments in `argc`. When this function returns, the successor context is activated. If the successor context pointer is `NULL`, the program exits by a call to `_exit`.

The `__agbabi_swapcontext` function saves the current context in the structure pointed to by `oucp`, and then activates the context pointed to by `ucp`.

When successful, `__agbabi_swapcontext` does not return. (But we may return later, in case `oucp` is activated, in which case it looks like `__agbabi_swapcontext` returns `0`.)

## Interrupt handlers
Implements IRQ handling without requiring a "switch-board" handling table.

To use these functions their address must be written to `0x3007FFC`.
```c
void __agbabi_irq_empty();
void __agbabi_irq_user();
```
Certain GBA BIOS functions and hardware features depend on IRQs being raised and then acknowledged by a handler. The function `__agbabi_irq_empty` will simply acknowledge raised IRQs and return.

The handler `__agbabi_irq_user` acknowledges raised IRQs, but will also jump to the function pointer at symbol `__agbabi_irq_uproc` with a branch-exchange, allowing more complex IRQ handling to be implemented.

Nested IRQ handling can be enabled by writing `1` to the lowest bit of `REG_IME` from the `__agbabi_irq_uproc` user procedure.

```c
void (*__agbabi_irq_uproc)(short flags);
```
The argument `flags` of the `__agbabi_irq_uproc` procedure will contain a mask of the raised IRQs.

### Context irq
Implements an IRQ handler that can modify the return context.

To use this function its address must be written to `0x3007FFC`.
```c
void __agbabi_irq_ucontext();
```
Behaves identically to `__agbabi_irq_user`, however the `__agbabi_irq_uproc` procedure signature is changed.

```c
const ucontext_t* (*__agbabi_irq_uproc)(const ucontext_t *inContext, short flags);
```
The argument `inContext` of the `__agbabi_irq_uproc` procedure will contain a context describing the program state before the IRQ was raised. 

The return value is the context to be set when the IRQ handler is complete.    
`inContext` must be returned if no context switching is needed.

## OAM and affine matrix copying and setting
These functions are intended for weaving OAM data with object affine matrices.

`srcA` is expected to point to a structure similar to:
```c
struct oam_data  {
    short attr0;
    short attr1;
    short attr2;
    short padding;
};
```
### OAM/affine copying
`dest` is filled with the contents of `srcA`, however the highest half-word is copied from `srcB`.   
This results in `dest` being filled with half-words semi-woven between `srcA` and `srcB`.
```c
void __agbabi_oamcpy(void *dest, const oam_data *srcA, const short *srcB, size_t n);
```
The `size_t` argument is expected to be a multiple of 8.
### OAM/affine setting
`dest` is filled with the first 3 half words of `srcA`, however the 4th half-word is appended with four half-words from `srcB`.
```c
void __agbabi_oamset(void *dest, const oam_data *srcA, const short *srcB, size_t n);
```
The `size_t` argument is expected to be a multiple of 8.
