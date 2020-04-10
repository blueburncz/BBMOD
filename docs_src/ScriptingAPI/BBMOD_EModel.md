# BBMOD_EModel
`enum`
## Description
An enumeration of members of a Model structure.

### Members
| Name | Description |
| ---- | ----------- |
| `Version` | The version of the model file. |
| `HasVertices` | True if the model has vertices (always true). |
| `HasNormals` | True if the model has normal vectors. |
| `HasTextureCoords` | True if the model has texture coordinates. |
| `HasColors` | True if the model has vertex colors. |
| `HasTangentW` | True if the model has tangent vectors and bitangent sign. |
| `HasBones` | True if the model has vertex weights and bone indices. |
| `InverseTransformMatrix` | The global inverse transform matrix. |
| `RootNode` | The root Node structure. |
| `BoneCount` | Number of bones. |
| `Skeleton` | The root Bone structure. |
| `MaterialCount` | Number of materials that the model uses. |
| `SIZE` | The size of the Model structure. |