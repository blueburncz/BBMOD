cmake_minimum_required(VERSION 3.23)

project(BBMOD)

set(CMAKE_CXX_STANDARD 17)

set(SOURCES
    src/BBMOD/Animation.cpp
    src/BBMOD/Bone.cpp
    src/BBMOD/Importer.cpp
    src/BBMOD/Mesh.cpp
    src/BBMOD/Model.cpp
    src/BBMOD/Node.cpp
    src/BBMOD/VertexFormat.cpp)

find_library(LIBASSIMP
    NAMES assimp-vc143-mt assimp.5
    PATHS lib/)

function(configure_target target)
    set_target_properties(${target} PROPERTIES OUTPUT_NAME BBMOD)

    target_include_directories(${target} PRIVATE include/)

    target_link_libraries(${target} ${LIBASSIMP})

    # if(APPLE)
    #     # Find shared libraries next to the executable
    #     # Source: https://stackoverflow.com/a/69707790
    #     # ($ORIGIN doesn't work but . does)
    #     set_target_properties(${target} PROPERTIES
    #         BUILD_WITH_INSTALL_RPATH FALSE
    #         LINK_FLAGS "-Wl,-rpath,./")
    # endif()
endfunction()

# BBMOD CLI
add_executable(BBMOD_CLI
    src/main.cpp
    src/terminal.cpp
    ${SOURCES})

configure_target(BBMOD_CLI)

# BBMOD DLL
add_library(BBMOD_DLL SHARED
    src/exports.cpp
    ${SOURCES})

configure_target(BBMOD_DLL)

# Copy Assimp dynamic library
if(WIN32)
    add_custom_command(
        TARGET BBMOD_CLI POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
            ${CMAKE_CURRENT_SOURCE_DIR}/bin/assimp-vc143-mt.dll
            $<TARGET_FILE_DIR:BBMOD_CLI>)
elseif(APPLE)
    add_custom_command(
        TARGET BBMOD_CLI POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
            ${CMAKE_CURRENT_SOURCE_DIR}/lib/libassimp.5.dylib
            $<TARGET_FILE_DIR:BBMOD_CLI>)
endif()

# Copy Assimp license
add_custom_command(
    TARGET BBMOD_CLI POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_SOURCE_DIR}/bin/LICENSE-Assimp
        $<TARGET_FILE_DIR:BBMOD_CLI>)
