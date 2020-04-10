# bbmod_load
`script`
```gml
bbmod_load(file[, sha1])
```

## Description
Loads a model/animation from a BBMOD/BBANIM file.

### Arguments
| Name | Type | Description |
| ---- | ---- | ----------- |
| file | `string` | The path to the file. |
| [sha1] | `string` | Expected SHA1 of the file. If the actual one does not match with this, then the model will not be loaded. Default is  `undefined`. |

## Returns
`array/BBMOD_NONE` The loaded model/animation on success or
 `BBMOD_NONE` on fail.