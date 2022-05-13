# Changelog 3.3.1

## GML API:
### Camera module:
* Added new property `Roll` to `BBMOD_Camera`, using which you can control camera's rotation from side to side.
* Added new properties `DirectionUpMin` and `DirectionUpMax` to `BBMOD_Camera`, using which you can control the minimum and maximum values of `Direction`. These are set to -89 and 89 respectively, same as was the hard limit before. To remove the limit, use set these to `undefined`.
* Property `Up` of `BBMOD_Camera` is now obsolete, please use the `get_up` method instead to retrieve a camera's up vector.
