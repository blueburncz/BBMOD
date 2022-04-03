/// @var {Struct.BBMOD_Material/Undefined} The currently applied material.
/// @private
global.__bbmodMaterialCurrent = undefined;

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

	/// @var {Struct.BBMOD_RenderQueue} The render queue used by this material.
	/// Defaults to the default BBMOD render queue.
	/// @readonly
	/// @see BBMOD_RenderQueue
	/// @see bbmod_get_default_render_queue
	RenderQueue = bbmod_get_default_render_queue();

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

	/// @var {Bool}
	AlphaBlend = false;

	/// @var {Bool} Use `false` to disable mimapping for this material. Default
	/// value is `true`.
	Mipmapping = true;

	/// @var {Bool} Use `false` to disable linear texture filtering for this
	/// material. Default value is `true`.
	Filtering = true;

	/// @var {Bool} Use `true` to enable texture repeat for this material.
	/// Default value is `false`.
	Repeat = false;

	/// @func set_priority(_p)
	/// @desc Changes the material priority.
	/// @param {Real} _p The new material priority.
	/// @obsolete Priority has been moved from materials to render queues.
	/// Please use {@link BBMOD_RenderQueue.set_priority} instead.
	static set_priority = function (_p) {
		return self;
	};

	/// @func copy(_dest)
	/// @desc Copies properties of this material into another material.
	/// @param {Struct.BBMOD_Material} _dest The destination material.
	/// @return {Struct.BBMOD_Material} Returns `self`.
	static copy = function (_dest) {
		_dest.RenderPass = RenderPass;
		_dest.Shaders = array_create(BBMOD_ERenderPass.SIZE, undefined);
		array_copy(_dest.Shaders, 0, Shaders, 0, BBMOD_ERenderPass.SIZE);
		_dest.RenderQueue = RenderQueue;
		_dest.OnApply = OnApply;
		_dest.BlendMode = BlendMode;
		_dest.Culling = Culling;
		_dest.ZWrite = ZWrite;
		_dest.ZTest = ZTest;
		_dest.ZFunc = ZFunc;
		_dest.AlphaTest = AlphaTest;
		_dest.AlphaBlend = AlphaBlend;
		_dest.Mipmapping = Mipmapping;
		_dest.Filtering = Filtering;
		_dest.Repeat = Repeat;
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
			gpu_set_blendenable(AlphaBlend);
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
	};

	if (_shader != undefined)
	{
		set_shader(BBMOD_ERenderPass.Forward, _shader);
	}
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
