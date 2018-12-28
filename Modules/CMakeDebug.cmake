# Copyright (c) Matthew Rodusek
# Distributed under the OSI-approved MIT License. See accompanying
# file LICENSE.txt or https://opensource.org/licenses/MIT for details.

#.rst:
# CMakeDebug
# ----------
#
# This module defines various debugging utilities for authors of CMake 
# scripts. This module should realistically never be used in production,
# as it is intended to help diagnose issues in authored CMake scripts.

if (CMAKE_VERSION VERSION_LESS 3.5.0)
  include(CMakeParseArguments)
endif ()

#.rst:
# .. command:: cmake_debug_dump_variables
#
#   This command dumps out the names and values of all variables that are
#   currently set and in scope.
#
# .. code-block:: cmake
#
#   cmake_debug_dump_variables([MATCHING <regex>])
# 
# The options are:
#
#   ``MATCHING``
#     A regular-expression for the names of the variables to set
function(cmake_debug_dump_variables)
  cmake_parse_arguments(
    CMAKE_DEBUG # Prefix
    ""       # Option-args
    MATCHING # Single-args
    ""       # Multi-args
  )
  if (CMAKE_DEBUG_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "cmake_debug_dump_variables: Unknown arguments '${CMAKE_DEBUG_UNPARSED_ARGUMENTS}'")
  endif ()

  get_property(variable GLOBAL PROPERTY VARIABLES) 
  foreach (variable IN LISTS variables)
    if (CMAKE_DEBUG_MATCHING)
      if (variable MATCHES "${CMAKE_DEBUG_MATCHING}")
        message(STATUS "${variable} = '${${variable}}'")
      endif ()
    else ()
      message(STATUS "${variable} = '${${variable}}'")
    endif ()
  endforeach ()
endfunction()


function(_cmake_debug_watch_variable_callback variable access value file)
  message(STATUS "${file}:ACCESS(${access}): ${variable} = '${value}'")
endfunction()

#.rst:
# .. command:: cmake_debug_watch_variables
#
#   This command logs all accesses to all variables which match the specified
#   regex, or all variables (if unspecified)
#
# .. code-block:: cmake
#
#   cmake_debug_dump_variables([MATCHING <regex>])
#
# The options are:
#
#   ``MATCHING``
#     A regular-expression for the names of the variables to watch
function(cmake_debug_watch_variables)
  cmake_parse_arguments(
    CMAKE_DEBUG # Prefix
    ""       # Option-args
    MATCHING # Single-args
    ""       # Multi-args
  )
  if (CMAKE_DEBUG_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "cmake_debug_watch_variables: Unknown arguments '${CMAKE_DEBUG_UNPARSED_ARGUMENTS}'")
  endif ()

  get_property(variable GLOBAL PROPERTY VARIABLES) 
  foreach (variable IN LISTS variables)
    if (CMAKE_DEBUG_MATCHING)
      if (variable MATCHES "${CMAKE_DEBUG_MATCHING}")
        variable_watch("${variable}" _cmake_debug_watch_variable_callback)
      endif ()
    else ()
      variable_watch("${variable}" _cmake_debug_watch_variable_callback)
    endif ()
  endforeach ()
endfunction()

#.rst:
# .. command:: cmake_debug_message
#
# Prints a debug message
#
# .. code-block:: cmake
#
#   cmake_debug_message([<message>...])
#
# The parameter(s) are:
#
#   ``<message>``
#     The message strings to print
function(cmake_debug_message)
  message(AUTHOR_WARNING ${ARGN})
endfunction()