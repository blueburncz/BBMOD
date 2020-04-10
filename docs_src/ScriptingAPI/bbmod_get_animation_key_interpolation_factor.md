# bbmod_get_animation_key_interpolation_factor
`script`
```gml
bbmod_get_animation_key_interpolation_factor(key, key_next, animation_time)
```

## Description
Calculates interpolation factor between two animation keys at specified
 animation time.

### Arguments
| Name | Type | Description |
| ---- | ---- | ----------- |
| key | `array` | The first AnimationKey structure. |
| key_next | `array` | The second AnimationKey structure. |
| animation_time | `real` | The animation time. |

## Returns
`real` The calculated interpolation factor.