# Transforming bones
There are situations in which you may want to change specific bones' transformation. For example if you are making a shooter game, a character's hands should be pointing towards its target, or in a RPG, NPC should rotate their head towards characters they are interacting with etc. 

This can be achieved with functions [bbmod_set_bone_rotation](./bbmod_set_bone_rotation.html) and [bbmod_set_bone_position](./bbmod_set_bone_rotation.html).

```gml
/// @desc Step
var _arm_id = bbmod_model_find_bone_id(model, "arm_right");
var _rotation = ce_quaternion_create_from_axisangle([0, 0, 1], direction_up);
bbmod_set_bone_rotation(animation_player, _arm_id, _rotation);
bbmod_animation_player_update(animation_player);
```

Please note that in this example we are using a script [bbmod_model_find_bone_id](./bbmod_model_find_bone_id.html) to obtain a bone's id from its name. This is just for extra clarity of the example, but as the script's documentation states, you shouldn't be using it in production, as it can slow down your game. You should instead use the ids available from the `_log.txt` files.
