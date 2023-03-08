cmake_minimum_required(VERSION 3.18)

project(agbabi_test ASM C)

# Use local agbabi
add_subdirectory(.. ${CMAKE_BINARY_DIR}/lib/agbabi)

find_package(librom)
find_package(tonclib)
find_package(posprintf)

add_executable(agbabi_test main.c
    test_memcpy.c
    test_memset.c
)
target_compile_options(agbabi_test PRIVATE -mthumb -Wpedantic -Wall -Wextra -Wconversion)
target_link_libraries(agbabi_test PRIVATE librom agbabi tonclib posprintf)

set_target_properties(agbabi_test PROPERTIES
    ROM_TITLE "AGBABI test"
    ROM_ID AATE
    ROM_MAKER FJ
    ROM_VERSION 1
)

install_rom(agbabi_test)
