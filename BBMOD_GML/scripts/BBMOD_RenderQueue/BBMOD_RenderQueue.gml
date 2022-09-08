/// @var {Array<Struct.BBMOD_RenderQueue>} Array of all existing render queues,
/// sorted by their priority in an asceding order.
/// @see BBMOD_RenderQueue
/// @readonly
global.bbmod_render_queues = [];

/// @func BBMOD_RenderQueue([_name[, _priority]])
///
/// @extends BBMOD_Class
///
/// @desc A cointainer of render commands.
///
/// @param {String} [_name] The name of the render queue. Defaults to
/// "RenderQueue" + number of created render queues - 1 (e.g. "RenderQueue0",
/// "RenderQueue1" etc.) if `undefined`.
/// @param {Real} [_priority] The priority of the render queue. Defaults to 0.
///
/// @see bbmod_render_queue_get_default
/// @see BBMOD_ERenderCommand
function BBMOD_RenderQueue(_name=undefined, _priority=0)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Super_Class = {
		destroy: destroy,
	};

	static IdNext = 0;

	/// @var {String} The name of the render queue. This can be useful for
	/// debugging purposes.
	Name = _name ?? ("RenderQueue" + string(IdNext++));

	/// @var {Real} The priority of the render queue. Render queues with lower
	/// priority come first in the {@link global.bbmod_render_queues} array.
	/// @readonly
	Priority = _priority;

	/// @var {Id.DsList<Struct.BBMOD_RenderCommand>}
	/// @private
	/// @see BBMOD_RenderCommand
	RenderCommands = ds_list_create();

	/// @func set_priority(_p)
	///
	/// @desc Changes the priority of the render queue. Render queues with lower
	/// priority come first in the {@link global.bbmod_render_queues} array.
	///
	/// @param {Real} _p The new priority of the render queue.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_priority = function (_p) {
		gml_pragma("forceinline");
		Priority = _p;
		__bbmod_reindex_render_queues();
		return self;
	};

	/// @func apply_material(_material[, _enabledPasses])
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.ApplyMaterial} command into
	/// the queue.
	///
	/// @param {Struct.BBMOD_Material} _material The material to apply.
	/// @param {Real} [_enabledPasses] Mask of enabled rendering passes. The
	/// material will not be applied if the current rendering pass is not one
	/// of them.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static apply_material = function (_material, _enabledPasses=~0) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.ApplyMaterial,
			2,
			_material,
			_enabledPasses);
		return self;
	};

	/// @func begin_conditional_block()
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.BeginConditionalBlock} command
	/// into the queue.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static begin_conditional_block = function () {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.BeginConditionalBlock,
			0);
		return self;
	};

	/// @func check_render_pass(_passes)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.CheckRenderPass} command into
	/// the queue.
	///
	/// @param {Real} [_passes] Mask of allowed rendering passes.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static check_render_pass = function (_passes) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.CheckRenderPass,
			1,
			_passes);
		return self;
	};

	/// @func draw_mesh(_vertexBuffer, _matrix, _material[, _primitiveType])
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawMesh} command into the
	/// queue.
	///
	/// @param {Id.VertexBuffer} _vertexBuffer The vertex buffer to draw.
	/// @param {Array<Real>} _matrix The world matrix.
	/// @param {Struct.BBMOD_Material} _material The material to use.
	/// @param {Constant.PrimitiveType} [_primitiveType] The primitive type of
	/// the mesh. Defaults to `pr_trianglelist`.
	/// @param {Real} [_materialIndex]
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static draw_mesh = function (_vertexBuffer, _matrix, _material, _primitiveType=pr_trianglelist, _materialIndex=-1) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.DrawMesh,
			6,
			global.__bbmodInstanceID,
			_material,
			_matrix,
			_materialIndex,
			_primitiveType,
			_vertexBuffer);
		return self;
	};

	/// @func draw_mesh_animated(_vertexBuffer, _matrix, _material, _boneTransform[, _primitiveType])
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawMeshAnimated} command into
	/// the queue.
	///
	/// @param {Id.VertexBuffer} _vertexBuffer The vertex buffer to draw.
	/// @param {Array<Real>} _matrix The world matrix.
	/// @param {Struct.BBMOD_Material} _material The material to use.
	/// @param {Array<Real>} _boneTransform An array with bone transformation
	/// data.
	/// @param {Constant.PrimitiveType} [_primitiveType] The primitive type of
	/// the mesh. Defaults to `pr_trianglelist`.
	/// @param {Real} [_materialIndex]
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static draw_mesh_animated = function (_vertexBuffer, _matrix, _material, _boneTransform, _primitiveType=pr_trianglelist, _materialIndex=-1) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.DrawMeshAnimated,
			7,
			global.__bbmodInstanceID,
			_material,
			_matrix,
			_boneTransform,
			_materialIndex,
			_primitiveType,
			_vertexBuffer);
		return self;
	};

	/// @func draw_mesh_batched(_vertexBuffer, _matrix, _material, _batchData[, _primitiveType])
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawMeshBatched} command into
	/// the queue.
	///
	/// @param {Id.VertexBuffer} _vertexBuffer The vertex buffer to draw.
	/// @param {Array<Real>} _matrix The world matrix.
	/// @param {Struct.BBMOD_Material} _material The material to use.
	/// @param {Array<Real>} _batchData An array with batch data.
	/// @param {Constant.PrimitiveType} [_primitiveType] The primitive type of
	/// the mesh. Defaults to `pr_trianglelist`.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static draw_mesh_batched = function (_vertexBuffer, _matrix, _material, _batchData, _primitiveType=pr_trianglelist) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.DrawMeshBatched,
			6,
			global.__bbmodInstanceID,
			_material,
			_matrix,
			_batchData,
			_primitiveType,
			_vertexBuffer);
		return self;
	};

	/// @func end_conditional_block()
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.EndConditionalBlock} command
	/// into the queue.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static end_conditional_block = function () {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.EndConditionalBlock,
			0);
		return self;
	};

	/// @func pop_gpu_state()
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.PopGpuState} command into the
	/// queue.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static pop_gpu_state = function () {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.PopGpuState,
			0);
		return self;
	};

	/// @func push_gpu_state()
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.PushGpuState} command into the
	/// queue.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static push_gpu_state = function () {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.PushGpuState,
			0);
		return self;
	};

	/// @func reset_material()
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.ResetMaterial} command into the
	/// queue.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static reset_material = function () {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.ResetMaterial,
			0);
		return self;
	};

	/// @func reset_shader()
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.ResetShader} command into the
	/// queue.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static reset_shader = function () {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.ResetShader,
			0);
		return self;
	};

	/// @func set_gpu_alphatestenable(_enable)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuAlphaTestEnable} command
	/// into the queue.
	///
	/// @param {Bool} _enable Use `true` to enable alpha testing.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_alphatestenable = function (_enable) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuAlphaTestEnable,
			1,
			_enable);
		return self;
	};

	/// @func set_gpu_alphatestref(_value)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuAlphaTestRef} command
	/// into the queue.
	///
	/// @param {Real} _value The new alpha test threshold value.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_alphatestref = function (_value) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuAlphaTestRef,
			1,
			_value);
		return self;
	};

	/// @func set_gpu_blendenable(_enable)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuBlendEnable} command into
	/// the queue.
	///
	/// @param {Bool} _enable Use `true` to enable alpha blending.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_blendenable = function (_enable) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuBlendEnable,
			1,
			_enable);
		return self;
	};

	/// @func set_gpu_blendmode(_blendmode)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuBlendMode} command into
	/// the queue.
	///
	/// @param {Constant.BlendMode} _blendmode The new blend mode.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_blendmode = function (_blendmode) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuBlendMode,
			1,
			_blendmode);
		return self;
	};

	/// @func set_gpu_blendmode_ext(_src, _dest)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuBlendModeExt} command
	/// into the queue.
	///
	/// @param {Constant.BlendMode} _src Source blend mode.
	/// @param {Constant.BlendMode} _dest Destination blend mode.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_blendmode_ext = function (_src, _dest) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuBlendModeExt,
			2,
			_src,
			_dest);
		return self;
	};

	/// @func set_gpu_blendmode_ext_sepalpha(_src, _dest, _srcalpha, _destalpha)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuBlendModeExtSepAlpha}
	/// command into the queue.
	///
	/// @param {Constant.BlendMode} _src Source blend mode.
	/// @param {Constant.BlendMode} _dest Destination blend mode.
	/// @param {Constant.BlendMode} _srcalpha Blend mode for source alpha channel.
	/// @param {Constant.BlendMode} _destalpha Blend mode for destination alpha
	/// channel.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_blendmode_ext_sepalpha = function (_src, _dest, _srcalpha, _destalpha) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuBlendModeExtSepAlpha,
			4,
			_src,
			_dest,
			_srcalpha,
			_destalpha);
		return self;
	};

	/// @func set_gpu_colorwriteenable(_red, _green, _blue, _alpha)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuColorWriteEnable} command
	/// into the queue.
	///
	/// @param {Bool} _red Use `true` to enable writing to the red color
	/// channel.
	/// @param {Bool} _green Use `true` to enable writing to the green color
	/// channel.
	/// @param {Bool} _blue Use `true` to enable writing to the blue color
	/// channel.
	/// @param {Bool} _alpha Use `true` to enable writing to the alpha channel.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_colorwriteenable = function (_red, _green, _blue, _alpha) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuColorWriteEnable,
			4,
			_red,
			_green,
			_blue,
			_alpha);
		return self;
	};

	/// @func set_gpu_cullmode(_cullmode)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuCullMode} command into
	/// the queue.
	///
	/// @param {Constant.CullMode} _cullmode The new coll mode.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_cullmode = function (_cullmode) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuCullMode,
			1,
			_cullmode);
		return self;
	};

	/// @func set_gpu_fog(_enable, _color, _start, _end)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuFog} command into the
	/// queue.
	///
	/// @param {Bool} _enable Use `true` to enable fog.
	/// @param {Constant.Color} _color The color of the fog.
	/// @param {Real} _start The distance from the camera at which the fog
	/// starts.
	/// @param {Real} _end The distance from the camera at which the fog reaches
	/// maximum intensity.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_fog = function (_enable, _color, _start, _end) {
		gml_pragma("forceinline");
		if (_enable)
		{
			ds_list_add(
				RenderCommands,
				BBMOD_ERenderCommand.SetGpuFog,
				4,
				true,
				_color,
				_start,
				_end);
		}
		else
		{
			ds_list_add(
				RenderCommands,
				BBMOD_ERenderCommand.SetGpuFog,
				1,
				false);
		}
		return self;
	};

	/// @func set_gpu_tex_filter(_linear)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexFilter} command into
	/// the queue.
	///
	/// @param {Bool} _linear Use `true` to enable linear texture filtering.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_filter = function (_linear) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexFilter,
			1,
			_linear);
		return self;
	};

	/// @func set_gpu_tex_filter_ext(_name, _linear)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexFilterExt} command
	/// into the queue.
	///
	/// @param {String} _name The name of the sampler.
	/// @param {Bool} _linear Use `true` to enable linear texture filtering for
	/// the sampler.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_filter_ext = function (_name, _linear) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexFilterExt,
			2,
			_name,
			_linear);
		return self;
	};

	/// @func set_gpu_tex_max_aniso(_value)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMaxAniso} command into
	/// the queue.
	///
	/// @param {Real} _value The maximum level of anisotropy.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_max_aniso = function (_value) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexMaxAniso,
			1,
			_value);
		return self;
	};

	/// @func set_gpu_tex_max_aniso_ext(_name, _value)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMaxAnisoExt} command
	/// into the queue.
	///
	/// @param {String} _name The name of the sampler.
	/// @param {Real} _value The maximum level of anisotropy.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_max_aniso_ext = function (_name, _value) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexMaxAnisoExt,
			2,
			_name,
			_value);
		return self;
	};

	/// @func set_gpu_tex_max_mip(_value)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMaxMip} command into
	/// the queue.
	///
	/// @param {Real} _value The maximum mipmap level.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_max_mip = function (_value) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexMaxMip,
			1,
			_value);
		return self;
	};

	/// @func set_gpu_tex_max_mip_ext(_name, _value)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMaxMipExt} command
	/// into the queue.
	///
	/// @param {String} _name The name of the sampler.
	/// @param {Real} _value The maximum mipmap level.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_max_mip_ext = function (_name, _value) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexMaxMipExt,
			2,
			_name,
			_value);
		return self;
	};

	/// @func set_gpu_tex_min_mip(_value)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMinMip} command into
	/// the queue.
	///
	/// @param {Real} _value The minimum mipmap level.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_min_mip = function (_value) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexMinMip,
			1,
			_value);
		return self;
	};

	/// @func set_gpu_tex_min_mip_ext(_name, _value)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMinMipExt} command
	/// into the queue.
	///
	/// @param {String} _name The name of the sampler.
	/// @param {Real} _value The minimum mipmap level.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_min_mip_ext = function (_name, _value) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexMinMipExt,
			2,
			_name,
			_value);
		return self;
	};

	/// @func set_gpu_tex_mip_bias(_value)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMipBias} command into
	/// the queue.
	///
	/// @param {Real} _value The mipmap bias.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_mip_bias = function (_value) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexMipBias,
			1,
			_value);
		return self;
	};

	/// @func set_gpu_tex_mip_bias_ext(_name, _value)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMipBiasExt} command
	/// into the queue.
	///
	/// @param {String} _name The name of the sampler.
	/// @param {Real} _value The mipmap bias.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_mip_bias_ext = function (_name, _value) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexMipBiasExt,
			2,
			_name,
			_value);
		return self;
	};

	/// @func set_gpu_tex_mip_enable(_enable)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMipEnable} command
	/// into the queue.
	///
	/// @param {Bool} _enable Use `true` to enable mipmapping.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_mip_enable = function (_enable) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexMipEnable,
			1,
			_enable);
		return self;
	};

	/// @func set_gpu_tex_mip_enable_ext(_name, _enable)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMipEnableExt} command
	/// into the queue.
	///
	/// @param {String} _name The name of the sampler.
	/// @param {Bool} _enable Use `true` to enable mipmapping.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_mip_enable_ext = function (_name, _enable) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexMipEnableExt,
			2,
			_name,
			_enable);
		return self;
	};

	/// @func set_gpu_tex_mip_filter(_filter)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMipFilter} command
	/// into the queue.
	///
	/// @param {Constant.MipFilter} _filter The mipmap filter.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_mip_filter = function (_filter) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexMipFilter,
			1,
			_filter);
		return self;
	};

	/// @func set_gpu_tex_mip_filter_ext(_name, _filter)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMipFilterExt} command
	/// into the queue.
	///
	/// @param {String} _name The name of the sampler.
	/// @param {Constant.MipFilter} _filter The mipmap filter.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_mip_filter_ext = function (_name, _filter) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexMipFilterExt,
			2,
			_name,
			_filter);
		return self;
	};

	/// @func set_gpu_tex_repeat(_enable)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexRepeat} command into
	/// the queue.
	///
	/// @param {Bool} _enable Use `true` to enable texture repeat.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_repeat = function (_enable) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexRepeat,
			1,
			_enable);
		return self;
	};

	/// @func set_gpu_tex_repeat_ext(_name, _enable)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexRepeatExt} command
	/// into the queue.
	///
	/// @param {String} _name The name of the sampler.
	/// @param {Bool} _enable Use `true` to enable texture repeat.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_repeat_ext = function (_name, _enable) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexRepeatExt,
			2,
			_name,
			_enable);
		return self;
	};

	/// @func set_gpu_zfunc(_func)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuZFunc} command into the
	/// queue.
	///
	/// @param {Constant.CmpFunc} _func The depth test function.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_zfunc = function (_func) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuZFunc,
			1,
			_func);
		return self;
	};

	/// @func set_gpu_ztestenable(_enable)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuZTestEnable} command into
	/// the queue.
	///
	/// @param {Bool} _enable Use `true` to enable testing against the detph
	/// buffer.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_ztestenable = function (_enable) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuZTestEnable,
			1,
			_enable);
		return self;
	};

	/// @func set_gpu_zwriteenable(_enable)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuZWriteEnable} command
	/// into the queue.
	///
	/// @param {Bool} _enable Use `true` to enable writing to the depth buffer.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_zwriteenable = function (_enable) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuZWriteEnable,
			1,
			_enable);
		return self;
	};

	/// @func set_projection_matrix(_matrix)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetProjectionMatrix} command
	/// into the queue.
	///
	/// @param {Array<Real>} _matrix The new projection matrix.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_projection_matrix = function (_matrix) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetProjectionMatrix,
			1,
			_matrix);
		return self;
	};

	/// @func set_sampler(_name _texture)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetSampler} command into the
	/// queue.
	///
	/// @param {String} _name The name of the sampler.
	/// @param {Pointer.Texture} _texture The new texture.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_sampler = function (_name, _texture) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetSampler,
			2,
			_name,
			_texture);
		return self;
	};

	/// @func set_shader(_shader)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetShader} command into the
	/// queue.
	///
	/// @param {Asset.GMShader} _shader The shader to set.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_shader = function (_shader) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetShader,
			1,
			_shader);
		return self;
	};

	/// @func set_uniform_f(_name, _value)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformFloat} command into
	/// the queue.
	///
	/// @param {String} _name The name of the uniform.
	/// @param {Real} _value The new uniform value.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_uniform_f = function (_name, _value) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetUniformFloat,
			2,
			_name,
			_value);
		return self;
	};

	/// @func set_uniform_f2(_name, _v1, _v2)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformFloat2} command into
	/// the queue.
	///
	/// @param {String} _name The name of the uniform.
	/// @param {Real} _v1 The value of the first component.
	/// @param {Real} _v2 The value of the second component.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_uniform_f2 = function (_name, _v1, _v2) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetUniformFloat2,
			3,
			_name,
			_v1,
			_v2);
		return self;
	};

	/// @func set_uniform_f3(_name, _v1, _v2, _v3)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformFloat3} command into
	/// the queue.
	///
	/// @param {String} _name The name of the uniform.
	/// @param {Real} _v1 The value of the first component.
	/// @param {Real} _v2 The value of the second component.
	/// @param {Real} _v3 The value of the third component.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_uniform_f3 = function (_name, _v1, _v2, _v3) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetUniformFloat3,
			4,
			_name,
			_v1,
			_v2,
			_v3);
		return self;
	};

	/// @func set_uniform_f4(_name, _v1, _v2, _v3, _v4)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformFloat4} command into
	/// the queue.
	///
	/// @param {String} _name The name of the uniform.
	/// @param {Real} _v1 The value of the first component.
	/// @param {Real} _v2 The value of the second component.
	/// @param {Real} _v3 The value of the third component.
	/// @param {Real} _v4 The value of the fourth component.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_uniform_f4 = function (_name, _v1, _v2, _v3, _v4) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetUniformFloat4,
			5,
			_name,
			_v1,
			_v2,
			_v3,
			_v4);
		return self;
	};

	/// @func set_uniform_f_array(_name, _array)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformFloatArray} command
	/// into the queue.
	///
	/// @param {String} _name The name of the uniform.
	/// @param {Array<Real>} _array The array of values.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_uniform_f_array = function (_name, _array) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetUniformFloatArray,
			2,
			_name,
			_array);
		return self;
	};

	/// @func set_uniform_i(_name, _value)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformInt} command into the
	/// queue.
	///
	/// @param {String} _name The name of the uniform.
	/// @param {Real} _value The new uniform value.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_uniform_i = function (_name, _value) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetUniformInt,
			2,
			_name,
			_value);
		return self;
	};

	/// @func set_uniform_i2(_name, _v1, _v2)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformInt2} command into
	/// the queue.
	///
	/// @param {String} _name The name of the uniform.
	/// @param {Real} _v1 The value of the first component.
	/// @param {Real} _v2 The value of the second component.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_uniform_i2 = function (_name, _v1, _v2) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetUniformInt2,
			3,
			_name,
			_v1,
			_v2);
		return self;
	};

	/// @func set_uniform_i3(_name, _v1, _v2, _v3)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformInt3} command into
	/// the queue.
	///
	/// @param {String} _name The name of the uniform.
	/// @param {Real} _v1 The value of the first component.
	/// @param {Real} _v2 The value of the second component.
	/// @param {Real} _v3 The value of the third component.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_uniform_i3 = function (_name, _v1, _v2, _v3) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetUniformInt3,
			4,
			_name,
			_v1,
			_v2,
			_v3);
		return self;
	};

	/// @func set_uniform_i4(_name, _v1, _v2, _v3, _v4)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformInt4} command into
	/// the queue.
	///
	/// @param {String} _name The name of the uniform.
	/// @param {Real} _v1 The value of the first component.
	/// @param {Real} _v2 The value of the second component.
	/// @param {Real} _v3 The value of the third component.
	/// @param {Real} _v4 The value of the fourth component.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_uniform_i4 = function (_name, _v1, _v2, _v3, _v4) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetUniformInt4,
			5,
			_name,
			_v1,
			_v2,
			_v3,
			_v4);
		return self;
	};

	/// @func set_uniform_i_array(_name, _array)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformIntArray} command
	/// into the queue.
	///
	/// @param {String} _name The name of the uniform.
	/// @param {Array<Real>} _array The array of values.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_uniform_i_array = function (_name, _array) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetUniformIntArray,
			2,
			_name,
			_array);
		return self;
	};

	/// @func set_uniform_matrix(_name)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformMatrix} command into
	/// the queue.
	///
	/// @param {String} _name The name of the uniform.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_uniform_matrix = function (_name) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetUniformMatrix,
			1,
			_name);
		return self;
	};

	/// @func set_uniform_matrix_array(_name, _array)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformMatrixArray} command
	/// into the queue.
	///
	/// @param {String} _name The name of the uniform.
	/// @param {Array<Real>} _array The array of values.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_uniform_matrix_array = function (_name, _array) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetUniformMatrixArray,
			2,
			_name,
			_array);
		return self;
	};

	/// @func set_view_matrix(_matrix)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetViewMatrix} command into the
	/// queue.
	///
	/// @param {Array<Real>} _matrix The new view matrix.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_view_matrix = function (_matrix) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetViewMatrix,
			1,
			_matrix);
		return self;
	};

	/// @func set_world_matrix(_matrix)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetWorldMatrix} command into
	/// the queue.
	///
	/// @param {Array<Real>} _matrix The new world matrix.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_world_matrix = function (_matrix) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetWorldMatrix,
			1,
			_matrix);
		return self;
	};

	/// @func submit_vertex_buffer(_vertexBuffer, _prim, _texture)
	///
	/// @desc Adds a {@link BBMOD_ERenderCommand.SubmitVertexBuffer} command
	/// into the queue.
	///
	/// @param {Id.VertexBuffer} _vertexBuffer The vertex buffer to submit.
	/// @param {Constant.PrimitiveType} _prim Primitive type of the vertex
	/// buffer.
	/// @param {Pointer.Texture} _texture The texture to use.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static submit_vertex_buffer = function (_vertexBuffer, _prim, _texture) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SubmitVertexBuffer,
			3,
			_vertexBuffer,
			_prim,
			_texture);
		return self;
	};

	/// @func is_empty()
	///
	/// @desc Checks whether the render queue is empty.
	///
	/// @return {Bool} Returns `true` if there are no commands in the render
	/// queue.
	static is_empty = function () {
		gml_pragma("forceinline");
		return ds_list_empty(RenderCommands);
	};

	/// @func submit([_instances])
	///
	/// @desc Submits render commands.
	///
	/// @param {Id.DsList<Id.Instance>} [_instances] If specified then only
	/// meshes with an instance ID from the list are submitted. Defaults to
	/// `undefined`.
	///
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	///
	/// @see BBMOD_RenderQueue.clear
	static submit = function (_instances=undefined) {
		var i = 0;
		var _renderCommands = RenderCommands;
		var _renderCommandsCount = ds_list_size(_renderCommands);
		var _condition = false;

		while (i < _renderCommandsCount)
		{
			var _command = _renderCommands[| i++];
			var _size = _renderCommands[| i++];

			switch (_command)
			{
			case BBMOD_ERenderCommand.ApplyMaterial:
				var _material = _renderCommands[| i++];
				var _enabledPasses = _renderCommands[| i++];
				if (((1 << bbmod_render_pass_get()) & _enabledPasses) == 0
					|| !_material.apply())
				{
					_condition = false;
					continue;
				}
				break;

			case BBMOD_ERenderCommand.BeginConditionalBlock:
				if (!_condition)
				{
					var _counter = 1;
					while (_counter > 0)
					{
						var _commandInner = _renderCommands[| i++];
						var _sizeInner = _renderCommands[| i++];
						switch (_commandInner)
						{
						case BBMOD_ERenderCommand.BeginConditionalBlock:
							++_counter;
							break;

						case BBMOD_ERenderCommand.EndConditionalBlock:
							--_counter;
							break;
						}
						i += _sizeInner;
					}
				}
				break;

			case BBMOD_ERenderCommand.CheckRenderPass:
				if (((1 << bbmod_render_pass_get()) & _renderCommands[| i++]) == 0)
				{
					_condition = false;
					continue;
				}
				break;

			case BBMOD_ERenderCommand.DrawMesh:
				var _id = _renderCommands[| i++];
				var _material = _renderCommands[| i++];
				if ((_instances != undefined && ds_list_find_index(_instances, _id) == -1)
					|| !_material.apply())
				{
					i += 4;
					_condition = false;
					continue;
				}
				with (BBMOD_SHADER_CURRENT)
				{
					set_instance_id(_id);
					matrix_set(matrix_world, _renderCommands[| i++]);
					set_material_index(_renderCommands[| i++]);
				}
				var _primitiveType = _renderCommands[| i++];
				vertex_submit(_renderCommands[| i++], _primitiveType, _material.BaseOpacity);
				break;

			case BBMOD_ERenderCommand.DrawMeshAnimated:
				var _id = _renderCommands[| i++];
				var _material = _renderCommands[| i++];
				if ((_instances != undefined && ds_list_find_index(_instances, _id) == -1)
					|| !_material.apply())
				{
					i += 5;
					_condition = false;
					continue;
				}
				with (BBMOD_SHADER_CURRENT)
				{
					set_instance_id(_id);
					matrix_set(matrix_world, _renderCommands[| i++]);
					set_bones(_renderCommands[| i++]);
					set_material_index(_renderCommands[| i++]);
				}
				var _primitiveType = _renderCommands[| i++];
				vertex_submit(_renderCommands[| i++], _primitiveType, _material.BaseOpacity);
				break;

			case BBMOD_ERenderCommand.DrawMeshBatched:
				var _id = _renderCommands[| i++];
				var _material = _renderCommands[| i++];
				if ((_instances != undefined && ds_list_find_index(_instances, _id) == -1)
					|| !_material.apply())
				{
					i += 4;
					_condition = false;
					continue;
				}
				BBMOD_SHADER_CURRENT.set_instance_id(_id);
				matrix_set(matrix_world, _renderCommands[| i++]);
				BBMOD_SHADER_CURRENT.set_batch_data(_renderCommands[| i++]);
				var _primitiveType = _renderCommands[| i++];
				vertex_submit(_renderCommands[| i++], _primitiveType, _material.BaseOpacity);
				break;

			case BBMOD_ERenderCommand.EndConditionalBlock:
				// TODO: show_error("Found unmatching end of conditional block in render queue " + Name + "!", true);
				break;

			case BBMOD_ERenderCommand.PopGpuState:
				gpu_pop_state();
				break;

			case BBMOD_ERenderCommand.PushGpuState:
				gpu_push_state();
				break;

			case BBMOD_ERenderCommand.ResetMaterial:
				bbmod_material_reset();
				break;

			case BBMOD_ERenderCommand.ResetShader:
				shader_reset();
				break;

			case BBMOD_ERenderCommand.SetGpuAlphaTestEnable:
				gpu_set_alphatestenable(_renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuAlphaTestRef:
				gpu_set_alphatestref(_renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuBlendEnable:
				gpu_set_blendenable(_renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuBlendMode:
				gpu_set_blendmode(_renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuBlendModeExt:
				var _src = _renderCommands[| i++];
				var _dest = _renderCommands[| i++];
				gpu_set_blendmode_ext(_src, _dest);
				break;

			case BBMOD_ERenderCommand.SetGpuBlendModeExtSepAlpha:
				var _src = _renderCommands[| i++];
				var _dest = _renderCommands[| i++];
				var _srcalpha = _renderCommands[| i++];
				var _destalpha = _renderCommands[| i++];
				gpu_set_blendmode_ext_sepalpha(_src, _dest, _srcalpha, _destalpha);
				break;

			case BBMOD_ERenderCommand.SetGpuColorWriteEnable:
				var _red = _renderCommands[| i++];
				var _green = _renderCommands[| i++];
				var _blue = _renderCommands[| i++];
				var _alpha = _renderCommands[| i++];
				gpu_set_colorwriteenable(_red, _green, _blue, _alpha);
				break;

			case BBMOD_ERenderCommand.SetGpuCullMode:
				gpu_set_cullmode(_renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuFog:
				if (_renderCommands[| i++])
				{
					var _color = _renderCommands[| i++];
					var _start = _renderCommands[| i++];
					var _end = _renderCommands[| i++];
					gpu_set_fog(true, _color, _start, _end);
				}
				else
				{
					gpu_set_fog(false, c_black, 0, 1);
				}
				break;

			case BBMOD_ERenderCommand.SetGpuTexFilter:
				gpu_set_tex_filter(_renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuTexFilterExt:
				var _index = shader_get_sampler_index(shader_current(), _renderCommands[| i++]);
				gpu_set_tex_filter_ext(_index, _renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuTexMaxAniso:
				gpu_set_tex_max_aniso(_renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuTexMaxAnisoExt:
				var _index = shader_get_sampler_index(shader_current(), _renderCommands[| i++]);
				gpu_set_tex_max_aniso_ext(_index, _renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuTexMaxMip:
				gpu_set_tex_max_mip(_renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuTexMaxMipExt:
				var _index = shader_get_sampler_index(shader_current(), _renderCommands[| i++]);
				gpu_set_tex_max_mip_ext(_index, _renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuTexMinMip:
				gpu_set_tex_min_mip(_renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuTexMinMipExt:
				var _index = shader_get_sampler_index(shader_current(), _renderCommands[| i++]);
				gpu_set_tex_min_mip_ext(_index, _renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuTexMipBias:
				gpu_set_tex_mip_bias(_renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuTexMipBiasExt:
				var _index = shader_get_sampler_index(shader_current(), _renderCommands[| i++]);
				gpu_set_tex_mip_bias_ext(_index, _renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuTexMipEnable:
				gpu_set_tex_mip_enable(_renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuTexMipEnableExt:
				var _index = shader_get_sampler_index(shader_current(), _renderCommands[| i++]);
				gpu_set_tex_mip_enable_ext(_index, _renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuTexMipFilter:
				gpu_set_tex_mip_filter(_renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuTexMipFilterExt:
				var _index = shader_get_sampler_index(shader_current(), _renderCommands[| i++]);
				gpu_set_tex_mip_filter_ext(_index, _renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuTexRepeat:
				gpu_set_tex_repeat(_renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuTexRepeatExt:
				var _index = shader_get_sampler_index(shader_current(), _renderCommands[| i++]);
				gpu_set_tex_repeat_ext(_index, _renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuZFunc:
				gpu_set_zfunc(_renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuZTestEnable:
				gpu_set_ztestenable(_renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetGpuZWriteEnable:
				gpu_set_zwriteenable(_renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetProjectionMatrix:
				matrix_set(matrix_projection, _renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetSampler:
				var _index = shader_get_sampler_index(shader_current(), _renderCommands[| i++]);
				texture_set_stage(_index, _renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetShader:
				shader_set(_renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetUniformFloat:
				var _uniform = shader_get_uniform(shader_current(), _renderCommands[| i++]);
				shader_set_uniform_f(_uniform, _renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetUniformFloat2:
				var _uniform = shader_get_uniform(shader_current(), _renderCommands[| i++]);
				var _v1 = _renderCommands[| i++];
				var _v2 = _renderCommands[| i++];
				shader_set_uniform_f(_uniform, _v1, _v2);
				break;

			case BBMOD_ERenderCommand.SetUniformFloat3:
				var _uniform = shader_get_uniform(shader_current(), _renderCommands[| i++]);
				var _v1 = _renderCommands[| i++];
				var _v2 = _renderCommands[| i++];
				var _v3 = _renderCommands[| i++];
				shader_set_uniform_f(_uniform, _v1, _v2, _v3);
				break;

			case BBMOD_ERenderCommand.SetUniformFloat4:
				var _uniform = shader_get_uniform(shader_current(), _renderCommands[| i++]);
				var _v1 = _renderCommands[| i++];
				var _v2 = _renderCommands[| i++];
				var _v3 = _renderCommands[| i++];
				var _v4 = _renderCommands[| i++];
				shader_set_uniform_f(_uniform, _v1, _v2, _v3, _v4);
				break;

			case BBMOD_ERenderCommand.SetUniformFloatArray:
				var _uniform = shader_get_uniform(shader_current(), _renderCommands[| i++]);
				shader_set_uniform_f_array(_uniform, _renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetUniformInt:
				var _uniform = shader_get_uniform(shader_current(), _renderCommands[| i++]);
				shader_set_uniform_i(_uniform, _renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetUniformInt2:
				var _uniform = shader_get_uniform(shader_current(), _renderCommands[| i++]);
				var _v1 = _renderCommands[| i++];
				var _v2 = _renderCommands[| i++];
				shader_set_uniform_i(_uniform, _v1, _v2);
				break;

			case BBMOD_ERenderCommand.SetUniformInt3:
				var _uniform = shader_get_uniform(shader_current(), _renderCommands[| i++]);
				var _v1 = _renderCommands[| i++];
				var _v2 = _renderCommands[| i++];
				var _v3 = _renderCommands[| i++];
				shader_set_uniform_i(_uniform, _v1, _v2, _v3);
				break;

			case BBMOD_ERenderCommand.SetUniformInt4:
				var _uniform = shader_get_uniform(shader_current(), _renderCommands[| i++]);
				var _v1 = _renderCommands[| i++];
				var _v2 = _renderCommands[| i++];
				var _v3 = _renderCommands[| i++];
				var _v4 = _renderCommands[| i++];
				shader_set_uniform_i(_uniform, _v1, _v2, _v3, _v4);
				break;

			case BBMOD_ERenderCommand.SetUniformIntArray:
				var _uniform = shader_get_uniform(shader_current(), _renderCommands[| i++]);
				shader_set_uniform_i_array(_uniform, _renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetUniformMatrix:
				shader_set_uniform_matrix(shader_get_uniform(shader_current(), _renderCommands[| i++]));
				break;

			case BBMOD_ERenderCommand.SetUniformMatrixArray:
				var _uniform = shader_get_uniform(shader_current(), _renderCommands[| i++]);
				shader_set_uniform_matrix_array(_uniform, _renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetViewMatrix:
				matrix_set(matrix_view, _renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SetWorldMatrix:
				matrix_set(matrix_world, _renderCommands[| i++]);
				break;

			case BBMOD_ERenderCommand.SubmitVertexBuffer:
				var _vertexBuffer = _renderCommands[| i++];
				var _prim = _renderCommands[| i++];
				var _texture = _renderCommands[| i++];
				vertex_submit(_vertexBuffer, _prim, _texture);
				break;
			}

			_condition = true;
		}

		return self;
	};

	/// @func clear()
	///
	/// @desc Clears the render queue.
	///
	/// @return {Struct.BBMOD_Material} Returns `self`.
	static clear = function () {
		gml_pragma("forceinline");
		ds_list_clear(RenderCommands);
		return self;
	};

	static destroy = function () {
		method(self, Super_Class.destroy)();
		__bbmod_remove_render_queue(self);
		return undefined;
	};

	__bbmod_add_render_queue(self);
}

function __bbmod_add_render_queue(_renderQueue)
{
	gml_pragma("forceinline");
	array_push(global.bbmod_render_queues, _renderQueue);
	__bbmod_reindex_render_queues();
}

function __bbmod_remove_render_queue(_renderQueue)
{
	gml_pragma("forceinline");
	for (var i = 0; i < array_length(global.bbmod_render_queues); ++i)
	{
		if (global.bbmod_render_queues[i] == _renderQueue)
		{
			array_delete(global.bbmod_render_queues, i, 1);
			break;
		}
	}
	__bbmod_reindex_render_queues();
}

function __bbmod_reindex_render_queues()
{
	gml_pragma("forceinline");
	static _sortFn = function (_a, _b) {
		if (_b.Priority > _a.Priority) return -1;
		if (_b.Priority < _a.Priority) return +1;
		return 0;
	};
	array_sort(global.bbmod_render_queues, _sortFn);
}

/// @func bbmod_render_queue_get_default()
///
/// @desc Retrieves the default render queue.
///
/// @return {Struct.BBMOD_RenderQueue} The default render queue.
///
/// @see BBMOD_RenderQueue
function bbmod_render_queue_get_default()
{
	static _renderQueue = new BBMOD_RenderQueue("Default");
	return _renderQueue;
}
