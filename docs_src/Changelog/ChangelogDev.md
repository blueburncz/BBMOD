# Changelog

## GML API:
### General:
* Updated documented types to GameMaker 2022.3 style.

### Code module:
* Replaced property `BBMOD_RenderCommand.Texture` with `BBMOD_RenderCommand.Material`, which is the material used in the draw call.
* Added new struct `BBMOD_RenderQueue`, which is a container for `BBMOD_RenderCommand`s.
* Renamed property `RenderCommands` of `BBMOD_BaseMaterial` to `RenderQueue` and changed its type to `BBMOD_RenderQueue`.
* Added new function `bbmod_get_default_render_queue`, which returns a render queue that is by default used by all materials.
* Methods `has_commands`, `submit_queue` and `clear_queue` of `BBMOD_BaseMaterial` are now obsolete. Please use methods of `BBMOD_RenderQueue` instead.
* Added new struct `BBMOD_Material`, which is now the base struct for all materials.
* Moved basic properties and methods from `BBMOD_BaseMaterial` to `BBMOD_Material`.
* Struct `BBMOD_BaseMaterial` now inherits from `BBMOD_Material`.
* Added new property `BBMOD_Material.AlphaBlend`, using which you can enable/disable alpha blending. This is by default **disabled**.

### Terrain module:
* Added new module - Terrain.
* Added new struct `BBMOD_Terrain`.
