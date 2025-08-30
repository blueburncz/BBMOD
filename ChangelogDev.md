# Changelog dev

> This file is used to accumulate changes before a changelog for a release is created.

* Added new method `get_node_array` to `BBMOD_Model`, which returns an array of all nodes of the model.
* Added new struct `BBMOD_LayeredAnimationPlayer`.
* Added new struct `BBMOD_AnimationLayer`.
* Added new struct `BBMOD_SkeletonMask`.
* Method `get_animation_time` of struct `BBMOD_Animation` now wraps returned value into range 0...`Duration` (inclusive).
* Property `PlaybackSpeed` of `BBMOD_AnimationPlayer` no longer needs to be a positive value - reverse animation playback is now supported!
* Using GameMaker's new function `matrix_inverse` in method `InverseSelf` of struct `BBMOD_Matrix`.
* Added new method `ToEuler` to `BBMOD_Quaternion`, which retrieves euler angles from the quaternion.
* Updated Assimp to [v6.0.2](https://github.com/assimp/assimp/releases/tag/v6.0.2).
