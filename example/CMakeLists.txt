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
project(ExampleFortran VERSION 0.3.2 LANGUAGES CXX Fortran)

include(GNUInstallDirs)

find_package(COLA_Fortran REQUIRED)

set(CMAKE_INSTALL_PREFIX ${COLA_DIR})
set(COLA_MODULE_NAME ExampleFortran)

# ---------------------------------------------------------------------------
# Fortran Lib
# ---------------------------------------------------------------------------

add_cola_fortran_library(
  ${COLA_MODULE_NAME}
  SOURCES
    cola_fortran_converter_impl.f90
    cola_fortran_generator_impl.f90
    cola_fortran_writer_impl.f90
)

target_include_directories(${COLA_MODULE_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/generated>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

target_include_directories(${COLA_MODULE_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/modules>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${COLA_MODULE_NAME}/modules>
)

# ---------------------------------------------------------------------------
# Installation
# ---------------------------------------------------------------------------

set(GENERATED_HEADERS_DIR ${CMAKE_CURRENT_BINARY_DIR}/generated/${COLA_MODULE_NAME})

install(TARGETS ${COLA_MODULE_NAME}
    EXPORT ${COLA_MODULE_NAME}Export
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
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
