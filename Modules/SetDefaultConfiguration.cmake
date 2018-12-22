# Distributed under the OSI-approved MIT License. See accompanying
# file LICENSE.txt or https://opensource.org/licenses/MIT for details.

#.rst:
# SetDefaultConfiguration
# -----------------------
#
# This module contains a command for setting the default build configuration
# in circumstances where it is otherwise unset.

#.rst:
# .. command::set_default_configuration
#
#   Sets the default cmake build type/configuration if none were specified.
#
# ::
#
#   set_default_configuration( <configuration> )
#
#   <configuration> - The configuration to default to
macro(set_default_configuration configuration)
  if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "${configuration}" CACHE STRING "The configuration to be built" FORCE)

    # Set the possible values of build type for cmake-gui
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
  endif()
endmacro()