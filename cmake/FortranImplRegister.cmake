function(configure_template)
  cmake_parse_arguments(ARG "" "TEMPLATE;OUTPUT" "VARS" ${ARGN})
  if(NOT ARG_TEMPLATE OR NOT ARG_OUTPUT)
    message(FATAL_ERROR "configure_template requires TEMPLATE and OUTPUT")
  endif()
  list(LENGTH ARG_VARS ARGS_NUM)
  math(EXPR ARGS_NUM_MOD "${ARGS_NUM} % 2")
  if(ARGS_NUM GREATER 0 AND (ARGS_NUM LESS 2 OR NOT (ARGS_NUM_MOD EQUAL 0)))
    message(FATAL_ERROR "configure_template VARS must be key value pairs")
  endif()
  if(ARGS_NUM GREATER 0)
    math(EXPR LAST "${ARGS_NUM} - 2")
    foreach(i RANGE 0 ${LAST} 2)
      list(GET ARG_VARS ${i} KEY)
      math(EXPR j "${i} + 1")
      list(GET ARG_VARS ${j} VALUE)
      set(${KEY} "${VALUE}")
    endforeach()
  endif()
  configure_file(${ARG_TEMPLATE} ${ARG_OUTPUT} @ONLY)
endfunction()

function(_register_fortran_source_filters)
  cmake_parse_arguments(ARG "" "IMPL_MODULE;FILTER_TYPE;TEMPLATE_BASE;OUTPUT_DIR" "TYPE_NAMES" ${ARGN})
  string(TOLOWER "${ARG_FILTER_TYPE}" FILTER_TYPE_LOWER)

  set(HEADER_FILES "")
  set(CPP_FILES "")
  set(FORTRAN_FILES "")

  set(WRAPPER_MODULE )
  set(CPP_WRAPPER_NAME "Fortran${ARG_FILTER_TYPE}")

  foreach(TYPE_NAME IN LISTS ARG_TYPE_NAMES)
    configure_template(
      TEMPLATE "${ARG_TEMPLATE_BASE}/cpp/${CPP_WRAPPER_NAME}.hh.in"
      OUTPUT  "${ARG_OUTPUT_DIR}/COLA/${TYPE_NAME}.hh"
      VARS   CLASS_NAME "${TYPE_NAME}"
    )
    configure_template(
      TEMPLATE "${ARG_TEMPLATE_BASE}/cpp/${CPP_WRAPPER_NAME}.cc.in"
      OUTPUT  "${ARG_OUTPUT_DIR}/${TYPE_NAME}.cc"
      VARS   CLASS_NAME "${TYPE_NAME}"
    )
    configure_template(
      TEMPLATE "${ARG_TEMPLATE_BASE}/fortran/cola_fortran_${FILTER_TYPE_LOWER}_wrapper.f90.in"
      OUTPUT  "${ARG_OUTPUT_DIR}/${TYPE_NAME}_wrapper.f90"
      VARS   WRAPPER_MODULE "cola_fortran_${FILTER_TYPE_LOWER}_wrapper" IMPL_MODULE "${ARG_IMPL_MODULE}"
             TYPE_NAME "${TYPE_NAME}"
    )

    list(APPEND FORTRAN_FILES "${ARG_OUTPUT_DIR}/${TYPE_NAME}_wrapper.f90")
    list(APPEND HEADER_FILES "${ARG_OUTPUT_DIR}/${TYPE_NAME}.hh")
    list(APPEND CPP_FILES "${ARG_OUTPUT_DIR}/${TYPE_NAME}.cc")

  endforeach()

  set(GENERATED_FORTRAN_FILES "${FORTRAN_FILES}" PARENT_SCOPE)
  set(GENERATED_HEADER_FILES "${HEADER_FILES}" PARENT_SCOPE)
  set(GENERATED_CPP_FILES "${CPP_FILES}" PARENT_SCOPE)

endfunction()

function(register_fortran_source)
  cmake_parse_arguments(ARG "" "FORTRAN_FILE;OUTPUT_DIR" "" ${ARGN})
  if(NOT ARG_FORTRAN_FILE)
    message(FATAL_ERROR "register_fortran_source requires FORTRAN_FILE")
  endif()
  if(NOT ARG_OUTPUT_DIR)
    set(ARG_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")
  endif()
  file(MAKE_DIRECTORY "${ARG_OUTPUT_DIR}" "${ARG_OUTPUT_DIR}/COLA")

  get_filename_component(FORTRAN_FILE_ABS "${ARG_FORTRAN_FILE}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
  if(NOT EXISTS "${FORTRAN_FILE_ABS}")
    message(FATAL_ERROR "register_fortran_source: file not found: ${FORTRAN_FILE_ABS}")
  endif()
  file(READ "${FORTRAN_FILE_ABS}" FCONTENT)

  string(REGEX MATCH "module[ \t]+([a-zA-Z_][a-zA-Z0-9_]*)" _ "${FCONTENT}")
  set(IMPL_MODULE "${CMAKE_MATCH_1}")
  if(NOT IMPL_MODULE)
    message(FATAL_ERROR "register_fortran_source: could not parse module name from ${ARG_FORTRAN_FILE}")
  endif()
  
  set(CONVERTER_TYPES "")
  string(REGEX MATCHALL "extends[ \t]*\\([ \t]*AbstractFortranConverter[ \t]*\\)[ \t]*::[ \t]*([a-zA-Z_][a-zA-Z0-9_]*)" _ "${FCONTENT}")
  if(CMAKE_MATCH_1)
    set(CONVERTER_TYPES ${CMAKE_MATCH_1})
  endif()
  
  set(GENERATOR_TYPES "")
  string(REGEX MATCHALL "extends[ \t]*\\([ \t]*AbstractFortranGenerator[ \t]*\\)[ \t]*::[ \t]*([a-zA-Z_][a-zA-Z0-9_]*)" _ "${FCONTENT}")
  if(CMAKE_MATCH_1)
    set(GENERATOR_TYPES ${CMAKE_MATCH_1})
  endif()
  
  set(WRITER_TYPES "")
  string(REGEX MATCHALL "extends[ \t]*\\([ \t]*AbstractFortranWriter[ \t]*\\)[ \t]*::[ \t]*([a-zA-Z_][a-zA-Z0-9_]*)" _ "${FCONTENT}")
  if(CMAKE_MATCH_1)
    set(WRITER_TYPES ${CMAKE_MATCH_1})
  endif()

  set(_TEMPLATE_BASE "${CMAKE_CURRENT_SOURCE_DIR}/templates")
  set(_GENERATED_FORTRAN_SOURCE_FILES "")
  set(_GENERATED_HEADER_SOURCE_FILES "")
  set(_GENERATED_CPP_SOURCE_FILES "")

  _register_fortran_source_filters(
    TYPE_NAMES    "${CONVERTER_TYPES}"
    IMPL_MODULE  "${IMPL_MODULE}"
    FILTER_TYPE         Converter
    TEMPLATE_BASE "${_TEMPLATE_BASE}"
    OUTPUT_DIR   "${ARG_OUTPUT_DIR}"
  )
  list(APPEND _GENERATED_FORTRAN_SOURCE_FILES ${GENERATED_FORTRAN_FILES})
  list(APPEND _GENERATED_HEADER_SOURCE_FILES ${GENERATED_HEADER_FILES})
  list(APPEND _GENERATED_CPP_SOURCE_FILES ${GENERATED_CPP_FILES})

  _register_fortran_source_filters(
    TYPE_NAMES    "${GENERATOR_TYPES}"
    IMPL_MODULE  "${IMPL_MODULE}"
    FILTER_TYPE         Generator
    TEMPLATE_BASE "${_TEMPLATE_BASE}"
    OUTPUT_DIR   "${ARG_OUTPUT_DIR}"
  )
  list(APPEND _GENERATED_FORTRAN_SOURCE_FILES ${GENERATED_FORTRAN_FILES})
  list(APPEND _GENERATED_HEADER_SOURCE_FILES ${GENERATED_HEADER_FILES})
  list(APPEND _GENERATED_CPP_SOURCE_FILES ${GENERATED_CPP_FILES})

  _register_fortran_source_filters(
    TYPE_NAMES    "${WRITER_TYPES}"
    IMPL_MODULE  "${IMPL_MODULE}"
    FILTER_TYPE         Writer
    TEMPLATE_BASE "${_TEMPLATE_BASE}"
    OUTPUT_DIR   "${ARG_OUTPUT_DIR}"
  )
  list(APPEND _GENERATED_FORTRAN_SOURCE_FILES ${GENERATED_FORTRAN_FILES})
  list(APPEND _GENERATED_HEADER_SOURCE_FILES ${GENERATED_HEADER_FILES})
  list(APPEND _GENERATED_CPP_SOURCE_FILES ${GENERATED_CPP_FILES})

  set(GENERATED_FORTRAN_SOURCE_FILES "${_GENERATED_FORTRAN_SOURCE_FILES}" PARENT_SCOPE)
  set(GENERATED_HEADER_SOURCE_FILES "${_GENERATED_HEADER_SOURCE_FILES}" PARENT_SCOPE)
  set(GENERATED_CPP_SOURCE_FILES "${_GENERATED_CPP_SOURCE_FILES}" PARENT_SCOPE)
endfunction()

function(add_cola_fortran_library TARGET_NAME)
  cmake_parse_arguments(ARG "" "" "SOURCES" ${ARGN})
  if(NOT TARGET_NAME)
    message(FATAL_ERROR "cola_fortran_add_wrapper_library requires a target name")
  endif()
  if(NOT ARG_SOURCES)
    message(FATAL_ERROR "cola_fortran_add_wrapper_library requires SOURCES")
  endif()
  set(OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")
  file(MAKE_DIRECTORY "${OUTPUT_DIR}")

  set(ALL_GENERATED_FORTRAN_FILES "")
  set(ALL_GENERATED_CPP_FILES "")
  foreach(SOURCE IN LISTS ARG_SOURCES)
    register_fortran_source(FORTRAN_FILE "${SOURCE}" OUTPUT_DIR "${OUTPUT_DIR}")
    list(APPEND ALL_GENERATED_FORTRAN_FILES ${GENERATED_FORTRAN_SOURCE_FILES})
    list(APPEND ALL_GENERATED_CPP_FILES ${GENERATED_CPP_SOURCE_FILES})
  endforeach()

  add_library(${TARGET_NAME} STATIC
    ${ARG_SOURCES}
    ${ALL_GENERATED_FORTRAN_FILES}
    ${ALL_GENERATED_FORTRAN_FILES}
  )
  target_link_libraries(${TARGET_NAME} PRIVATE cola_fortran COLA)
  target_include_directories(${TARGET_NAME} PRIVATE
    ${CMAKE_CURRENT_BINARY_DIR}/modules
    ${OUTPUT_DIR}
  )
  target_compile_features(${TARGET_NAME} PRIVATE cxx_std_17)
  install(TARGETS ${TARGET_NAME} ARCHIVE DESTINATION lib)

endfunction()
