# Copyright (c) Matthew Rodusek
# Distributed under the OSI-approved MIT License. See accompanying
# file LICENSE.txt or https://opensource.org/licenses/MIT for details.

#.rst:
# ClangFormat
# -----------
#
# clang-format support in CMake
#
# This module defines the following variables:
#
#   ``CLANG_FORMAT_EXECUTABLE`` 
#     Path to the ``clang-format`` executable, or ``NOTFOUND`` if it cannot 
#     be found.

set(__FIND_ROOT_PATH_MODE_PROGRAM ${CMAKE_FIND_ROOT_PATH_MODE_PROGRAM})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

find_program(CLANG_FORMAT_EXECUTABLE clang-format QUIET)
mark_as_advanced(CLANG_FORMAT_EXECUTABLE)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ${__FIND_ROOT_PATH_MODE_PROGRAM})
set(__FIND_ROOT_PATH_MODE_PROGRAM)

if (CMAKE_VERSION VERSION_LESS 3.5.0)
  include(CMakeParseArguments)
endif ()

#.rst:
# .. command:: add_clang_format_target
#
# This command sets the clang-format language and arguments globally for all
# targets defined after the invocation at any directory scope deeper than
# the current setting
#
# .. code-block:: cmake
#
#   add_clang_format_target(
#     <name>
#     [INPLACE] 
#     [VERBOSE]
#     [STYLE <style>]
#     [TARGETS <target>...]
#     [SOURCES <source>...]
#     [CLANG_FORMAT_ARGS <arg>...]
#   )
#
# Adds a target with the name ``<name>`` that runs ``clang-format`` on the
# input. The options are:
# 
#   ``INPLACE``
#     Makes the edits to the sources in-place
#
#   ``VEROSE`` 
#     Verbosely logs the changes being made (translates to -verbose flag)
#
#   ``STYLE``
#     The clang-format style (translates to -style flag). Defaults to 
#     ``-style=file`` to read the file from disk.
#
#   ``TARGETS``
#     Target(s) to base the ``clang-format`` args on. Any ``<target>`` will 
#     have its sources used for the ``clang-format`` target
#
#   ``SOURCES``
#     Source files to build
#
#   ``CLANG_FORMAT_ARGS``
#     Arguments to forward directly to ``clang-format``
function(add_clang_format_target target)
  if (NOT CLANG_FORMAT_EXECUTABLE)
    message(FATAL_ERROR "add_clang_format_target: clang-format not found.")
  endif ()

  cmake_parse_arguments(
    CLANG_FORMAT      # Prefix
    "INPLACE;VERBOSE" # Option-args
    "STYLE"           # Single-args
    "SOURCES;TARGETS;CLANG_FORMAT_ARGS" # Multi-args
    ${ARGN}
  )

  set(sources)
  foreach (source_target IN LISTS CLANG_FORMAT_TARGETS)
    list(APPEND sources "$<TARGET_PROPERTY:${source_target},SOURCES>")
  endforeach ()
  foreach (source IN LISTS CLANG_FORMAT_SOURCES)
    list(APPEND sources "${source}")
  endforeach ()

  if (NOT sources)
    message(FATAL_ERROR "add_clang_format_target: No sources specified")
  endforeach ()

  if (CLANG_FORMAT_STYLE)
    set(style_arg "-style=${CLANG_FORMAT_STYLE}")
  else ()
    set(style_arg "-style=file")
  endif ()

  set(inplace_arg)
  if (CLANG_FORMAT_INPLACE)
    set(inplace_arg "-i")
  endif ()
  
  set(verbose_arg)
  if (CLANG_FORMAT_VERBOSE)
    set(verbose_arg "-verbose")
  endif ()

  add_custom_target(
    "${target}"
    COMMAND "${CLANG_FORMAT_EXECUTABLE}"
      ${style_arg}
      ${inplace_arg}
      ${verbose_arg}
      ${CLANG_FORMAT_CLANG_FORMAT_ARGS}
      ${sources}
  )

  # Add dependencies to each target
  foreach (source_target IN LISTS CLANG_FORMAT_TARGETS)
    add_dependencies("${target}" ${source_target})
  endforeach ()

endfunction()
