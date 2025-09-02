# Changelog dev

> This file is used to accumulate changes before a changelog for a release is created.

* Added new method `get_node_array()` to `BBMOD_Model`, which returns an array of all nodes of the model.
* Added new function `bbmod_wrap_value(_value, _rangeMax)`, which wraps given value to range 0..max-1.
* Added new struct `BBMOD_LayeredAnimationPlayer`, which is an animation player with support for multiple layers, blending and masking. Compatible
only with animations with optimization level 0!
* Added new struct `BBMOD_AnimationLayer`, which is a single layer of a layered animation player. Each layer plays its own animation and can affect a selected portion of the skeleton. Individual layers can be mixed or additively blended together.
* Added new struct `BBMOD_SkeletonMask`, which is a struct that defines which nodes of a model are affected by an animation layer.
* Property `PlaybackSpeed` of `BBMOD_AnimationPlayer` no longer needs to be a positive value - reverse animation playback is now supported!
* Using GameMaker's new function `matrix_inverse` in method `InverseSelf` of struct `BBMOD_Matrix`.
* Added new method `ToEuler` to `BBMOD_Quaternion`, which retrieves euler angles from the quaternion.
* Updated Assimp to [v6.0.2](https://github.com/assimp/assimp/releases/tag/v6.0.2).
