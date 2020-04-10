# bbmod_rotation_key_interpolate
`script`
```gml
bbmod_rotation_key_interpolate(rk1, rk2, factor)
```

## Description
Interpolates between two rotation keys.

### Arguments
| Name | Type | Description |
| ---- | ---- | ----------- |
| rk1 | `array` | The first rotation key. |
| rk2 | `array` | The second rotation key. |
| factor | `real` | The interpolation factor. Should be a value in range 0..1. |

## Returns
`array` A new key with the interpolated animation time and position.