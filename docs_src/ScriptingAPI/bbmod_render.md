# bbmod_render
`script`
```gml
bbmod_render(model[, materials[, transform]])
```

## Description
Submits a Model for rendering.

### Arguments
| Name | Type | Description |
| ---- | ---- | ----------- |
| model | `array` | A Model structure. |
| [materials] | `array/undefined` | An array of Material structures, one for each material slot of the Model. If not specified, then the default  material is used for each slot. Default is `undefined`. |
| [transform] | `array/undefined` | An array of transformation matrices (for animated models) or `undefined`. |