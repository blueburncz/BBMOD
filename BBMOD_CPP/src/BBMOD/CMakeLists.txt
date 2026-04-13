add_library(BBMOD_CORE STATIC
    Animation.cpp
    Bone.cpp
    Importer.cpp
    Mesh.cpp
    Model.cpp
    Node.cpp
    VertexFormat.cpp
)

target_link_libraries(BBMOD_CORE
    PUBLIC assimp
)
