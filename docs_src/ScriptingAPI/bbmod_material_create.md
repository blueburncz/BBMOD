# bbmod_material_create
`script`
```gml
bbmod_material_create(shader, [diffuse[, normal]])
```

## Description
Creates a new Material structure.

### Arguments
| Name | Type | Description |
| ---- | ---- | ----------- |
| shader | `ptr` | A shader that the material uses. |
| [diffuse] | `ptr` | A diffuse texture. |
| [normal] | `ptr` | A normal texture. |

## Returns
`array` The created Material structure.