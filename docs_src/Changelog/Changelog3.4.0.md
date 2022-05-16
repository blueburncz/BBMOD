# Changelog
Added new "Gizmo" module.

Shader code was cleaned up, utilizing the latest features of [Xpanda](https://github.com/GameMakerDiscord/Xpanda).

Models and animation files now have major and minor version. This allows us to include additional data into the files, without requiring you to reconvert all your assets.

**All API that was previously marked as deprecated or obsolete was removed, so make sure to read through the change log before upgrading your project!**

## GML API:
### General:
* Further fixes of variable and argument types in docs.
* Removed all API previously marked as deprecated or obsolete!

### Core module:
* Added new property `ShadowmapBias` to `BBMOD_DefaultMaterial`.
* Added new property `BaseOpacityMultiplier` to `BBMOD_BaseMaterial`, which is a multiplier of `BaseOpacity`.
* Fixed method `Mul` of `BBMOD_Matrix`.
* Added new function `bbmod_set_instance_id`.

* Added new macros `BBMOD_VERSION_MAJOR` and `BBMOD_VERSION_MINOR`.
* Macro `BBMOD_VERSION` is now obsolete.
* Added new properties `VersionMajor` and `VersionMinor` to structs `BBMOD_Model` and `BBMOD_Animation`.
* Property `Version` of structs `BBMOD_Model` and `BBMOD_Animation` is now obsolete.

* Added new property `Model` to `BBMOD_Mesh`.
* Added new optional `_model` parameter to `BBMOD_Mesh`'s constructor.
* Added new properties `BboxMin` and `BboxMax` to `BBMOD_Mesh`, which are the minimum and maximum coordinates of the mesh's bounding box. This is supported ony for model version 3.1!

* Added optional argument `_instances` to method `submit` of `BBMOD_RenderQueue`, using which you can submit only meshes with given instance IDs.

### Camera module:
* Added new property `Roll` to `BBMOD_Camera`, using which you can control camera's rotation from side to side.
* Added new properties `DirectionUpMin` and `DirectionUpMax` to `BBMOD_Camera`, using which you can control the minimum and maximum values of `Direction`. These are set to -89 and 89 respectively, same as was the hard limit before. To remove the limit, use set these to `undefined`.
* Property `Up` of `BBMOD_Camera` is now obsolete, please use the `get_up` method instead to retrieve a camera's up vector.

### Gizmo module:
* Added new module - Gizmo.
* Added new struct `BBMOD_Gizmo`.
* Added new macros `BBMOD_SHADER_INSTANCE_ID` and `BBMOD_SHADER_INSTANCE_ID_ANIMATED`, which are shaders used when rendering instance IDs.
* Added new enum `BBMOD_EEditAxis`.
* Added new enum `BBMOD_EEditType`.

### Rendering module:
#### Renderer submodule:
* Added new property `RenderInstanceIDs` to `BBMOD_Renderer`.
* Added new property `Gizmo` to `BBMOD_Renderer`.
* Added new method `get_instance_id` to `BBMOD_Renderer`.
* Added new method `select_gizmo` to `BBMOD_Renderer`.
* Added an optional argument `_clearQueues` to `BBMOD_Renderer.render`, using which you can disable clearing render queues at the end of the method.
* Added new property `InstanceHighlightColor`, which is the outline color of selected instances.
