add_library(BBMOD_D3D11 SHARED
    exports.cpp
)

add_custom_command(TARGET BBMOD_D3D11 POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:BBMOD_D3D11> ${DIR_D3D11}
)
