# bbmod_model_find_bone_id
`script`
```gml
bbmod_model_find_bone_id(model, bone_name[, bone])
```

## Description
Seaches for a bone id assigned to given bone name.

### Arguments
| Name | Type | Description |
| ---- | ---- | ----------- |
| model | `array` | The Model structure. |
| bone_name | `string` | The name of the Bone structure. |
| [bone] | `array/undefined` | The Bone structure to start searching from. Use `undefined` to use the model's root bone. Defaults to `undefined`. |

## Returns
`real/BBMOD_NONE` The id of the bone on success or `BBMOD_NONE` on fail.

## Note
 It is not recommened to use this script in release builds, because having
many of these lookups can slow down your game! You should instead use the
ids available from the `_log.txt` files, which are created during model
conversion.