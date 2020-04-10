# bbmod_animation_create_transition
`script`
```gml
bbmod_animation_create_transition(model, anim_from, time_from, anim_to, time_to, duration)
```

## Description
Creates a new animation transition between two specified animations.

### Arguments
| Name | Type | Description |
| ---- | ---- | ----------- |
| model | `array` | A Model structure. |
| anim_from | `array` | An Animation structure. |
| time_from | `real` | Animation time of the first animation. |
| anim_to | `array` | An Animation structure. |
| time_to | `real` | Animation time of the second animation. |
| duration | `real` | The duration of the transition in seconds. |

## Returns
`array` The created transition Animation struct.