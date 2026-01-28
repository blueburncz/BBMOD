cmake_minimum_required(VERSION 3.23)

project(BBMOD LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(DIST_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../BBMOD_GML/datafiles/Data/BBMOD)

if(APPLE)
    set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64" CACHE STRING "" FORCE)
endif()

# -----------------------------
# Assimp config
# -----------------------------
set(ASSIMP_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(ASSIMP_BUILD_ASSIMP_TOOLS OFF CACHE BOOL "" FORCE)
set(ASSIMP_INSTALL OFF CACHE BOOL "" FORCE)

add_subdirectory(external/assimp)

# -----------------------------
# Shared code
# -----------------------------
add_subdirectory(src/BBMOD)

# -----------------------------
# Projects
# -----------------------------
add_subdirectory(src/CLI)
add_subdirectory(src/DLL)
