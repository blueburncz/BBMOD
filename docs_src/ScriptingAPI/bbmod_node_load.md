# bbmod_node_load
`script`
```gml
bbmod_node_load(buffer, format, format_mask)
```

## Description
Loads a Node structure from a buffer.

### Arguments
| Name | Type | Description |
| ---- | ---- | ----------- |
| buffer | `real` | The buffer to load the structure from. |
| format | `real` | A vertex format for node's meshes. |
| format_mask | `real` | A vertex format mask. |

## Returns
`array` The loaded Node structure.