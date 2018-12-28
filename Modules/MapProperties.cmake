# Copyright (c) Matthew Rodusek
# Distributed under the OSI-approved MIT License. See accompanying
# file LICENSE.txt or https://opensource.org/licenses/MIT for details.

#.rst:
# MapProperties
# -------------
#
# This module defines various utilities for mapping properties between
# a source and destination. Unlike the :module:`CopyProperties` module, 
# these functions map one property to another, which supports things like 
# copying :prop_tgt:`INTERFACE_INCLUDE_DIRECTORIES` to 
# :prop_tgt:`INCLUDE_DIRECTORIES`

if (CMAKE_VERSION VERSION_LESS 3.5.0)
  include(CMakeParseArguments)
endif ()

#.rst:
# .. command:: map_properties:
#
# Maps properties from a source to a given destination
#
# .. code-block:: cmake
#
#   map_properties(
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
#     SOURCE_PROPERTIES source_prop1 source_prop2 ...
#     DESTINATION_PROPERTIES dest_prop1 dest_prop2 ...
#   )
#
# Copies all source properties specified by ``source_prop1``, 
# ``source_prop2``, ... to the respective destination properties specified 
# by ``dest_prop1``, ``dest_prop2``, ...
#
# The number of properties specified by ``SOURCE_PROPERTIES`` must match 
# the number of properties specified by the ``DESTINATION_PROPERTIES``.
#
# A property at a given index from ``SOURCE_PROPERTIES`` will copy its 
# value to the property at the same index in the ``DESTINATION_PROPERTIES``.
# For example:
#
# .. code-block:: cmake
#
#   map_properties(
#     SOURCE TARGET IFoo
#     SOURCE_PROPERTIES INTERFACE_INCLUDE_DIRECTORIES INTERFACE_LINK_LIBARIES
#     DESTINATION TARGET Foo 
#     DESTINATION_PROPERTIES INCLUDE_DIRECTORIES LINK_LIBARIES
#   )
#
# Will copy ``IFoo``'s ``INTERFACE_INCLUDE_DIRECTORIES`` to 
# ``Foo``'s ``INCLUDE_DIRECTORIES``, and ``IFoo``'s 
# ``INTERFACE_LINK_LIBARIES`` to ``Foo``'s ``LINK_LIBARIES``
function(map_properties)

  set(multi_args 
    SOURCE 
    DESTINATION
    SOURCE_PROPERTIES
    DESTINATION_PROPERTIES
  )

  cmake_parse_arguments(
    "MAP_PROPERTIES"
    ""             
    ""             
    "${multi_args}"
    ${ARGN}
  )

  if (NOT MAP_PROPERTIES_SOURCE)
    message(FATAL_ERROR 
      "map_properties SOURCE: source not specified"
    )
  endif ()
  if (NOT MAP_PROPERTIES_DESTINATION)
    message(FATAL_ERROR 
      "map_properties DESTINATION: destination not specified"
    )
  endif ()
  if (NOT MAP_PROPERTIES_SOURCE_PROPERTIES)
    message(FATAL_ERROR 
      "map_properties SOURCE_PROPERTIES: properties not specified"
    )
  endif ()
  if (NOT MAP_PROPERTIES_DESTINATION_PROPERTIES)
    message(FATAL_ERROR 
      "map_properties DESTINATION_PROPERTIES: properties not specified"
    )
  endif ()

  list(LENGTH MAP_PROPERTIES_SOURCE_PROPERTIES source_length)
  list(LENGTH MAP_PROPERTIES_DESTINATION_PROPERTIES dest_length)

  if (source_length GREATER dest_length)
    message(FATAL_ERROR
      "map_properties SOURCE_PROPERTIES: More source-properties than"
      "destination properties specified"
    )
  endif ()
  if (source_length LESS dest_length)
    message(FATAL_ERROR
      "map_properties DESTINATION_PROPERTIES: More destination-properties"
      "than source properties specified"
    )
  endif ()
  set(length ${dest_length})

  foreach (index RANGE 0 ${length})
    list(GET MAP_PROPERTIES_SOURCE_PROPERTIES ${index} source_property)
    list(GET MAP_PROPERTIES_DESTINATION_PROPERTIES ${index} dest_property)

    get_property(value ${MAP_PROPERTIES_SOURCE} PROPERTY "${source_property}")
    set_property(${MAP_PROPERTIES_DESTINATION} PROPERTY "${dest_property}" "${value}")
  endforeach ()
endfunction()

#.rst:
# .. command:: map_target_properties:
#
# Maps properties from a source target to a given destination target
#
# .. code-block:: cmake
#
#   map_target_properties(
#     SOURCE <source>
#     DESTINATION <destination>
#     SOURCE_PROPERTIES source_prop1 source_prop2 ...
#     DESTINATION_PROPERTIES dest_prop1 dest_prop2 ...
#   )
#
# Maps all properties specified by ``source_prop1``, 
# ``source_prop2``, ... from the source target ``<source>`` to the 
# destination target ``<destination>``'s ``dest_prop1``, ``dest_prop2`, ....
function(map_target_properties)

  set(single_args SOURCE DESTINATION)
  set(multi_args SOURCE_PROPERTIES DESTINATION_PROPERTIES)

  cmake_parse_arguments(
    "MAP_PROPERTIES"
    ""
    "${single_args}"
    "${multi_args}"
    ${ARGN}
  )

  if (NOT MAP_PROPERTIES_SOURCE)
    message(FATAL_ERROR 
      "map_target_properties SOURCE: source target not specified"
    )
  endif ()
  if (NOT MAP_PROPERTIES_DESTINATION)
    message(FATAL_ERROR 
      "map_target_properties DESTINATION: destination target not specified"
    )
  endif ()
  if (NOT MAP_PROPERTIES_SOURCE_PROPERTIES)
    message(FATAL_ERROR 
      "map_target_properties SOURCE_PROPERTIES: properties not specified"
    )
  endif ()
  if (NOT MAP_PROPERTIES_DESTINATION_PROPERTIES)
    message(FATAL_ERROR 
      "map_target_properties DESTINATION_PROPERTIES: properties not specified"
    )
  endif ()

  map_properties(
    SOURCE TARGET "${MAP_PROPERTIES_SOURCE}"
    DESTINATION TARGET "${MAP_PROPERTIES_DESTINATION}"
    SOURCE_PROPERTIES "${MAP_PROPERTIES_SOURCE_PROPERTIES}"
    DESTINATION_PROPERTIES "${MAP_PROPERTIES_DESTINATION_PROPERTIES}"
  )

endfunction()

#.rst:
# .. command:: map_test_properties:
#
# Maps properties from a source test to a given destination test
#
# .. code-block:: cmake
#
#   map_test_properties(
#     SOURCE <source>
#     DESTINATION <destination>
#     SOURCE_PROPERTIES source_prop1 source_prop2 ...
#     DESTINATION_PROPERTIES dest_prop1 dest_prop2 ...
#   )
#
# Maps all properties specified by ``source_prop1``, 
# ``source_prop2``, ... from the source test ``<source>`` to the 
# destination test ``<destination>``'s ``dest_prop1``, ``dest_prop2`, ....
function(map_test_properties)

  set(single_args SOURCE DESTINATION)
  set(multi_args SOURCE_PROPERTIES DESTINATION_PROPERTIES)

  cmake_parse_arguments(
    "MAP_PROPERTIES"
    ""
    "${single_args}"
    "${multi_args}"
    ${ARGN}
  )

  if (NOT MAP_PROPERTIES_SOURCE)
    message(FATAL_ERROR 
      "map_test_properties SOURCE: source test not specified"
    )
  endif ()
  if (NOT MAP_PROPERTIES_DESTINATION)
    message(FATAL_ERROR 
      "map_test_properties DESTINATION: destination test not specified"
    )
  endif ()
  if (NOT MAP_PROPERTIES_SOURCE_PROPERTIES)
    message(FATAL_ERROR 
      "map_test_properties SOURCE_PROPERTIES: properties not specified"
    )
  endif ()
  if (NOT MAP_PROPERTIES_DESTINATION_PROPERTIES)
    message(FATAL_ERROR 
      "map_test_properties DESTINATION_PROPERTIES: properties not specified"
    )
  endif ()

  map_properties(
    SOURCE TEST "${MAP_PROPERTIES_SOURCE}"
    DESTINATION TEST "${MAP_PROPERTIES_DESTINATION}"
    SOURCE_PROPERTIES "${MAP_PROPERTIES_SOURCE_PROPERTIES}"
    DESTINATION_PROPERTIES "${MAP_PROPERTIES_DESTINATION_PROPERTIES}"
  )

endfunction()

#.rst:
# .. command:: map_source_file_properties:
#
# Maps properties from a source file to a given destination file
#
# .. code-block:: cmake
#
#   map_source_file_properties(
#     SOURCE <source>
#     DESTINATION <destination>
#     SOURCE_PROPERTIES source_prop1 source_prop2 ...
#     DESTINATION_PROPERTIES dest_prop1 dest_prop2 ...
#   )
#
# Maps all properties specified by ``source_prop1``, 
# ``source_prop2``, ... from the source file ``<source>`` to the 
# destination source file ``<destination>``'s ``dest_prop1``, 
# ``dest_prop2`, ....
function(map_source_file_properties)

  set(single_args SOURCE DESTINATION)
  set(multi_args SOURCE_PROPERTIES DESTINATION_PROPERTIES)

  cmake_parse_arguments(
    "MAP_PROPERTIES"
    ""
    "${single_args}"
    "${multi_args}"
    ${ARGN}
  )

  if (NOT MAP_PROPERTIES_SOURCE)
    message(FATAL_ERROR 
      "map_source_file_properties SOURCE: source source file not specified"
    )
  endif ()
  if (NOT MAP_PROPERTIES_DESTINATION)
    message(FATAL_ERROR 
      "map_source_file_properties DESTINATION: destination source file not specified"
    )
  endif ()
  if (NOT MAP_PROPERTIES_SOURCE_PROPERTIES)
    message(FATAL_ERROR 
      "map_source_file_properties SOURCE_PROPERTIES: properties not specified"
    )
  endif ()
  if (NOT MAP_PROPERTIES_DESTINATION_PROPERTIES)
    message(FATAL_ERROR 
      "map_source_file_properties DESTINATION_PROPERTIES: properties not specified"
    )
  endif ()

  map_properties(
    SOURCE SOURCE "${MAP_PROPERTIES_SOURCE}"
    DESTINATION SOURCE "${MAP_PROPERTIES_DESTINATION}"
    SOURCE_PROPERTIES "${MAP_PROPERTIES_SOURCE_PROPERTIES}"
    DESTINATION_PROPERTIES "${MAP_PROPERTIES_DESTINATION_PROPERTIES}"
  )

endfunction()

#.rst:
# .. command:: map_directory_properties:
#
# Maps properties from a source test to a given destination test
#
# .. code-block:: cmake
#
#   map_directory_properties(
#     [SOURCE <source>]
#     [DESTINATION <destination>]
#     SOURCE_PROPERTIES source_prop1 source_prop2 ...
#     DESTINATION_PROPERTIES dest_prop1 dest_prop2 ...
#   )
#
# Maps all properties specified by ``source_prop1``, 
# ``source_prop2``, ... from the source directory ``<source>`` to the 
# destination directory ``<destination>``'s ``dest_prop1``, 
# ``dest_prop2`, ....
#
# If unspecified, the default ``SOURCE`` or ``DIRECTORY`` is the current 
# source directory. 
#
# Note: At least one of ``SOURCE`` or ``DESTINATION`` must be specified.
function(map_directory_properties)

  set(single_args SOURCE DESTINATION)
  set(multi_args SOURCE_PROPERTIES DESTINATION_PROPERTIES)

  cmake_parse_arguments(
    "MAP_PROPERTIES"
    ""
    "${single_args}"
    "${multi_args}"
    ${ARGN}
  )

  if (NOT MAP_PROPERTIES_SOURCE AND NOT MAP_PROPERTIES_DESTINATION)
    message(FATAL_ERROR 
      "map_directory_properties: both SOURCE and DESTINATION not specified"
    )
  endif ()
  if (NOT MAP_PROPERTIES_SOURCE_PROPERTIES)
    message(FATAL_ERROR 
      "map_directory_properties SOURCE_PROPERTIES: properties not specified"
    )
  endif ()
  if (NOT MAP_PROPERTIES_DESTINATION_PROPERTIES)
    message(FATAL_ERROR 
      "map_directory_properties DESTINATION_PROPERTIES: properties not specified"
    )
  endif ()

  # Args are set up independently here so that the 'SOURCE' and 'DESTINATION' value can
  # retain any spaces when passed to 'copy_properties' below. This is necessary since 
  # filepaths on some systems may contain spaces.
  set(source_arg DIRECTORY)
  if (MAP_PROPERTIES_SOURCE)
    set(source_arg DIRECTORY "${MAP_PROPERTIES_SOURCE}")
  endif ()

  set(destination_arg DIRECTORY)
  if (MAP_PROPERTIES_DESTINATION)
    set(destination_arg DIRECTORY "${MAP_PROPERTIES_DESTINATION}")
  endif ()

  map_properties(
    SOURCE "${source_arg}"
    DESTINATION "${destination_arg}"
    SOURCE_PROPERTIES "${MAP_PROPERTIES_SOURCE_PROPERTIES}"
    DESTINATION_PROPERTIES "${MAP_PROPERTIES_DESTINATION_PROPERTIES}"
  )

endfunction()