# Arm Standard Compiler Helper Function Library

## Long-long helper functions

| Signature                                                                                 | Description                         |
|:------------------------------------------------------------------------------------------|:------------------------------------|
| `long long __aeabi_lmul(long long a, long long b)`                                        | 64-bit multiplication               |
| `lldiv_t __aeabi_ldivmod(long long numerator, long long denominator)`                     | Signed 64-bit division and modulo   |
| `ulldiv_t __aeabi_uldivmod(unsigned long long numerator, unsigned long long denominator)` | Unsigned 64-bit division and modulo |
| `long long __aeabi_llsl(long long x, int n)`                                              | 64-bit logical shift left           |
| `long long __aeabi_llsr(long long x, int n)`                                              | 64-bit logical shift right          |
| `long long __aeabi_lasr(long long x, int n)`                                              | 64-bit arithmetic shift right       |

`lldiv_t`, `ulldiv_t` are pseudo types that represent a 2x vector passed by register.

## Integer division

| Signature                                                                         | Description                         |
|:----------------------------------------------------------------------------------|:------------------------------------|
| `int __aeabi_idiv(int numerator, int denominator)`                                | Signed 32-bit division              |
| `unsigned int __aeabi_uidiv(unsigned int numerator, unsigned int denominator)`    | Unsigned 32-bit division            |
| `idiv_return __aeabi_idivmod(int numerator, int denominator)`                     | Signed 32-bit division and modulo   |
| `uidiv_return __aeabi_uidivmod(unsigned int numerator, unsigned int denominator)` | Unsigned 32-bit division and modulo |

`idiv_return`, `uidiv_return` are pseudo types that represent a 2x vector passed by register.

## Memory copying

| Signature                                                      | Description                                                                            |
|:---------------------------------------------------------------|:---------------------------------------------------------------------------------------|
| `void __aeabi_memcpy8(void* dest, const void* src, size_t n)`  | Alias of `__aeabi_memcpy4`                                                             |
| `void __aeabi_memcpy4(void* dest, const void* src, size_t n)`  | Copies n bytes from src to dest (forward)<br/> Assumes dest and src are 4-byte aligned |
| `void __aeabi_memcpy(void* dest, const void* src, size_t n)`   | Copies n bytes from src to dest (forward)                                              |
| `void __aeabi_memmove8(void* dest, const void* src, size_t n)` | Alias of `__aeabi_memmove4`                                                            |
| `void __aeabi_memmove4(void* dest, const void* src, size_t n)` | Safely copies n bytes of src to dest<br/>Assumes dest and src are 4-byte aligned       |
| `void __aeabi_memmove(void* dest, const void* src, size_t n)`  | Safely copies n bytes of src to dest                                                   |

These routines should be expected to perform 8-bit, 16-bit, and 32-bit copies.

## Memory clearing and setting

| Signature                                           | Description                                                          |
|:----------------------------------------------------|:---------------------------------------------------------------------|
| `void __aeabi_memset8(void* dest, size_t n, int c)` | Alias of `__aeabi_memset4`                                           |
| `void __aeabi_memset4(void* dest, size_t n, int c)` | Set n bytes of dest to (c & 0xff)<br/>Assumes dest is 4-byte aligned |
| `void __aeabi_memset(void* dest, size_t n, int c)`  | Set n bytes of dest to (c & 0xff)                                    |
| `void __aeabi_memclr8(void* dest, size_t n)`        | Alias of `__aeabi_memclr4`                                           |
| `void __aeabi_memclr4(void* dest, size_t n)`        | Clears n bytes of dest to 0<br/>Assumes dest is 4-byte aligned       |
| `void __aeabi_memclr(void* dest, size_t n)`         | Clears n bytes of dest to 0                                          |

These routines should be expected to perform 8-bit, 16-bit, and 32-bit writes.
