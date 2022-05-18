# Changelog 3.4.2
This release further fixes issues with the new Gizmo module and adds possibility to control the renderer's position and size on the screen, which comes useful for example for level editors with dockable windows etc.

## GML API:
### Core module:
* Function `bbmod_render_pass_set` now calls `bbmod_material_reset`.

### Gizmo module:
* Fixed mouse-picking of gizmo, where the scale tool was selected instead of rotate and vice versa.

### Rendering module:
#### Renderer submodule:
* Added new properties `X`, `Y`, `Width`, `Height` to `BBMOD_Renderer`, using which you can control the area on the screen where the game is drawn in the `present` method.
* Added new methods `set_position`, `set_size` and `set_rectangle` to `BBMOD_Renderer`, using which you can change multiple of the previously mentioned properties at once.
