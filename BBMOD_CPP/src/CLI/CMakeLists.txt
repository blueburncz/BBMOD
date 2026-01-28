add_executable(BBMOD_CLI
    main.cpp
    terminal.cpp
)

target_link_libraries(BBMOD_CLI
    PRIVATE BBMOD_CORE
)

set_target_properties(BBMOD_CLI PROPERTIES OUTPUT_NAME BBMOD)

add_custom_command(TARGET BBMOD_CLI POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
        $<TARGET_FILE:BBMOD_CLI>
        ${DIR_DATAFILES}
)

#===============================================================================
# Assimp runtime copy
#===============================================================================
if(WIN32)
    set(ASSIMP_DLL "${CMAKE_BINARY_DIR}/external/assimp/bin/Release/assimp-vc143-mt.dll")
    add_custom_command(TARGET BBMOD_CLI POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${ASSIMP_DLL}
            ${DIR_DATAFILES}
    )
elseif(APPLE OR UNIX)
    add_custom_command(TARGET BBMOD_CLI POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
            $<TARGET_FILE:assimp>
            ${DIR_DATAFILES}
    )
endif()

#===============================================================================
# License
#===============================================================================
add_custom_command(TARGET BBMOD_CLI POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_SOURCE_DIR}/external/assimp/LICENSE
        ${DIR_DATAFILES}/LICENSE-Assimp
)
