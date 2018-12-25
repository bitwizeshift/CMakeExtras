# Copyright (c) Matthew Rodusek
# Distributed under the OSI-approved MIT License. See accompanying
# file LICENSE.txt or https://opensource.org/licenses/MIT for details.

#.rst:
# FindGSL
# -------
#
# Find the Microsoft GSL library
#
# The following ``IMPORTED`` targets are defined:
#
#  ``GSL::GSL``
#    Interface library target for the GSL headers
#
# The module defines the following variables:
#
#  ``GSL_FOUND``
#    ``TRUE`` if GSL was found
#  ``GSL_INCLUDE_DIRS``
#    The include path for the GSL

find_path(
  GSL_INCLUDE_DIR /gsl_math.h
  NAMES "gsl/gsl" "gsl/gsl_byte" "gsl/gsl_span"
  DOC "Guideline-Support Library include directory"
)

set(
  GSL_INCLUDE_DIRS
  ${GSL_INCLUDE_DIR} CACHE FILEPATH
  "Include directory for the GSL library"
)

# Create a custom GSL target if not already defined
if (NOT TARGET GSL::GSL AND GSL_INCLUDE_DIRS)
  add_library(GSL::GSL INTERFACE IMPORTED)
  set_target_properties(GSL::GSL
    PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES ${GSL_INCLUDE_DIRS}
  )
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GSL DEFAULT_MSG GSL_INCLUDE_DIR)
mark_as_advanced(GSL_INCLUDE_DIRS)