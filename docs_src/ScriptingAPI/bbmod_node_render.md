# bbmod_node_render
`script`
```gml
bbmod_node_render(model, node, materials, transform)
```

## Description
Submits a Node structure for rendering.

### Arguments
| Name | Type | Description |
| ---- | ---- | ----------- |
| model | `array` | The Model structure to which the Node belongs. |
| node | `array` | The Node structure. |
| materials | `array` | An array of Material structures, one for each material slot of the Model. |
| transform | `array/undefined` | An array of transformation matrices (for animated models) or `undefined`. |