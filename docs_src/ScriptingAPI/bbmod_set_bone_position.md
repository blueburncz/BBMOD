# bbmod_set_bone_position
`script`
```gml
bbmod_set_bone_position(animation_player, bone_id, position)
```

## Description
Defines a bone position to be used instead of one from the animation
 that's currently playing.

### Arguments
| Name | Type | Description |
| ---- | ---- | ----------- |
| animation_player | `array` | The animation player structure. |
| bone_id | `real` | The id of the bone to transform. |
| position | `array/undefined` | An array with the new bone position `[x,y,z]`, or `undefined` to disable the override. |

## Note
 This should be used before [bbmod_animation_player_update](./bbmod_animation_player_update.html)
is executed.