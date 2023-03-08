#include <aeabi.h>

#include "agbtest.h"

static void fill_ascii_buffer(void* buf, size_t len, char base);

AGBTEST(memset, byte) {
    unsigned char b = 0xff;
    __aeabi_memset(&b, 1, 0xcd);
    ASSERT_EQUAL(b, 0xcd);
}

AGBTEST(memset, short) {
    unsigned short b = 0xffff;
    __aeabi_memset(&b, 2, 0xcd);
    ASSERT_EQUAL(b, 0xcdcd);
}

AGBTEST(memset, int) {
    unsigned int b = 0xffffffff;
    __aeabi_memset(&b, 4, 0xcd);
    ASSERT_EQUAL(b, 0xcdcdcdcd);
}

AGBTEST(memset, int64) {
    unsigned long long b = 0xffffffffffffffffULL;
    __aeabi_memset(&b, 8, 0xcd);
    ASSERT_EQUAL(b, 0xcdcdcdcdcdcdcdcdULL);
}

AGBTEST(memset, offset_1) {
    char b[8];
    fill_ascii_buffer(b, 8, 'a');

    __aeabi_memset(&b[1], 4, '?');
    ASSERT_MEMCMP(b, char, 'a', '?', '?', '?', '?', 'f', 'g', 'h');
}

AGBTEST(memset, offset_2) {
    char b[8];
    fill_ascii_buffer(b, 8, 'a');

    __aeabi_memset(&b[2], 4, '?');
    ASSERT_MEMCMP(b, char, 'a', 'b', '?', '?', '?', '?', 'g', 'h');
}

AGBTEST(memset, offset_3) {
    char b[8];
    fill_ascii_buffer(b, 8, 'a');

    __aeabi_memset(&b[3], 4, '?');
    ASSERT_MEMCMP(b, char, 'a', 'b', 'c', '?', '?', '?', '?', 'h');
}

AGBTEST(memset, big_offset_1) {
    char b[26];
    fill_ascii_buffer(b, 26, 'a');

    __aeabi_memset(&b[1], 16, '?');
    ASSERT_MEMCMP(b, char, 'a',
                  '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?',
                  'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z');
}

AGBTEST(memset, big_offset_2) {
    char b[26];
    fill_ascii_buffer(b, 26, 'a');

    __aeabi_memset(&b[2], 16, '?');
    ASSERT_MEMCMP(b, char, 'a', 'b',
                  '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?',
                  's', 't', 'u', 'v', 'w', 'x', 'y', 'z');
}

AGBTEST(memset, big_offset_3) {
    char b[26];
    fill_ascii_buffer(b, 26, 'a');

    __aeabi_memset(&b[3], 16, '?');
    ASSERT_MEMCMP(b, char, 'a', 'b', 'c',
                  '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?', '?',
                  't', 'u', 'v', 'w', 'x', 'y', 'z');
}

void fill_ascii_buffer(void* buf, size_t len, char base) {
    char* b = (char*) buf;
    for (size_t i = 0; i < len; ++i) {
        b[i] = (char) (base + (i % 26));
    }
}
