# bbmod_get_interpolated_rotation_key
`script`
```gml
bbmod_get_interpolated_rotation_key(rotations, time[, index])
```

## Description
Creates a new RotationKey struct by interpolating two closest ones
 for specified animation time.

### Arguments
| Name | Type | Description |
| ---- | ---- | ----------- |
| rotations | `array` | An array of RotationKey structs. |
| time | `real` | The current animation time. |
| [index] | `real` | An index where to start searching for two closest rotation keys for specified time. Defaults to 0. |

## Returns
`array` The interpolated RotationKey.