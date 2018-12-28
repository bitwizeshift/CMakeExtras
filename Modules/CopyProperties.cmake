# Copyright (c) Matthew Rodusek
# Distributed under the OSI-approved MIT License. See accompanying
# file LICENSE.txt or https://opensource.org/licenses/MIT for details.

#.rst:
# CopyProperties
# --------------
#
# This module defines various utilities for copying properties between
# a source and destination.
#
# These utilities follow the same structure as the :command:`get_target`
# and :command:`set_target` commands that are built into CMake by allowing
# a full-formed version, along with short-form versions for easier
# consumption.

if (CMAKE_VERSION VERSION_LESS 3.5.0)
  include(CMakeParseArguments)
endif ()

#.rst:
# .. command:: copy_properties:
#
# Copies properties from a source to a given destination
#
# .. code-block:: cmake
#
#   copy_properties(
#     SOURCE <GLOBAL             |
#             DIRECTORY [dir]    |
#             TARGET    <target> |
#             SOURCE    <source> |
#             TEST      <test>   |
#             CACHE     <entry>  |
#             VARIABLE>
#     DESTINATION <GLOBAL               |
#                  DIRECTORY [dir]      |
#                  TARGET    <target>   |
#                  SOURCE    <source>   |
#                  TEST      <test>     |
#                  CACHE     <entry>    |
#                  VARIABLE>
#     PROPERTIES prop1 prop2 ...
#   )
#
# Copies all properties specified by ``prop1``, ``prop2``, ... from the source
# to the destination.
#
# The properties being copied must be available on both the source and the 
# destination. For example, 
#
# .. code-block:: cmake
#
#   copy_properties(SOURCE GLOBAL DESTINATION TARGET foo PROPERTIES VARIABLES)
#
# is ill-formed, since :prop_gbl:`VARIABLES` is a global property, and can't
# be set on a target.
function(copy_properties)

  cmake_parse_arguments(
    "COPY_PROPERTIES"               # Prefix
    ""                              # Option-args
    ""                              # Single-args
    "SOURCE;DESTINATION;PROPERTIES" # Multi-args
    ${ARGN}
  )

  if (NOT COPY_PROPERTIES_SOURCE)
    message(FATAL_ERROR 
      "copy_properties SOURCE: source not specified"
    )
  endif ()
  if (NOT COPY_PROPERTIES_DESTINATION)
    message(FATAL_ERROR 
      "copy_properties DESTINATION: destination not specified"
    )
  endif ()
  if (NOT COPY_PROPERTIES_PROPERTIES)
    message(FATAL_ERROR 
      "copy_properties PROPERTIES: properties not specified"
    )
  endif ()

  # Copy each property over
  foreach (property IN LISTS COPY_PROPERTIES_PROPERTIES)
    get_property(value ${COPY_PROPERTIES_SOURCE} PROPERTY "${property}")
    set_property(${COPY_PROPERTIES_DESTINATION} PROPERTY "${property}" "${value}")
  endforeach ()

endfunction()

#.rst:
# .. command:: copy_target_properties:
#
# Copies properties from a source target to a given destination target
#
# .. code-block:: cmake
#
#   copy_target_properties(
#     SOURCE <source>
#     DESTINATION <destination>
#     PROPERTIES prop1 prop2 ...
#   )
#
# Copies all properties specified by ``prop1``, ``prop2``, ... from the source
# target ``<source>`` to the destination target ``<destination>``.
function(copy_target_properties)

  cmake_parse_arguments(
    "COPY_PROPERTIES"    # Prefix
    ""                   # Option-args
    "SOURCE;DESTINATION" # Single-args
    "PROPERTIES"         # Multi-args
    ${ARGN}
  )

  if (NOT COPY_PROPERTIES_SOURCE)
    message(FATAL_ERROR 
      "copy_target_properties SOURCE: source target not specified"
    )
  endif ()
  if (NOT COPY_PROPERTIES_DESTINATION)
    message(FATAL_ERROR 
      "copy_target_properties DESTINATION: destination target not specified"
    )
  endif ()
  if (NOT COPY_PROPERTIES_PROPERTIES)
    message(FATAL_ERROR 
      "copy_target_properties PROPERTIES: properties not specified"
    )
  endif ()

  copy_properties(
    SOURCE TARGET "${COPY_PROPERTIES_SOURCE}"
    DESTINATION TARGET "${COPY_PROPERTIES_DESTINATION}"
    PROPERTIES "${COPY_PROPERTIES_PROPERTIES}"
  )

endfunction()

#.rst:
# .. command:: copy_test_properties:
#
# Copies properties from a source test to a given destination test
#
# .. code-block:: cmake
#
#   copy_test_properties(
#     SOURCE <source>
#     DESTINATION <destination>
#     PROPERTIES prop1 prop2 ...
#   )
#
# Copies all properties specified by ``prop1``, ``prop2``, ... from the source
# test ``<source>`` to the destination test ``<destination>``.
function(copy_test_properties)

  cmake_parse_arguments(
    "COPY_PROPERTIES"    # Prefix
    ""                   # Option-args
    "SOURCE;DESTINATION" # Single-args
    "PROPERTIES"         # Multi-args
    ${ARGN}
  )

  if (NOT COPY_PROPERTIES_SOURCE)
    message(FATAL_ERROR 
      "copy_test_properties SOURCE: source test not specified"
    )
  endif ()
  if (NOT COPY_PROPERTIES_DESTINATION)
    message(FATAL_ERROR 
      "copy_test_properties DESTINATION: destination test not specified"
    )
  endif ()
  if (NOT COPY_PROPERTIES_PROPERTIES)
    message(FATAL_ERROR 
      "copy_test_properties PROPERTIES: properties not specified"
    )
  endif ()

  copy_properties(
    SOURCE TEST "${COPY_PROPERTIES_SOURCE}"
    DESTINATION TEST "${COPY_PROPERTIES_DESTINATION}"
    PROPERTIES "${COPY_PROPERTIES_PROPERTIES}"
  )

endfunction()

#.rst:
# .. command:: copy_source_file_properties:
#
# Copies properties from a source file to a given destination file
#
# .. code-block:: cmake
#
#   copy_source_file_properties(
#     SOURCE <source>
#     DESTINATION <destination>
#     PROPERTIES prop1 prop2 ...
#   )
#
# Copies all properties specified by ``prop1``, ``prop2``, ... from the source
# file ``<source>`` to the destination file ``<destination>``.
function(copy_source_file_properties)

  cmake_parse_arguments(
    "COPY_PROPERTIES"    # Prefix
    ""                   # Option-args
    "SOURCE;DESTINATION" # Single-args
    "PROPERTIES"         # Multi-args
    ${ARGN}
  )

  if (NOT COPY_PROPERTIES_SOURCE)
    message(FATAL_ERROR 
      "copy_source_file_properties SOURCE: source file not specified"
    )
  endif ()
  if (NOT COPY_PROPERTIES_DESTINATION)
    message(FATAL_ERROR 
      "copy_source_file_properties DESTINATION: destination file not specified"
    )
  endif ()
  if (NOT COPY_PROPERTIES_PROPERTIES)
    message(FATAL_ERROR 
      "copy_source_file_properties PROPERTIES: properties not specified"
    )
  endif ()

  copy_properties(
    SOURCE SOURCE "${COPY_PROPERTIES_SOURCE}"
    DESTINATION SOURCE "${COPY_PROPERTIES_DESTINATION}"
    PROPERTIES "${COPY_PROPERTIES_PROPERTIES}"
  )

endfunction()

#.rst:
# .. command:: copy_directory_properties:
#
# Copies properties from a source directory to a given destination directory
#
# .. code-block:: cmake
#
#   copy_directory_properties(
#     [SOURCE <source>]
#     [DESTINATION <destination>]
#     PROPERTIES prop1 prop2 ...
#   )
#
# Copies all properties specified by ``prop1``, ``prop2``, ... from the source
# directory ``<source>`` to the destination directory ``<destination>``.
function(copy_directory_properties)

  cmake_parse_arguments(
    "COPY_PROPERTIES"    # Prefix
    ""                   # Option-args
    "SOURCE;DESTINATION" # Single-args
    "PROPERTIES"         # Multi-args
    ${ARGN}
  )

  if (NOT COPY_PROPERTIES_PROPERTIES)
    message(FATAL_ERROR 
      "copy_directory_properties PROPERTIES: properties not specified"
    )
  endif ()
  if (NOT COPY_PROPERTIES_SOURCE AND NOT COPY_PROPERTIES_DESTINATION)
    message(FATAL_ERROR 
      "copy_directory_properties: both SOURCE and DESTINATION not specified"
    )
  endif ()

  # Args are set up independently here so that the 'SOURCE' and 'DESTINATION' value can
  # retain any spaces when passed to 'copy_properties' below. This is necessary since 
  # filepaths on some systems may contain spaces.
  set(source_arg DIRECTORY)
  if (COPY_PROPERTIES_SOURCE)
    set(source_arg DIRECTORY "${COPY_PROPERTIES_SOURCE}")
  endif ()

  set(destination_arg DIRECTORY)
  if (COPY_PROPERTIES_DESTINATION)
    set(destination_arg DIRECTORY "${COPY_PROPERTIES_DESTINATION}")
  endif ()

  copy_properties(
    SOURCE "${source_arg}"
    DESTINATION "${destination_arg}"
    PROPERTIES "${COPY_PROPERTIES_PROPERTIES}"
  )

endfunction()