# Changelog

## GML API:
### General:
* Updated documented types to GameMaker 2022.3 style.

### Code module:
* Added new struct `BBMOD_RenderQueue`.
* Renamed property `RenderCommands` of `BBMOD_BaseMaterial` to `RenderQueue` and changed its type to `BBMOD_RenderQueue`.
* Removed methods `has_commands`, `submit_queue` and `clear_queue` from `BBMOD_BaseMaterial`. Please use methods of its render queue instead.
* Added new struct `BBMOD_Material`, which is now the base struct for all materials.
* Struct `BBMOD_BaseMaterial` now inherits from `BBMOD_Material`.

### Terrain module:
* Added new module - Terrain.
* Added new struct `BBMOD_Terrain`.
