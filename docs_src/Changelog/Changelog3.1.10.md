# Changelog 3.1.10
This release mainly updates Assimp (used in BBMOD CLI and DLL) to 5.2.0, which is at this moment the latest stable release. This should fix many issues with model conversion, e.g. vertex colors not converting properly for `glTF`, support for `.blend` files etc.

## CLI:
* Updated Assimp to 5.2.0.
* `BBMOD.exe` is now x64 only!

## GML API:
### Core module:
* Struct `BBMOD_Exception` now inherits from `BBMOD_Class`. This can be useful for checking exception types.
* Added new struct `BBMOD_OutOfRangeException`, which is an exception thrown when you try to read a value from a data structure at an index which is out of its range.
* Added new method `Get` to `BBMOD_Vec2`, `BBMOD_Vec3` and `BBMOD_Vec4`, using which you can retrieve a vector component at given index (0 for X, 1 for Y, etc.).
* Added new method `Clamp` to `BBMOD_Vec2`, `BBMOD_Vec3` and `BBMOD_Vec4`, using which you can clamp the vector's components between other two min and max vectors.
* Added new struct `BBMOD_Matrix`, which is a wrapper for regular GameMaker matrices, allowing you to do various matrix operations which are not included in GML.
* Fixed visual glitches (abrupt changes in animation frames) in animation playback that could have happened when you have increased `TransitionIn` or `TransitionOut` of `BBMOD_Animation`.

### DLL module:
* The DLL module now requires a 64bit runtime! This can be enabled by checking the "Use x64 Windows Runtime" option in `Game Options` > `Windows` > `General`.
