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
project(COLA_Fortran VERSION 0.1 LANGUAGES CXX Fortran)

include(GNUInstallDirs)

find_package(SWIG REQUIRED)
find_package(COLA REQUIRED)

set(CMAKE_INSTALL_PREFIX ${COLA_DIR})
set(COLA_MODULE_NAME COLA_Fortran)

include(UseSWIG)

enable_language(Fortran)

set(CMAKE_SWIG_OUTDIR ${CMAKE_CURRENT_BINARY_DIR})

add_library(
    ${COLA_MODULE_NAME}_CPP
    SHARED
    COLA_Fortran/utils.cc
)

target_include_directories(${COLA_MODULE_NAME}_CPP PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

set_property(SOURCE cola.i PROPERTY CPLUSPLUS ON)

swig_add_library(${COLA_MODULE_NAME}
    TYPE SHARED
    LANGUAGE fortran
    SOURCES cola.i
)

target_link_libraries(${COLA_MODULE_NAME}_CPP PUBLIC COLA)
target_link_libraries(${COLA_MODULE_NAME} PUBLIC ${COLA_MODULE_NAME}_CPP)

set_target_properties(${COLA_MODULE_NAME} PROPERTIES
    SWIG_USE_TARGET_INCLUDE_DIRECTORIES TRUE
    Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/modules
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)

target_include_directories(${COLA_MODULE_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/modules>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${COLA_MODULE_NAME}/modules>
)

# ---------------------------------------------------------------------------
# Installation
# ---------------------------------------------------------------------------

install(TARGETS ${COLA_MODULE_NAME} ${COLA_MODULE_NAME}_CPP
    EXPORT ${COLA_MODULE_NAME}Export
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

include(CMakePackageConfigHelpers)

set(TEMPLATE_INSTALL_DIR ${CMAKE_INSTALL_DATAROOTDIR}/${COLA_MODULE_NAME}/templates)
set(CMAKE_INSTALL_DIR ${CMAKE_INSTALL_DATAROOTDIR}/${COLA_MODULE_NAME}/cmake)

configure_package_config_file(
    ${PROJECT_SOURCE_DIR}/data/${COLA_MODULE_NAME}Config.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/${COLA_MODULE_NAME}Config.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${COLA_MODULE_NAME}
    PATH_VARS
        TEMPLATE_INSTALL_DIR
        CMAKE_INSTALL_DIR
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

install(DIRECTORY ${PROJECT_SOURCE_DIR}/${COLA_MODULE_NAME}
    DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    FILES_MATCHING PATTERN "*.hh"
)

install(DIRECTORY cmake/
    DESTINATION ${CMAKE_INSTALL_DIR}
    FILES_MATCHING PATTERN "*.cmake"
)

install(DIRECTORY templates/
    DESTINATION ${TEMPLATE_INSTALL_DIR}
)

install(FILES "${CMAKE_CURRENT_BINARY_DIR}/${COLA_MODULE_NAME}Config.cmake"
              "${CMAKE_CURRENT_BINARY_DIR}/${COLA_MODULE_NAME}ConfigVersion.cmake"
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${COLA_MODULE_NAME}
)
