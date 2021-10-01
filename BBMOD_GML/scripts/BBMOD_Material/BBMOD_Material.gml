/// @macro {real} A flag used to tell that a model is rendered in a shadow
/// render pass.
/// @see BBMOD_RENDER_DEFERRED
/// @see BBMOD_RENDER_FORWARD
/// @see global.bbmod_render_pass
/// @see BBMOD_Material.RenderPass
#macro BBMOD_RENDER_SHADOWS (1 << 0)

/// @macro {real} A flag used to tell that a model is rendered in a deferred
/// render pass.
/// @see BBMOD_RENDER_FORWARD
/// @see BBMOD_RENDER_SHADOWS
/// @see global.bbmod_render_pass
/// @see BBMOD_Material.RenderPass
#macro BBMOD_RENDER_DEFERRED (1 << 1)

/// @macro {real} A flag used to tell that a model is rendered in a forward
/// render pass.
/// @see BBMOD_RENDER_DEFERRED
/// @see BBMOD_RENDER_SHADOWS
/// @see global.bbmod_render_pass
/// @see BBMOD_Material.RenderPass
#macro BBMOD_RENDER_FORWARD (1 << 2)

/// @macro {BBMOD_VertexFormat} The default vertex format for static models.
/// @see BBMOD_VertexFormat
#macro BBMOD_VFORMAT_DEFAULT __bbmod_vformat_default()

/// @macro {BBMOD_VertexFormat} The default vertex format for animated models.
/// @see BBMOD_VertexFormat
#macro BBMOD_VFORMAT_DEFAULT_ANIMATED __bbmod_vformat_default_animated()

/// @macro {BBMOD_VertexFormat} The default vertex format for dynamically batched models.
/// @see BBMOD_VertexFormat
/// @see BBMOD_DynamicBatch
#macro BBMOD_VFORMAT_DEFAULT_BATCHED __bbmod_vformat_default_batched()

/// @macro {BBMOD_Shader} The default shader.
/// @see BBMOD_Shader
#macro BBMOD_SHADER_DEFAULT __bbmod_shader_default()

/// @macro {BBMOD_Shader} The default shader for animated models.
/// @see BBMOD_Shader
#macro BBMOD_SHADER_DEFAULT_ANIMATED __bbmod_shader_default_animated()

/// @macro {BBMOD_Shader} The default shader for dynamically batched models.
/// @see BBMOD_Shader
/// @see BBMOD_DynamicBatch
#macro BBMOD_SHADER_DEFAULT_BATCHED __bbmod_shader_default_batched()

/// @macro {BBMOD_Material} The default material.
/// @see BBMOD_Material
#macro BBMOD_MATERIAL_DEFAULT __bbmod_material_default()

/// @macro {BBMOD_Material} The default material for animated models.
/// @see BBMOD_Material
#macro BBMOD_MATERIAL_DEFAULT_ANIMATED __bbmod_material_default_animated()

/// @macro {BBMOD_Material} The default material for dynamically batched models.
/// @see BBMOD_Material
/// @see BBMOD_DynamicBatch
#macro BBMOD_MATERIAL_DEFAULT_BATCHED __bbmod_material_default_batched()

/// @var {BBMOD_Material/BBMOD_NONE} The currently applied material.
/// @private
global.__bbmodMaterialCurrent = BBMOD_NONE;

/// @var {real} The current render pass. Its initial value is
/// {@link BBMOD_RENDER_FORWARD}.
/// @example
/// ```gml
/// if (global.bbmod_render_pass & BBMOD_RENDER_DEFERRED)
/// {
///     // Draw objects to a G-Buffer...
/// }
/// ```
/// @see BBMOD_RENDER_FORWARD
/// @see BBMOD_RENDER_DEFERRED
/// @see BBMOD_RENDER_SHADOWS
global.bbmod_render_pass = BBMOD_RENDER_FORWARD;

/// @func bbmod_get_materials()
/// @desc Retrieves an array of all existing materials, sorted by their priority.
/// Materials with smaller priority come first in the array.
/// @return {BBMOD_Material[]} A read-only array of all existing materials.
/// @see BBMOD_Material.Priority
function bbmod_get_materials()
{
	static _materials = [];
	return _materials;
}

/// @func BBMOD_Material(_shader)
/// @extends BBMOD_Struct
/// @desc A material that can be used when rendering models.
/// @param {BBMOD_Shader} _shader A shader that the material uses.
/// @see BBMOD_Shader
function BBMOD_Material(_shader)
	: BBMOD_Struct() constructor
{
	static Super = {
		destroy: destroy,
	};

	/// @var {uint} Passes in which is the material rendered. Defaults to
	/// {@link BBMOD_RENDER_FORWARD}.
	/// @see BBMOD_RENDER_DEFERRED
	/// @see BBMOD_RENDER_FORWARD
	/// @see BBMOD_RENDER_SHADOWS
	RenderPass = BBMOD_RENDER_FORWARD;

	/// @var {BBMOD_Shader} A shader that the material uses.
	Shader = _shader;

	/// @var {real} The priority of the material. Determines order of materials in
	/// the array retrieved by {@link bbmod_get_materials} (materials with smaller
	/// priority come first in the array). Defaults to `0`.
	/// @readonly
	/// @see BBMOD_Material.set_priority
	Priority = 0;

	/// @var {ds_list<BBMOD_RenderCommand>} A list of render commands using this
	/// material.
	/// @readonly
	RenderCommands = ds_list_create();

	/// @var {func/undefined} A function that is executed when the shader is
	/// applied. Must take the material as the first argument. Use `undefined`
	/// if you do not want to execute any function. Defaults to `undefined`.
	OnApply = undefined;

	/// @var {real} A blend mode. Use one of the `bm_` constants. Default value
	/// is `bm_normal`.
	BlendMode = bm_normal;

	/// @var {real} A culling mode. Use one of the `cull_` constants. Default
	/// value is `cull_counterclockwise`.
	Culling = cull_counterclockwise;

	/// @var {bool} If `true` then models using this material should write to
	/// the depth buffer. Default value is `true`.
	ZWrite = true;

	/// @var {bool} If `true` then models using this material should be tested
	/// against the depth buffer. Defaults value is `true`.
	ZTest = true;

	/// @var {real} The function used for depth testing when
	/// {@link BBMOD_Material.ZTest} is enabled. Use one of the `cmpfunc_`
	/// constants. Default value is `cmpfunc_lessequal`.
	ZFunc = cmpfunc_lessequal;

	/// @var {real} Discard pixels with alpha less than this value. Use values
	/// in range 0..1.
	AlphaTest = 1.0;

	/// @var {bool} Use `false` to disable mimapping for this material. Default
	/// value is `true`.
	Mipmapping = true;

	/// @var {bool} Use `false` to disable linear texture filtering for this
	/// material. Default value is `true`.
	Filtering = true;

	/// @var {bool} Use `true` to enable texture repeat for this material.
	/// Default value is `false`.
	Repeat = false;

	/// @var {ptr} A texture with a base color in the RGB channels and opacity
	/// in the alpha channel.
	BaseOpacity = sprite_get_texture(BBMOD_SprCheckerboard, 0);

	BaseOpacitySprite = undefined;

	/// @var {BBMOD_Vec2} An offset of texture UV coordinates. Defaults to `[0, 0]`.
	/// Using this you can control texture's position within texture page.
	TextureOffset = new BBMOD_Vec2(0.0);

	/// @var {BBMOD_Vec2} A scale of texture UV coordinates. Defaults to `[1, 1]`.
	/// Using this you can control texture's size within texture page.
	TextureScale = new BBMOD_Vec2(1.0);

	/// @func copy(_dest)
	/// @desc Copies properties of this material into another material.
	/// @param {BBMOD_Material} _dest The destination material.
	/// @return {BBMOD_Material} Returns `self`.
	static copy = function (_dest) {
		_dest.RenderPass = RenderPass;
		_dest.OnApply = OnApply;
		_dest.BlendMode = BlendMode;
		_dest.Culling = Culling;
		_dest.ZWrite = ZWrite;
		_dest.ZTest = ZTest;
		_dest.ZFunc = ZFunc;
		_dest.AlphaTest = AlphaTest;
		_dest.Mipmapping = Mipmapping;
		_dest.Filtering = Filtering;
		_dest.Repeat = Repeat;

		if (_dest.BaseOpacitySprite != undefined)
		{
			sprite_delete(_dest.BaseOpacitySprite);
			_dest.BaseOpacitySprite = undefined;
		}

		if (BaseOpacitySprite != undefined)
		{
			_dest.BaseOpacitySprite = sprite_duplicate(BaseOpacitySprite);
			_dest.BaseOpacity = sprite_get_texture(_dest.BaseOpacitySprite, 0);
		}
		else
		{
			_dest.BaseOpacity = BaseOpacity;
		}

		_dest.TextureOffset = TextureOffset;
		_dest.TextureScale = TextureScale;

		_dest.set_priority(Priority);
		return self;
	};

	/// @func clone()
	/// @desc Creates a clone of the material.
	/// @return {BBMOD_Material} The created clone.
	static clone = function () {
		var _clone = new BBMOD_Material(Shader);
		copy(_clone);
		return _clone;
	};

	/// @func apply()
	/// @desc Makes this material the current one.
	/// @return {BBMOD_Material} Returns `self`.
	/// @see BBMOD_Material.reset
	static apply = function () {
		if (global.__bbmodMaterialCurrent != self)
		{
			reset();

			gpu_push_state();
			gpu_set_blendmode(BlendMode);
			gpu_set_cullmode(Culling);
			gpu_set_zwriteenable(ZWrite);
			gpu_set_ztestenable(ZTest);
			gpu_set_zfunc(ZFunc);
			gpu_set_tex_mip_enable(Mipmapping ? mip_on : mip_off);
			gpu_set_tex_filter(Filtering);
			gpu_set_tex_repeat(Repeat);

			Shader.set();
			Shader.set_material(self);

			global.__bbmodMaterialCurrent = self;
		}

		if (OnApply != undefined)
		{
			OnApply(self);
		}

		return self;
	};

	static _make_sprite = function (_r, _g, _b, _a) {
		gml_pragma("forceinline");
		static _sur = noone;
		if (!surface_exists(_sur))
		{
			_sur = surface_create(1, 1);
		}
		surface_set_target(_sur);
		draw_clear_alpha(make_color_rgb(_r, _g, _b), _a);
		surface_reset_target();
		return sprite_create_from_surface(_sur, 0, 0, 1, 1, false, false, 0, 0);
	};

	/// @func set_base_opacity(_baseColor, _opacity)
	/// @desc Changes the base color and opacity to a uniform value for the
	/// entire material.
	/// @param {uint} _baseColor The new base color.
	/// @param {real} _opacity The new opacity. Use values in range 0..1.
	/// @return {BBMOD_Material} Returns `self`.
	static set_base_opacity = function (_baseColor, _opacity) {
		if (BaseOpacitySprite != undefined)
		{
			sprite_delete(BaseOpacitySprite);
		}
		BaseOpacitySprite = _make_sprite(
			color_get_red(_baseColor),
			color_get_green(_baseColor),
			color_get_blue(_baseColor),
			_opacity,
		);
		BaseOpacity = sprite_get_texture(BaseOpacitySprite, 0);
		return self;
	};

	/// @func set_priority(_p)
	/// @desc Changes the material priority. This affects its position within
	/// an array returned by {@link bbmod_get_materials}. Materials with lower
	/// priority come first in the array.
	/// @param {real} _p The new material priority.
	/// @see BBMOD_Material.Priority
	static set_priority = function (_p) {
		gml_pragma("forceinline");
		Priority = _p;
		array_sort(bbmod_get_materials(), function (_m1, _m2) {
			if (_m2.Priority > _m1.Priority) return -1;
			if (_m2.Priority < _m1.Priority) return +1;
			return 0;
		});
		return self;
	};

	/// @func reset()
	/// @desc Resets the current material to {@link BBMOD_NONE}.
	/// @return {BBMOD_Material} Returns `self`.
	/// @see BBMOD_Material.apply
	/// @see bbmod_material_reset
	static reset = function () {
		gml_pragma("forceinline");
		bbmod_material_reset();
		return self;
	};

	/// @func has_commands()
	/// @desc Checks whether the material has any render commands waiting for
	/// submission.
	/// @return {bool} Returns true if the material's render queue is not empty.
	static has_commands = function () {
		gml_pragma("forceinline");
		return !ds_list_empty(RenderCommands);
	};

	/// @func submit_queue()
	/// @desc Submits all render commands.
	/// @return {BBMOD_Material} Returns `self`.
	/// @see BBMOD_Material.RenderCommands
	/// @see BBMOD_RenderCommand
	static submit_queue = function () {
		var _matWorld = matrix_get(matrix_world);
		var i = 0;
		repeat (ds_list_size(RenderCommands))
		{
			var _command = RenderCommands[| i++];

			var _matrix = _command.Matrix;
			if (!array_equals(_matWorld, _matrix))
			{
				matrix_set(matrix_world, _matrix);
				_matWorld = _matrix;
			}

			var _transform = _command.BoneTransform;
			if (_transform != undefined)
			{
				Shader.set_bones(_transform);
			}

			var _data = _command.BatchData;
			if (_data != undefined)
			{
				Shader.set_batch_data(_data);
			}

			vertex_submit(_command.VertexBuffer, pr_trianglelist, _command.Texture);
		}
		ds_list_clear(RenderCommands);
	};

	static destroy = function () {
		method(self, Super.destroy)();

		ds_list_destroy(RenderCommands);

		if (BaseOpacitySprite != undefined)
		{
			sprite_delete(BaseOpacitySprite);
		}

		// Remove from list of materials
		var _materials = bbmod_get_materials();
		var i = 0;
		repeat (array_length(_materials))
		{
			if (_materials[i] == self)
			{
				array_delete(_materials, i, 1);
				break;
			}
			++i;
		}
	};

	var _allMaterials = bbmod_get_materials();
	array_push(_allMaterials, self);
	array_sort(_allMaterials, function (_m1, _m2) {
		return (_m1.Priority - _m2.Priority);
	});
}

/// @func bbmod_material_reset()
/// @desc Resets the current material to {@link BBMOD_NONE}. Every block of code
/// rendering models must start and end with this function!
/// @example
/// ```gml
/// bbmod_material_reset();
///
/// // Render static batch of trees
/// treeBatch.submit(matTree);
///
/// // Render characters
/// var _world = matrix_get(matrix_world);
/// with (OCharacter)
/// {
///     matrix_set(matrix_world, matrix_build(x, y, z, 0, 0, direction, 1, 1, 1));
///     animationPlayer.submit();
/// }
/// matrix_set(matrix_world, _world);
///
/// bbmod_material_reset();
/// ```
/// @see BBMOD_Material.reset
function bbmod_material_reset()
{
	gml_pragma("forceinline");
	if (global.__bbmodMaterialCurrent != BBMOD_NONE)
	{
		BBMOD_SHADER_CURRENT.reset();
		gpu_pop_state();
		global.__bbmodMaterialCurrent = BBMOD_NONE;
	}
}