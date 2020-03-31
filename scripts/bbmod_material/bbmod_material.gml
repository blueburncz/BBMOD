/// @func bbmod_material()

/// @enum An enumeration of members of a Material structure.
enum BBMOD_EMaterial
{
	/// @enum A render path. See `BBMOD_RENDER_*` macros.
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
	/// @member Total number of members in this enum.
	SIZE
};