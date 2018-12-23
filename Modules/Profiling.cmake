# Distributed under the OSI-approved MIT License. See accompanying
# file LICENSE.txt or https://opensource.org/licenses/MIT for details.

#.rst:
# Profiling
# ---------
#
# This module defines functionality for enabling profiling support 
# in the built executables

if (CMAKE_VERSION VERSION_LESS 3.5.0)
  include(CMakeParseArguments)
endif()

function(_get_profile_flags result_var)
  if (CMAKE_C_COMPILER_ID MATCHES "Clang" OR 
      CMAKE_CXX_COMPILER_ID MATCHES "Clang" OR
      CMAKE_C_COMPILER_ID MATCHES "GNU" OR 
      CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    set(${result_var} "-p" PARENT_SCOPE)
  else()
    message(WARNING 
      "Unknown compiler '${CMAKE_CXX_COMPILER_ID}'."
      "Unable to enable profiling."
    )
  endif()
endfunction()

#.rst:
# .. command:: enable_profiling
#
# This command enables the C/C++ compiler option for profiling
# for all subsequent targets created after this at the same or 
# deeper directory scopes.
function(enable_profiling)
  _get_profile_flags(flags)
  add_compile_options(${flags})
endfunction()

#.rst:
# .. command:: target_enable_profiling
#
# This command enables the C/C++ compiler option for profiling
# on the specified target.
#
# .. code-block:: cmake
#
#   target_enable_profiling(<target>)
#
# Enables profiling for the target with name ``<target>``
function(target_enable_profiling target)
  _get_profile_flags(flags)
  target_compile_options("${target}" PRIVATE ${flags})
endfunction()