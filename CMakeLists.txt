#===============================================================================
#
# CMakeLists.txt for compiling agbabi
#
# Copyright (C) 2021-2022 agbabi contributors
# For conditions of distribution and use, see copyright notice in LICENSE.md
#
#===============================================================================

cmake_minimum_required(VERSION 3.0)

project(agbabi ASM C)

add_library(agbabi STATIC
    source/context.s
    source/idiv.s
    source/irq.s
    source/ldiv.s
    source/lmul.s
    source/memcpy.s
    source/memmove.s
    source/memset.s
    source/rmemcpy.s
    source/sine.s
    source/uidiv.s
    source/uldiv.s
    source/uluidiv.s

    source/makecontext.c
    source/multiboot.c
)

target_include_directories(agbabi SYSTEM PUBLIC include/ include/sys/)
target_compile_options(agbabi PRIVATE
    $<$<COMPILE_LANGUAGE:ASM>:-x assembler-with-cpp>
    $<$<COMPILE_LANGUAGE:C>:-mabi=aapcs -march=armv4t -mcpu=arm7tdmi -mthumb -ffunction-sections -fdata-sections -Wall -Wextra -Wno-unused-parameter>
)
