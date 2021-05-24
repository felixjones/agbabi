@--------------------------------------------------------------------------------
@ lmul.s
@--------------------------------------------------------------------------------
@ Implementation of:
@   long long __aeabi_lmul(long long, long long)
@--------------------------------------------------------------------------------

    .section .iwram.__aeabi_lmul, "ax", %progbits
    .align 2
    .arm
    .global __aeabi_lmul
    .type __aeabi_lmul STT_FUNC
__aeabi_lmul:
	mov	    r12, r0
	push	{r11}
	umull	r0, r11, r12, r2
	mla	    r12, r3, r12, r11
	pop	    {r11}
	mla	    r1, r2, r1, r12
	bx	    lr
