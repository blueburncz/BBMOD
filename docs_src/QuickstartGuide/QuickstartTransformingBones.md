# Transforming bones
There are situations in which you may want to change specific bones'
transformation. For example if you are making a shooter game, a character's
hands should be pointing towards its target, or in a RPG, NPCs could rotate
their head towards characters they interact with etc.

This can be achieved with methods
[set_node_rotation](./BBMOD_AnimationPlayer.set_node_rotation.html)
and [set_node_position](./BBMOD_AnimationPlayer.set_node_rotation.html)
of [BBMOD_AnimationPlayer](./BBMOD_AnimationPlayer.html):

```gml
/// @desc Step event
var _armId = modCharacter.find_node_id("ArmRight");
var _rotation = new BBMOD_Quaternion()
    .FromAxisAngle(new BBMOD_Vec3(0, 1, 0), directionUp);
animationPlayer.set_node_rotation(_armId, _rotation);
animationPlayer.update(delta_time);
```
