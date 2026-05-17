cmake_minimum_required(VERSION 3.14)
project(
    ExampleFortran
    VERSION 0.3.2
    LANGUAGES CXX Fortran
)

include(GNUInstallDirs)

find_package(COLA_Fortran REQUIRED)

set(CMAKE_INSTALL_PREFIX ${COLA_DIR})
set(COLA_MODULE_NAME ExampleFortran)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

# ---------------------------------------------------------------------------
# Fortran Lib
# ---------------------------------------------------------------------------

add_cola_fortran_library(
    ${COLA_MODULE_NAME} SOURCES cola_fortran_converter_impl.f90 cola_fortran_generator_impl.f90
    cola_fortran_writer_impl.f90
)

target_include_directories(
    ${COLA_MODULE_NAME} PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/generated>
                               $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

target_include_directories(
    ${COLA_MODULE_NAME}
    PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/modules>
           $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${COLA_MODULE_NAME}/modules>
)

# ---------------------------------------------------------------------------
# Runner Lib
# ---------------------------------------------------------------------------

add_executable(Runner run.cpp)

target_link_libraries(Runner PUBLIC ${COLA_MODULE_NAME})

target_include_directories(Runner PUBLIC ${CMAKE_CURRENT_BINARY_DIR}/generated)
