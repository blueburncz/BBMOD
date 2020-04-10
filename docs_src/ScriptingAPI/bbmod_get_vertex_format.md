# bbmod_get_vertex_format
`script`
```gml
bbmod_get_vertex_format(vertices, normals, uvs, colors, tangetw, bones)
```

## Description
Creates a new vertex format or retrieves an existing one with specified
 properties.

### Arguments
| Name | Type | Description |
| ---- | ---- | ----------- |
| vertices | `bool` | True if the vertex format must have vertices. |
| normals | `bool` | True if the vertex format must have normal vectors. |
| uvs | `bool` | True if the vertex format must have texture coordinates. |
| colors | `bool` | True if the vertex format must have vertex colors. |
| tangentw | `bool` | True if the vertex format must have tangent vectors and bitangent signs. |
| bones | `bool` | True if the vertex format must have vertex weights and bone indices. |

## Returns
`real` The vertex format.