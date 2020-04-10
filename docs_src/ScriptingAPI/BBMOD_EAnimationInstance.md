# BBMOD_EAnimationInstance
`enum`
## Description
An enumeration of members of an AnimationInstance structure.

### Members
| Name | Description |
| ---- | ----------- |
| `Animation` | The animation to be played. |
| `Loop` | True if the animation should be looped. |
| `AnimationStart` | Time when the animation started playing (in seconds). |
| `AnimationTime` | The current animation time. |
| `AnimationTimeLast` | Animation time in last frame. Used to reset members in  	 looping animations or when switching between animations. |
| `PositionKeyLast` | An index of a position key which was used last frame.  	 Used to optimize search of position keys in following frames. |
| `RotationKeyLast` | An index of a rotation key which was used last frame.  	 Used to optimize search of rotation keys in following frames. |
| `BoneTransform` | An array of individual bone transformation matrices,  	 without offsets. Useful for attachments. |
| `TransformArray` | An array containing transformation matrices of all bones.  	 Used to pass current model pose as a uniform to a vertex shader. |
| `SIZE` | The size of an AnimationInstance structure. |