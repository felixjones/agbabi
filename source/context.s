@--------------------------------------------------------------------------------
@ context.s
@--------------------------------------------------------------------------------
@ Based on POSIX context switching
@ int __agbabi_getcontext(ucontext_t *ucp)
@ int __agbabi_setcontext(const ucontext_t *ucp)
@ void __agbabi_makecontext(ucontext_t *ucp, void (*func)(), int argc, ...)
@ int __agbabi_swapcontext(ucontext_t *oucp, const ucontext_t *ucp)
@--------------------------------------------------------------------------------

#define MCONTEXT_ARM_R0     12
#define MCONTEXT_ARM_R1     16
#define MCONTEXT_ARM_R2     20
#define MCONTEXT_ARM_R3     24
#define MCONTEXT_ARM_R4     28
#define MCONTEXT_ARM_R5     32
#define MCONTEXT_ARM_R6     36
#define MCONTEXT_ARM_R7     40
#define MCONTEXT_ARM_R8     44
#define MCONTEXT_ARM_R9     48
#define MCONTEXT_ARM_R10    52
#define MCONTEXT_ARM_R11    56
#define MCONTEXT_ARM_R12    60
#define MCONTEXT_ARM_SP     64
#define MCONTEXT_ARM_LR     68
#define MCONTEXT_ARM_PC     72
#define MCONTEXT_ARM_CPSR   76

    .section .iwram, "ax", %progbits
    .align 2
    .arm
    .func   __agbabi_getcontext
    .global __agbabi_getcontext
    .type   __agbabi_getcontext STT_FUNC
__agbabi_getcontext:
    .fnstart
    @ Save r0
    str     r0, [r0, #MCONTEXT_ARM_R0]

    @ Save r1-r12
    add     r0, r0, #MCONTEXT_ARM_R1
    stmia   r0, {r1-r12, sp, lr}

    @ Load cpsr and pc
    mrs     r1, cpsr
    sub     r2, lr, #8

    @ Test lr for thumb flag
    tst     lr, #1
    orrne   r1, r1, #0x20   @ Mix with cpsr thumb flag
    addne   r2, r2, #4      @ Adjust thumb PC

    @ Save cpsr and pc
    str     r1, [r0, #(MCONTEXT_ARM_CPSR - MCONTEXT_ARM_R1)]
    str     r2, [r0, #(MCONTEXT_ARM_PC - MCONTEXT_ARM_R1)]

    @ Return 0 = success
    mov     r0, #0
.Lbx_lr:
    bx      lr
    .fnend
    .endfunc

    .section .iwram, "ax", %progbits
    .align 2
    .arm
    .func   __agbabi_setcontext
    .global __agbabi_setcontext
    .type   __agbabi_setcontext STT_FUNC
__agbabi_setcontext:
    .fnstart
    @ Disable IRQ
    mrs     r1, cpsr
    orr     r1, r1, #0x80
    msr     cpsr, r1

    @ Restore r2-r12, sp, lr
    add     r0, r0, #MCONTEXT_ARM_R2
    ldmia   r0, {r2-r12, sp, lr}

    @ Enter IRQ mode (IRQ still disabled)
    mov     r1, #0x92
    msr     cpsr, r1

    @ Restore cpsr into irq spsr
    ldr     r1, [r0, #(MCONTEXT_ARM_CPSR - MCONTEXT_ARM_R2)]
    msr     spsr, r1

    @ Restore pc into irq lr
    ldr     lr, [r0, #(MCONTEXT_ARM_PC - MCONTEXT_ARM_R2)]

    @ Restore r0-r1
    sub     r0, r0, #(MCONTEXT_ARM_R2 - MCONTEXT_ARM_R0)
    ldmia   r0, {r0-r1}

    @ pc = irq lr, cpsr = irq spsr
    movs    pc, lr
    .fnend
    .endfunc

    .section .iwram, "ax", %progbits
    .align 2
    .arm
    .func   __agbabi_swapcontext
    .global __agbabi_swapcontext
    .type   __agbabi_swapcontext STT_FUNC
__agbabi_swapcontext:
    .fnstart
    push    {r0-r1, lr}
    bl      __agbabi_getcontext
    pop     {r0-r1, lr}

    @ Return 0 = success
    mov     r2, #0
    str     r2, [r0, #MCONTEXT_ARM_R0]

    str     sp, [r0, #MCONTEXT_ARM_SP]
    str     lr, [r0, #MCONTEXT_ARM_LR]
    ldr     r2, =.Lbx_lr
    str     r2, [r0, #MCONTEXT_ARM_PC]

    mov     r0, r1
    b       __agbabi_setcontext
    .fnend
    .endfunc
