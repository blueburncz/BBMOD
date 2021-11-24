# Changelog 3.1.1
This release patches few errors in the BBMOD GML library.

## GML API:
### Core module:
* Moved interface `BBMOD_IRenderable` from the Renderer module to the Core module.
* Fixed return value of `BBMOD_Material.submit_queue`, which should have been `self`, but the method did not return anything.
* Fixed methods `Reflect` of `BBMOD_Vec2`, `BBMOD_Vec3` and `BBMOD_Vec4`, which returned incorrect results.
