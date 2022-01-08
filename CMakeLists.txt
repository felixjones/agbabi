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
)

target_include_directories(agbabi SYSTEM PUBLIC include/ include/sys/)
target_compile_options(agbabi PRIVATE
    $<$<COMPILE_LANGUAGE:ASM>:-x assembler-with-cpp>
    $<$<COMPILE_LANGUAGE:C>:-Wall -Wextra -ffunction-sections -fdata-sections -mcpu=arm7tdmi -mthumb>
)
