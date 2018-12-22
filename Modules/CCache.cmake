# Distributed under the OSI-approved MIT License. See accompanying
# file LICENSE.txt or https://opensource.org/licenses/MIT for details.

#.rst:
# CCache
# ------
#
# This module defines a simple way of enable CCache in a project, if
# the executable is discovered.

if( ${CMAKE_VERSION} VERSION_LESS 3.5.0 )
  include(CMakeParseArguments)
endif()

#.rst
# .. command::enable_ccache
#
#   This command finds and enables ccache, if able to, for a given
#   project.
#
# ::
#
#   enable_ccache([VERBOSE] [REQUIRED])
#
#   VERBOSE  - Logs whether or not CCache is enabled
#   REQUIRED - Halts configuration with a hard-error if CCache is not found
macro(enable_ccache)

  cmake_parse_arguments(
    ENABLE_CCACHE    # Prefix
    VERBOSE REQUIRED # Options args
    ""               # Single args
    ""               # Multi args
    ${ARGN}
  )

  set(__FIND_ROOT_PATH_MODE_PROGRAM ${CMAKE_FIND_ROOT_PATH_MODE_PROGRAM})
  set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

  find_program(CCACHE_PATH ccache)

  set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ${__FIND_ROOT_PATH_MODE_PROGRAM})
  set(__FIND_ROOT_PATH_MODE_PROGRAM)

  if(CCACHE_PATH)
    set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE ${CCACHE_PATH})
    set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK ${CCACHE_PATH})
  endif()

  # Verbose messages
  if(ENABLE_CCACHE_VERBOSE)
    if(CCACHE_PATH)
      message(STATUS "CCache enabled")
    else()
      message(STATUS "CCache not enabled")
    endif()
  endif()

  if(ENABLE_CCACHE_REQUIRED AND NOT CCACHE_PATH)
    message(${message_type} "enable_ccache REQUIRED: CCache not found")
  endif()

  mark_as_advanced(CCACHE_PATH)

endmacro()