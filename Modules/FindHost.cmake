# Copyright (c) Matthew Rodusek
# Distributed under the OSI-approved MIT License. See accompanying
# file LICENSE.txt or https://opensource.org/licenses/MIT for details.

#.rst:
# FindHost
# --------
#
# This module defines various utilities for finding packages, libraries,
# executables, or modules in standard way while cross-compiling.

#.rst:
# .. command:: find_host_package
#
# Finds a package using the host computer's find paths.
#
# .. code-block:: cmake
#
#   find_host_package([<arg>...])
# 
# Calls the :command:`find_package` command with ``<arg>...``, but searches
# on the host system instead of the target system.
macro(find_host_package)
  # all mode variables are set to 'never', since find_package calls
  # may be calling arbitrary CMake which will also implicitly depend on 
  # these variables. Not setting these would otherwise have any 
  # 'find_library', 'find_file', 'find_executable', etc being found from
  # the target system, rather than the host system.
  set(__OLD_LIBRARY_MODE ${CMAKE_FIND_ROOT_PATH_MODE_LIBRARY})
  set(__OLD_PROGRAM_MODE ${CMAKE_FIND_ROOT_PATH_MODE_PROGRAM})
  set(__OLD_INCLUDE_MODE ${CMAKE_FIND_ROOT_PATH_MODE_INCLUDE})
  set(CMAKE_FIND_ROOT_PATH_MODE_LIBARY NEVER)
  set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
  set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER)

  find_package(${ARGN})

  set(CMAKE_FIND_ROOT_PATH_MODE_LIBARY ${__OLD_LIBRARY_MODE})
  set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ${__OLD_PROGRAM_MODE})
  set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ${__OLD_INCLUDE_MODE})
  unset(__OLD_LIBRARY_MODE)
  unset(__OLD_PROGRAM_MODE)
  unset(__OLD_INCLUDE_MODE)
endmacro()

#.rst:
# .. command:: find_host_library
#
# Finds a library on the host computer.
#
# .. code-block:: cmake
#
#   find_host_library([<arg>...])
# 
# Calls the :command:`find_library` command with ``<arg>...``, but searches
# on the host system instead of the target system.
macro(find_host_library)
  set(__OLD_MODE ${CMAKE_FIND_ROOT_PATH_MODE_LIBRARY})
  set(CMAKE_FIND_ROOT_PATH_MODE_LIBARY NEVER)
  find_library(${ARGN})
  set(CMAKE_FIND_ROOT_PATH_MODE_LIBARY ${__OLD_MODE})
  unset(__OLD_MODE)
endmacro()

#.rst:
# .. command:: find_host_program
#
# Finds a program on the host computer.
#
# .. code-block:: cmake
#
#   find_host_program([<arg>...])
# 
# Calls the :command:`find_program` command with ``<arg>...``, but searches
# on the host system instead of the target system.
macro(find_host_program)
  set(__OLD_MODE ${CMAKE_FIND_ROOT_PATH_MODE_PROGRAM})
  set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
  find_program(${ARGN})
  set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM ${__OLD_MODE})
  unset(__OLD_MODE)
endmacro()

#.rst:
# .. command:: find_host_file
#
# Finds a file on the host computer.
#
# .. code-block:: cmake
#
#   find_host_file([<arg>...])
# 
# Calls the :command:`find_file` command with ``<arg>...``, but searches
# on the host system instead of the target system.
macro(find_host_file)
  set(__OLD_MODE ${CMAKE_FIND_ROOT_PATH_MODE_INCLUDE})
  set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER)
  find_file(${ARGN})
  set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ${__OLD_MODE})
  unset(__OLD_MODE)
endmacro()

#.rst:
# .. command:: find_host_path
#
# Finds a path on the host computer.
#
# .. code-block:: cmake
#
#   find_host_path([<arg>...])
# 
# Calls the :command:`find_path` command with ``<arg>...``, but searches
# on the host system instead of the target system.
macro(find_host_path)
  set(__OLD_MODE ${CMAKE_FIND_ROOT_PATH_MODE_INCLUDE})
  set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER)
  find_path(${ARGN})
  set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ${__OLD_MODE})
  unset(__OLD_MODE)
endmacro()