# Changelog 3.1.3
This release mainly adds per-vertex ambient (split into upper and lower hemisphere), directional and point lights and per-pixel fog into the default shaders, imitating the classic GameMaker 3D look.

## GML API:
### Core module:
* Added new functions `bbmod_light_ambient_set`, `bbmod_light_ambient_get_up`, `bbmod_light_ambient_set_up`, `bbmod_light_ambient_get_down` and `bbmod_light_ambient_set_down` using which you can configure color of the ambient light sent to shaders.
* Added new struct `BBMOD_Light`, which is a base class for dynamic.
* Added new struct `BBMOD_PointLight`, which is a dynamic point light.
* Added new functions `bbmod_light_point_add`, `bbmod_light_point_count`, `bbmod_light_point_get`, `bbmod_light_point_remove`, `bbmod_light_point_remove_index` and `bbmod_light_point_clear` using which you can configure point lights sent to shaders.
* Added new struct `BBMOD_DirectionalLight`, which is a dynamic directional light.
* Added new functions `bbmod_light_directional_get` and `bbmod_light_directional_set` using which you can configure directional light sent to shaders.
* Added new struct `BBMOD_ImageBasedLight`, which casts light from RGBM-encoded prefiltered octahedrons onto the scene.
* Added new functions `bbmod_fog_set`, `bbmod_fog_set_color`, `bbmod_fog_get_intensity`, `bbmod_fog_set_intensity`, `bbmod_fog_get_start`, `bbmod_fog_set_start`, `bbmod_fog_get_end` and `bbmod_fog_set_end` using which you can configure fog properties passed to shaders.
* Added a new functions `bbmod_ibl_get` and `bbmod_ibl_set` using which you can configure image based light sent to shaders.
* Added new methods `on_set` and `on_reset` to `BBMOD_BaseShader`, which are executed when the shader is set/reset. These are now used in derived shaders to set global shader uniforms instead of misusing method `set_material`.
* Added new methods `set_ambient_light`, `set_directional_light`, `set_point_lights` and `set_fog` to `BBMOD_Shader`, which are called automatically in `on_set` to pass defined lights and fog to the shader.
* Added new functions `bbmod_camera_get_position` and `bbmod_camera_set_position` using which you can configure the camera position sent to shaders.
* Deprecated variable `global.bbmod_camera_position`, please use the new functions instead.
* Added new functions `bbmod_camera_get_exposure` and `bbmod_camera_set_exposure` using which you can configure the camera exposure value sent to shaders.
* Deprecated variable `global.bbmod_camera_exposure`, please use the new functions instead.
* Added new functions `bbmod_render_pass_get` and `bbmod_render_pass_set` using which you can configure the current render pass.
* Deprecated variable `global.bbmod_render_pass`, please use the new functions instead.
* Added new macros `BBMOD_C_AQUA`, `BBMOD_C_BLACK`, `BBMOD_C_BLUE`, `BBMOD_C_DKGRAY`, `BBMOD_C_FUCHSIA`, `BBMOD_C_GRAY`, `BBMOD_C_GREEN`, `BBMOD_C_LIME`, `BBMOD_C_LTGRAY`, `BBMOD_C_MAROON`, `BBMOD_C_NAVY`, `BBMOD_C_OLIVE`, `BBMOD_C_ORANGE`, `BBMOD_C_PURPLE`, `BBMOD_C_RED`, `BBMOD_C_SILVER`, `BBMOD_C_TEAL`, `BBMOD_C_WHITE` and `BBMOD_C_YELLOW`, which are shorthands for `new BBMOD_Color().FromConstant(c_aqua)` etc.
* Added new method `BBMOD_Color.FromHex` using which you can initialize a color using `RRGGBB` hexadecimal format.

### Rendering module:
#### PBR submodule:
* Using material `BBMOD_MATERIAL_SKY` does no longer implicitly load sky and IBL sprites from the included files! You will need to do that yourself if you want to use the PBR shaders!
* Moved methods `set_cam_pos` and `set_exposure` from `BBMOD_PBRShader` to `BBMOD_Shader`. These are also called in the `on_set` method.
* Method `BBMOD_PBRShader.set_ibl` now optionally takes a `BBMOD_ImageBasedLight` to pass to the shader. When not specified, it defaults to the one defined using `bbmod_ibl_set`. Call of this method was also moved to `on_set`.
* Deprecated functions `bbmod_set_ibl_sprite` and `bbmod_set_ibl_texture`. Please use the new struct `BBMOD_ImageBasedLight` and function `bbmod_ibl_set` instead.
