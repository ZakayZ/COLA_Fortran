#
# Copyright (c) 2024-2025 Alexandr Svetlichnyi, Savva Savenkov, Artemii Novikov
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
# associated documentation files (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge, publish, distribute,
# sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or
# substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
# NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

cmake_minimum_required(VERSION 3.14)
project(Urqmd4 VERSION 0.1.0 LANGUAGES CXX Fortran)

include(GNUInstallDirs)

find_package(COLA_Fortran REQUIRED)

set(CMAKE_INSTALL_PREFIX ${COLA_DIR})
set(COLA_MODULE_NAME Urqmd4)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

# ---------------------------------------------------------------------------
# URQMD static library (exclude main program urqmd.f)
# ---------------------------------------------------------------------------
set(URQMD_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/urqmd-4.0)

# Explicit source list from GNUmakefile SRC, minus urqmd.f, using gnuranf.f
set(URQMD_F_SOURCES
  ${URQMD_SOURCE_DIR}/1fluid.f
  ${URQMD_SOURCE_DIR}/addpart.f
  ${URQMD_SOURCE_DIR}/angdis.f
  ${URQMD_SOURCE_DIR}/anndec.f
  ${URQMD_SOURCE_DIR}/bessel.f
  ${URQMD_SOURCE_DIR}/blockres.f
  ${URQMD_SOURCE_DIR}/boxprg.f
  ${URQMD_SOURCE_DIR}/cascinit.f
  ${URQMD_SOURCE_DIR}/CFmax.f90
  ${URQMD_SOURCE_DIR}/coload.f
  ${URQMD_SOURCE_DIR}/cornelius.f90
  ${URQMD_SOURCE_DIR}/dectim.f
  ${URQMD_SOURCE_DIR}/delpart.f
  ${URQMD_SOURCE_DIR}/detbal.f
  ${URQMD_SOURCE_DIR}/dwidth.f
  ${URQMD_SOURCE_DIR}/error.f
  ${URQMD_SOURCE_DIR}/getmass.f
  ${URQMD_SOURCE_DIR}/getspin.f
  ${URQMD_SOURCE_DIR}/gnuranf.f
  ${URQMD_SOURCE_DIR}/hepchg.f
  ${URQMD_SOURCE_DIR}/hepcmp.f
  ${URQMD_SOURCE_DIR}/hepnam.f
  ${URQMD_SOURCE_DIR}/init.f
  ${URQMD_SOURCE_DIR}/input.f
  ${URQMD_SOURCE_DIR}/iso.f
  ${URQMD_SOURCE_DIR}/ityp2pdg.f
  ${URQMD_SOURCE_DIR}/jdecay2.f
  ${URQMD_SOURCE_DIR}/make22.f
  ${URQMD_SOURCE_DIR}/numrec.f
  ${URQMD_SOURCE_DIR}/output.f
  ${URQMD_SOURCE_DIR}/paulibl.f
  ${URQMD_SOURCE_DIR}/proppot.f
  ${URQMD_SOURCE_DIR}/pythia6409.f
  ${URQMD_SOURCE_DIR}/quadri.f90
  ${URQMD_SOURCE_DIR}/saveinfo.f
  ${URQMD_SOURCE_DIR}/scatter.f
  ${URQMD_SOURCE_DIR}/siglookup.f
  ${URQMD_SOURCE_DIR}/string.f
  ${URQMD_SOURCE_DIR}/tabinit.f
  ${URQMD_SOURCE_DIR}/uhmerge.f
  ${URQMD_SOURCE_DIR}/upmerge.f
  ${URQMD_SOURCE_DIR}/whichres.f
)

add_library(urqmd_static STATIC ${URQMD_F_SOURCES}
  ${CMAKE_CURRENT_SOURCE_DIR}/urqmd_cola_bridge.f
)
set_target_properties(urqmd_static PROPERTIES
  Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/urqmd_modules
)
target_include_directories(urqmd_static PRIVATE ${URQMD_SOURCE_DIR})

# ---------------------------------------------------------------------------
# Fortran Lib (COLA wrapper)
# ---------------------------------------------------------------------------

add_cola_fortran_library(
  ${COLA_MODULE_NAME}
  SOURCES
    cola_fortran_generator_impl.f90
)

target_include_directories(${COLA_MODULE_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/generated>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)
target_include_directories(${COLA_MODULE_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/modules>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${COLA_MODULE_NAME}/modules>
)
target_link_libraries(${COLA_MODULE_NAME} PRIVATE urqmd_static)

# ---------------------------------------------------------------------------
# Installation
# ---------------------------------------------------------------------------

set(GENERATED_HEADERS_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated/${COLA_MODULE_NAME})

install(TARGETS ${COLA_MODULE_NAME}
    EXPORT ${COLA_MODULE_NAME}Export
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/${COLA_MODULE_NAME}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${COLA_MODULE_NAME}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${COLA_MODULE_NAME}
)

include(CMakePackageConfigHelpers)

configure_package_config_file(
    ${PROJECT_SOURCE_DIR}/data/${COLA_MODULE_NAME}Config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/${COLA_MODULE_NAME}Config.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${COLA_MODULE_NAME}
)

write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/${COLA_MODULE_NAME}ConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY AnyNewerVersion
)

install(EXPORT ${COLA_MODULE_NAME}Export DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${COLA_MODULE_NAME})

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/modules/
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${COLA_MODULE_NAME}/modules
    FILES_MATCHING PATTERN "*.mod"
)

message(STATUS "cola dir: ${COLA_DIR}; include ${CMAKE_INSTALL_INCLUDEDIR}")
install(DIRECTORY ${GENERATED_HEADERS_DIR}
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.hh"
)

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${COLA_MODULE_NAME}Config.cmake"
              "${CMAKE_CURRENT_BINARY_DIR}/${COLA_MODULE_NAME}ConfigVersion.cmake"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${COLA_MODULE_NAME}
)

# ---------------------------------------------------------------------------
# Runner Lib
# ---------------------------------------------------------------------------
# Run from urqmd-4/: ./build/Runner  (urqmd_compare_input in urqmd-4/)

add_executable(
  Runner
  run.cpp
)

target_link_libraries(
  Runner
  PUBLIC
  ${COLA_MODULE_NAME}
)
target_include_directories(
  Runner
  PUBLIC
  ${CMAKE_CURRENT_BINARY_DIR}/generated
)

# RunCompare: dump first event for comparison with pure UrQMD
add_executable(
  RunCompare
  run_compare.cpp
)
target_link_libraries(
  RunCompare
  PUBLIC
  ${COLA_MODULE_NAME}
)
target_include_directories(
  RunCompare
  PUBLIC
  ${CMAKE_CURRENT_BINARY_DIR}/generated
)
