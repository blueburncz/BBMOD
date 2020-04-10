# bbmod_get_animation_key
`script`
```gml
bbmod_get_animation_key(keys, index)
```

## Description
Retrieves an animation key at specified index. Checks for boundaries
 to never read outside of the `keys` array.

### Arguments
| Name | Type | Description |
| ---- | ---- | ----------- |
| keys | `array` | An array of AnimationKey structures. |
| index | `real` | The index. |

## Returns
`array` The animation key.