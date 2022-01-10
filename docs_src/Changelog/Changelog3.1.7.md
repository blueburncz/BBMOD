# Changelog 3.1.7

## GML API:
### Core module:
* Added new function `bbmod_buffer_load_async`, using which you can asynchronnously load buffer from a file.
* Added new property `IsLoaded` to `BBMOD_Model` and `BBMOD_Animation`, which is `false` until they are loaded.
* Arguments of the `BBMOD_Model` constructor are now optional.
* Methods `from_buffer` and `from_file` of `BBMOD_Model` are now public and they can be used to load a model from a buffer/file when no arguments are passed to the constructor.
* Added new methods `from_file_async` to `BBMOD_Model` and `BBMOD_Animation`, using which you can load them asynchronnously. This is the required approach on HTML5.
* Fixed method `BBMOD_VertexFormat.get_byte_size`, which returned incorrect values when the vertex format included vertex colors or bones.
* Fixed creating dynamic and static batches with models that have vertex colors.

### Camera module:
* Fixed mouselook on HTML5.
