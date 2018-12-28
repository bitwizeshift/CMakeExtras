# Copyright (c) Matthew Rodusek
# Distributed under the OSI-approved MIT License. See accompanying
# file LICENSE.txt or https://opensource.org/licenses/MIT for details.

#.rst:
# IncludeWhatYouUse
# -----------------
#
# ``include-what-you-use`` support in CMake
#
# This module only works for CMake versions 3.5 or above, due to a few
# CMake limitations. In 3.5, only the ``add_iwyu_target`` work, 
# whereas anything above 3.5 can support the ``enable_iwyu`` commands
# in addition to the ``add_iwyu_target``. 
# This limitation is a result of the ``CMAKE_EXPORT_COMPILE_COMMANDS`` not 
# being present prior to this.
#
# This module defines the following variables:
#
#   ``INCLUDE_WHAT_YOU_USE_EXECUTABLE`` 
#     Path to the ``include-what-you-use`` executable, or 
#     ``NOTFOUND`` if it cannot be found

set(__FIND_ROOT_PATH_MODE_PROGRAM ${CMAKE_FIND_ROOT_PATH_MODE_PROGRAM})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

find_program(INCLUDE_WHAT_YOU_USE_EXECUTABLE include-what-you-use QUIET)
mark_as_advanced(INCLUDE_WHAT_YOU_USE_EXECUTABLE)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ${__FIND_ROOT_PATH_MODE_PROGRAM})
set(__FIND_ROOT_PATH_MODE_PROGRAM)

# Only added in 3.5.0
if (CMAKE_VERSION VERSION_LESS 3.3.0)
  message(FATAL_ERROR 
    "IncludeWhatYouUse: Minimum cmake version 3.3 not satisfied" 
    "(CMake ${CMAKE_VERSION})"
  )  
endif ()
set(CMAKE_EXPORT_COMPILE_COMMANDS True CACHE INTERNAL "")

if (CMAKE_VERSION VERSION_LESS 3.5.0)
  include(CMakeParseArguments)
endif ()

#.rst:
# .. command:: add_iwyu_target
#
# This command sets the include-what-you-use language and arguments globally for all
# targets defined after the invocation at any directory scope deeper than
# the current setting
#
# .. code-block:: cmake
#
#   add_iwyu_target(<name>
#                         [TARGETS <target>...]
#                         [SOURCES <source>...]
#                         [INCLUDE_WHAT_YOU_USE_ARGS <arg>...])
# 
# Creates a new ``include-what-you-use`` target with the name ``<name>``.
# The options are:
#
#   ``TARGETS``
#     Target(s) to base the ``include-what-you-use`` args on. Any ``<target>``
#     will have its sources used for the ``include-what-you-use`` target
#
#   ``SOURCES``
#     Source files to build
#
#   ``INCLUDE_WHAT_YOU_USE_ARGS``
#     Arguments to forward directly to ``include-what-you-use``
function(add_iwyu_target target)
  if (NOT INCLUDE_WHAT_YOU_USE_EXECUTABLE)
    message(FATAL_ERROR "add_iwyu_target: include-what-you-use not found.")
  endif ()

  cmake_parse_arguments(
    INCLUDE_WHAT_YOU_USE # Prefix
    ""         # Option-args
    ""         # Single-args
    "SOURCES;TARGETS;IWYU_ARGS" # Multi-args
    ${ARGN}
  )

  set(sources)
  foreach (source_target IN LISTS INCLUDE_WHAT_YOU_USE_TARGETS)
    list(APPEND sources $<TARGET_PROPERTY:${source_target},SOURCES>)
  endforeach ()
  foreach (source IN LISTS INCLUDE_WHAT_YOU_USE_SOURCES)
    list(APPEND sources "${source}")
  endforeach ()

  if (NOT sources)
    message(FATAL_ERROR "add_iwyu_target: No sources specified")
  endforeach ()

  add_custom_target(
    "${target}"
    COMMAND "${INCLUDE_WHAT_YOU_USE_EXECUTABLE}"
      ${sources}
      ${INCLUDE_WHAT_YOU_USE_IWYU_ARGS}
    COMMENT "Executing include-what-you-use"
  )

  # Add dependencies to each target
  foreach (source_target IN LISTS INCLUDE_WHAT_YOU_USE_TARGETS)
    add_dependencies("${target}" ${source_target})
  endforeach ()

endfunction()

#.rst:
# .. command:: enable_iwyu
#
# This command sets the include-what-you-use language and arguments globally for all
# targets defined after the invocation at any directory scope deeper than
# the current setting.
#
# Note: This command only works on CMake 3.6 or greater. If used on a 
#       cmake version less than 3.6, FATAL_ERROR is emitted.
#
# .. code-block:: cmake
#
#   enable_iwyu([REQUIRED]
#                     [LANGUAGES <language>...]
#                     [INCLUDE_WHAT_YOU_USE_ARGS <arg>...])
# 
# The options are:
#
#   ``REQUIRED``
#     Creates a hard-error if include-what-you-use is not found
#
#   ``LANGUAGES``
#     Languages to support (C,CXX)
#
#   ``INCLUDE_WHAT_YOU_USE_ARGS`` 
#     Arguments to forward directly to include-what-you-use
function(enable_iwyu)
  if (NOT CMAKE_VERSION VERSION_GREATER 3.3)
    message(FATAL_ERROR "enable_iwyu: built-in include-what-you-use support only available in CMake 3.5 or above")
  endif ()

  cmake_parse_arguments(
    INCLUDE_WHAT_YOU_USE   # Prefix
    "REQUIRED"             # Option-args
    ""                     # Single-args
    "LANGUAGES;IWYU_ARGS"  # Multi-args
    ${ARGN}
  )

  if (INCLUDE_WHAT_YOU_USE_REQUIRED AND NOT INCLUDE_WHAT_YOU_USE_EXECUTABLE)
    message(FATAL_ERROR "enable_iwyu REQUIRED: include-what-you-use program not found")
  elseif (NOT INCLUDE_WHAT_YOU_USE_EXECUTABLE)
    return()
  endif ()

  if (NOT INCLUDE_WHAT_YOU_USE_LANGUAGES)
    set(INCLUDE_WHAT_YOU_USE_LANGUAGES CXX) # default to C++ support
  endif ()

  foreach (lang IN LISTS INCLUDE_WHAT_YOU_USE_LANGUAGES)
    set(CMAKE_${lang}_INCLUDE_WHAT_YOU_USE "${INCLUDE_WHAT_YOU_USE_EXECUTABLE};${INCLUDE_WHAT_YOU_USE_IWYU_ARGS}")
  endforeach ()

  set(CMAKE_INCLUDE_WHAT_YOU_USE_ENABLED True CACHE INTERNAL "")
endfunction()

#.rst
# .. command:: target_enable_iwyu
#
# This command sets the include-what-you-use language and arguments locally for the
# specified target
#
# Note: This command only works on CMake 3.6 or greater. If used on a 
#       cmake version less than 3.6, FATAL_ERROR is emitted.
#
# .. code-block:: cmake
#
#   enable_iwyu(<target>
#                     [REQUIRED]
#                     [LANGUAGES <language>...]
#                     [ARGS <arg>...])
# 
# Enables ``include-what-you-use`` for the specified ``<target>``.
# The options are:
#
#   ``REQUIRED``
#     Creates a hard-error if include-what-you-use is not found
#
#   ``LANGUAGES``
#     Languages to support (C,CXX)
#
#   ``IWYU_ARGS`` 
#     Arguments to forward directly to include-what-you-use
function(target_enable_iwyu target)
  if (NOT CMAKE_VERSION VERSION_GREATER 3.3)
    message(FATAL_ERROR "enable_iwyu: built-in include-what-you-use support only available in CMake 3.5 or above")
  endif ()

  cmake_parse_arguments(
    INCLUDE_WHAT_YOU_USE   # Prefix 
    "REQUIRED"             # Option-args
    ""                     # Single-args
    "LANGUAGES;IWYU_ARGS"  # Multi-args
    ${ARGN}
  )

  if (INCLUDE_WHAT_YOU_USE_REQUIRED AND NOT INCLUDE_WHAT_YOU_USE_EXECUTABLE)
    message(FATAL_ERROR "enable_iwyu REQUIRED: include-what-you-use program not found")
  elseif (NOT INCLUDE_WHAT_YOU_USE_EXECUTABLE)
    return()
  endif ()

  if (NOT INCLUDE_WHAT_YOU_USE_LANGUAGES)
    set(INCLUDE_WHAT_YOU_USE_LANGUAGES CXX) # default to C++ support
  endif ()

  foreach (lang IN LISTS INCLUDE_WHAT_YOU_USE_LANGUAGES )
    set_target_properties(
      ${target} 
      PROPERTY ${lang}_INCLUDE_WHAT_YOU_USE 
      "${INCLUDE_WHAT_YOU_USE_EXECUTABLE};${INCLUDE_WHAT_YOU_USE_IWYU_ARGS}"
    )
  endforeach ()
endfunction()