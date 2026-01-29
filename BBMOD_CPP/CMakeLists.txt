cmake_minimum_required(VERSION 3.23)

project(BBMOD LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(DIR_DATAFILES "${CMAKE_CURRENT_SOURCE_DIR}/../BBMOD_GML/datafiles/Data/BBMOD")
set(DIR_PHYSICS "${CMAKE_CURRENT_SOURCE_DIR}/../BBMOD_GML/extensions/BBMOD_Physics")
set(DIR_D3D11 "${CMAKE_CURRENT_SOURCE_DIR}/../BBMOD_GML/extensions/BBMOD_D3D11")

if(APPLE)
    set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64" CACHE STRING "" FORCE)
endif()

# ==============================================================================
# Shared code
# ==============================================================================
add_subdirectory(src/BBMOD)

# ==============================================================================
# Assimp config
# ==============================================================================
set(ASSIMP_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(ASSIMP_BUILD_ASSIMP_TOOLS OFF CACHE BOOL "" FORCE)
set(ASSIMP_INSTALL OFF CACHE BOOL "" FORCE)

set(BUILD_SHARED_LIBS ON CACHE BOOL "" FORCE) # Shared
add_subdirectory(external/assimp)

# ==============================================================================
# Bullet
# ==============================================================================
set(BUILD_BULLET2_DEMOS OFF CACHE BOOL "" FORCE)
set(BUILD_BULLET3 OFF CACHE BOOL "" FORCE)
set(BUILD_CPU_DEMOS OFF CACHE BOOL "" FORCE)
set(BUILD_EXTRAS OFF CACHE BOOL "" FORCE)
set(BUILD_OPENGL3_DEMOS OFF CACHE BOOL "" FORCE)
set(BUILD_UNIT_TESTS OFF CACHE BOOL "" FORCE)
set(USE_DOUBLE_PRECISION ON CACHE BOOL "" FORCE)

set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE) # Static
add_subdirectory(external/bullet3)

# ==============================================================================
# Projects
# ==============================================================================
add_subdirectory(src/CLI)
add_subdirectory(src/DLL)
add_subdirectory(src/Physics)

if(WIN32)
    add_subdirectory(src/D3D11)
endif()
