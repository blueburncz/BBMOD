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

if(${CMAKE_BUILD_TYPE} STREQUAL Debug)
    add_executable(BBMOD
        src/main.cpp
        src/terminal.cpp
        ${SOURCES})
elseif(${CMAKE_BUILD_TYPE} STREQUAL Debug_DLL)
    add_library(BBMOD SHARED
        src/exports.cpp
        ${SOURCES})
endif()

target_include_directories(BBMOD PRIVATE include/)

find_library(LIBASSIMP
    NAMES assimp-vc143-mt assimp.5
    PATHS lib/)

target_link_libraries(BBMOD ${LIBASSIMP})

if(APPLE)
    # Find shared libraries next to the executable
    # Source: https://stackoverflow.com/a/69707790
    # ($ORIGIN doesn't work but . does)
    set_target_properties(BBMOD PROPERTIES
        BUILD_WITH_INSTALL_RPATH FALSE
        LINK_FLAGS "-Wl,-rpath,./")
endif()
