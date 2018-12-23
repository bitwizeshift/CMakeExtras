# Distributed under the OSI-approved MIT License. See accompanying
# file LICENSE.txt or https://opensource.org/licenses/MIT for details.

#.rst:
# Git
# ---
#
# This module defines various utilities to simplify the use of ``git`` from
# within CMake scripts.
#
# This module defines the following variables:
#
#   ``GIT_EXECUTABLE`` 
#     Path to the ``git`` executable, or ``NOTFOUND`` if it cannot be found

find_package(Git QUIET)

if (CMAKE_VERSION VERSION_LESS 3.5.0)
  include(CMakeParseArguments)
endif()

#.rst:
# .. command:: git_sha1
#
# Gets the SHA1 hash of the current commit
#
# .. code-block:: cmake
#
#   git_sha1(<result_var>)
#
# The result is stored in ``<result_var>``. The options are:
#
#   ``SHORT``
#     Changes the SHA1 to be th eshort SHA1
function(git_sha1 result_var)

  cmake_parse_arguments(
    GIT     # Prefix
    "SHORT" # Option-args
    ""      # Single-args
    ""      # Multi-args
    ${ARGN}
  )

  set(short_flag)
  if (GIT_SHORT)
    set(short_flag "--short")
  endif()

  execute_process(
    COMMAND "${GIT_EXECUTABLE}" rev-parse ${short_flag} HEAD
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    OUTPUT_VARIABLE "output"
    ERROR_VARIABLE "error"
    RESULT_VARIABLE "result"
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_STRIP_TRAILING_WHITESPACE 
  )

  if (NOT _result EQUAL 0)
    message(FATAL_ERROR "git_branch: Error retrieving branch name. ${error}")
  endif()

  set("${result_var}" ${output} PARENT_SCOPE)
endfunction()

#.rst:
# .. command:: git_branch
#
# Gets the branch hash of the current commit
#
# .. code-block:: cmake
#
#   git_branch(<result_var>)
#
# The result is stored in ``<result_var>``.
function(git_branch result_var)
  execute_process(
    COMMAND "${GIT_EXECUTABLE}" rev-parse --abbrev-ref HEAD
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    OUTPUT_VARIABLE "output"
    ERROR_VARIABLE "error"
    RESULT_VARIABLE "result"
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_STRIP_TRAILING_WHITESPACE 
  )

  if (NOT _result EQUAL 0)
    message(FATAL_ERROR "git_branch: Error retrieving branch name. ${error}")
  endif()

  set("${result_var}" ${output} PARENT_SCOPE)
endfunction()