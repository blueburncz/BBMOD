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

/// @func bbmod_material_create(_shader[, _base_opacity[, _normal_roughness[, _metallic_ao[, _subsurface[, _emissive]]]]])
/// @desc Creates a new Material structure.
/// @param {ptr} _shader A shader that the material uses.
/// @param {ptr} [_base_opacity] A texture with base color in RGB and opacity in alpha.
/// @param {ptr} [_normal_roughness] A texture with normals in RGB and roughness in alpha.
/// @param {ptr} [_metallic_ao] A texture with metallic in R and ambient occlusion in G.
/// @param {ptr} [_subsurface] A texture with subsurface color in RGB and intensity in alpha.
/// @param {ptr} [_emissive] A texture with RGBM encoded emissive color.
/// @return {array} The created Material structure.
function bbmod_material_create()
{
	var _mat = array_create(BBMOD_EMaterial.SIZE, -1);

	_mat[@ BBMOD_EMaterial.RenderPath] = BBMOD_RENDER_FORWARD;
	_mat[@ BBMOD_EMaterial.Shader] = argument[0];
	_mat[@ BBMOD_EMaterial.OnApply] = bbmod_material_on_apply_default;
	_mat[@ BBMOD_EMaterial.BlendMode] = bm_normal;
	_mat[@ BBMOD_EMaterial.Culling] = cull_counterclockwise;
	_mat[@ BBMOD_EMaterial.ZWrite] = true;
	_mat[@ BBMOD_EMaterial.ZTest] = true;
	_mat[@ BBMOD_EMaterial.ZFunc] = cmpfunc_lessequal;

	_mat[@ BBMOD_EMaterial.BaseOpacity] = (argument_count > 1) ? argument[1]
		: sprite_get_texture(BBMOD_SprDefaultMaterial, 0);

	_mat[@ BBMOD_EMaterial.NormalRoughness] = (argument_count > 2) ? argument[2]
		: sprite_get_texture(BBMOD_SprDefaultMaterial, 1);

	_mat[@ BBMOD_EMaterial.MetallicAO] = (argument_count > 3) ? argument[3]
		: sprite_get_texture(BBMOD_SprDefaultMaterial, 2);

	_mat[@ BBMOD_EMaterial.Subsurface] = (argument_count > 4) ? argument[4]
		: sprite_get_texture(BBMOD_SprDefaultMaterial, 3);

	_mat[@ BBMOD_EMaterial.Emissive] = (argument_count > 5) ? argument[5]
		: sprite_get_texture(BBMOD_SprDefaultMaterial, 4);

	return _mat;
}

/// @func bbmod_material_clone(_material)
/// @desc Creates a copy of a Material structure.
/// @param {array} _material The Material structure to create a copy of.
/// @return {array} The created Material structure.
function bbmod_material_clone(_material)
{
	gml_pragma("forceinline");
	var _copy = array_create(BBMOD_EMaterial.SIZE, 0);
	array_copy(_copy, 0, _material, 0, BBMOD_EMaterial.SIZE);
	return _copy;
}

/// @func bbmod_material_apply(_material)
/// @desc Applies a material.
/// @param {array} _material A Material structure.
/// @return {bool} True if the material was applied or false if it was already
/// the current one.
function bbmod_material_apply(_material)
{
	if (_material == global.__bbmod_material_current)
	{
		return false;
	}

	bbmod_material_reset();

	// Shader
	var _shader = _material[BBMOD_EMaterial.Shader];
	if (shader_current() != _shader)
	{
		shader_set(_shader);

		var _on_apply = _material[BBMOD_EMaterial.OnApply];
		if (!is_undefined(_on_apply))
		{
			script_execute(_on_apply, _material);
		}
	}

	// Gpu state
	gpu_set_blendmode(_material[BBMOD_EMaterial.BlendMode]);
	gpu_set_cullmode(_material[BBMOD_EMaterial.Culling]);
	gpu_set_zwriteenable(_material[BBMOD_EMaterial.ZWrite]);

	var _ztest = _material[BBMOD_EMaterial.ZTest];
	gpu_set_ztestenable(_ztest);

	if (_ztest)
	{
		gpu_set_zfunc(_material[BBMOD_EMaterial.ZFunc]);
	}

	global.__bbmod_material_current = _material;

	return true;
}

/// @func bbmod_material_reset()
/// @desc Resets the current material to `undefined`.
function bbmod_material_reset()
{
	gml_pragma("forceinline");
	if (global.__bbmod_material_current != undefined)
	{
		shader_reset();
		gpu_pop_state();
		global.__bbmod_material_current = undefined;
	}
	else
	{
		gpu_push_state();
	}
}

/// @func bbmod_material_on_apply_default(material)
/// @desc The default material application function.
/// @param {array} material The Material struct.
function bbmod_material_on_apply_default(material)
{
	var _shader = material[BBMOD_EMaterial.Shader];

	texture_set_stage(shader_get_sampler_index(_shader, "u_texNormalRoughness"),
		material[BBMOD_EMaterial.NormalRoughness]);

	texture_set_stage(shader_get_sampler_index(_shader, "u_texMetallicAO"),
		material[BBMOD_EMaterial.MetallicAO]);

	texture_set_stage(shader_get_sampler_index(_shader, "u_texSubsurface"),
		material[BBMOD_EMaterial.Subsurface]);

	texture_set_stage(shader_get_sampler_index(_shader, "u_texEmissive"),
		material[BBMOD_EMaterial.Emissive]);

	var _ibl = global.__bbmod_ibl_texture;

	if (_ibl != pointer_null)
	{
		_bbmod_shader_set_ibl(_shader, _ibl, global.__bbmod_ibl_texel);
	}

	_bbmod_shader_set_camera_position(_shader);

	_bbmod_shader_set_exposure(_shader);
}