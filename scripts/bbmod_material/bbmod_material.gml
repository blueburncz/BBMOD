/// @func bbmod_material()
/// @desc Contains definition of the Material structure.
/// @see BBMOD_EMaterial

/// @enum An enumeration of members of a Material structure.
enum BBMOD_EMaterial
{
	/// @member A render path. See macros
	/// [BBMOD_RENDER_FORWARD](./BBMOD_RENDER_FORWARD.html) and
	/// [BBMOD_RENDER_DEFERRED](./BBMOD_RENDER_DEFFERED.html).
	RenderPath,
	/// @member A shader that the material uses.
	Shader,
	/// @member A script that is executed when the shader is applied.
	/// Must take the material structure as the first argument. Use
	/// `undefined` if you don't want to execute any script.
	OnApply,
	/// @member A blend mode.
	BlendMode,
	/// @member A culling mode.
	Culling,
	/// @member A diffuse texture.
	Diffuse,
	/// @member A normal texture.
	Normal,
	/// @member The size of the Material structure.
	SIZE
};