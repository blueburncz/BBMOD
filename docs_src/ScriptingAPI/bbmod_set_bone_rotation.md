# bbmod_set_bone_rotation
`script`
```gml
bbmod_set_bone_rotation(animation_player, bone_id, quaternion)
```

## Description
Defines a bone rotation to be used instead of one from the animation
 that's currently playing.

### Arguments
| Name | Type | Description |
| ---- | ---- | ----------- |
| animation_player | `array` | The animation player structure. |
| bone_id | `real` | The id of the bone to transform. |
| quaternion | `array/undefined` | An array with the new bone rotation `[x,y,z,w]`, or `undefined` to disable the override. |

## Note
 This should be used before [bbmod_animation_player_update](./bbmod_animation_player_update.html)
is executed.