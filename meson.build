#===============================================================================
#
# meson.build for compiling agbabi
#
# Copyright (C) 2021-2023 agbabi contributors
# For conditions of distribution and use, see copyright notice in LICENSE.md
#
#===============================================================================

project('agbabi', 'c',
  version: '2.1.6',
  license: 'Zlib',
  meson_version: '>=0.56.2',
  default_options: [
    'buildtype=release',
    'warning_level=3',
    'c_std=c11',
  ])

sources_asm = [
  'source/context.s',
  'source/coroutine.s',
  'source/fiq_memcpy.s',
  'source/idiv.s',
  'source/irq.s',
  'source/ldiv.s',
  'source/lmul.s',
  'source/memcpy.s',
  'source/memmove.s',
  'source/memset.s',
  'source/rmemcpy.s',
  'source/sine.s',
  'source/sqrt.s',
  'source/uidiv.s',
  'source/uldiv.s',
  'source/uluidiv.s',
]

sources_c_arm = [
  'source/atan2.c',
]

sources_c_thumb = [
  'source/context.c',
  'source/coroutine.c',
  'source/ewram.c',
  'source/multiboot.c',
  'source/rtc.c',
]

includes = ['include']

c_args = [
  '-masm-syntax-unified',
  '-fomit-frame-pointer',
  '-ffunction-sections',
  '-fdata-sections',
]
if get_option('warning_level') == '3'
  c_args += '-Wconversion'
  c_args += '-Wstrict-prototypes'
endif

agbabi_asm = static_library('agbabi-asm',
  sources_asm,
  c_args: ['-masm-syntax-unified', '-Wa,-I' + meson.current_source_dir() + '/source'])

agbabi_arm = static_library('agbabi-arm',
  sources_c_arm,
  include_directories: includes,
  c_args: ['-marm'] + c_args)

agbabi_thumb = static_library('agbabi-thumb',
  sources_c_thumb,
  include_directories: includes,
  c_args: ['-mthumb'] + c_args)

agbabi = static_library('agbabi',
  objects: [
    agbabi_asm.extract_all_objects(recursive: false),
    agbabi_arm.extract_all_objects(recursive: false),
    agbabi_thumb.extract_all_objects(recursive: false)
  ])

agbabi_dep = declare_dependency(
  include_directories: includes,
  link_with: agbabi,
  version: meson.project_version())

meson.override_dependency('agbabi', agbabi_dep)
