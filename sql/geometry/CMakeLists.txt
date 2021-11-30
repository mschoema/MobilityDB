# No Postgres version dependant files

SET(LOCAL_FILES
  120_tgeometry
  124_tgeometry_boxops
  )

foreach (f ${LOCAL_FILES})
  process_file(${f} ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR})
  configure_file(${CMAKE_CURRENT_BINARY_DIR}/${f}.sql.in ${CMAKE_BINARY_DIR}/sql/${f}.sql @ONLY)
  list(APPEND PACKAGE_SQL_FILES  ${CMAKE_BINARY_DIR}/sql/${f}.sql)
endforeach()

set(PROJECT_SQL_FILES ${PROJECT_SQL_FILES} ${PACKAGE_SQL_FILES} PARENT_SCOPE)
