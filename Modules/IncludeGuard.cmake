# Copyright (c) Matthew Rodusek
# Distributed under the OSI-approved MIT License. See accompanying
# file LICENSE.txt or https://opensource.org/licenses/MIT for details.

#.rst:
# IncludeGuard
# ------------
#
# This module defines various utilities to simplify the use of ``git`` from
# within CMake scripts.
#
# This module defines the following variables:
#
#   ``GIT_EXECUTABLE`` 
#     Path to the ``git`` executable, or ``NOTFOUND`` if it cannot be found


# include_guard becomes a built-in in 3.10
if (CMAKE_VERSION VERSION_LESS 3.10)

  #.rst:
  # .. command:: include_guard
  #
  # Provides an include guard for the file currently being processed by CMake.
  #
  # .. code-block:: cmake
  #
  #   include_guard([DIRECTORY|GLOBAL])
  #
  # Sets up an include guard for the current CMake file (see the 
  # :variable:`CMAKE_CURRENT_LIST_FILE` variable documentation).
  #
  # CMake will end its processing of the current file at the location of 
  # the :command:`include_guard` command if the current file has already been
  # processed for the applicable scope (see below). This provides 
  # functionality similar to the include guards commonly used in source 
  # headers or to the ``#pragma once`` directive. If the current file has been 
  # processed previously for the applicable scope, the effect is as though 
  # :command:`return()` had been called. 
  # Do not call this command from inside a function being defined within the 
  # current file.
  #
  # An optional argument specifying the scope of the guard may be provided. 
  # Possible values for the option are:
  #
  # ``DIRECTORY``
  #   The include guard applies within the current directory and below. The 
  #   file will only be included once within this directory scope, but may be 
  #   included again by other files outside of this directory (i.e. a parent 
  #   directory or another directory not pulled in by 
  #   :command:`add_subdirectory()` or :command:`include()` from the current 
  #   file or its children).
  #
  # ``GLOBAL``
  #   The include guard applies globally to the whole build. The current file 
  #   will only be included once regardless of the scope.
  #
  # If no arguments given, include_guard has the same scope as a variable, 
  # meaning that the include guard effect is isolated by the most recent 
  # function scope or current directory if no inner function scopes exist. 
  # In this case the command behavior is the same as:
  #
  # .. code-block:: cmake
  #
  #   if(__CURRENT_FILE_VAR__)
  #     return()
  #   endif()
  #   set(__CURRENT_FILE_VAR__ TRUE)
  macro(include_guard)

    if (ARGC GREATER 1)
      message(FATAL_ERROR "include_guard: Too many arguments (${ARGC}, expected at most 1)")
    endif()

    set(__GUARD__ "GUARD_${CMAKE_CURRENT_LIST_FILE}")

    if (ARGC EQUAL 1)
      if (ARGV0 STREQUAL "DIRECTORY")
        get_property(
          __CURRENT_PROPERTY_VALUE__ 
          DIRECTORY "${CMAKE_CURRENT_LIST_DIR}" 
          PROPERTY "${__GUARD__}"
        )
        if (__CURRENT_PROPERTY_VALUE__)
          unset(__CURRENT_PROPERTY_VALUE__)
          return()
        endif()
        set_property(
          DIRECTORY "${CMAKE_CURRENT_LIST_DIR}"
          PROPERTY "${__GUARD__}" 
          True
        )
      elseif (ARGV0 STREQUAL "GLOBAL")
        get_property(
          __CURRENT_PROPERTY_VALUE__ 
          GLOBAL
          PROPERTY "${__GUARD__}"
        )
        if (__CURRENT_PROPERTY_VALUE__)
          unset(__CURRENT_PROPERTY_VALUE__)
          return()
        endif()
        set_property(
          GLOBAL
          PROPERTY "${__GUARD__}" 
          True
        )
      else()
        message(FATAL_ERROR "include_guard: Unknown option '${ARGV1}'.")
      endif()
    else ()
      if (DEFINED "${__GUARD__}")
        return()
      endif()
      set("${__GUARD__}" TRUE)
    endiF()
  endmacro()

endif()