# Changelog
This release of BBMOD mainly brings features useful for level editors. There is a new Gizmo module and the renderer now supports mouse-picking of instances and gizmos, as well as highlight of selected instances. Models and animation files now also have a minor version - this allows us to include additional data into the files, without requiring you to reconvert all your assets. Additionally, the camera now supports 360° vertical rotation and roll from side to side. All shader code was cleaned up utilizing the latest features of [Xpanda](https://github.com/GameMakerDiscord/Xpanda).

## GML API:
### General:
* Further fixes of variable and argument types in docs.
* **Removed all API previously marked as deprecated or obsolete!**

### Core module:
* Added new macros `BBMOD_VERSION_MAJOR` and `BBMOD_VERSION_MINOR`.
* Macro `BBMOD_VERSION` is now obsolete.
* Added new properties `VersionMajor` and `VersionMinor` to structs `BBMOD_Model` and `BBMOD_Animation`.
* Property `Version` of structs `BBMOD_Model` and `BBMOD_Animation` is now obsolete.
* Added new property `Model` to `BBMOD_Mesh`.
* Added new optional `_model` parameter to `BBMOD_Mesh`'s constructor.
* Added new properties `BboxMin` and `BboxMax` to `BBMOD_Mesh`, which are the minimum and maximum coordinates of the mesh's bounding box. This is supported ony for model version 3.1!
* Added new function `bbmod_set_instance_id`.
* Added optional argument `_instances` to method `submit` of `BBMOD_RenderQueue`, using which you can submit only meshes with given instance IDs.
* Added new property `ShadowmapBias` to `BBMOD_DefaultMaterial`, using which you can control a range over which a material smoothly transitions into a full shadow. This is useful for example for volumetric objects.
* Added new property `BaseOpacityMultiplier` to `BBMOD_BaseMaterial`, which is a color multiplier of `BaseOpacity`.
* Fixed method `Mul` of `BBMOD_Matrix`.
* Method `destroy` of `BBMOD_Class` now returns `undefined`.

### Camera module:
* Added new property `Roll` to `BBMOD_Camera`, using which you can control camera's rotation from side to side.
* Added new properties `DirectionUpMin` and `DirectionUpMax` to `BBMOD_Camera`, using which you can control the minimum and maximum values of `Direction`. These are set to -89 and 89 respectively, same as was the hard limit before. To remove the limit, use set these to `undefined`.
* Property `Up` of `BBMOD_Camera` is now obsolete, please use the `get_up` method instead to retrieve a camera's up vector.

### Gizmo module:
* Added new module - Gizmo.
* Added new struct `BBMOD_Gizmo`.
* Added new macros `BBMOD_SHADER_INSTANCE_ID` and `BBMOD_SHADER_INSTANCE_ID_ANIMATED`, which are shaders used when rendering instance IDs.
* Added new enum `BBMOD_EEditAxis`, which is an enumeration of edit axes.
* Added new enum `BBMOD_EEditType`, which is an enumeration of edit types.

### Rendering module:
#### Renderer submodule:
* Added an optional argument `_clearQueues` to `BBMOD_Renderer.render`, using which you can disable clearing render queues at the end of the method.
* Added new property `RenderInstanceIDs` to `BBMOD_Renderer`. When set to `true`, then the renderer renders instance IDs into an off-screen surface.
* Added new method `get_instance_id` to `BBMOD_Renderer`, using which you can pick an instance ID at given position on the screen.
* Added new property `InstanceHighlightColor`, which is the outline color of selected instances.
* Added new property `Gizmo` to `BBMOD_Renderer`, using which you can add a gizmo to a renderer. This enables its automatic rendering and highlight of its selected instances.
* Added new method `select_gizmo` to `BBMOD_Renderer`, using which you can pick a gizmo at given position on the screen.
