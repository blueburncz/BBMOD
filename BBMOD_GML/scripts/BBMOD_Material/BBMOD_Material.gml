/// @var {BBMOD_Material/BBMOD_NONE} The currently applied material.
/// @private
global.__bbmodMaterialCurrent = BBMOD_NONE;

/// @var {real} The current render pass. Its initial value is
/// {@link BBMOD_ERenderPass.Forward}.
/// @example
/// ```gml
/// if (global.bbmod_render_pass & (1 << BBMOD_ERenderPass.Forward))
/// {
///     // Draw objects to a G-Buffer...
/// }
/// ```
/// @see BBMOD_ERenderPass
global.bbmod_render_pass = BBMOD_ERenderPass.Forward;

// Array of all existing materials.
global.__bbmodMaterialsAll = [];

// Array of arrays of materials. Each index corresponds to a render pass.
var _materials = array_create(BBMOD_ERenderPass.SIZE);
for (var i = 0; i < BBMOD_ERenderPass.SIZE; ++i)
{
	_materials[i] = [];
}
global.__bbmodMaterials = _materials;

/// @func BBMOD_Material([_shader])
/// @extends BBMOD_Class
/// @desc A material that can be used when rendering models.
/// @param {BBMOD_Shader/undefined} [_shader] A shader that the material uses in
/// the {@link BBMOD_ERenderPass.Forward} pass. Leave `undefined` if you would
/// like to use {@link BBMOD_Material.set_shader} to specify shaders used in
/// specific render passes.
/// @see BBMOD_Shader
function BBMOD_Material(_shader=undefined)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Super_Class = {
		destroy: destroy,
	};

	/// @var {uint} Render passes in which is the material rendered. Defaults
	/// to 0 (no passes).
	/// @readonly
	/// @see BBMOD_ERenderPass
	RenderPass = 0;

	/// @var {BBMOD_Shader[]} Shaders used in specific render passes.
	/// @private
	/// @see BBMOD_Material.set_shader
	/// @see BBMOD_Material.get_shader
	Shaders = array_create(BBMOD_ERenderPass.SIZE, undefined);

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
	BaseOpacity = pointer_null;

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
		_dest.Shaders = array_create(BBMOD_ERenderPass.SIZE, undefined);
		array_copy(_dest.Shaders, 0, Shaders, 0, BBMOD_ERenderPass.SIZE);
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
		var _clone = new BBMOD_Material();
		copy(_clone);
		return _clone;
	};

	/// @func apply()
	/// @desc Makes this material the current one.
	/// @return {bool} Returns `true` if the material was applied.
	/// @see BBMOD_Material.reset
	static apply = function () {
		if ((RenderPass & (1 << global.bbmod_render_pass)) == 0)
		{
			return false;
		}

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
		}

		var _shader = Shaders[global.bbmod_render_pass];
		if (BBMOD_SHADER_CURRENT != _shader)
		{
			if (BBMOD_SHADER_CURRENT != BBMOD_NONE)
			{
				BBMOD_SHADER_CURRENT.reset();
			}
			_shader.set();
		}

		if (global.__bbmodMaterialCurrent != self)
		{
			_shader.set_material(self);
			global.__bbmodMaterialCurrent = self;
		}

		if (OnApply != undefined)
		{
			OnApply(self);
		}

		return true;
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
		__bbmod_sort_materials();
		return self;
	};

	/// @func set_shader(_pass, _shader)
	/// @desc Defines a shader used in a specific render pass.
	/// @param {BBMOD_ERenderPass} _pass The render pass.
	/// @param {BBMOD_Shader} _shader The shader used in the render pass.
	/// @return {BBMOD_Material} Returns `self`.
	/// @see BBMOD_Material.get_shader
	/// @see BBMOD_ERenderPass
	static set_shader = function (_pass, _shader) {
		gml_pragma("forceinline");
		RenderPass |= (1 << _pass);
		Shaders[_pass] = _shader;
		__bbmod_reindex_materials();
		return self;
	};

	/// @func has_shader(_pass)
	/// @desc Checks whether the material has a shader for the render pass.
	/// @param {BBMOD_ERenderPass} _pass The render pass.
	/// @return {bool} Returns `true` if the material has a shader for the
	/// render pass.
	/// @see BBMOD_ERenderPass
	static has_shader = function (_pass) {
		gml_pragma("forceinline");
		return ((RenderPass & (1 << _pass)) != 0);
	};

	/// @func get_shader(_pass)
	/// @desc Retrieves a shader used in a specific render pass.
	/// @param {BBMOD_ERenderPass} _pass The render pass.
	/// @return {BBMOD_Shader/undefined} The shader.
	/// @see BBMOD_Material.set_shader
	/// @see BBMOD_ERenderPass
	static get_shader = function (_pass) {
		gml_pragma("forceinline");
		return Shaders[_pass];
	};

	/// @func remove_shader(_pass)
	/// @desc Removes a shader used in a specific render pass.
	/// @param {uint} _pass The render pass.
	/// @return {BBMOD_Material} Returns `self`.
	static remove_shader = function (_pass) {
		gml_pragma("forceinline");
		RenderPass &= ~(1 << _pass);
		Shaders[_pass] = undefined;
		__bbmod_reindex_materials();
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
	/// @desc Submits all render commands without clearing the render queue.
	/// @return {BBMOD_Material} Returns `self`.
	/// @see BBMOD_Material.clear_queue
	/// @see BBMOD_Material.RenderCommands
	/// @see BBMOD_RenderCommand
	static submit_queue = function () {
		var _matWorld = matrix_get(matrix_world);
		var i = 0;

		var _shaderCurrent = BBMOD_SHADER_CURRENT;
		var _setBones = method(_shaderCurrent, _shaderCurrent.set_bones);
		var _setData = method(_shaderCurrent, _shaderCurrent.set_batch_data);
		var _renderCommands = RenderCommands;

		repeat (ds_list_size(_renderCommands))
		{
			var _command = _renderCommands[| i++];

			var _matrix = _command.Matrix;
			if (_matrix != undefined
				&& !array_equals(_matWorld, _matrix))
			{
				matrix_set(matrix_world, _matrix);
				_matWorld = _matrix;
			}

			var _transform = _command.BoneTransform;
			if (_transform != undefined)
			{
				_setBones(_transform);
			}

			var _data = _command.BatchData;
			if (_data != undefined)
			{
				_setData(_data);
			}

			var _vbuffer = _command.VertexBuffer;
			if (_vbuffer != undefined)
			{
				vertex_submit(_vbuffer, pr_trianglelist, _command.Texture);
			}
		}

		return self;
	};

	/// @func clear_queue()
	/// @desc Clears the queue of render commands.
	/// @return {BBMOD_Material} Returns `self`.
	static clear_queue = function () {
		gml_pragma("forceinline");
		ds_list_clear(RenderCommands);
		return self;
	};

	static destroy = function () {
		method(self, Super_Class.destroy)();

		ds_list_destroy(RenderCommands);

		if (BaseOpacitySprite != undefined)
		{
			sprite_delete(BaseOpacitySprite);
		}

		__bbmod_remove_material(self);
	};

	if (_shader != undefined)
	{
		set_shader(BBMOD_ERenderPass.Forward, _shader);
	}

	__bbmod_add_material(self);
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
		gpu_pop_state();
		global.__bbmodMaterialCurrent = BBMOD_NONE;
	}
	if (BBMOD_SHADER_CURRENT != BBMOD_NONE)
	{
		BBMOD_SHADER_CURRENT.reset();
	}
}

/// @func bbmod_get_materials([_pass])
/// @desc Retrieves an array of all existing materials, sorted by their priority.
/// Materials with smaller priority come first in the array.
/// @param {BBMOD_ERenderPass/undefined} [_pass] If defined, then only materials
/// used in specified render pass will be returned.
/// @return {BBMOD_Material[]} A read-only array of materials.
/// @see BBMOD_Material.Priority
/// @see BBMOD_ERenderPass
function bbmod_get_materials(_pass=undefined)
{
	gml_pragma("forceinline");
	if (_pass == undefined)
	{
		return global.__bbmodMaterialsAll;
	}
	return global.__bbmodMaterials[_pass];
}

function __bbmod_add_material(_material)
{
	gml_pragma("forceinline");
	array_push(global.__bbmodMaterialsAll, _material);
	__bbmod_reindex_materials();
}

function __bbmod_remove_material(_material)
{
	gml_pragma("forceinline");
	for (var i = 0; i < array_length(global.__bbmodMaterialsAll); ++i)
	{
		if (global.__bbmodMaterialsAll[i] == _material)
		{
			array_delete(global.__bbmodMaterialsAll, i, 1);
			break;
		}
	}
	__bbmod_reindex_materials();
}

function __bbmod_sort_materials()
{
	gml_pragma("forceinline");
	__bbmod_reindex_materials();
}

function __bbmod_reindex_materials()
{
	static _sortFn = function (_m1, _m2) {
		if (_m2.Priority > _m1.Priority) return -1;
		if (_m2.Priority < _m1.Priority) return +1;
		return 0;
	};

	array_sort(global.__bbmodMaterialsAll, _sortFn);

	var _materials = array_create(BBMOD_ERenderPass.SIZE);
	var _materialCount = array_length(global.__bbmodMaterialsAll);

	for (var _pass = 0; _pass < BBMOD_ERenderPass.SIZE; ++_pass)
	{
		_materials[_pass] = [];
		for (var i = 0; i < _materialCount; ++i)
		{
			var _mat = global.__bbmodMaterialsAll[i];
			if (_mat.has_shader(_pass))
			{
				array_push(_materials[_pass], _mat);
			}
		}
	}

	global.__bbmodMaterials = _materials;
}