# Changelog dev
> This file is used to accumulate changes before a changelog for a release is created.

* Added new function `bbmod_camera_get_fov_flip()`, which returns whether BBMOD cameras use a flipped field of view.
* Added new function `bbmod_camera_set_fov_flip(_flip)`, using which you can change whether BBMOD cameras should use a flipped field of view. By default this is **enabled** for backwards compatibility.
* Added new function `bbmod_camera_get_aspect_flip()`, which returns whether BBMOD cameras use a flipped aspect ratio.
* Added new function `bbmod_camera_set_aspect_flip(_flip)`, using which you can change whether BBMOD cameras should use a flipped aspect ratio. By default this is **enabled** for backwards compatibility.
* Added new property `ClearColor` to `BBMOD_DeferredRenderer`, which is the color to clear the background with. Default value is `c_black`.
* Fixed normal vectors of backfaces being flipped incorrectly.
* Fixed lens dirt post-processing effect on OpenGL platforms.
