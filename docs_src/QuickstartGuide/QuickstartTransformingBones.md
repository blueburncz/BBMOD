# Transforming bones
There are situations in which you may want to change specific bones' transformation. For example if you are making a shooter game, a character's hands should be pointing towards its target, or in a RPG, NPC should rotate their head towards characters they are interacting with etc. 

This can be achieved with methods [set_node_rotation](./BBMOD_AnimationPlayer.set_node_rotation.html) and [set_node_position](./BBMOD_AnimationPlayer.set_node_rotation.html).

```gml
/// @desc Step
var _arm_id = mod_character.find_node_id("arm_right");
var _rotation = ce_quaternion_create_from_axisangle([0, 1, 0], direction_up);
animation_player.set_node_rotation(_arm_id, _rotation);
animation_player.update(delta_time);
```

Please note that in this example we are using a method [find_node_id](./BBMOD_Model.find_node_id.html) to obtain a bone's id from its name. This is just for extra clarity of the example, but as the method's documentation states, you shouldn't be using it in production, as it can slow down your game. You should instead use the ids available from the `_log.txt` files.
