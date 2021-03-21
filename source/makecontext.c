#include <stdarg.h>
#include <sys/ucontext.h>

#define REGISTER_ARGS   ( 4 )

void __agbabi_makecontext( struct ucontext_t *, void ( * )( void ), int, ... ) __attribute__((section(".text"))) __attribute__((target("thumb")));

static void __agbabi_popcontext() __attribute__((section(".iwram"))) __attribute__((target("arm")));

static __attribute__((naked)) void __agbabi_popcontext() {
    asm(
        "pop\t{r0}\r\n"
        "cmp\tr0, #0\r\n"
        ".extern\t__agbabi_setcontext\r\n"
        "bne\t__agbabi_setcontext\r\n"
        ".extern\t_exit\r\n"
        "ldr\tr1, =_exit\r\n"
        "bx\tr1"
    );
}

void __agbabi_makecontext( struct ucontext_t * ucp, void ( * func )( void ), int argc, ... ) {
    long unsigned int * funcstack = ( long unsigned int * ) ( ucp->uc_stack.ss_sp + ucp->uc_stack.ss_size );

    // Push link context onto stack
    funcstack -= 1;
    *funcstack = ( long unsigned int ) ucp->uc_link;

    if ( argc > REGISTER_ARGS ) {
        funcstack -= ( argc - REGISTER_ARGS );
    }

    ucp->uc_mcontext.arm_sp = ( long unsigned int ) funcstack;
    ucp->uc_mcontext.arm_lr = ( long unsigned int ) __agbabi_popcontext;
    ucp->uc_mcontext.arm_pc = ( long unsigned int ) func;
    ucp->uc_mcontext.arm_cpsr = ( ucp->uc_mcontext.arm_pc & 1 ? 0x3f : 0x1f );

    va_list vl;
    va_start( vl, argc );

    long unsigned int reg;
    long unsigned int * regptr = &ucp->uc_mcontext.arm_r0;

    for ( reg = 0; reg < argc && reg < REGISTER_ARGS; ++reg ) {
        *regptr++ = va_arg( vl, long unsigned int );
    }

    for ( ; reg < argc; ++reg ) {
        *funcstack++ = va_arg( vl, long unsigned int );
    }

    va_end( vl );
}
