# Copyright (c) Matthew Rodusek
# Distributed under the OSI-approved MIT License. See accompanying
# file LICENSE.txt or https://opensource.org/licenses/MIT for details.

#.rst:
# CompilerWarnings
# ----------------
#
# This module defines an easy way to enable the equivalent of '-Wall' on
# most compilers

include(CheckCXXCompilerFlag)

if (CMAKE_VERSION VERSION_LESS 3.5.0)
  include(CMakeParseArguments)
endif ()

function(_compiler_warnings_get_flags result_var)
  cmake_parse_arguments(
    COMPILER_WARNINGS
    "EXTRA;WARNINGS_AS_ERRORS"
    ""
    ""
    ${ARGN}
  )

  if (COMPILER_WARNINGS_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR
      "enable_compiler_warnings: "
      "Unknown argument '${COMPILER_WARNINGS_UNPARSED_ARGUMENTS}'"
    )
  endif ()

  set(result)
  if (MSVC)
    list(APPEND result "/W4")
 
    if (ENABLE_EXTRA_COMPILER_WARNINGS)
      list(APPEND result "/Wall")
    endif ()
  else ()
    check_cxx_compiler_flag("-Wall" compiler_supports_wall)
    if (compiler_supports_wall)
      list(APPEND result"-Wall")
    endif ()
  
    check_cxx_compiler_flag("-W" compiler_supports_w)
    if (compiler_supports_w)
      list(APPEND result "-W")
    endif ()

    if (ENABLE_EXTRA_COMPILER_WARNINGS)
      check_cxx_compiler_flag("-Weverything" compiler_supports_weverything)
      if (compiler_supports_wextra)
        list(APPEND result "-Weverything")
      endif () 

      check_cxx_compiler_flag("-Wextra" compiler_supports_wextra)
      if (compiler_supports_weverything)
        list(APPEND result "-Wextra")
      endif ()
    endif ()
  endif ()

  set("${result_var}" ${result} PARENT_SCOPE)
endfunction()

#.rst:
# .. command:: enable_compiler_warnings
#
# Enables compiler warnings for all targets created in the same directory and
# below, after the invocation of this function. Th
#
# .. code-block:: cmake
#
#   enable_compiler_warnings(
#     [EXTRA]
#     [WARNINGS_AS_ERRORS]
#   )
#
# The options are:
#
#   ``EXTRA``
#     Enables extra warnings outside the base set of warnings
#
#   ``WARNINGS_AS_ERRORS``
#     Treats warnings as errors
function(enable_compiler_warnings)
  _compiler_warnings_get_flags(flags ${ARGN})
  add_compile_options(${flags})
endfunction()

#.rst:
# .. command:: enable_compiler_warnings
#
# Enables compiler warnings for the specified target
#
# .. code-block:: cmake 
#
#   enable_compiler_warnings(<target>
#     [EXTRA]
#     [WARNINGS_AS_ERRORS]
#   )
#
# The specified target ``<target>`` must not be an ``INTERFACE`` library, 
# since warnings should not be forced to be transitive on consumers.
#
# The options are:
#
#   ``EXTRA``
#     Enables extra warnings outside the base set of warnings
#
#   ``WARNINGS_AS_ERRORS``
#     Treats warnings as errors
function(target_enable_compiler_warnings target)

  # Interface libraries don't get built, and warnings should not be 
  # transitively imposed on the consumer
  get_property(type TARGET "${target}" PROPERTY TYPE)
  if (type STREQUAL "INTERFACE_LIBRARY")
    message(FATAL_ERROR
      "target_enable_compiler_warnings:" 
      "Cannot enable warnings on INTERFACE library."
    )
  endif ()

  _compiler_warnings_get_flags(flags ${ARGN})
  target_compile_options(${target} PRIVATE ${flags})
endfunction()