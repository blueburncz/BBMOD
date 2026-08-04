cmake_minimum_required(VERSION 3.23)

project(BBMOD_D3D11 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(DIR_D3D11 "${CMAKE_CURRENT_SOURCE_DIR}/../BBMOD_GML/extensions/BBMOD_D3D11")

if(WIN32)
    add_subdirectory(src/D3D11)
else()
    message(STATUS "BBMOD_D3D11 is only built on Windows.")
endif()
