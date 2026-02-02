add_executable(BBMOD_CLI
    main.cpp
)

target_link_libraries(BBMOD_CLI
    PRIVATE BBMOD_CORE
)

set_target_properties(BBMOD_CLI PROPERTIES OUTPUT_NAME BBMOD)

add_custom_command(TARGET BBMOD_CLI POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
        $<TARGET_FILE:BBMOD_CLI>
        ${DIR_BBMOD}
)

if(WIN32)
    add_custom_command(TARGET BBMOD_CLI POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${CMAKE_BINARY_DIR}/external/assimp/bin/Release/assimp-vc143-mt.dll"
            ${DIR_BBMOD}
    )
elseif(APPLE OR UNIX)
    add_custom_command(TARGET BBMOD_CLI POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
            $<TARGET_FILE:assimp>
            "${DIR_BBMOD}/libassimp.6.dylib"
    )
endif()

add_custom_command(TARGET BBMOD_CLI POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_SOURCE_DIR}/external/assimp/LICENSE
        ${DIR_BBMOD}/LICENSE-Assimp
)
