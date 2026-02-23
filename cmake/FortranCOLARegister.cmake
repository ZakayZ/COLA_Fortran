if(NOT COLA_Fortran_TEMPLATES_DIR)
  set(COLA_Fortran_TEMPLATES_DIR "templates")
endif()

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
  cmake_parse_arguments(ARG "" "USER_MODULE_NAME;MODULE_NAME;FILTER_TYPE;OUTPUT_DIR" "TYPE_NAMES" ${ARGN})
  string(TOLOWER "${ARG_FILTER_TYPE}" FILTER_TYPE_LOWER)

  set(HEADER_FILES "")
  set(CPP_FILES "")
  set(FORTRAN_FILES "")

  set(WRAPPER_MODULE )
  set(CPP_WRAPPER_NAME "Fortran${ARG_FILTER_TYPE}")

  foreach(TYPE_NAME IN LISTS ARG_TYPE_NAMES)
    set(GENERATED_HEADER_PATH "${ARG_OUTPUT_DIR}/${MODULE_NAME}/${TYPE_NAME}.hh")
    set(GENERATED_CPP_PATH "${ARG_OUTPUT_DIR}/${TYPE_NAME}.cc")
    set(GENERATED_FORTRAN_PATH "${ARG_OUTPUT_DIR}/${TYPE_NAME}_wrapper.f90")
    configure_template(
      TEMPLATE "${COLA_Fortran_TEMPLATES_DIR}/cpp/${CPP_WRAPPER_NAME}.hh.in"
      OUTPUT  ${GENERATED_HEADER_PATH}
      VARS   CLASS_NAME "${TYPE_NAME}"
    )
    configure_template(
      TEMPLATE "${COLA_Fortran_TEMPLATES_DIR}/cpp/${CPP_WRAPPER_NAME}.cc.in"
      OUTPUT  ${GENERATED_CPP_PATH}
      VARS   CLASS_NAME "${TYPE_NAME}" MODULE_NAME "${MODULE_NAME}"
    )
    configure_template(
      TEMPLATE "${COLA_Fortran_TEMPLATES_DIR}/fortran/${FILTER_TYPE_LOWER}_wrapper.f90.in"
      OUTPUT  ${GENERATED_FORTRAN_PATH}
      VARS   WRAPPER_MODULE "${FILTER_TYPE_LOWER}_wrapper" USER_MODULE_NAME "${ARG_USER_MODULE_NAME}"
             TYPE_NAME "${TYPE_NAME}"
    )

    list(APPEND HEADER_FILES ${GENERATED_HEADER_PATH})
    list(APPEND CPP_FILES ${GENERATED_CPP_PATH})
    list(APPEND FORTRAN_FILES ${GENERATED_FORTRAN_PATH})

  endforeach()

  set(GENERATED_FORTRAN_FILES "${FORTRAN_FILES}" PARENT_SCOPE)
  set(GENERATED_HEADER_FILES "${HEADER_FILES}" PARENT_SCOPE)
  set(GENERATED_CPP_FILES "${CPP_FILES}" PARENT_SCOPE)

endfunction()

function(register_fortran_source)
  cmake_parse_arguments(ARG "" "MODULE_NAME;FORTRAN_FILE;OUTPUT_DIR" "" ${ARGN})
  if(NOT ARG_MODULE_NAME)
    message(FATAL_ERROR "register_fortran_source requires MODULE_NAME")
  endif()
  if(NOT ARG_FORTRAN_FILE)
    message(FATAL_ERROR "register_fortran_source requires FORTRAN_FILE")
  endif()
  if(NOT ARG_OUTPUT_DIR)
    message(FATAL_ERROR "register_fortran_source requires OUTPUT_DIR)")
  endif()
  file(MAKE_DIRECTORY "${ARG_OUTPUT_DIR}")

  get_filename_component(FORTRAN_FILE_ABS "${ARG_FORTRAN_FILE}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
  if(NOT EXISTS "${FORTRAN_FILE_ABS}")
    message(FATAL_ERROR "register_fortran_source: file not found: ${FORTRAN_FILE_ABS}")
  endif()
  file(READ "${FORTRAN_FILE_ABS}" FCONTENT)

  string(REGEX MATCH "module[ \t]+([a-zA-Z_][a-zA-Z0-9_]*)" _ "${FCONTENT}")
  set(USER_MODULE_NAME "${CMAKE_MATCH_1}")
  if(NOT USER_MODULE_NAME)
    set(GENERATED_FORTRAN_SOURCE_FILES "" PARENT_SCOPE)
    set(GENERATED_HEADER_SOURCE_FILES "" PARENT_SCOPE)
    set(GENERATED_CPP_SOURCE_FILES "" PARENT_SCOPE)
    set(COLA_FILTERS "" PARENT_SCOPE)
    return()
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

  set(_GENERATED_FORTRAN_SOURCE_FILES "")
  set(_GENERATED_HEADER_SOURCE_FILES "")
  set(_GENERATED_CPP_SOURCE_FILES "")

  _register_fortran_source_filters(
    TYPE_NAMES    "${CONVERTER_TYPES}"
    USER_MODULE_NAME  "${USER_MODULE_NAME}"
    MODULE_NAME       "${MODULE_NAME}"
    FILTER_TYPE         Converter
    OUTPUT_DIR   "${ARG_OUTPUT_DIR}"
  )
  list(APPEND _GENERATED_FORTRAN_SOURCE_FILES ${GENERATED_FORTRAN_FILES})
  list(APPEND _GENERATED_HEADER_SOURCE_FILES ${GENERATED_HEADER_FILES})
  list(APPEND _GENERATED_CPP_SOURCE_FILES ${GENERATED_CPP_FILES})

  _register_fortran_source_filters(
    TYPE_NAMES    "${GENERATOR_TYPES}"
    USER_MODULE_NAME  "${USER_MODULE_NAME}"
    MODULE_NAME       "${MODULE_NAME}"
    FILTER_TYPE         Generator
    OUTPUT_DIR   "${ARG_OUTPUT_DIR}"
  )
  list(APPEND _GENERATED_FORTRAN_SOURCE_FILES ${GENERATED_FORTRAN_FILES})
  list(APPEND _GENERATED_HEADER_SOURCE_FILES ${GENERATED_HEADER_FILES})
  list(APPEND _GENERATED_CPP_SOURCE_FILES ${GENERATED_CPP_FILES})

  _register_fortran_source_filters(
    TYPE_NAMES    "${WRITER_TYPES}"
    USER_MODULE_NAME  "${USER_MODULE_NAME}"
    MODULE_NAME       "${MODULE_NAME}"
    FILTER_TYPE         Writer
    OUTPUT_DIR   "${ARG_OUTPUT_DIR}"
  )
  list(APPEND _GENERATED_FORTRAN_SOURCE_FILES ${GENERATED_FORTRAN_FILES})
  list(APPEND _GENERATED_HEADER_SOURCE_FILES ${GENERATED_HEADER_FILES})
  list(APPEND _GENERATED_CPP_SOURCE_FILES ${GENERATED_CPP_FILES})

  set(_COLA_FILTERS "")
  list(APPEND _COLA_FILTERS ${GENERATOR_TYPES})
  list(APPEND _COLA_FILTERS ${CONVERTER_TYPES})
  list(APPEND _COLA_FILTERS ${WRITER_TYPES})
  set(COLA_FILTERS "${_COLA_FILTERS}" PARENT_SCOPE)

  set(GENERATED_FORTRAN_SOURCE_FILES "${_GENERATED_FORTRAN_SOURCE_FILES}" PARENT_SCOPE)
  set(GENERATED_HEADER_SOURCE_FILES "${_GENERATED_HEADER_SOURCE_FILES}" PARENT_SCOPE)
  set(GENERATED_CPP_SOURCE_FILES "${_GENERATED_CPP_SOURCE_FILES}" PARENT_SCOPE)
endfunction()

function(add_cola_fortran_library MODULE_NAME)
  cmake_parse_arguments(ARG "" "" "SOURCES" ${ARGN})
  if(NOT MODULE_NAME)
    message(FATAL_ERROR "add_wrapper_library requires a target name")
  endif()
  if(NOT ARG_SOURCES)
    message(FATAL_ERROR "add_wrapper_library requires SOURCES")
  endif()
  set(OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/generated")
  file(MAKE_DIRECTORY "${OUTPUT_DIR}")

  set(ALL_GENERATED_FORTRAN_FILES "")
  set(ALL_GENERATED_CPP_FILES "")
  set(ALL_GENERATED_HEADER_FILES "")
  set(ALL_COLA_FILTERS "")
  foreach(SOURCE IN LISTS ARG_SOURCES)
    register_fortran_source(MODULE_NAME "${MODULE_NAME}" FORTRAN_FILE "${SOURCE}" OUTPUT_DIR "${OUTPUT_DIR}")
    list(APPEND ALL_GENERATED_FORTRAN_FILES ${GENERATED_FORTRAN_SOURCE_FILES})
    list(APPEND ALL_GENERATED_CPP_FILES ${GENERATED_CPP_SOURCE_FILES})
    list(APPEND ALL_GENERATED_HEADER_FILES ${GENERATED_HEADER_SOURCE_FILES})
    list(APPEND ALL_COLA_FILTERS ${COLA_FILTERS})
  endforeach()

  string(REPLACE ";" "Factory, " COMMA_SEPARATED_CLASS_NAMES "${ALL_COLA_FILTERS}")
  set(COMMA_SEPARATED_CLASS_NAMES "${COMMA_SEPARATED_CLASS_NAMES}Factory")

  string(REPLACE ";" ".hh>\n#include <${MODULE_NAME}/" INCLUDE_FORTRAN_WRAPPER_CLASSES "${ALL_COLA_FILTERS}")
  set(INCLUDE_FORTRAN_WRAPPER_CLASSES "#include <${MODULE_NAME}/${INCLUDE_FORTRAN_WRAPPER_CLASSES}.hh>")

  configure_template(
    TEMPLATE "${COLA_Fortran_TEMPLATES_DIR}/cpp/FortranModule.hh.in"
    OUTPUT  "${OUTPUT_DIR}/${MODULE_NAME}/${MODULE_NAME}Module.hh"
    VARS   MODULE_NAME "${MODULE_NAME}"
           COMMA_SEPARATED_CLASS_NAMES ${COMMA_SEPARATED_CLASS_NAMES}
           INCLUDE_FORTRAN_WRAPPER_CLASSES ${INCLUDE_FORTRAN_WRAPPER_CLASSES}
  )

  configure_template(
    TEMPLATE "${COLA_Fortran_TEMPLATES_DIR}/cpp/FortranModule.cc.in"
    OUTPUT  "${OUTPUT_DIR}/${MODULE_NAME}Module.cc"
    VARS   MODULE_NAME "${MODULE_NAME}"
  )

  add_library(${MODULE_NAME} SHARED
    ${ARG_SOURCES}
    ${ALL_GENERATED_FORTRAN_FILES}
    ${ALL_GENERATED_CPP_FILES}
    "${OUTPUT_DIR}/${MODULE_NAME}Module.cc"
  )

  set_target_properties(${MODULE_NAME} PROPERTIES
      Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/modules
      LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  )

  target_link_libraries(${MODULE_NAME} PUBLIC COLA_Fortran)

endfunction()
