#include <aeabi.h>

#include "agbtest.h"

static void fill_ascii_buffer(void* buf, size_t len, char base);

#define MEMCPY_TEST(TYPE, OFFSRC, OFFDST, ...) \
    AGBTEST(memcpy, TYPE##_offset_##OFFSRC##_##OFFDST) { \
        static const size_t len = 8; \
        char dest[len]; \
        fill_ascii_buffer(dest, len, 'a'); \
        char src[len]; \
        fill_ascii_buffer(src, len, 'A'); \
        __aeabi_memcpy(&dest[OFFSRC], &src[OFFDST], sizeof(TYPE)); \
        ASSERT_MEMCMP(dest, char, __VA_ARGS__); \
    }

MEMCPY_TEST(char, 0, 0, 'A', 'b', 'c', 'd')
MEMCPY_TEST(char, 0, 1, 'B', 'b', 'c', 'd')
MEMCPY_TEST(char, 1, 0, 'a', 'A', 'c', 'd')
MEMCPY_TEST(char, 1, 1, 'a', 'B', 'c', 'd')

MEMCPY_TEST(short, 0, 0, 'A', 'B', 'c', 'd')
MEMCPY_TEST(short, 0, 1, 'B', 'C', 'c', 'd')
MEMCPY_TEST(short, 1, 0, 'a', 'A', 'B', 'd')
MEMCPY_TEST(short, 1, 1, 'a', 'B', 'C', 'd')
MEMCPY_TEST(short, 0, 2, 'C', 'D', 'c', 'd')
MEMCPY_TEST(short, 2, 0, 'a', 'b', 'A', 'B')

MEMCPY_TEST(int, 0, 0, 'A', 'B', 'C', 'D', 'e', 'f', 'g', 'h')
MEMCPY_TEST(int, 0, 1, 'B', 'C', 'D', 'E', 'e', 'f', 'g', 'h')
MEMCPY_TEST(int, 1, 0, 'a', 'A', 'B', 'C', 'D', 'f', 'g', 'h')
MEMCPY_TEST(int, 1, 1, 'a', 'B', 'C', 'D', 'E', 'f', 'g', 'h')
MEMCPY_TEST(int, 0, 2, 'C', 'D', 'E', 'F', 'e', 'f', 'g', 'h')
MEMCPY_TEST(int, 2, 0, 'a', 'b', 'A', 'B', 'C', 'D', 'g', 'h')
MEMCPY_TEST(int, 0, 3, 'D', 'E', 'F', 'G', 'e', 'f', 'g', 'h')
MEMCPY_TEST(int, 3, 0, 'a', 'b', 'c', 'A', 'B', 'C', 'D', 'h')
MEMCPY_TEST(int, 1, 3, 'a', 'D', 'E', 'F', 'G', 'f', 'g', 'h')
MEMCPY_TEST(int, 3, 1, 'a', 'b', 'c', 'B', 'C', 'D', 'E', 'h')

AGBTEST(memcpy, struct) {
    struct test_struct {
        unsigned short a;
        char b[8];
        char c : 7;
        char d : 1;
    };

    struct test_struct dest = {0xcdcdu, {0xcd, 0xcd, 0xcd, 0xcd, 0xcd, 0xcd, 0xcd, 0xcd}, 0x4d, 1};

    char src[8];
    fill_ascii_buffer(src, 8, 'a');

    __aeabi_memcpy(&dest.b[0], src, 7);
    ASSERT_EQUAL(dest.a, 0xcdcd);
    ASSERT_MEMCMP(&dest.b[0], char, 'a', 'b', 'c', 'd', 'e', 'f', 'g');
    ASSERT_EQUAL(dest.b[7], 0xcd);
    ASSERT_EQUAL(dest.c, 0x4d);
    ASSERT_EQUAL(dest.d, 1);
}

void fill_ascii_buffer(void* buf, size_t len, char base) {
    char* b = (char*) buf;
    for (size_t i = 0; i < len; ++i) {
        b[i] = (char) (base + (i % 26));
    }
}
