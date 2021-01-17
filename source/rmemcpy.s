@--------------------------------------------------------------------------------
@ rmemcpy.s
@--------------------------------------------------------------------------------
@ Equivalent to memcpy, but copies in reverse.
@   __agbabi_wordrcopy4
@   __agbabi_wordrcopy
@   (void *dest, const void *src, size_t n)
@ wordrcopy4 dest * src are word-aligned
@ wordrcopy might not be word-aligned
@--------------------------------------------------------------------------------

    .section .iwram, "ax", %progbits
    .align 2
    .arm
    .global __aeabi_memset8
    .type __aeabi_memset8 STT_FUNC
__agbabi_wordrcopy4:
