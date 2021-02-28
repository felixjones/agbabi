cmake_minimum_required(VERSION 3.0)

project(agbabi C ASM)

add_library(agbabi STATIC
    source/context.s
    source/irq.s
    source/idiv.s
    source/irqcontext.s
    source/makecontext.c
    source/mat_mult.c
    source/memmove.c
    source/memcpy.s
    source/memset.s
    source/rmemcpy.s
    source/sine.s
    source/uidiv.s
    source/vmem.s
)
target_include_directories(agbabi SYSTEM PUBLIC "include/")

set(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -marm -x assembler-with-cpp")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -marm -Wall -fno-strict-aliasing")
