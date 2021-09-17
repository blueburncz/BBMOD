# Bone attachments
If you would like to attach a model to a specific bone of an animated character,
you can use method [get_node_transform](./BBMOD_AnimationPlayer.get_node_transform.html):

```gml
/// @desc Draw event
bbmod_material_reset();

// Draw character:
var _bodyMatrix = matrix_build(x, y, z, 0, 0, direction, 1, 1, 1);
matrix_set(matrix_world, _bodyMatrix);
animationPlayer.submit();

// Draw sword attachment:
var _handId = modCharacter.find_node_id("HandRight");
var _handMatrix = animationPlayer.get_node_transform(_handId).ToMatrix();
var _swordMatrix = matrix_multiply(_handMatrix, _bodyMatrix);
matrix_set(matrix_world, _swordMatrix);
modSword.submit();

bbmod_material_reset();
```
