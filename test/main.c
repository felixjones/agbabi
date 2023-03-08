#include <tonc.h>
#include <agbabi.h>
#include <aeabi.h>

#include "agbtest.h"

static void test_callback(const char* name, int result, const char* message);

AGBTEST_SET(memcpy, test_callback);
AGBTEST_SET(memset, test_callback);

int main(void) {
    irq_init(NULL);
    irq_add(II_VBLANK, NULL);
    REG_DISPCNT = DCNT_MODE0 | DCNT_BG0;
    REG_BG0HOFS = 248;
    REG_BG0VOFS = 248;

    tte_init_se(0, BG_CBB(0) | BG_SBB(31), 0, CLR_YELLOW, 14, NULL, NULL);

    pal_bg_bank[1][15] = CLR_RED;
    pal_bg_bank[2][15] = CLR_GREEN;
    pal_bg_bank[3][15] = CLR_BLUE;
    pal_bg_bank[4][15] = CLR_WHITE;
    pal_bg_bank[5][15] = CLR_MAG;

    tte_erase_screen();

    tte_write("memcpy ");
    AGBTEST_RUN(memcpy);
    tte_write("\n");

    tte_write("memset ");
    AGBTEST_RUN(memset);
    tte_write("\n");

    key_wait_till_hit(KEY_ANY);
}

void test_callback(const char* name, int failed, const char* message) {
    if (failed) {
        tte_write("X\n");
        tte_write(name);
        tte_write("\n");
        tte_write(message);
    } else {
        tte_write("O");
    }
}
