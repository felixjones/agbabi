#===============================================================================
#
# CMakeLists.txt for compiling agbabi
#
# Copyright (C) 2021-2023 agbabi contributors
# For conditions of distribution and use, see copyright notice in LICENSE.md
#
#===============================================================================

cmake_minimum_required(VERSION 3.18)

project(agbabi ASM C)

add_library(agbabi STATIC
    source/atan2.c
    source/context.c
    source/coroutine.c
    source/multiboot.c
    source/rtc.c

    source/context.s
    source/coroutine.s
    source/fiq_memcpy.s
    source/idiv.s
    source/irq.s
    source/ldiv.s
    source/lmul.s
    source/memcpy.s
    source/memmove.s
    source/memset.s
    source/rmemcpy.s
    source/sine.s
    source/sqrt.s
    source/uidiv.s
    source/uldiv.s
    source/uluidiv.s
)

set_source_files_properties(source/atan2.c PROPERTIES COMPILE_FLAGS "-marm")

target_include_directories(agbabi PUBLIC include)
target_compile_options(agbabi PRIVATE
    $<$<COMPILE_LANGUAGE:ASM>:
        "-Wa,-I${CMAKE_CURRENT_LIST_DIR}/source"
    >
    $<$<COMPILE_LANGUAGE:C>: -mthumb -O2
        -fomit-frame-pointer
        -ffunction-sections
        -fdata-sections
        -Wall
        -Wextra
        -Wpedantic
        -Wconversion
    >
)

install(TARGETS agbabi
    LIBRARY DESTINATION lib
)
install(DIRECTORY include/
    DESTINATION include
)
