# Changelog

## GML API:
### Gizmo module:
* Added new optional argument `_size` to `BBMOD_Gizmo`'s constructor.
* Added new enum `BBMOD_EEditSpace`.
* Added new property `EditSpace` to `BBMOD_Gizmo`.
* Property `Visible` of `BBMOD_Gizmo` is now obsolete.
* Added new property `Rotation` to `BBMOD_Gizmo`.
* Added new properties
`InstanceExists`
`GetInstancePosX`
`GetInstancePosY`
`GetInstancePosZ`
`GetInstanceRotX`
`GetInstanceRotY`
`GetInstanceRotZ`
`GetInstanceScaleX`
`GetInstanceScaleY`
`GetInstanceScaleZ`
`SetInstancePosX`
`SetInstancePosY`
`SetInstancePosZ`
`SetInstanceRotX`
`SetInstanceRotY`
`SetInstanceRotZ`
`SetInstanceScaleX`
`SetInstanceScaleY`
`SetInstanceScaleZ`
to `BBMOD_Gizmo`.
* Added new method `update` to `BBMOD_Gizmo`.

### Rendering module:
#### Renderer submodule:
* Added new property `EditMode` to `BBMOD_Renderer`.
* Method `select_gizmo` of `BBMOD_Renderer` is now obsolete.
