# Changelog dev
> This file is used to accumulate changes before a changelog for a release is created.

* Fixed strength of lens flares exceeding 1 when property `Range` is not `infinity`.
* Fixed macro `BBMOD_RELEASE_PATCH`, which we forgot to increase the last release.
* Fixed macro `BBMOD_RELEASE_STRING`, which used invalid syntax.
* Fixed method `set_material` of `BBMOD_DefaultSpriteShader`, which set material UVs incorrectly.
* Added more ready-to-use models of basic shapes.
* Fixed method `clear` of `BBMOD_ResourceManager` not always removing destroyed resources, which could cause crashes for example when restarting rooms.
* Shaders `BBMOD_SHADER_DEFAULT_DEPTH` and `BBMOD_SHADER_GBUFFER` are now compatible with vertex format `BBMOD_VFORMAT_DEFAULT_SPRITE`.
* Added new macro `BBMOD_U_SUBSURFACE_UV`, which is the name of a fragment shader uniform of type `vec4` that holds top left and bottom right coordinates of the subsurface texture on its texture page.
* Added new function `bbmod_shader_set_subsurface_uv`, which sets the `BBMOD_U_SUBSURFACE_UV` uniform to given values.
* Added new macro `BBMOD_U_EMISSIVE_UV`, which is the name of a fragment shader uniform of type `vec4` that holds top left and bottom right coordinates of the emissive texture on its texture page.
* Added new function `bbmod_shader_set_emissive_uv`, which sets the `BBMOD_U_EMISSIVE_UV` uniform to given values.
* Added new macro `BBMOD_U_TWO_SIDED`, which is the name of a fragment shader uniform of type `float` that equals 1 when the material is two-sided or 0 when it is not. If a material is two-sided, normal vectors of backfaces are flipped before shading.
* Added new function `bbmod_shader_set_two_sided`, which sets the `BBMOD_U_TWO_SIDED` uniform.
* Added new property `TwoSided` to `BBMOD_BaseMaterial`, which tells whether the material is two-sided. If the material is two-sided, normal vectors of backfaces are flipped before shading. Default value is `true`.
* Fixed property `RenderScale` of renderers affecting the size of the final surface on screen.

* Methods `DrawSprite`, `DrawSpriteExt`, `DrawSpriteGeneral`, `DrawSpritePart`, `DrawSpritePartExt`, `DrawSpritePos`, `DrawSpriteStretched`, `DrawSpriteStretchedExt`, `DrawSpriteTiled`, `DrawSpriteTiledExt` of `BBMOD_RenderQueue` now set uniform `BBMOD_U_BASE_OPACITY_UV` automatically and you do not need to assign the `BaseOpacity` property of used material to the sprite drawn.

* Added new member `SetGpuDepth` to enum `BBMOD_ERenderCommand`, which is a render command that changes the z coordinate at which sprites and text are drawn.
* Added new method `SetGpuDepth` to `BBMOD_RenderQueue`, which adds a `SetGpuDepth` command to the render queue.

* Added new member `DrawText` to enum `BBMOD_ERenderCommand`, which is a render command that draws text using the `draw_text` function.
* Added new member `DrawTextColor` to enum `BBMOD_ERenderCommand`, which is a render command that draws text using the `draw_text_color` function.
* Added new member `DrawTextExt` to enum `BBMOD_ERenderCommand`, which is a render command that draws text using the `draw_text_ext` function.
* Added new member `DrawTextExtColor` to enum `BBMOD_ERenderCommand`, which is a render command that draws text using the `draw_text_ext_color` function.
* Added new member `DrawTextExtTransformed` to enum `BBMOD_ERenderCommand`, which is a render command that draws text using the `draw_text_ext_transformed` function.
* Added new member `DrawTextExtTransformedColor` to enum `BBMOD_ERenderCommand`, which is a render command that draws text using the `draw_text_ext_transformed_color` function.
* Added new member `DrawTextTransformed` to enum `BBMOD_ERenderCommand`, which is a render command that draws text using the `draw_text_transformed` function.
* Added new member `DrawTextTransformedColor` to enum `BBMOD_ERenderCommand`, which is a render command that draws text using the `draw_text_transformed_color` function.
* Added new method `DrawText` to `BBMOD_RenderQueue`, which adds a `DrawText` command to the render queue.
* Added new method `DrawTextColor` to `BBMOD_RenderQueue`, which adds a `DrawTextColor` command to the render queue.
* Added new method `DrawTextExt` to `BBMOD_RenderQueue`, which adds a `DrawTextExt` command to the render queue.
* Added new method `DrawTextExtColor` to `BBMOD_RenderQueue`, which adds a `DrawTextExtColor` command to the render queue.
* Added new method `DrawTextExtTransformed` to `BBMOD_RenderQueue`, which adds a `DrawTextExtTransformed` command to the render queue.
* Added new method `DrawTextExtTransformedColor` to `BBMOD_RenderQueue`, which adds a `DrawTextExtTransformedColor` command to the render queue.
* Added new method `DrawTextTransformed` to `BBMOD_RenderQueue`, which adds a `DrawTextTransformed` command to the render queue.
* Added new method `DrawTextTransformedColor` to `BBMOD_RenderQueue`, which adds a `DrawTextTransformedColor` command to the render queue.

* Added new member `CallFunction` to enum `BBMOD_ERenderCommand`, which is a render command that executes a custom function with given arguments.
* Added new method `CallFunction` to `BBMOD_RenderQueue`, which adds a `CallFunction` command to the render queue.
