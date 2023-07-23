# AGB Support Library

## Long long division

| Signature                                                                                         | Description                                                                                          |
|:--------------------------------------------------------------------------------------------------|:-----------------------------------------------------------------------------------------------------|
| `long long __agbabi_ldiv(long long numerator, long long denominator)`                             | Signed 64-bit division                                                                               |
| `unsigned long long __agbabi_uldiv(unsigned long long numerator, unsigned long long denominator)` | Unsigned 64-bit division                                                                             |
| `ulldiv_t __agbabi_unsafe_uldivmod(unsigned long long numerator, unsigned long long denominator)` | Unsigned 64-bit division and modulo<br/>Check for divide by zero is not performed                    |
| `unsigned long long __agbabi_uluidiv(unsigned long long numerator, unsigned int denominator)`     | Unsigned 64-bit / 32-bit -> 64-bit division                                                          |
| `ulldiv_t __agbabi_uluidivmod(unsigned long long numerator, unsigned int denominator)`            | Unsigned 64-bit / 32-bit -> 64-bit division and modulo                                               |
| `ulldiv_t __agbabi_unsafe_uluidivmod(unsigned long long numerator, unsigned int denominator)`     | Unsigned 64-bit / 32-bit -> 64-bit division and modulo<br/>Check for divide by zero is not performed |

`ulldiv_t` is a pseudo type that represent a 2x vector passed by register.

## Integer division

| Signature                                                                                 | Description                                                                       |
|:------------------------------------------------------------------------------------------|:----------------------------------------------------------------------------------|
| `uidiv_return __agbabi_unsafe_uidivmod(unsigned int numerator, unsigned int denominator)` | Unsigned 32-bit division and modulo<br/>Check for divide by zero is not performed |

`uidiv_return` is a pseudo type that represent a 2x vector passed by register.

## Memory copying

| Signature                                                       | Description                                                                                                  |
|:----------------------------------------------------------------|:-------------------------------------------------------------------------------------------------------------|
| `void __agbabi_memcpy2(void* dest, const void* src, size_t n)`  | Copies n bytes from src to dest (forward)<br/>Assumes dest and src are 2-byte aligned                        |
| `void __agbabi_memcpy1(void* dest, const void* src, size_t n)`  | Copies n bytes from src to dest (forward)<br/>This is a slow, unaligned, byte-by-byte copy: ideal for SRAM   |
| `void __agbabi_rmemcpy1(void* dest, const void* src, size_t n)` | Copies n bytes from src to dest (backwards)<br/>This is a slow, unaligned, byte-by-byte copy: ideal for SRAM |
| `void __agbabi_rmemcpy(void* dest, const void* src, size_t n)`  | Copies n bytes from src to dest (backwards)                                                                  |

## Fast memory copying

| Signature                                                            | Description                                                                                                                   |
|:---------------------------------------------------------------------|:------------------------------------------------------------------------------------------------------------------------------|
| `void __agbabi_fiq_memcpy4x4(void* dest, const void* src, size_t n)` | Copies n bytes in multiples of 16 bytes from src to dest (forward) using FIQ mode<br/>Assumes dest and src are 4-byte aligned |
| `void __agbabi_fiq_memcpy4(void* dest, const void* src, size_t n)`   | Copies n bytes from src to dest (forward) using FIQ mode<br/>Assumes dest and src are 4-byte aligned                          |

Uses the additional registers of Fast IRQ CPU mode to perform a very fast memory copy.

## Memory setting

| Signature                                                    | Description                                                                                                                     |
|:-------------------------------------------------------------|:--------------------------------------------------------------------------------------------------------------------------------|
| `void __agbabi_lwordset4(void* dest, size_t n, long long c)` | Fills dest with n bytes of c<br/>Assumes dest is 4-byte aligned<br/>Trailing copy uses the low word of c, and the low byte of c |
| `void __agbabi_wordset4(void* dest, size_t n, int c)`        | Fills dest with n bytes of c<br/>Assumes dest is 4-byte aligned<br/>Trailing copy uses the low byte of c                        |

## Additional math functions

```c
#include <agbabi.h>

int main() {
    /* takes a 15-bit binary angle measurement, where 0x4000 = 180 degrees or Pi radians */
    int a = __agbabi_sin(0x1000); /* returns a 32-bit Q29 fixed point value between -1 and +1 */
    /* `a` is roughly `0.70710678118` (`Sin(45_deg)`) */
    
    /* takes two 32-bit Q12 fixed point coords around a circle */
    unsigned int b = __agbabi_atan2(0x300, 0x400); /* returns a 15-bit binary angle measurement, where 0x4000 = 180 degrees or Pi radians */
    /* `b` is roughly `0.927295` (`ArcTan2(0.25, 0.1875)`) */
}
```

| Signature                                   | Description                             |
|:--------------------------------------------|:----------------------------------------|
| `int __agbabi_sin(int x)`                   | Fixed-point sine approximation          |
| `unsigned int __agbabi_atan2(int x, int y)` | Calculates the arc tangent of x, y      |
| `int __agbabi_sqrt(unsigned int x)`         | Calculates the integer square root of x |

## IRQ handling

```c
#include <agbabi.h>

#define IRQ_HANDLER (*(void(**)()) 0x3FFFFFC)
void my_irq_handler(int irqFlags);

int main() {
    IRQ_HANDLER = __agbabi_irq_user;
    __agbabi_irq_user_fn = my_irq_handler;
}
```

| Signature                                          | Description                                                                    |
|:---------------------------------------------------|:-------------------------------------------------------------------------------|
| `void __agbabi_irq_empty()`                        | Empty IRQ handler that acknowledges raised IRQs                                |
| `void __agbabi_irq_user()`                         | Nested IRQ handler that calls `__agbabi_irq_user_fn` with the raised IRQ flags |
| `extern void(*__agbabi_irq_user_fn)(int irqFlags)` | Handler called by `__agbabi_irq_user`                                          |

## Coroutines

```c
#include <agbabi.h>

int my_coro_proc(__agbabi_coro_t* coro);

int main() {
    #define STACK_LEN (0x200)
    int stack[STACK_LEN];
    
    __agbabi_coro_t coro;
    __agbabi_coro_make(&coro, stack + STACK_LEN, my_coro_proc);
    
    while (coro.joined == 0) {
        int i = __agbabi_coro_resume(&coro);
    }
}

int my_coro_proc(__agbabi_coro_t* coro) {
    for (int i = 0; i < 10; ++i) {
        __agbabi_coro_yield(coro, i);
    }
    return 10; /* Joins coroutine */
}
```

| Signature                                                                                      | Description                                            |
|:-----------------------------------------------------------------------------------------------|:-------------------------------------------------------|
| `void __agbabi_coro_make(__agbabi_coro_t* coro, void* sp_top, int(*coproc)(__agbabi_coro_t*))` | Initializes a coro struct to call a given coroutine    |
| `int __agbabi_coro_resume(__agbabi_coro_t* coro)`                                              | Starts/resumes a given coroutine                       |
| `void __agbabi_coro_yield(__agbabi_coro_t* coro, int value)`                                   | Yields a given value of a coroutine back to the caller |

`__agbabi_coro_t` is a bitfield with a 1-bit `joined` flag, set to `1` when the coroutine has joined, and a 31-bit `arm_sp` address of the coroutine stack.

```c
typedef struct {
    unsigned int arm_sp : 31;
    unsigned int joined : 1;
} __agbabi_coro_t;
```

### Restarting a joined coroutine

Calling `__agbabi_coro_resume` on a coroutine with the `joined` flag set will clear the `joined` flag and restart the coroutine.

```c
__agbabi_coro_t coro;
/* __agbabi_coro_make */

while (coro.joined == 0) {
    __agbabi_coro_resume(&coro);
}
/* coro.joined is now 1 */

if (coro.joined == 1) {
    /* Restart coro */
    __agbabi_coro_resume(&coro);
    /* coro.joined is now 0 */
}
```

## Real-time clock

Requires RTC hardware. Time and date is in big-endian BCD format.

```c
#include <agbabi.h>

int main() {
    if (__agbabi_rtc_init() == 0) {
        unsigned int time = __agbabi_rtc_time();
        __agbabi_rtc_settime(0x563412); /* Set time to 12:34:56 */
        __agbabi_rtc_setdatetime((__agbabi_datetime_t) {
            0x100978,
            0x563412
        }); /* Set date & time to 2078-09-10, 12:34:56 */
    }
}
```

| Signature                                                     | Description                                   |
|:--------------------------------------------------------------|:----------------------------------------------|
| `int __agbabi_rtc_init()`                                     | Initialize GPIO pins for RTC                  |
| `unsigned int __agbabi_rtc_time()`                            | Get the current, raw time from the RTC        |
| `void __agbabi_rtc_settime(unsigned int time)`                | Set the Hour, Minute, Second                  |
| `__agbabi_datetime_t __agbabi_rtc_datetime()`                 | Get the current, raw date & time from the RTC |
| `void __agbabi_rtc_setdatetime(__agbabi_datetime_t datetime)` | Set the time and date                         |

`__agbabi_datetime_t` is a 2x vector type passed by register.

## Multiboot

```c
/* Example has a multiboot ROM binary at MY_MULTIBOOT_ROM */

#include <agbabi.h>

int on_clients_connected(int mask);
int on_header_progress(int prog);
int on_palette_progress(int mask);
int on_multiboot_ready();

int main() {
    __agbabi_multiboot_t param;
    param.header = MY_MULTIBOOT_ROM;
    param.begin = MY_MULTIBOOT_ROM + MY_MULTIBOOT_HEADER_SIZE;
    param.end = MY_MULTIBOOT_ROM + MY_MULTIBOOT_ROM_SIZE;
    param.palette = 0;
    param.clients_connected = on_clients_connected;
    param.header_progress = on_header_progress;
    param.palette_progress = on_palette_progress;
    param.accept = on_multiboot_ready;
    
    if (__agbabi_multiboot(&param) != 0) {
        /* An error has occurred (check `errno`) */
    }
}

int on_clients_connected(int mask) {
    if (mask & 0xc) {
        return 1; /* Cancel as we only expected 0x3 clients (2 players) */    
    }
    return 0;
}

int on_header_progress(int prog) {
    /* Display progress as `prog / 0x60` */
    /* If cancel button is pressed: `return 1` */
    return 0;
}

int on_palette_progress(int mask) {
    /* If cancel button is pressed: `return 1` */
    return 0;
}

int on_multiboot_ready() {
    /* Wait for confirmation button */
    /* `return 1` if cancelled or timedout */
    return 0; /* Confirm send multiboot ROM */
}
```

| Signature                                                   | Description                                                        |
|:------------------------------------------------------------|:-------------------------------------------------------------------|
| `int __agbabi_multiboot(const __agbabi_multiboot_t* param)` | Send Multiboot data over serial IO<br/>IRQs must first be disabled |

`__agbabi_multiboot_t` is a parameter structure that contains pointesr to the multiboot binary, the palette type to display, and callback functions.

```c
typedef struct {
    const void* header;
    const void* begin;
    const void* end;
    int palette;
    int(*clients_connected)(int mask);
    int(*header_progress)(int prog);
    int(*palette_progress)(int mask);
    int(*accept)();
} __agbabi_multiboot_t;
```

## EWRAM Overclock

Checks if EWRAM is compatible with `REG_MEMCNT` set to `0x0E000020`.

Interrupts are disabled during the hardware test.

```c
#include <agbabi.h>

#define REG_MEMCNT (*(volatile int*) 0x4000800)

int main() {
    if (__agbabi_poll_ewram()) {
        /* It is (probably) safe to activate fast EWRAM */
        REG_MEMCNT = 0x0E000020;
    }
}
```

| Signature                   | Description                                |
|:----------------------------|:-------------------------------------------|
| `int __agbabi_poll_ewram()` | Returns 1 for fast EWRAM, 0 for slow EWRAM |
