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

    .section .iwram.__agbabi_getcontext, "ax", %progbits
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

    .section .iwram.__agbabi_setcontext, "ax", %progbits
    .align 2
    .arm
    .func   __agbabi_setcontext
    .global __agbabi_setcontext
    .type   __agbabi_setcontext STT_FUNC
__agbabi_setcontext:
    .fnstart
    @ Enter target mode (IRQ disabled, ARM mode forced)
    ldr     r2, [r0, #MCONTEXT_ARM_CPSR]
    orr     r1, r2, #0x80
    bic     r1, r1, #0x20
    msr     cpsr, r1

    @ Restore r3-r12
    add     r0, r0, #MCONTEXT_ARM_R3
    ldmia   r0, {r3-r12}

    @ Restore sp, lr
    ldr     sp, [r0, #(MCONTEXT_ARM_SP - MCONTEXT_ARM_R3)]
    ldr     lr, [r0, #(MCONTEXT_ARM_LR - MCONTEXT_ARM_R3)]

    @ Enter f_IRQ mode (IRQ still disabled)
    mov     r1, #0x91
    msr     cpsr, r1

    @ Restore cpsr into f_irq spsr
    msr     spsr, r2

    @ Restore pc into f_irq lr
    ldr     lr, [r0, #(MCONTEXT_ARM_PC - MCONTEXT_ARM_R3)]

    @ Restore r0-r2
    sub     r0, r0, #(MCONTEXT_ARM_R3 - MCONTEXT_ARM_R0)
    ldmia   r0, {r0-r2}

    @ pc = f_irq lr, cpsr = f_irq spsr
    movs    pc, lr
    .fnend
    .endfunc

    .section .iwram.__agbabi_swapcontext, "ax", %progbits
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
