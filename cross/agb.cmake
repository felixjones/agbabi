#===============================================================================
#
# agb.cmake for CMake cross compiling
#
# Copyright (C) 2021-2023 agbabi contributors
# For conditions of distribution and use, see copyright notice in LICENSE.md
#
#===============================================================================

set(CMAKE_SYSTEM_NAME Generic CACHE INTERNAL "")
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY CACHE INTERNAL "")

find_program(CMAKE_C_COMPILER arm-none-eabi-gcc)
set(CMAKE_ASM_COMPILER "${CMAKE_C_COMPILER}" CACHE INTERNAL "")

set(CMAKE_C_COMPILER_TARGET arm-none-eabi CACHE INTERNAL "")
set(CMAKE_ASM_COMPILER_TARGET "${CMAKE_C_COMPILER_TARGET}" CACHE INTERNAL "")
