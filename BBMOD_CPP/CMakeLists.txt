cmake_minimum_required(VERSION 3.23)

project(BBMOD LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(DIR_D3D11 "${CMAKE_CURRENT_SOURCE_DIR}/../BBMOD_GML/extensions/BBMOD_D3D11")
set(DIR_DATAFILES "${CMAKE_CURRENT_SOURCE_DIR}/../BBMOD_GML/datafiles/Data/BBMOD")

if(APPLE)
    set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64" CACHE STRING "" FORCE)
endif()

# ==============================================================================
# Assimp
# ==============================================================================
set(ASSIMP_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(ASSIMP_BUILD_ASSIMP_TOOLS OFF CACHE BOOL "" FORCE)
set(ASSIMP_INSTALL OFF CACHE BOOL "" FORCE)

set(BUILD_SHARED_LIBS ON CACHE BOOL "" FORCE) # Shared
add_subdirectory(external/assimp)

# ==============================================================================
# Projects
# ==============================================================================
include_directories(include)
add_subdirectory(src/BBMOD) # Shared across projects

add_subdirectory(src/CLI)
add_subdirectory(src/DLL)

if(WIN32)
    add_subdirectory(src/D3D11)
endif()
