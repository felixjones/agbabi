@--------------------------------------------------------------------------------
@ irqcontext.s
@--------------------------------------------------------------------------------
@ IRQ handler capable of context switching
@ Ideally for implementing a thread switcher
@ __agbabi_irq_ucontext | Executes a provided function in user mode (__agbabi_irq_uproc)
@ __agbabi_irq_uproc must have the signature:
@ const ucontext_t *( const ucontext_t * inContext, short flags )
@ The returned context is the next context to be run
@--------------------------------------------------------------------------------

#define REG_BIOSIF  0x3FFFFF8
#define REG_BASE    0x4000000
#define REG_IE_IF   0x4000200
#define REG_IF      0x4000202
#define REG_IME     0x4000208

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

#define UCONTEXT_SIZEOF ( MCONTEXT_ARM_CPSR + 4 )

    .section .iwram.__agbabi_irq_ucontext,"ax",%progbits
    .align 2
    .arm
    .func   __agbabi_irq_ucontext
    .global __agbabi_irq_ucontext
    .type __agbabi_irq_ucontext STT_FUNC
__agbabi_irq_ucontext:
    .fnstart
    @ Save cpsr
    mrs     r0, cpsr

    @ Enter target mode (IRQ disabled, ARM mode forced)
    mrs     r2, spsr
    orr     r1, r2, #0x80
    bic     r1, r1, #0x20
    msr     cpsr, r1

    @ Store target sp
    mov     r1, sp

    msr     cpsr, r0

    @ Point r0 to original stack
    mov     r0, sp
    sub     sp, sp, #UCONTEXT_SIZEOF

    @ Store target sp
    str     r1, [sp, #MCONTEXT_ARM_SP]

    @ Store cpsr
    str     r2, [sp, #MCONTEXT_ARM_CPSR]

    @ Retrieve & store lr from stack (use as pc)
    ldr     r1, [r0, #(4 * 5)]
    @ -4 from lr because BIOS IRQ does that
    sub     r1, r1, #4
    str     r1, [sp, #MCONTEXT_ARM_PC]

    @ Retrieve r0-r2 from stack
    ldmia   r0, {r0-r2}

    @ Store r0-r12
    add     sp, sp, #MCONTEXT_ARM_R0
    stmia   sp, {r0-r12}
    sub     sp, sp, #MCONTEXT_ARM_R0

    @ Store pointer to irq's ucontext_t
    mov     r0, sp

    @ Normal uproc IRQ
    mov     r2, #REG_BASE

    ldr     r1, [r2, #(REG_IE_IF - REG_BASE)]!
    and     r1, r1, r1, lsr #16

    ldr     r3, [r2, #(REG_BIOSIF - REG_IE_IF)]
    orr     r3, r3, r1

    strh    r1, [r2, #(REG_IF - REG_IE_IF)]
    str     r3, [r2, #(REG_BIOSIF - REG_IE_IF)]

    ldrh    r3, [r2]
    bic     r3, r3, r1
    strh    r3, [r2]

    mov     r3, #0
    str     r3, [r2, #(REG_IME - REG_IE_IF)]

    mrs     r3, cpsr
    bic     r3, r3, #0xdf
    orr     r3, r3, #0x1f
    msr     cpsr, r3

    .weak   __agbabi_irq_uproc
    ldr     r3, =__agbabi_irq_uproc
    ldr     r3, [r3]

    push    { r1-r2, r4-r11, lr }

    mov     lr, pc
    bx      r3

    pop     { r1-r2, r4-r11, lr }

    @ r0 points to next ucontext_t

    mov     r3, #0
    str     r3, [r2, #(REG_IME - REG_IE_IF)]

    mrs     r3, cpsr
    bic     r3, r3, #0xdf
    orr     r3, r3, #0x92
    msr     cpsr, r3

    @ BIOS IRQ stack pop
    add     sp, sp, #(UCONTEXT_SIZEOF + 4 * 6)

    ldrh    r3, [r2]
    orr     r3, r3, r1
    strh    r3, [r2]

    @ Set r0 context

    @ Restore r4-r12
    add     r0, r0, #MCONTEXT_ARM_R4
    ldmia   r0, {r4-r12}

    @ Enter target mode (IRQ still disabled, ARM mode forced)
    ldr     r3, [r0, #(MCONTEXT_ARM_CPSR - MCONTEXT_ARM_R4)]
    orr     r1, r3, #0x80
    bic     r1, r1, #0x20
    msr     cpsr, r1

    @ Re-enable reg_ime
    mov     r1, #1
    str     r1, [r2, #(REG_IME - REG_IE_IF)]

    ldr     sp, [r0, #(MCONTEXT_ARM_SP - MCONTEXT_ARM_R4)]
    ldr     lr, [r0, #(MCONTEXT_ARM_LR - MCONTEXT_ARM_R4)]

    @ Enter f_IRQ mode (IRQ still disabled)
    mov     r1, #0x91
    msr     cpsr, r1

    @ Restore cpsr into f_irq spsr
    msr     spsr, r3

    @ Restore pc into f_irq lr
    ldr     lr, [r0, #(MCONTEXT_ARM_PC - MCONTEXT_ARM_R4)]

    @ Restore r0-r3
    sub     r0, r0, #(MCONTEXT_ARM_R4 - MCONTEXT_ARM_R0)
    ldmia   r0, {r0-r3}

    movs    pc, lr
