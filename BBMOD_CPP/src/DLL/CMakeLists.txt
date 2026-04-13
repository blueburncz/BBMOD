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
        ${DIR_DATAFILES}
)

if(WIN32)
    add_custom_command(TARGET BBMOD_DLL POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${CMAKE_BINARY_DIR}/external/assimp/bin/Release/assimp-vc143-mt.dll"
            ${DIR_DATAFILES}
    )
elseif(APPLE OR UNIX)
    add_custom_command(TARGET BBMOD_DLL POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
            $<TARGET_FILE:assimp>
            "${DIR_DATAFILES}/libassimp.6.dylib"
    )
endif()

add_custom_command(TARGET BBMOD_DLL POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_SOURCE_DIR}/external/assimp/LICENSE
        ${DIR_DATAFILES}/LICENSE-Assimp
)
