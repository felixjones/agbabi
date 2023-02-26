# POSIX Support Library

## Context switching

```c
#include <sys/ucontext.h>

void my_context_function();

static int ctx_stack[200] {};

int main() {
  ucontext_t link_ctx;
  
  ucontext_t ctx;
  ctx.uc_stack.ss_sp = ctx_stack;
  ctx.uc_stack.ss_size = sizeof(ctx_stack);
  ctx.uc_link = &link_ctx;
  
  makecontext(&ctx, my_context_function, 0);
  
  /* Do some stuff */
  
  swapcontext( &link_ctx, &ctx ); /* Swap from `link_ctx` to `ctx` */
  
  /* Continue doing stuff */
}

void my_context_function() {
  /* Do other stuff */
}
```

| Signature                                                             | Description                                                                                                                                                                                                               |
|:----------------------------------------------------------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `int getcontext(ucontext_t* ucp)`                                     | Copies the current machine context into `ucp`                                                                                                                                                                             |
| `int setcontext(const ucontext_t* ucp)`                               | Sets the current context to `ucp`                                                                                                                                                                                         |
| `int swapcontext(ucontext_t* oucp, const ucontext_t* ucp)`            | Writes current context into `oucp`, and switches to `ucp`                                                                                                                                                                 |
| `void makecontext(ucontext_t* ucp, void(*func)(void), int argc, ...)` | Modifies context `ucp` to invoke func with `setcontext`. Before invoking, the caller must allocate a new stack for this context and assign its address to `ucp->uc_stack`, and set a successor context to `ucp->uc_link`. |

`ucontext_t` is a structure with a pointer to the next context to return to (`uc_link`), the stack creation parameters (`stack_t`), and the opaque machine context (`uc_mcontext`).

```c
typedef struct ucontext_t {
    struct ucontext_t* uc_link;
    stack_t uc_stack;
    mcontext_t uc_mcontext;
} ucontext_t;
```

## Time functions

Requires RTC hardware, and for the RTC hardware to be first initialized with `__agbabi_rtc_init`.

```c
#include <agbabi.h>

#include <sys/time.h> /* `gettimeofday` `settimeofday` */
#include <time.h> /* C time API also available */

int main() {
    if (__agbabi_rtc_init() == 0) {
        /* RTC available for time related functions */
    }
}
```

| Signature                                                               | Description |
|:------------------------------------------------------------------------|:------------|
| `int gettimeofday(struct timeval* tv, void* tz)`                        |             |
| `int settimeofday(const struct timeval* tv, const struct timezone* tz)` |             |
