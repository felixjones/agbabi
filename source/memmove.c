#include <stddef.h>

void __aeabi_memmove8( void * dest, const void * src, size_t n ) __attribute__((alias("__aeabi_memmove4")));
void __aeabi_memmove4( void * dest, const void * src, size_t n ) __attribute__((section(".ewram.__aeabi_memmove4"))) __attribute__((target("thumb")));
void __aeabi_memmove( void * dest, const void * src, size_t n ) __attribute__((section(".ewram.__aeabi_memmove"))) __attribute__((target("thumb")));

void __aeabi_memmove4( void * dest, const void * src, size_t n ) {
    void __agbabi_rmemcpy4( void *, const void *, size_t );
    void __aeabi_memcpy4( void *, const void *, size_t );

    if ( dest > src ) {
        __agbabi_rmemcpy4( dest, src, n );
    } else {
        __aeabi_memcpy4( dest, src, n );
    }
}

void __aeabi_memmove( void * dest, const void * src, size_t n ) {
    void __agbabi_rmemcpy( void *, const void *, size_t );
    void __aeabi_memcpy( void *, const void *, size_t );

    if ( dest > src ) {
        __agbabi_rmemcpy( dest, src, n );
    } else {
        __aeabi_memcpy( dest, src, n );
    }
}
