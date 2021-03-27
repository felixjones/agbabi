@--------------------------------------------------------------------------------
@ c_string_byte.s
@--------------------------------------------------------------------------------
@ Bindings of the C byte functions:
@   memcpy
@   void*( void *dest, const void *src, size_t count )
@--------------------------------------------------------------------------------

    .section .iwram, "ax", %progbits
    .align 2
    .arm
    .global __memcpy_from_arm
    .type __memcpy_from_arm STT_FUNC
__memcpy_from_arm:
    push    {r0, lr}
    .extern __aeabi_memcpy
    bl      __aeabi_memcpy
    pop     {r0, lr}
    bx      lr

    .section .ewram, "ax", %progbits
    .align 2
    .thumb
    .global __memcpy_from_thumb
    .type __memcpy_from_thumb STT_FUNC
__memcpy_from_thumb:
    .global memcpy
    .type memcpy STT_FUNC
memcpy:
    push    {r0, lr}
    .extern __aeabi_memcpy
    bl      __aeabi_memcpy
    pop     {r0}
    pop     {r1}
    bx      r1
