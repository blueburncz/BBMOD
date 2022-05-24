# Changelog

## GML API:
### Gizmo module:
* Added new optional argument `_size` to `BBMOD_Gizmo`'s constructor, which is the size of the gizmo.
* Added new enum `BBMOD_EEditType`, which is an enumeration of edit types (move, rotate, scale).
* Added new property `EditType` to `BBMOD_Gizmo`, which is the current edit type.
* Added new property `KeyNextEditType` to `BBMOD_Gizmo`, which is the virtual key used to cycle between edit types.
* Added new property `Models` to `BBMOD_Gizmo`, which is an array of gizmo models for each edit type.
* Property `Model` of `BBMOD_Gizmo` is now obsolete.
* Added new enum `BBMOD_EEditSpace`, which is an enumeration of edit spaces (global, local).
* Added new property `EditSpace` to `BBMOD_Gizmo`, which is the current edit space.
* Added new property `KeyNextEditSpace` to `BBMOD_Gizmo`, which is the virtual key used to cycle between edit spaces.
* Added new property `Rotation` to `BBMOD_Gizmo`, which is the gizmo's rotation.
* Added new property `ButtonDrag` to `BBMOD_Gizmo`, which is the mouse button used to control the gizmo.
* Added new properties `KeyEditFaster` and `KeyEditSlower` to `BBMOD_Gizmo`, which are virtual keys used to edit selected instances faster/slower.
* Added new properties `InstanceExists`, `SetInstancePositionX`, `GetInstancePositionX`, `SetInstancePositionY`, `GetInstancePositionY`, `SetInstancePositionZ`, `GetInstancePositionZ`, `SetInstanceRotationX`, `GetInstanceRotationX`, `SetInstanceRotationY`, `GetInstanceRotationY`, `SetInstanceRotationZ`, `GetInstanceRotationZ`, `SetInstanceScaleX`, `GetInstanceScaleX`, `SetInstanceScaleY`, `GetInstanceScaleY`, `SetInstanceScaleZ` and `GetInstanceScaleZ` to `BBMOD_Gizmo`. These are used to check if an instance exists and to retrieve/change its position, rotation and scale. **You can override these in case they work with different variables than you use in your project.**
* Added new methods `get_instance_position_vec3`, `set_instance_position_vec3`, `get_instance_rotation_vec3`, `set_instance_rotation_vec3`, `get_instance_scale_vec3` and `set_instance_scale_vec3` to `BBMOD_Gizmo`, which are used to retrieve/change an instance's position, rotation and scale using `BBMOD_Vec3`.
* Added new method `update_position` to `BBMOD_Gizmo`, which updates gizmo's position based on its selected instances.
* Added new method `update` to `BBMOD_Gizmo`, which updates the gizmo (handles instance editing etc.).
* Property `Visible` of `BBMOD_Gizmo` is now obsolete.

### Rendering module:
#### Renderer submodule:
* Added new property `EditMode` to `BBMOD_Renderer`, which enables its `Gizmo` and selecting instances.
* Added new property `ButtonSelect` to `BBMOD_Renderer`, which is the mouse button used to select instances.
* Added new property `KeyMultiSelect` to `BBMOD_Renderer`, which is the virtual keys used for adding/removing instances to/from multiple selection.
* Method `select_gizmo` of `BBMOD_Renderer` is now obsolete.
