# Changelog 3.16.5
This release mainly fixes specular reflections and the size of the gizmo when using an orthographic projection. Additionally, resources can now be marked as persistent and a new `clear` method was added to the resource manager, which frees all non-persistent resources.

* Added new property `Height` to `BBMOD_BaseCamera`, which is the height of the orthographic projection. If `undefined`, then it is computed from `Width` using `AspectRatio`. Defaults to `undefined`.
* Property `Width` of `BBMOD_BaseCamera` can now be `undefined`. It is then computed from `Height` using `AspectRatio`.
* Fixed gizmo changing size based on its distance from the camera when using an orthographic projection.
* Fixed specular reflections when using an orthographic projection.
* Added new property `Persistent` to `BBMOD_Resource`. If it is `true`, then the resource is persistent and it is not destroyed when method `free` is used. Default value is `false`.
* Added new method `clear` to `BBMOD_ResourceManager`, which destroys all non-persistent resources.
* Added new macro `BBMOD_RESOURCE_MANAGER`, which is the default resource manager.
