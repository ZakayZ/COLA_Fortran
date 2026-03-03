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
project(COLA_UrQMD VERSION 0.1.0 LANGUAGES CXX Fortran)

include(GNUInstallDirs)

find_package(COLA_Fortran REQUIRED)

set(CMAKE_INSTALL_PREFIX ${COLA_DIR})
set(COLA_MODULE_NAME COLA_UrQMD)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

set(URQMD_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/urqmd-4.0)

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

add_cola_fortran_library(
  ${COLA_MODULE_NAME}
  SOURCES
    cola_fortran_generator_impl.f90
    urqmd_cola_ref.f
    ${URQMD_F_SOURCES}
)

target_compile_options(${COLA_MODULE_NAME} PRIVATE -fPIC)

target_compile_options(${COLA_MODULE_NAME} PRIVATE
  $<$<AND:$<COMPILE_LANGUAGE:Fortran>,$<Fortran_COMPILER_ID:GNU>>:-fcoarray=single;-finit-local-zero>
)

target_include_directories(${COLA_MODULE_NAME} PRIVATE
    $<$<COMPILE_LANGUAGE:Fortran>:${URQMD_SOURCE_DIR}>
)

target_include_directories(${COLA_MODULE_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/generated>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)
target_include_directories(${COLA_MODULE_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/modules>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/${COLA_MODULE_NAME}/modules>
)

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
