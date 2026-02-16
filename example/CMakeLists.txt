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
project(COLA_Fortran_Example VERSION 0.3.2 LANGUAGES CXX Fortran)

find_package(COLA_Fortran REQUIRED)

add_cola_fortran_library(
  ExampleFortranModule
  SOURCES
    cola_fortran_converter_impl.f90
    cola_fortran_generator_impl.f90
    cola_fortran_writer_impl.f90
)

add_executable(
  Runner
  run.cpp
)

target_link_libraries(
  Runner
  PUBLIC
  ExampleFortranModule
)

target_include_directories(
  Runner
  PUBLIC
  ${CMAKE_CURRENT_BINARY_DIR}/generated
)

get_target_property(inc_dirs Runner INTERFACE_INCLUDE_DIRECTORIES)
message("Provider inc dirs: ${inc_dirs}")
