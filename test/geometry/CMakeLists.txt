add_test(
  NAME load_geometry_tables
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test/scripts
  COMMAND test.sh run_passfail load_geometry_tables "${CMAKE_CURRENT_SOURCE_DIR}/data/load_geometry.sql.xz"
)

set_tests_properties(load_geometry_tables PROPERTIES
  DEPENDS create_extension
  FIXTURES_SETUP DBGEOMETRY
  FIXTURES_REQUIRED DB)

file(GLOB testfiles "queries/*.sql")
list(SORT testfiles)

foreach(file ${testfiles})
  get_filename_component(TESTNAME ${file} NAME_WE)
  set(DOTEST TRUE)
  if(${TESTNAME} MATCHES "_pg([0-9]+)")
    if(${POSTGRESQL_VERSION_MAJOR} LESS ${CMAKE_MATCH_1})
      message("Disabling test ${TESTNAME}")
      set(DOTEST FALSE)
    endif()
  endif()
  if(DOTEST)
    add_test(
      NAME ${TESTNAME}
      WORKING_DIRECTORY ${CMAKE_BINARY_DIR}/test/scripts
      COMMAND test.sh run_compare ${TESTNAME} ${file}
      )
    set_tests_properties(${TESTNAME} PROPERTIES
      FIXTURES_REQUIRED DBGEOMETRY
      RESOURCE_LOCK DBLOCK)
  endif()
endforeach()
