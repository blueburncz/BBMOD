add_library(BBMOD_DLL SHARED
    exports.cpp
)

target_link_libraries(BBMOD_DLL
    PRIVATE BBMOD_CORE
)

set_target_properties(BBMOD_DLL PROPERTIES OUTPUT_NAME BBMOD)

add_custom_command(TARGET BBMOD_DLL POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
        $<TARGET_FILE:BBMOD_DLL>
        ${DIST_DIR}
)
