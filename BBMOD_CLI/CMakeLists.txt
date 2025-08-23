cmake_minimum_required(VERSION 3.23)

project(BBMOD)

set(CMAKE_CXX_STANDARD 17)
set(DIST_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../BBMOD_GML/datafiles/Data/BBMOD)

if(APPLE)
    set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64" CACHE STRING "Build architectures for macOS" FORCE)
endif()

set(SOURCES
    src/BBMOD/Animation.cpp
    src/BBMOD/Bone.cpp
    src/BBMOD/Importer.cpp
    src/BBMOD/Mesh.cpp
    src/BBMOD/Model.cpp
    src/BBMOD/Node.cpp
    src/BBMOD/VertexFormat.cpp
)

set(ASSIMP_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(ASSIMP_BUILD_ASSIMP_TOOLS OFF CACHE BOOL "" FORCE)
set(ASSIMP_INSTALL OFF CACHE BOOL "" FORCE)
add_subdirectory(external/assimp)

function(configure_target target)
    set_target_properties(${target} PROPERTIES OUTPUT_NAME BBMOD)
    target_include_directories(${target} PRIVATE include/)
    target_link_libraries(${target} PRIVATE assimp)
    add_custom_command(TARGET ${target} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${target}> ${DIST_DIR}
    )
endfunction()

add_executable(BBMOD_CLI
    src/main.cpp
    src/terminal.cpp
    ${SOURCES}
)
configure_target(BBMOD_CLI)

add_library(BBMOD_DLL SHARED
    src/exports.cpp
    ${SOURCES}
)
configure_target(BBMOD_DLL)

if(WIN32)
    set(ASSIMP_DLL "${CMAKE_CURRENT_BINARY_DIR}/external/assimp/bin/Release/assimp-vc143-mt.dll")
    add_custom_command(TARGET BBMOD_CLI POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different ${ASSIMP_DLL} ${DIST_DIR}
    )
elseif(APPLE OR UNIX)
    add_custom_command(TARGET BBMOD_CLI POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:assimp> ${DIST_DIR}
    )
endif()

add_custom_command(TARGET BBMOD_CLI POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_SOURCE_DIR}/external/assimp/LICENSE
        ${DIST_DIR}/LICENSE-Assimp
)
