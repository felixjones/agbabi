project('agbabi', 'c',
  version: '2.0.0',
  license: 'Zlib',
  meson_version: '>=0.54.0',
  default_options: ['warning_level=2'])

sources_asm = [
  'source/atan2.s',
  'source/context.s',
  'source/coroutine.s',
  'source/fiq_memcpy.s',
  'source/frac.s',
  'source/idiv.s',
  'source/irq.s',
  'source/sqrt.s',
  'source/ldiv.s',
  'source/lmul.s',
  'source/memcpy.s',
  'source/memmove.s',
  'source/memset.s',
  'source/rmemcpy.s',
  'source/rtc.s',
  'source/sine.s',
  'source/uidiv.s',
  'source/uldiv.s',
  'source/uluidiv.s',
]

sources_c = [
  'source/coroutine.c',
  'source/frac.c',
  'source/makecontext.c',
  'source/rtc.c',
]

includes = ['include']

if get_option('use_devkitarm')
  add_project_arguments('-D__DEVKITARM__', language: 'c')
endif

agbabi_asm = static_library('agbabi-asm',
  sources_asm,
  include_directories: includes,
  c_args: ['-x', 'assembler-with-cpp'])

agbabi = static_library('agbabi',
  sources_c,
  include_directories: includes,
  c_args: ['-ffunction-sections', '-fdata-sections', '-Wno-unused-parameter'],
  link_with: agbabi_asm)

agbabi_dep = declare_dependency(
  include_directories: includes,
  link_with: agbabi)

meson.override_dependency('agbabi', agbabi_dep)
