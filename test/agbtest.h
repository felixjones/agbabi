#include <malloc.h>
#include <stddef.h>

extern void posprintf(char *, const char *, ...);

typedef void (*agbtest_fun)(char* agbtest_output, int* agbtest_result);
typedef void (*agbtest_callback_fun)(const char* name, int failed, const char* message);

struct agbtest_test {
    const char* name;
    agbtest_fun func;
};

struct agbtest_state {
    size_t num_tests;
    struct agbtest_test* tests;
    agbtest_callback_fun callback;
};

#define AGBTEST_CTOR(F)  \
  static void F(void) __attribute__((constructor)); \
  static void F(void)

#define AGBTEST(SET, NAME) \
    extern struct agbtest_state agbtest_set_##SET; \
    static void agbtest_run_##SET##_##NAME(char* agbtest_output, int* agbtest_result); \
    AGBTEST_CTOR(agbtest_add_##SET##_##NAME) { \
        const size_t idx = agbtest_set_##SET.num_tests++; \
        agbtest_set_##SET.tests = (struct agbtest_test*) realloc(agbtest_set_##SET.tests, sizeof(struct agbtest_test) * agbtest_set_##SET.num_tests); \
        agbtest_set_##SET.tests[idx].name = #SET ":" #NAME; \
        agbtest_set_##SET.tests[idx].func = &agbtest_run_##SET##_##NAME; \
    } \
    void agbtest_run_##SET##_##NAME(char* agbtest_output, int* agbtest_result)

#define AGBTEST_SET(SET, CALLBACK) struct agbtest_state agbtest_set_##SET = {0, NULL, CALLBACK}

static inline void agbtest_run(const struct agbtest_state* set) {
    char message[80];
    for (size_t i = 0; i < set->num_tests; ++i) {
        int result = 0;
        set->tests[i].func(message, &result);
        set->callback(set->tests[i].name, result, message);
    }
}

#define AGBTEST_RUN(SET) agbtest_run(&agbtest_set_##SET)

#define ASSERT_FAIL do {(*agbtest_result) = 1; return;} while(0)

#define ASSERT_MEMCMP(BUF, TYPE, ...) \
    do { \
        static const TYPE TMP[] = {__VA_ARGS__}; \
        const char* tmp = (const char*) TMP; \
        const char* buf = (const char*) BUF; \
        for (size_t i = 0; i < sizeof(TMP); ++i) { \
            if (buf[i] != tmp[i]) { \
                posprintf(agbtest_output, "Byte %d expected 0x%02x got 0x%02x", i, tmp[i], buf[i]); \
                ASSERT_FAIL; \
                break; \
            } \
        } \
    } while(0)

#define ASSERT_EQUAL(A, B) \
    do { \
        posprintf(agbtest_output, "Expected %d == %d", A, B); \
        if ((A) != (B)) ASSERT_FAIL; \
    } while (0)
