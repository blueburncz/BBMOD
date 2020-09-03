/// @enum An enumeration of members of a BBMOD_EMaterial legacy struct.
/// @deprecated Legacy structs are deprecated. Please use {@link BBMOD_Material}
/// instead.
enum BBMOD_EMaterial
{
	/// @member A render path. See macros {@link BBMOD_RENDER_FORWARD} and
	/// {@link BBMOD_RENDER_DEFERRED}.
	RenderPath,
	/// @member A shader that the material uses.
	Shader,
	/// @member A script that is executed when the shader is applied.
	/// Must take the material as the first argument. Use `undefined`
	/// if you don't want to execute any script. Defaults
	/// to {@link bbmod_material_on_apply_default}.
	OnApply,

	////////////////////////////////////////////////////////////////////////////
	// GPU settings

	/// @member A blend mode. Use one of the `bm_` constants. Defaults to
	/// `bm_normal`.
	BlendMode,
	/// @member A culling mode. Use one of the `cull_` constants. Defaults to
	/// `cull_counterclockwise`.
	Culling,
	/// @member `true` if models using this material should write to the depth
	/// buffer. Defaults to `true`.
	ZWrite,
	/// @member `true` if models using this material should be tested againsy the
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

	/// @member Total number of members of this enum.
	SIZE
};

/// @func bbmod_material_create(_shader[, _base_opacity[, _normal_roughness[, _metallic_ao[, _subsurface[, _emissive]]]]])
/// @desc Creates a new material.
/// @param {ptr} _shader A shader that the material uses.
/// @param {ptr} [_base_opacity] A texture with base color in RGB and opacity in alpha.
/// @param {ptr} [_normal_roughness] A texture with normals in RGB and roughness in alpha.
/// @param {ptr} [_metallic_ao] A texture with metallic in R and ambient occlusion in G.
/// @param {ptr} [_subsurface] A texture with subsurface color in RGB and intensity in alpha.
/// @param {ptr} [_emissive] A texture with RGBM encoded emissive color.
/// @return {BBMOD_EMaterial} The created material.
/// @deprecated This function is deprecated. Please use {@link BBMOD_Material} instead.
function bbmod_material_create(_shader)
{
	var _base_opacity = (argument_count > 1) ? argument[1] : undefined;
	var _normal_roughness = (argument_count > 2) ? argument[2] : undefined;
	var _metallic_ao = (argument_count > 3) ? argument[3] : undefined;
	var _subsurface = (argument_count > 4) ? argument[4] : undefined;
	var _emissive = (argument_count > 5) ? argument[5] : undefined;

	var _mat = array_create(BBMOD_EMaterial.SIZE, -1);

	_mat[@ BBMOD_EMaterial.RenderPath] = BBMOD_RENDER_FORWARD;
	_mat[@ BBMOD_EMaterial.Shader] = _shader;
	_mat[@ BBMOD_EMaterial.OnApply] = bbmod_material_on_apply_default;
	_mat[@ BBMOD_EMaterial.BlendMode] = bm_normal;
	_mat[@ BBMOD_EMaterial.Culling] = cull_counterclockwise;
	_mat[@ BBMOD_EMaterial.ZWrite] = true;
	_mat[@ BBMOD_EMaterial.ZTest] = true;
	_mat[@ BBMOD_EMaterial.ZFunc] = cmpfunc_lessequal;

	_mat[@ BBMOD_EMaterial.BaseOpacity] = (_base_opacity != undefined) ? _base_opacity
		: sprite_get_texture(BBMOD_SprDefaultMaterial, 0);

	_mat[@ BBMOD_EMaterial.NormalRoughness] = (_normal_roughness != undefined) ? _normal_roughness
		: sprite_get_texture(BBMOD_SprDefaultMaterial, 1);

	_mat[@ BBMOD_EMaterial.MetallicAO] = (_metallic_ao != undefined) ? _metallic_ao
		: sprite_get_texture(BBMOD_SprDefaultMaterial, 2);

	_mat[@ BBMOD_EMaterial.Subsurface] = (_subsurface != undefined) ? _subsurface
		: sprite_get_texture(BBMOD_SprDefaultMaterial, 3);

	_mat[@ BBMOD_EMaterial.Emissive] = (_emissive != undefined) ? _emissive
		: sprite_get_texture(BBMOD_SprDefaultMaterial, 4);

	return _mat;
}

/// @func bbmod_material_clone(_material)
/// @desc Creates a copy of a material.
/// @param {BBMOD_EMaterial} _material The material to create a copy of.
/// @return {BBMOD_EMaterial} The created material.
/// @deprecated This function is deprecated. Please use {@link BBMOD_Material.clone}
/// instead.
function bbmod_material_clone(_material)
{
	gml_pragma("forceinline");
	var _copy = array_create(BBMOD_EMaterial.SIZE, 0);
	array_copy(_copy, 0, _material, 0, BBMOD_EMaterial.SIZE);
	return _copy;
}

/// @func bbmod_material_apply(_material)
/// @desc Applies a material.
/// @param {BBMOD_EMaterial} _material A material.
/// @return {bool} `true` if the material was applied or `false` if it was already
/// the current one.
/// @deprecated This function is deprecated. Please use {@link BBMOD_Material.apply}
/// instead.
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
			_on_apply(_material);
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
/// @deprecated This function is deprecated. Please use {@link BBMOD_Material.reset}
/// instead.
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

/// @func bbmod_material_on_apply_default(_material)
/// @desc The default material application function.
/// @param {BBMOD_EMaterial} _material The material.
function bbmod_material_on_apply_default(_material)
{
	var _shader = _material[BBMOD_EMaterial.Shader];

	texture_set_stage(shader_get_sampler_index(_shader, "u_texNormalRoughness"),
		_material[BBMOD_EMaterial.NormalRoughness]);

	texture_set_stage(shader_get_sampler_index(_shader, "u_texMetallicAO"),
		_material[BBMOD_EMaterial.MetallicAO]);

	texture_set_stage(shader_get_sampler_index(_shader, "u_texSubsurface"),
		_material[BBMOD_EMaterial.Subsurface]);

	texture_set_stage(shader_get_sampler_index(_shader, "u_texEmissive"),
		_material[BBMOD_EMaterial.Emissive]);

	var _ibl = global.__bbmod_ibl_texture;

	if (_ibl != pointer_null)
	{
		_bbmod_shader_set_ibl(_shader, _ibl, global.__bbmod_ibl_texel);
	}

	_bbmod_shader_set_camera_position(_shader);

	_bbmod_shader_set_exposure(_shader);
}

/// @func BBMOD_Material(_shader[, _base_opacity[, _normal_roughness[, _metallic_ao[, _subsurface[, _emissive]]]]])
/// @desc A material that can be used when rendering models.
/// @param {ptr} _shader A shader that the material uses.
/// @param {ptr} [_base_opacity] A texture with base color in RGB and opacity in alpha.
/// @param {ptr} [_normal_roughness] A texture with normals in RGB and roughness in alpha.
/// @param {ptr} [_metallic_ao] A texture with metallic in R and ambient occlusion in G.
/// @param {ptr} [_subsurface] A texture with subsurface color in RGB and intensity in alpha.
/// @param {ptr} [_emissive] A texture with RGBM encoded emissive color.
function BBMOD_Material(_shader) constructor
{
	var _base_opacity = (argument_count > 1) ? argument[1] : undefined;
	var _normal_roughness = (argument_count > 2) ? argument[2] : undefined;
	var _metallic_ao = (argument_count > 3) ? argument[3] : undefined;
	var _subsurface = (argument_count > 4) ? argument[4] : undefined;
	var _emissive = (argument_count > 5) ? argument[5] : undefined;

	/// @var {BBMOD_EMaterial} The material that this struct wraps.
	/// @private
	material = bbmod_material_create(_shader, _base_opacity, _normal_roughness,
		_metallic_ao, _subsurface, _emissive);

	/// @func get_render_path()
	/// @return {real}
	/// @see BBMOD_RENDER_FORWARD
	/// @see BBMOD_RENDER_DEFERRED
	static get_render_path = function () {
		return material[BBMOD_EMaterial.RenderPath];
	};

	/// @func set_render_path(_render_path)
	/// @param {real} _render_path
	/// @return {real}
	/// @see BBMOD_RENDER_FORWARD
	/// @see BBMOD_RENDER_DEFERRED
	static set_render_path = function (_render_path) {
		material[@ BBMOD_EMaterial.RenderPath] = _render_path;
	};

	/// @func get_shader()
	/// @return {real}
	static get_shader = function () {
		return material[BBMOD_EMaterial.Shader];
	};

	/// @func set_shader(_shader)
	/// @param {real} shader
	static set_shader = function (_shader) {
		material[@ BBMOD_EMaterial.Shader] = _shader;
	};

	/// @return get_on_apply()
	/// @return {function}
	static get_on_apply = function () {
		return material[BBMOD_EMaterial.OnApply];
	};

	/// @func set_on_apply(_on_apply)
	/// @param {function} _on_apply
	static set_on_apply = function (_on_apply) {
		material[@ BBMOD_EMaterial.OnApply] = method(self, _on_apply);
	};

	/// @func get_blendmode()
	/// @return {real}
	static get_blendmode = function () {
		return material[BBMOD_EMaterial.BlendMode];
	};

	/// @func set_blendmode(_blendmode)
	/// @param {real} _blendmode
	static set_blendmode = function (_blendmode) {
		material[@ BBMOD_EMaterial.BlendMode] = _blendmode;
	};

	/// @func get_culling()
	/// @return {real}
	static get_culling = function () {
		return material[BBMOD_EMaterial.Culling];
	};

	/// @func set_culling(_culling)
	/// @param {real} _culling
	static set_culling = function (_culling) {
		material[@ BBMOD_EMaterial.Culling] = _culling;
	};

	/// @func get_zwrite()
	/// @return {bool}
	static get_zwrite = function () {
		return material[BBMOD_EMaterial.ZWrite];
	};

	/// @func set_zwrite(_zwrite)
	/// @param {bool} _zwrite
	static set_zwrite = function (_zwrite) {
		material[@ BBMOD_EMaterial.ZWrite] = _zwrite;
	};

	/// @func get_ztest()
	/// @return {bool}
	static get_ztest = function () {
		return material[BBMOD_EMaterial.ZTest];
	};

	/// @func set_ztest(_ztest)
	/// @param {bool} _ztest
	static set_ztest = function (_ztest) {
		material[@ BBMOD_EMaterial.ZTest] = _ztest;
	};

	/// @func get_zfunc()
	/// @return {real}
	static get_zfunc = function () {
		return material[BBMOD_EMaterial.ZFunc];
	};

	/// @func set_zfunc(_zfunc)
	/// @param {real} _zfunc
	static set_zfunc = function (_zfunc) {
		material[@ BBMOD_EMaterial.ZFunc] = _zfunc;
	};

	/// @func get_base_opacity()
	/// @return {ptr}
	static get_base_opacity = function () {
		return material[BBMOD_EMaterial.BaseOpacity];
	};

	/// @func set_base_opacity(_base_opacity)
	/// @param {ptr} _base_opacity
	static set_base_opacity = function (_base_opacity) {
		material[@ BBMOD_EMaterial.BaseOpacity] = _base_opacity;
	};

	/// @func get_normal_roughness()
	/// @return {ptr}
	static get_normal_roughness = function () {
		return material[BBMOD_EMaterial.NormalRoughness];
	};

	/// @func set_normal_roughness(_normal_roughness)
	/// @param {ptr} _normal_roughness
	static set_normal_roughness = function (_normal_roughness) {
		material[@ BBMOD_EMaterial.NormalRoughness] = _normal_roughness;
	};

	/// @func get_metallic_ao()
	/// @return {ptr}
	static get_metallic_ao = function () {
		return material[BBMOD_EMaterial.MetallicAO];
	};

	/// @func set_metallic_ao(_metallic_ao)
	/// @param {ptr} _metallic_ao
	static set_metallic_ao = function (_metallic_ao) {
		material[@ BBMOD_EMaterial.MetallicAO] = _metallic_ao;
	};

	/// @func get_subsurface()
	/// @return {ptr}
	static get_subsurface = function () {
		return material[BBMOD_EMaterial.Subsurface];
	};

	/// @func set_subsurface(_subsurface)
	/// @param {ptr} _subsurface
	static set_subsurface = function (_subsurface) {
		material[@ BBMOD_EMaterial.Subsurface] = _subsurface;
	};

	/// @func get_emissive()
	/// @return {ptr}
	static get_emissive = function () {
		return material[BBMOD_EMaterial.Emissive];
	};

	/// @func set_emissive(_missive)
	/// @param {ptr} _missive
	static set_emissive = function (_missive) {
		material[@ BBMOD_EMaterial.Emissive] = _emissive;
	};

	/// @func clone()
	/// @desc Clones the material.
	/// @return {BBMOD_Material} The created clone.
	static clone = function () {
		var _clone = new BBMOD_Material(get_shader());
		_clone.material = bbmod_material_clone(material);
		_clone.set_on_apply(get_on_apply());
		return _clone;
	};

	/// @func apply()
	/// @desc Sets the current material to this one.
	static apply = function () {
		bbmod_material_apply(material);
	};

	/// @func reset()
	/// @desc Unsets the current material.
	static reset = function () {
		bbmod_material_reset();
	};
}