# Distributed under the OSI-approved MIT License. See accompanying
# file LICENSE.txt or https://opensource.org/licenses/MIT for details.

#.rst:
# FindCatch2
# ----------
#
# Find Catch2
#
# Find Philsquared's "Catch2" unit test library.
#
# ::
#
#     Catch2::Catch2      - Interface library target for the Catch2 headers
#     Catch2_FOUND        - TRUE if Catch2 was found
#     Catch2_INCLUDE_DIRS - The include path for Catch2 headers

find_path(
  Catch2_INCLUDE_DIR
  NAMES "catch.hpp"
  DOC "Catch2 unit-test include directory"
)

set(
  Catch2_INCLUDE_DIRS 
  ${Catch2_INCLUDE_DIR} CACHE FILEPATH 
  "Include directory for the CATCH unit test"
)

# Create a custom Catch2 target if not already defined
if (NOT TARGET Catch2::Catch2 AND Catch2_INCLUDE_DIRS)
  add_library(Catch2::Catch2 INTERFACE IMPORTED)
  set_target_properties(Catch2::Catch2 PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES ${Catch2_INCLUDE_DIRS}
  )
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Catch2 DEFAULT_MSG Catch2_INCLUDE_DIR)
mark_as_advanced(Catch2_INCLUDE_DIRS)