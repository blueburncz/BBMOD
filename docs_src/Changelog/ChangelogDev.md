# Changelog

## GML API:
### Code module:
* Added new struct `BBMOD_RenderQueue`.
* Renamed property `RenderCommands` of `BBMOD_BaseMaterial` to `RenderQueue` and changed its type to `BBMOD_RenderQueue`.
* Removed methods `has_commands`, `submit_queue` and `clear_queue` from `BBMOD_BaseMaterial`. Please use methods of its render queue instead.
