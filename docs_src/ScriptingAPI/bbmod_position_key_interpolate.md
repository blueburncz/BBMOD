# bbmod_position_key_interpolate
`script`
```gml
bbmod_position_key_interpolate(pk1, pk2, factor)
```

## Description
Interpolates between two position keys.

### Arguments
| Name | Type | Description |
| ---- | ---- | ----------- |
| pk1 | `array` | The first position key. |
| pk2 | `array` | The second position key. |
| factor | `real` | The interpolation factor. Should be a value in range 0..1. |

## Returns
`array` A new key with the interpolated animation time and position.