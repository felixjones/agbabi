# AGB ABI Library (agbabi)

## Quick Start Guide

Link with `libagbabi.a` via the normal means for your build environment (eg: `-Lagbabi` for GCC and Clang).

Linking will implicitly activate the `armeabi` library.

Include the `armeabi.h` and `agbabi.h` headers to access the `armeabi` and `agbabi` C functions.

```c
#include <aeabi.h>
#include <agbabi.h>
#include <sys/ucontext.h> /* POSIX context switching */

int main() {
    
    unsigned int a = __aeabi_uidiv(9u, 3u);
    
    int b = __agbabi_sqrt(25u);
    
    ucontext_t c;
    getcontext(&c);
    
    return 0;
}
```

## API Reference

- [aeabi](docs/aeabi.md)
- [agbabi](docs/agbabi.md)
- [POSIX](docs/posix.md)

## Building

Requires `gcc-arm-none-eabi` cross compiler, and either `cmake` or `meson` for configuration.

### CMake 3.18+

To cross-build `libagbabi.a` in directory `build/`:

```shell
cmake -S . -B build --toolchain=cross/agb.cmake
cmake --build build
```

### Meson 0.56.2+

To cross-build `libagbabi.a` in directory `build/`:

```shell
meson setup build --cross-file=cross/agb.ini
meson compile -C build
```
