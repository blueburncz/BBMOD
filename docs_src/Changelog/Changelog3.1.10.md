# Changelog 3.1.10

## CLI:
* Updated Assimp to 5.2.0.

## GML API:
### Core module:
* Struct `BBMOD_Exception` now inherits from `BBMOD_Class`. This can be useful for checking exception types.
* Added new struct `BBMOD_OutOfRangeException`, which is an exception thrown when you try to read a value from a data structure at an index which is out of its range.
* Added new method `Clamp` to `BBMOD_Vec2`, `BBMOD_Vec3` and `BBMOD_Vec4`, using which you can clamp the vector's components between other two min and max vectors.
* Added new method `Get` to `BBMOD_Vec2`, `BBMOD_Vec3` and `BBMOD_Vec4`, using which you can retrieve a vector component at given index (0 for X, 1 for Y, etc.).
* Added new struct `BBMOD_Matrix`, which is a wrapper for regular GameMaker matrices, allowing you to do various matrix operations which are not included in GML.

### DLL module:
* The DLL module now requires a 64bit runtime! This can be enabled by checking the "Use x64 Windows Runtime" option in `Game Options` > `Windows` > `General`.
