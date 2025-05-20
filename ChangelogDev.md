# Changelog dev
> This file is used to accumulate changes before a changelog for a release is created.

* Added new struct `BBMOD_LayeredAnimationPlayer`.
* Added new struct `BBMOD_AnimationLayer`.
* Added new struct `BBMOD_SkeletonMask`.
* Method `get_animation_time` of struct `BBMOD_Animation` now wraps returned value into range 0...`Duration` (inclusive).
* Property `PlaybackSpeed` of `BBMOD_AnimationPlayer` no longer needs to be a positive value - reverse animation playback is now supported!
* Use GameMaker's new function `matrix_inverse` in method `InverseSelf` of struct `BBMOD_Matrix`.
