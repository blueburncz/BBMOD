/// @var {Struct.BBMOD_Material/Undefined} The currently applied material.
/// @private
global.__bbmodMaterialCurrent = undefined;

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
/// @extends BBMOD_Resource
/// @desc Base class for materials.
/// @param {Struct.BBMOD_Shader/Undefined} [_shader] A shader that the material uses in
/// the {@link BBMOD_ERenderPass.Forward} pass. Leave `undefined` if you would
/// like to use {@link BBMOD_Material.set_shader} to specify shaders used in
/// specific render passes.
/// @see BBMOD_Shader
function BBMOD_Material(_shader=undefined)
	: BBMOD_Resource() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Super_Resource = {
		destroy: destroy,
	};

	/// @var {Real} Render passes in which is the material rendered. Defaults
	/// to 0 (no passes).
	/// @readonly
	/// @see BBMOD_ERenderPass
	RenderPass = 0;

	/// @var {Array.Struct.BBMOD_Shader} Shaders used in specific render passes.
	/// @private
	/// @see BBMOD_Material.set_shader
	/// @see BBMOD_Material.get_shader
	Shaders = array_create(BBMOD_ERenderPass.SIZE, undefined);

	/// @var {Real} The priority of the material. Determines order of materials in
	/// the array retrieved by {@link bbmod_get_materials} (materials with smaller
	/// priority come first in the array). Defaults to `0`.
	/// @readonly
	/// @see BBMOD_Material.set_priority
	Priority = 0;

	/// @var {Struct.BBMOD_RenderQueue} A render queue for render commands using this material.
	/// @readonly
	/// @see BBMOD_RenderQueue
	/// @see BBMOD_RenderCommand
	RenderQueue = new BBMOD_RenderQueue();

	/// @var {Function/Undefined} A function that is executed when the shader is
	/// applied. Must take the material as the first argument. Use `undefined`
	/// if you do not want to execute any function. Defaults to `undefined`.
	OnApply = undefined;

	/// @var {Real} A blend mode. Use one of the `bm_` constants. Default value
	/// is `bm_normal`.
	BlendMode = bm_normal;

	/// @var {Real} A culling mode. Use one of the `cull_` constants. Default
	/// value is `cull_counterclockwise`.
	Culling = cull_counterclockwise;

	/// @var {Bool} If `true` then models using this material should write to
	/// the depth buffer. Default value is `true`.
	ZWrite = true;

	/// @var {Bool} If `true` then models using this material should be tested
	/// against the depth buffer. Defaults value is `true`.
	ZTest = true;

	/// @var {Real} The function used for depth testing when
	/// {@link BBMOD_Material.ZTest} is enabled. Use one of the `cmpfunc_`
	/// constants. Default value is `cmpfunc_lessequal`.
	ZFunc = cmpfunc_lessequal;

	/// @var {Real} Discard pixels with alpha less than this value. Use values
	/// in range 0..1.
	AlphaTest = 1.0;

	/// @var {Bool} Use `false` to disable mimapping for this material. Default
	/// value is `true`.
	Mipmapping = true;

	/// @var {Bool} Use `false` to disable linear texture filtering for this
	/// material. Default value is `true`.
	Filtering = true;

	/// @var {Bool} Use `true` to enable texture repeat for this material.
	/// Default value is `false`.
	Repeat = false;

	/// @func copy(_dest)
	/// @desc Copies properties of this material into another material.
	/// @param {Struct.BBMOD_Material} _dest The destination material.
	/// @return {Struct.BBMOD_Material} Returns `self`.
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
		_dest.set_priority(Priority);
		return self;
	};

	/// @func clone()
	/// @desc Creates a clone of the material.
	/// @return {Struct.BBMOD_Material} The created clone.
	static clone = function () {
		var _clone = new BBMOD_Material();
		copy(_clone);
		return _clone;
	};

	/// @func apply()
	/// @desc Makes this material the current one.
	/// @return {Bool} Returns `true` if the material was applied.
	/// @see BBMOD_Material.reset
	static apply = function () {
		if ((RenderPass & (1 << bbmod_render_pass_get())) == 0)
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

		var _shader = Shaders[bbmod_render_pass_get()];
		if (BBMOD_SHADER_CURRENT != _shader)
		{
			if (BBMOD_SHADER_CURRENT != undefined)
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

	/// @func set_priority(_p)
	/// @desc Changes the material priority. This affects its position within
	/// an array returned by {@link bbmod_get_materials}. Materials with lower
	/// priority come first in the array.
	/// @param {Real} _p The new material priority.
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
	/// @param {Struct.BBMOD_Shader} _shader The shader used in the render pass.
	/// @return {Struct.BBMOD_Material} Returns `self`.
	/// @see BBMOD_Material.get_shader
	/// @see bbmod_render_pass_set
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
	/// @return {Bool} Returns `true` if the material has a shader for the
	/// render pass.
	/// @see BBMOD_ERenderPass
	static has_shader = function (_pass) {
		gml_pragma("forceinline");
		return ((RenderPass & (1 << _pass)) != 0);
	};

	/// @func get_shader(_pass)
	/// @desc Retrieves a shader used in a specific render pass.
	/// @param {BBMOD_ERenderPass} _pass The render pass.
	/// @return {Struct.BBMOD_Shader/Undefined} The shader.
	/// @see BBMOD_Material.set_shader
	/// @see BBMOD_ERenderPass
	static get_shader = function (_pass) {
		gml_pragma("forceinline");
		return Shaders[_pass];
	};

	/// @func remove_shader(_pass)
	/// @desc Removes a shader used in a specific render pass.
	/// @param {Real} _pass The render pass.
	/// @return {Struct.BBMOD_Material} Returns `self`.
	static remove_shader = function (_pass) {
		gml_pragma("forceinline");
		RenderPass &= ~(1 << _pass);
		Shaders[_pass] = undefined;
		__bbmod_reindex_materials();
		return self;
	};

	/// @func reset()
	/// @desc Resets the current material to `undefined`.
	/// @return {Struct.BBMOD_Material} Returns `self`.
	/// @see BBMOD_Material.apply
	/// @see bbmod_material_reset
	static reset = function () {
		gml_pragma("forceinline");
		bbmod_material_reset();
		return self;
	};

	static destroy = function () {
		method(self, Super_Resource.destroy)();
		RenderQueue.destroy();
		__bbmod_remove_material(self);
	};

	if (_shader != undefined)
	{
		set_shader(BBMOD_ERenderPass.Forward, _shader);
	}

	__bbmod_add_material(self);
}

/// @func bbmod_material_reset()
/// @desc Resets the current material to `undefined`. Every block of code
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
	if (global.__bbmodMaterialCurrent != undefined)
	{
		gpu_pop_state();
		global.__bbmodMaterialCurrent = undefined;
	}
	if (BBMOD_SHADER_CURRENT != undefined)
	{
		BBMOD_SHADER_CURRENT.reset();
	}
}

/// @func bbmod_get_materials([_pass])
/// @desc Retrieves an array of all existing materials, sorted by their priority.
/// Materials with smaller priority come first in the array.
/// @param {BBMOD_ERenderPass/Undefined} [_pass] If defined, then only materials
/// used in specified render pass will be returned.
/// @return {Array.Struct.BBMOD_Material} A read-only array of materials.
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