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
	/// `undefined` if you don't want to execute any script. Defaults
	/// to [bbmod_material_on_apply_default](./bbmod_material_on_apply_default.html).
	OnApply,

	////////////////////////////////////////////////////////////////////////////
	// GPU settings

	/// @member A blend mode. Use one of the `bm_` constants. Defaults to
	/// `bm_normal`.
	BlendMode,
	/// @member A culling mode. Use one of the `cull_` constants. Defaults to
	/// `cull_counterclockwise`.
	Culling,
	/// @member True if models using this material should write to the depth
	/// buffer. Defaults to `true`.
	ZWrite,
	/// @member True if models using this material should be tested againsy the
	/// depth buffer. Defaults to `true`.
	ZTest,
	/// @member The function used for depth testing when `ZTest` is enabled.
	/// Use one of the `cmpfunc_` constants. Defaults to `cmpfunc_lessequal`.
	ZFunc,

	////////////////////////////////////////////////////////////////////////////
	// Textures

	/// @member A texture with a base color in the RGB channels and opacity in the
	/// alpha channel.
	BaseOpacity,
	/// @member A texture with tangent-space normals in the RGB channels
	/// and roughnes in the alpha channel.
	NormalRoughness,
	/// @member A texture with metallic in the red channel and ambient occlusion
	/// in the green channel.
	MetallicAO,
	/// @member A texture with subsurface color in the RGB channels and subsurface
	/// effect intensity in the alpha channel.
	Subsurface,
	/// @member RGBM encoded emissive texture.
	Emissive,

	////////////////////////////////////////////////////////////////////////////

	/// @member The size of the Material structure.
	SIZE
};