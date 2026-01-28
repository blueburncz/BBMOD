add_library(BBMOD_Physics SHARED
    exports.cpp
)

if(WIN32)
    set_target_properties(BBMOD_Physics PROPERTIES OUTPUT_NAME BBMOD_Physics_x64)
endif()

target_include_directories(BBMOD_Physics PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/../../include
    ${CMAKE_SOURCE_DIR}/external/bullet3/src
)

target_link_libraries(BBMOD_Physics PRIVATE
    LinearMath
    BulletCollision
    BulletDynamics
)

#===============================================================================
# Copy BBMOD_Physics binary
#===============================================================================
add_custom_command(TARGET BBMOD_Physics POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:BBMOD_Physics> ${DIR_PHYSICS}
)

#===============================================================================
# License
#===============================================================================
add_custom_command(TARGET BBMOD_Physics POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_SOURCE_DIR}/external/bullet3/LICENSE.txt
        ${DIR_PHYSICS}/LICENSE-Bullet3
)
