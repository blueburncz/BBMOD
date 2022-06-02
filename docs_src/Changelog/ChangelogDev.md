# Changelog

## GML API:
### Camera module:
* Added `screen_point_to_vec3` to `BBMOD_Camera`, using which you can convert a position on the screen into a world-space direction.

### Gizmo module:
* Fixed dragging gizmo when renderer isn't the same size as the window.

### Importer module:
* Added new property `ConvertYToZUp` to `BBMOD_OBJImporter`, using which you can switch Y and Z axes of imported models.
* Added new property `InvertWinding` to `BBMOD_OBJImporter`, using which you can invert vertex winding order of imported models.

### Rendering module:
#### Renderer submodule:
* Fixed unselecting instances when clicking outside of the renderer.

### Terrain module:
* Fixed passing property `TextureRepeat` to shaders when using `BBMOD_Terrain.submit`.
