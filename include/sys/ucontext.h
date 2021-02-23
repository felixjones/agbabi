#ifndef _AGBABI_SYS_UCONTEXT_H_
#define _AGBABI_SYS_UCONTEXT_H_

#if defined( __cplusplus )
extern "C" {
#endif

#include <stddef.h>

typedef struct {
    void * ss_sp;
    size_t ss_size;
} stack_t;

typedef struct {
    unsigned long int arm_r0;
    unsigned long int arm_r1;
    unsigned long int arm_r2;
    unsigned long int arm_r3;
    unsigned long int arm_r4;
    unsigned long int arm_r5;
    unsigned long int arm_r6;
    unsigned long int arm_r7;
    unsigned long int arm_r8;
    unsigned long int arm_r9;
    unsigned long int arm_r10;
    unsigned long int arm_r11;
    unsigned long int arm_r12;
    unsigned long int arm_sp;
    unsigned long int arm_lr;
    unsigned long int arm_pc;
    unsigned long int arm_cpsr;
} mcontext_t;

typedef struct ucontext_t {
    struct ucontext_t * uc_link;
    stack_t uc_stack;
    mcontext_t uc_mcontext;
} ucontext_t;

#if defined( __cplusplus )
} // extern "C"
#endif

#endif // define _AGBABI_SYS_UCONTEXT_H_
