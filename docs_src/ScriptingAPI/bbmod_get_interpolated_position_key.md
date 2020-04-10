# bbmod_get_interpolated_position_key
`script`
```gml
bbmod_get_interpolated_position_key(positions, time[, index])
```

## Description
Creates a new PositionKey struct by interpolating two closest ones
 for specified animation time.

### Arguments
| Name | Type | Description |
| ---- | ---- | ----------- |
| positions | `array` | An array of PositionKey structs. |
| time | `real` | The current animation time. |
| [index] | `real` | An index where to start searching for two closest position keys for specified time. Defaults to 0. |

## Returns
`array` The interpolated PositionKey.