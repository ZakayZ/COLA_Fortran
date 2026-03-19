list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../cmake")
set(COLA_Fortran_TEMPLATES_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../templates")
include(FortranCOLARegister)

find_package(GTest REQUIRED)
include(GoogleTest)

add_cola_fortran_library(TestFortranFilters SOURCES test_converter.f90 test_generator.f90)

target_include_directories(TestFortranFilters PUBLIC ${CMAKE_CURRENT_BINARY_DIR}/generated)
target_include_directories(TestFortranFilters PUBLIC ${CMAKE_CURRENT_BINARY_DIR}/modules)

add_executable(COLA_FortranTest cola_fortran_test.cc)
target_compile_features(COLA_FortranTest PUBLIC cxx_std_17)

target_link_libraries(
    COLA_FortranTest
    PRIVATE
        TestFortranFilters
        GTest::Main
        GTest::GTest
)

target_include_directories(COLA_FortranTest PRIVATE ${CMAKE_CURRENT_BINARY_DIR}/generated)

gtest_discover_tests(COLA_FortranTest)
