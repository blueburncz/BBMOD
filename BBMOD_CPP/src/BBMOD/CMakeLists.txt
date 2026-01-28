add_library(BBMOD_CORE STATIC
    Animation.cpp
    Bone.cpp
    Importer.cpp
    Mesh.cpp
    Model.cpp
    Node.cpp
    VertexFormat.cpp
)

target_include_directories(BBMOD_CORE
    PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/../../include
)

target_link_libraries(BBMOD_CORE
    PUBLIC assimp
)
