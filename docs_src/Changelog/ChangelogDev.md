# Changelog

## GML API:
### General:
* Updated documented types to GameMaker 2022.3 style.

### Code module:
* Added new enum `BBMOD_ERenderCommand`, which contains all possible render commands.
* Added new struct `BBMOD_RenderQueue`, which is a container for render commands.
* Struct `BBMOD_RenderCommand` is now obsolete. Please use methods of `BBMOD_RenderQueue` to create render commands.
* Added new property `BBMOD_BaseMaterial.RenderQueue`, which is the render queue used by the material.
* Added new function `bbmod_get_default_render_queue`, which returns the default render queue.
* Property `RenderCommands` and methods `has_commands`, `submit_queue` and `clear_queue` of `BBMOD_BaseMaterial` are now obsolete. Please use its `RenderQueue` property instead.
* Added new struct `BBMOD_Material`, which is now the base struct for all materials.
* Moved basic properties and methods from `BBMOD_BaseMaterial` to `BBMOD_Material`.
* Struct `BBMOD_BaseMaterial` now inherits from `BBMOD_Material`.
* Added new property `BBMOD_Material.AlphaBlend`, using which you can enable/disable alpha blending. This is by default **disabled**.
* Added new utility function `bbmod_array_find_index`, which finds an index of a value within an array.

### Terrain module:
* Added new module - Terrain.
* Added new struct `BBMOD_Terrain`.
