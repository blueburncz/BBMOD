# Changelog

## GML API:
### Gizmo module:
* Added new optional argument `_size` to `BBMOD_Gizmo`'s constructor.
* Added new enum `BBMOD_EEditType`.
* Added new property `EditType` to `BBMOD_Gizmo`.
* Added new enum `BBMOD_EEditSpace`.
* Added new property `EditSpace` to `BBMOD_Gizmo`.
* Property `Visible` of `BBMOD_Gizmo` is now obsolete.
* Added new property `Rotation` to `BBMOD_Gizmo`.
* Added new properties `InstanceExists`, `SetInstancePositionX`, `GetInstancePositionX`, `SetInstancePositionY`, `GetInstancePositionY`, `SetInstancePositionZ`, `GetInstancePositionZ`, `SetInstanceRotationX`, `GetInstanceRotationX`, `SetInstanceRotationY`, `GetInstanceRotationY`, `SetInstanceRotationZ`, `GetInstanceRotationZ`, `SetInstanceScaleX`, `GetInstanceScaleX`, `SetInstanceScaleY`, `GetInstanceScaleY`, `SetInstanceScaleZ` and `GetInstanceScaleZ` to `BBMOD_Gizmo`.
* Added new methods `get_instance_position_vec3`, `set_instance_position_vec3`, `get_instance_rotation_vec3`, `set_instance_rotation_vec3`, `get_instance_scale_vec3` and `set_instance_scale_vec3` to `BBMOD_Gizmo`.
* Added new method `update` to `BBMOD_Gizmo`.
* Added new property `ButtonDrag` to `BBMOD_Gizmo`.
* Added new property `KeyNextEditType` to `BBMOD_Gizmo`.
* Added new property `KeyNextEditSpace` to `BBMOD_Gizmo`.
* Added new properties `KeyEditFaster` and `KeyEditSlower` to `BBMOD_Gizmo`.

### Rendering module:
#### Renderer submodule:
* Added new property `EditMode` to `BBMOD_Renderer`.
* Method `select_gizmo` of `BBMOD_Renderer` is now obsolete.
* Added new property `ButtonSelect` to `BBMOD_Renderer`.
* Added new property `KeyMultiSelect` to `BBMOD_Renderer`.
