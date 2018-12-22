# Distributed under the OSI-approved MIT License. See accompanying
# file LICENSE.txt or https://opensource.org/licenses/MIT for details.

#.rst:
# BuildConfiguration
# ------------------
#
# This module contains a command for setting the default build configuration
# in circumstances where it is otherwise unset.

#.rst:
# .. command::add_build_configuration
#
#   Appends a build configuration to the list of valid configurations
#
# ::
#
#    add_build_configuration( <configuration> )
#
#    <configuration> - the configuration to add to the list of valid types
function(add_build_configuration configuration)
  if (CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_CONFIGURATION_TYPES 
      "${CMAKE_CONFIGURATION_TYPES};${configuration}" 
      CACHE STRING "The supported configurations" FORCE
    )
  else()
    set_property(CACHE CMAKE_BUILD_TYPE APPEND PROPERTY STRINGS "${configuration}")
  endif()
endfunction()

#.rst:
# .. command::set_build_configurations
#
#   Sets the list of valid build configurations
#
# ::
#
#    set_build_configurations( [<configuration>...] )
#
#    <configuration> - the configurations to be set to
function(set_build_configurations)
  if (CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_CONFIGURATION_TYPES 
      "${ARGN}" 
      CACHE STRING "The supported configurations" FORCE
    )
  else()
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "${ARGN}")
  endif()
endfunction()

#.rst:
# .. command::get_build_configurations
#
#    Gets the list of valid build configurations
#
# ::
#
#    get_build_configurations( <result_var> )
#
#    <result_var> - the name of the variable to set the result to
function(get_build_configurations result_var)
  if (CMAKE_CONFIGURATION_TYPES)
    set("${result_var}" "${CMAKE_CONFIGURATION_TYPES}" PARENT_SCOPE)
  else()
    get_property(build_types CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS)
    set("${result_var}" "${build_types}" PARENT_SCOPE)
  endif()
endfunction()

#.rst:
# .. command::set_default_build_configuration
#
#   Sets the default cmake build type/configuration for when no 
#   configuration is specified. This only has an effect on single-config
#   generators like Makefile and Ninja.
#
# ::
#
#   set_default_configuration( <configuration> )
#
#   <configuration> - The configuration to default to
function(set_default_build_configuration configuration)
  if (NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE 
      "${configuration}" 
      CACHE STRING "The configuration to be built" FORCE
    )
  endif()
endfunction()

#.rst:
# .. command::reset_build_configurations
#
#   Resets the default build configuration list
#
# ::
#
#   reset_build_configurations()
function(reset_build_configurations)
  set(__default_configurations "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
  if (CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_CONFIGURATION_TYPES 
      ${__default_configurations} 
      CACHE STRING "The configurations to be built" FORCE
    )
  else()
    # Set the possible values of build type for cmake-gui
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS ${__default_configurations})
  endif()
endfunction()

#.rst:
# .. command::ensure_valid_configuration
#
#   Ensures that the specified CMAKE_BUILD_TYPE refers to a valid build 
#   configuration.
#   This only has effect on single-configuration generators like Makefile or
#   Ninja.
#
#   Configurations are compared case-insensitively, since CMake does not
#   distinguish between cases for CMAKE_BUILD_TYPE.
#
# ::
#
#   ensure_valid_configuration()
function(ensure_valid_configuration)
  if (CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    get_build_configurations(build_configurations)

    set(valid FALSE)
    string(TOUPPER "${CMAKE_BUILD_TYPE}" build_type)
    foreach(build_configuration IN LISTS build_configurations )
      string(TOUPPER "${build_configuration}" build_configuration )
      if (build_type STREQUAL build_configuration)
        set(valid TRUE)
        break()
      endif()
    endforeach()
    if (NOT valid)
      message(FATAL_ERROR "ensure_valid_configuration: Invalid CMAKE_BUILD_TYPE specified '${CMAKE_BUILD_TYPE}'. Valid types are '${build_configurations}'")
    endif()
  endif()
endfunction()