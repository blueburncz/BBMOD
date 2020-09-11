/// @macro {real} A flag used to tell that a model is rendered in a forward
/// render path.
/// @see BBMOD_RENDER_DEFERRED
/// @see global.bbmod_render_pass
/// @see BBMOD_Material.RenderPath
#macro BBMOD_RENDER_FORWARD (1)

/// @macro {real} A flag used to tell that a model is rendered in a deferred
/// render path.
/// @see BBMOD_RENDER_FORWARD
/// @see global.bbmod_render_pass
/// @see BBMOD_Material.RenderPath
#macro BBMOD_RENDER_DEFERRED (1 << 1)

/// @macro {BBMOD_Material} The default material.
/// @see BBMOD_Material
#macro BBMOD_MATERIAL_DEFAULT global.__bbmod_material_default

/// @macro {BBMOD_Material} The default material for animated models.
/// @see BBMOD_Material
#macro BBMOD_MATERIAL_DEFAULT_ANIMATED global.__bbmod_material_default_animated

/// @macro {BBMOD_Material} The default material for dynamically batched models.
/// @see BBMOD_Material
/// @see BBMOD_DynamicBatch
#macro BBMOD_MATERIAL_DEFAULT_BATCHED global.__bbmod_material_default_batched

/// @macro {BBMOD_Material} The default sky material.
/// @see BBMOD_Material
#macro BBMOD_MATERIAL_SKY global.__bbmod_material_sky

/// @var {BBMOD_Material} The default material.
/// @see BBMOD_Material
/// @private
global.__bbmod_material_default = new BBMOD_Material(BBMOD_ShDefault);

/// @var {BBMOD_Material} The default material for animated models.
/// @see BBMOD_Material
/// @private
global.__bbmod_material_default_animated = new BBMOD_Material(BBMOD_ShDefaultAnimated);

/// @var {BBMOD_Material} The default material for dynamically batched models.
/// @see BBMOD_Material
/// @private
global.__bbmod_material_default_batched = new BBMOD_Material(BBMOD_ShDefaultBatched);

// FIXME: Initial IBL setup
var _spr_sky = sprite_add("BBMOD/Skies/NoonSky.png", 0, false, true, 0, 0);
var _mat_sky = new BBMOD_Material(BBMOD_ShSky);
_mat_sky.BaseOpacity = sprite_get_texture(_spr_sky, 0);
_mat_sky.OnApply = function (_material) {
	var _shader = _material.Shader;
	_bbmod_shader_set_exposure(_shader);
};
_mat_sky.Culling = cull_noculling;

/// @macro {BBMOD_Material} The default sky material.
/// @see BBMOD_Material
global.__bbmod_material_sky = _mat_sky;

/// @var {BBMOD_EMaterial/BBMOD_NONE} The currently applied material.
/// @private
global.__bbmod_material_current = BBMOD_NONE;

/// @var {real} The current render pass.
/// @example
/// ```gml
/// if (global.bbmod_render_pass & BBMOD_RENDER_DEFERRED)
/// {
///     // Draw objects to a G-Buffer...
/// }
/// ```
/// @see BBMOD_RENDER_FORWARD
/// @see BBMOD_RENDER_DEFERRED
global.bbmod_render_pass = BBMOD_RENDER_FORWARD;

/// @enum An enumeration of members of a legacy material struct.
/// @obsolete This legacy struct is obsolete. Please use
/// {@link BBMOD_Material} instead.
enum BBMOD_EMaterial
{
	/// @member {real} A render path. See macros {@link BBMOD_RENDER_FORWARD} and
	/// {@link BBMOD_RENDER_DEFERRED}.
	RenderPath,
	/// @member {shader} A shader that the material uses.
	Shader,
	/// @member {function} A function that is executed when the shader is applied.
	/// Must take the material  as the first argument. Use `undefined` if you don't
	/// want to execute any function.
	OnApply,
	/// @member {real} A blend mode. Use one of the `bm_` constants. Defaults to
	/// `bm_normal`.
	BlendMode,
	/// @member {real} A culling mode. Use one of the `cull_` constants. Defaults to
	/// `cull_counterclockwise`.
	Culling,
	/// @member {ptr} A diffuse texture.
	Diffuse,
	/// @member {ptr} A normal texture.
	Normal,
	/// @member The size of the struct.
	SIZE
};

/// @func bbmod_material_create(_shader[, _base_opacity[, _normal_roughness]])
/// @desc Creates a new material.
/// @param {ptr} _shader A shader that the material uses.
/// @param {ptr} [_base_opacity] A texture with base color in RGB and opacity in alpha.
/// @param {ptr} [_normal_roughness] A texture with normals in RGB and roughness in alpha.
/// @return {BBMOD_Material} The created material.
/// @deprecated This function is deprecated. Please use {@link BBMOD_Material} instead.
function bbmod_material_create(_shader)
{
	gml_pragma("forceinline");
	var _base_opacity = (argument_count > 1) ? argument[1] : undefined;
	var _normal_roughness = (argument_count > 2) ? argument[2] : undefined;
	var _material = new BBMOD_Material(_shader);
	if (_base_opacity != undefined)
	{
		_material.BaseOpacity = _base_opacity;
	}
	if (_normal_roughness != undefined)
	{
		_material.NormalRoughness = _normal_roughness;
	}
	return _material;
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
	return _material.clone();
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
	gml_pragma("forceinline");
	return _material.apply();
}

/// @func bbmod_material_reset()
/// @desc Resets the current material to {@link BBMOD_NONE}. Every block of code
/// rendering models must start and end with this function!
/// @example
/// ```gml
/// bbmod_material_reset();
///
/// // Render static batch of trees
/// tree_batch.render(mat_tree);
///
/// // Render characters
/// var _world = matrix_get(matrix_world);
/// with (OCharacter)
/// {
///     matrix_set(matrix_world, matrix_build(x, y, z, 0, 0, direction, 1, 1, 1));
///     model.render(materials, animation_player.get_transform());
/// }
/// matrix_set(matrix_world, _world);
///
/// bbmod_material_reset();
/// ```
/// @see BBMOD_Material.reset
function bbmod_material_reset()
{
	gml_pragma("forceinline");
	if (global.__bbmod_material_current != BBMOD_NONE)
	{
		shader_reset();
		gpu_pop_state();
		global.__bbmod_material_current = BBMOD_NONE;
	}
}

/// @func bbmod_material_on_apply_default(_material)
/// @desc The default material application function.
/// @param {BBMOD_EMaterial} _material The material.
function bbmod_material_on_apply_default(_material)
{
	var _shader = _material.Shader;

	texture_set_stage(shader_get_sampler_index(_shader, "u_texNormalRoughness"),
		_material.NormalRoughness);

	texture_set_stage(shader_get_sampler_index(_shader, "u_texMetallicAO"),
		_material.MetallicAO);

	texture_set_stage(shader_get_sampler_index(_shader, "u_texSubsurface"),
		_material.Subsurface);

	texture_set_stage(shader_get_sampler_index(_shader, "u_texEmissive"),
		_material.Emissive);

	var _ibl = global.__bbmod_ibl_texture;

	if (_ibl != pointer_null)
	{
		_bbmod_shader_set_ibl(_shader, _ibl, global.__bbmod_ibl_texel);
	}

	_bbmod_shader_set_camera_position(_shader);

	_bbmod_shader_set_exposure(_shader);
}

/// @func BBMOD_Material(_shader)
/// @desc A material that can be used when rendering models.
/// @param {ptr} _shader A shader that the material uses.
function BBMOD_Material(_shader) constructor
{
	/// @var {real} A render path. See macros {@link BBMOD_RENDER_FORWARD} and
	/// {@link BBMOD_RENDER_DEFERRED}.
	RenderPath = BBMOD_RENDER_FORWARD;

	/// @var {shader} A shader that the material uses.
	Shader = _shader;

	/// @var {function} A function that is executed when the shader is applied.
	/// Must take the material as the first argument. Use `undefined`
	/// if you don't want to execute any function. Defaults
	/// to {@link bbmod_material_on_apply_default}.
	OnApply = bbmod_material_on_apply_default;

	/// @var {real} A blend mode. Use one of the `bm_` constants. Default value is
	/// `bm_normal`.
	BlendMode = bm_normal;

	/// @var {real} A culling mode. Use one of the `cull_` constants. Default value is
	/// `cull_counterclockwise`.
	Culling = cull_counterclockwise;

	/// @var {bool} If `true` then models using this material should write to the depth
	/// buffer. Default value is `true`.
	ZWrite = true;

	/// @var {bool} If `true` then models using this material should be tested against the
	/// depth buffer. Defaults value is `true`.
	ZTest = true;

	/// @var {real} The function used for depth testing when {@link BBMOD_Material.ZTest}
	/// is enabled. Use one of the `cmpfunc_` constants. Default value is `cmpfunc_lessequal`.
	ZFunc = cmpfunc_lessequal;

	/// @var {ptr} A texture with a base color in the RGB channels and opacity in the
	/// alpha channel.
	BaseOpacity = sprite_get_texture(BBMOD_SprDefaultMaterial, 0);

	/// @var {ptr} A texture with tangent-space normals in the RGB channels
	/// and roughness in the alpha channel.
	NormalRoughness = sprite_get_texture(BBMOD_SprDefaultMaterial, 1);

	/// @var {ptr} A texture with metallic in the red channel and ambient occlusion
	/// in the green channel.
	MetallicAO = sprite_get_texture(BBMOD_SprDefaultMaterial, 2);

	/// @var {ptr} A texture with subsurface color in the RGB channels and subsurface
	/// effect intensity in the alpha channel.
	Subsurface = sprite_get_texture(BBMOD_SprDefaultMaterial, 3);

	/// @var {ptr} RGBM encoded emissive texture.
	Emissive = sprite_get_texture(BBMOD_SprDefaultMaterial, 4);

	/// @func clone()
	/// @desc Creates a copy of the material.
	/// @return {BBMOD_Material} The created copy.
	static clone = function () {
		var _clone = new BBMOD_Material(Shader);
		_clone.RenderPath = RenderPath;
		_clone.OnApply = OnApply;
		_clone.BlendMode = BlendMode;
		_clone.Culling = Culling;
		_clone.ZWrite = ZWrite;
		_clone.ZTest = ZTest;
		_clone.ZFunc = ZFunc;
		_clone.BaseOpacity = BaseOpacity;
		_clone.NormalRoughness = NormalRoughness;
		_clone.MetallicAO = MetallicAO;
		_clone.Subsurface = Subsurface;
		_clone.Emissive = Emissive;
		return _clone;
	};

	/// @func apply()
	/// @desc Makes this material the current one.
	/// @return {bool} Returns `true` if the material has changed or `false`
	/// if this material already was the current one.
	static apply = function () {
		if (global.__bbmod_material_current == self)
		{
			return false;
		}

		reset();
		gpu_push_state();
		global.__bbmod_material_current = self;

		// Shader
		var _shader = Shader;
		if (shader_current() != _shader)
		{
			shader_set(_shader);

			var _on_apply = OnApply;
			if (!is_undefined(_on_apply))
			{
				_on_apply(self);
			}
		}

		// Gpu state
		gpu_set_blendmode(BlendMode);
		gpu_set_cullmode(Culling);
		gpu_set_zwriteenable(ZWrite);
		gpu_set_ztestenable(ZTest);

		if (ZTest)
		{
			gpu_set_zfunc(ZFunc);
		}

		global.__bbmod_material_current = self;

		return true;
	};

	/// @func reset()
	/// @desc Resets the current material to {@link BBMOD_NONE}.
	/// @see bbmod_material_reset
	static reset = function () {
		gml_pragma("forceinline");
		bbmod_material_reset();
	};
}