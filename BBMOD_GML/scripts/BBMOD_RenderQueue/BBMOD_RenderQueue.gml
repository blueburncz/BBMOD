/// @var {Array.Struct.BBMOD_RenderQueue} Array of all existing render queues.
/// @see BBMOD_RenderQueue
/// @readonly
global.bbmod_render_queues = [];

/// @func BBMOD_RenderQueue([_name])
/// @extends BBMOD_Class
/// @desc A cointainer of render commands.
/// @param {String/Undefined} [_name] The name of the render queue. Defaults to
/// "RenderQueue" + number of created render queues - 1, e.g. "RenderQueue0",
/// "RenderQueue1" etc.
/// @see BBMOD_ERenderCommand
function BBMOD_RenderQueue(_name=undefined)
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

	/// @var {Id.DsList.Struct.BBMOD_RenderCommand}
	/// @private
	/// @see BBMOD_RenderCommand
	RenderCommands = ds_list_create();

	/// @var {Real}
	/// @readonly
	Priority = 0;

	/// @func set_priority(_p)
	/// @desc Changes the priority of the render queue. Render queues with lower
	/// priority come first in the {@link global.bbmod_render_queues} array.
	/// @param {Real} _p The new priority of the render queue.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_priority = function (_p) {
		gml_pragma("forceinline");
		Priority = _p;
		__bbmod_reindex_render_queues();
		return self;
	};

	/// @func apply_material(_material)
	/// @desc Adds a {@link BBMOD_ERenderCommand.ApplyMaterial} command into the queue.
	/// @param {Struct.BBMOD_Material} _material
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static apply_material = function (_material) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.ApplyMaterial,
			_material);
		return self;
	};

	/// @func begin_conditional_block()
	/// @desc Adds a {@link BBMOD_ERenderCommand.BeginConditionalBlock} command into the queue.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static begin_conditional_block = function () {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.BeginConditionalBlock);
		return self;
	};

	/// @func draw_mesh(_vertexBuffer, _matrix, _material)
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawMesh} command into the queue.
	/// @param {Id.VertexBuffer} _vertexBuffer The vertex buffer to draw.
	/// @param {Array.Real} _matrix The world matrix.
	/// @param {Struct.BBMOD_Material} _material The material to use.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static draw_mesh = function (_vertexBuffer, _matrix, _material) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.DrawMesh,
			_material,
			_matrix,
			_vertexBuffer);
		return self;
	};

	/// @func draw_mesh_animated(_vertexBuffer, _matrix, _material, _boneTransform)
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawMeshAnimated} command into the queue.
	/// @param {Id.VertexBuffer} _vertexBuffer The vertex buffer to draw.
	/// @param {Array.Real} _matrix The world matrix.
	/// @param {Struct.BBMOD_Material} _material The material to use.
	/// @param {Array.Real} _boneTransform An array with bone transformation data.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static draw_mesh_animated = function (_vertexBuffer, _matrix, _material, _boneTransform) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.DrawMeshAnimated,
			_material,
			_matrix,
			_boneTransform,
			_vertexBuffer);
		return self;
	};

	/// @func draw_mesh_batched(_vertexBuffer, _matrix, _material, _batchData)
	/// @desc Adds a {@link BBMOD_ERenderCommand.DrawMeshBatched} command into the queue.
	/// @param {Id.VertexBuffer} _vertexBuffer The vertex buffer to draw.
	/// @param {Array.Real} _matrix The world matrix.
	/// @param {Struct.BBMOD_Material} _material The material to use.
	/// @param {Array.Real} _batchData An array with batch data.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static draw_mesh_batched = function (_vertexBuffer, _matrix, _material, _batchData) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.DrawMeshBatched,
			_material,
			_matrix,
			_batchData,
			_vertexBuffer);
		return self;
	};

	/// @func end_conditional_block()
	/// @desc Adds a {@link BBMOD_ERenderCommand.EndConditionalBlock} command into the queue.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static end_conditional_block = function () {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.EndConditionalBlock);
		return self;
	};

	/// @func pop_gpu_state()
	/// @desc Adds a {@link BBMOD_ERenderCommand.PopGpuState} command into the queue.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static pop_gpu_state = function () {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.PopGpuState);
		return self;
	};

	/// @func push_gpu_state()
	/// @desc Adds a {@link BBMOD_ERenderCommand.PushGpuState} command into the queue.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static push_gpu_state = function () {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.PushGpuState);
		return self;
	};

	/// @func reset_material()
	/// @desc Adds a {@link BBMOD_ERenderCommand.ResetMaterial} command into the queue.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static reset_material = function () {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.ResetMaterial);
		return self;
	};

	/// @func reset_shader()
	/// @desc Adds a {@link BBMOD_ERenderCommand.ResetShader} command into the queue.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static reset_shader = function () {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.ResetShader);
		return self;
	};

	/// @func set_gpu_alphatestenable(_enable)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuAlphaTestEnable} command into the queue.
	/// @param {Bool} _enable Use `true` to enable alpha testing.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_alphatestenable = function (_enable) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuAlphaTestEnable,
			_enable);
		return self;
	};

	/// @func set_gpu_alphatestref(_value)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuAlphaTestRef} command into the queue.
	/// @param {Real} _value The new alpha test threshold value.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_alphatestref = function (_value) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuAlphaTestRef,
			_value);
		return self;
	};

	/// @func set_gpu_blendenable(_enable)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuBlendEnable} command into the queue.
	/// @param {Bool} _enable Use `true` to enable alpha blending.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_blendenable = function (_enable) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuBlendEnable,
			_enable);
		return self;
	};

	/// @func set_gpu_blendmode(_blendmode)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuBlendMode} command into the queue.
	/// @param {Constant.BlendMode} _blendmode The new blend mode.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_blendmode = function () {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuBlendMode,
			_blendmode);
		return self;
	};

	/// @func set_gpu_blendmode_ext(_src, _dest)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuBlendModeExt} command into the queue.
	/// @param {Constant.BlendMode} _src Source blend mode.
	/// @param {Constant.BlendMode} _dest Destination blend mode.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_blendmode_ext = function (_src, _dest) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuBlendModeExt,
			_src,
			_dest);
		return self;
	};

	/// @func set_gpu_blendmode_ext_sepalpha(_src, _dest, _srcalpha, _destalpha)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuBlendModeExtSepAlpha} command into the queue.
	/// @param {Constant.BlendMode} _src Source blend mode.
	/// @param {Constant.BlendMode} _dest Destination blend mode.
	/// @param {Constant.BlendMode} _src Blend mode for source alpha channel.
	/// @param {Constant.BlendMode} _src Blend mode for destination alpha channel.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_blendmode_ext_sepalpha = function (_src, _dest, _srcalpha, _destalpha) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuBlendModeExtSepAlpha,
			_src,
			_dest,
			_srcalpha,
			_destalpha);
		return self;
	};

	/// @func set_gpu_colorwriteenable(_red, _green, _blue, _alpha)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuColorWriteEnable} command into the queue.
	/// @param {Bool} _red Use `true` to enable writing to the red color channel.
	/// @param {Bool} _green Use `true` to enable writing to the green color channel.
	/// @param {Bool} _blue Use `true` to enable writing to the blue color channel.
	/// @param {Bool} _alpha Use `true` to enable writing to the alpha channel.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_colorwriteenable = function (_red, _green, _blue, _alpha) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuColorWriteEnable,
			_red,
			_green,
			_blue,
			_alpha);
		return self;
	};

	/// @func set_gpu_cullmode(_cullmode)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuCullMode} command into the queue.
	/// @param {Constant.CullMode} _cullmode The new coll mode.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_cullmode = function (_cullmode) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuCullMode,
			_cullmode);
		return self;
	};

	/// @func set_gpu_fog(_enable, _color, _start, _end)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuFog} command into the queue.
	/// @param {Bool} _enable Use `true` to enable fog.
	/// @param {Constant.Color} _color The color of the fog.
	/// @param {Real} _start The distance from the camera at which the fog starts.
	/// @param {Real} _end The distance from the camera at which the fog reaches maximum intensity.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_fog = function (_enable, _color, _start, _end) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuFog,
			_enable,
			_color,
			_start,
			_end);
		return self;
	};

	/// @func set_gpu_tex_filter(_linear)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexFilter} command into the queue.
	/// @param {Bool} _linear Use `true` to enable linear texture filtering.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_filter = function (_linear) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexFilter,
			_linear);
		return self;
	};

	/// @func set_gpu_tex_filter_ext(_name, _linear)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexFilterExt} command into the queue.
	/// @param {String} _name The name of the sampler.
	/// @param {Bool} _linear Use `true` to enable linear texture filtering for the sampler.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_filter_ext = function (_name, _linear) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexFilterExt,
			_name,
			_linear);
		return self;
	};

	/// @func set_gpu_tex_max_aniso(_value)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMaxAniso} command into the queue.
	/// @param {Real} _value The maximum level of anisotropy.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_max_aniso = function (_value) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexMaxAniso,
			_value);
		return self;
	};

	/// @func set_gpu_tex_max_aniso_ext(_name, _value)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMaxAnisoExt} command into the queue.
	/// @param {String} _name The name of the sampler.
	/// @param {Real} _value The maximum level of anisotropy.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_max_aniso_ext = function (_name, _value) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexMaxAnisoExt,
			_name,
			_value);
		return self;
	};

	/// @func set_gpu_tex_max_mip(_value)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMaxMip} command into the queue.
	/// @param {Real} _value The maximum mipmap level.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_max_mip = function (_value) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexMaxMip,
			_value);
		return self;
	};

	/// @func set_gpu_tex_max_mip_ext(_name, _value)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMaxMipExt} command into the queue.
	/// @param {String} _name The name of the sampler.
	/// @param {Real} _value The maximum mipmap level.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_max_mip_ext = function (_name, _value) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexMaxMipExt,
			_name,
			_value);
		return self;
	};

	/// @func set_gpu_tex_min_mip(_value)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMinMip} command into the queue.
	/// @param {Real} _value The minimum mipmap level.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_min_mip = function (_value) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexMinMip,
			_value);
		return self;
	};

	/// @func set_gpu_tex_min_mip_ext(_name, _value)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMinMipExt} command into the queue.
	/// @param {String} _name The name of the sampler.
	/// @param {Real} _value The minimum mipmap level.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_min_mip_ext = function (_name, _value) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexMinMipExt,
			_name,
			_value);
		return self;
	};

	/// @func set_gpu_tex_mip_bias(_value)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMipBias} command into the queue.
	/// @param {Real} _value The mipmap bias.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_mip_bias = function (_value) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexMipBias,
			_value);
		return self;
	};

	/// @func set_gpu_tex_mip_bias_ext(_name, _value)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMipBiasExt} command into the queue.
	/// @param {String} _name The name of the sampler.
	/// @param {Real} _value The mipmap bias.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_mip_bias_ext = function (_name, _value) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexMipBiasExt,
			_name,
			_value);
		return self;
	};

	/// @func set_gpu_tex_mip_enable(_enable)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMipEnable} command into the queue.
	/// @param {Bool} _enable Use `true` to enable mipmapping.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_mip_enable = function (_enable) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexMipEnable,
			_enable);
		return self;
	};

	/// @func set_gpu_tex_mip_enable_ext(_name, _enable)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMipEnableExt} command into the queue.
	/// @param {String} _name The name of the sampler.
	/// @param {Bool} _enable Use `true` to enable mipmapping.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_mip_enable_ext = function (_name, _enable) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexMipEnableExt,
			_name,
			_enable);
		return self;
	};

	/// @func set_gpu_tex_mip_filter(_filter)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMipFilter} command into the queue.
	/// @param {Constant.MipFilter} _filter The mipmap filter.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_mip_filter = function (_filter) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexMipFilter,
			_filter);
		return self;
	};

	/// @func set_gpu_tex_mip_filter_ext(_name, _filter)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexMipFilterExt} command into the queue.
	/// @param {String} _name The name of the sampler.
	/// @param {Constant.MipFilter} _filter The mipmap filter.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_mip_filter_ext = function (_name, _filter) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexMipFilterExt,
			_name,
			_filter);
		return self;
	};

	/// @func set_gpu_tex_repeat(_enable)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexRepeat} command into the queue.
	/// @param {Bool} _enable Use `true` to enable texture repeat.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_repeat = function (_enable) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexRepeat,
			_enable);
		return self;
	};

	/// @func set_gpu_tex_repeat_ext(_name, _enable)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuTexRepeatExt} command into the queue.
	/// @param {String} _name The name of the sampler.
	/// @param {Bool} _enable Use `true` to enable texture repeat.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_tex_repeat_ext = function (_name, _enable) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuTexRepeatExt,
			_name,
			_enable);
		return self;
	};

	/// @func set_gpu_zfunc(_func)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuZFunc} command into the queue.
	/// @param {Constant.CmpFunc} _func The depth test function.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_zfunc = function (_func) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuZFunc,
			_func);
		return self;
	};

	/// @func set_gpu_ztestenable(_enable)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuZTestEnable} command into the queue.
	/// @param {Bool} _enable Use `true` to enable testing against the detph buffer.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_ztestenable = function (_enable) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuZTestEnable,
			_enable);
		return self;
	};

	/// @func set_gpu_zwriteenable(_enable)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetGpuZWriteEnable} command into the queue.
	/// @param {Bool} _enable Use `true` to enable writing to the depth buffer.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_gpu_zwriteenable = function (_enable) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetGpuZWriteEnable,
			_enable);
		return self;
	};

	/// @func set_projection_matrix(_matrix)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetProjectionMatrix} command into the queue.
	/// @param {Array.Real} _matrix The new projection matrix.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_projection_matrix = function (_matrix) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetProjectionMatrix,
			_matrix);
		return self;
	};

	/// @func set_sampler(_texture)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetSampler} command into the queue.
	/// @param {Pointer.Texture} _texture The new texture.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_sampler = function (_texture) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetSampler,
			_texture);
		return self;
	};

	/// @func set_shader(_shader)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetShader} command into the queue.
	/// @param {Resource.GMShader} _shader The shader to set.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_shader = function (_shader) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetShader,
			_shader);
		return self;
	};

	/// @func set_uniform_float(_value)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformFloat} command into the queue.
	/// @param {Real} _value The new uniform value.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_uniform_float = function (_value) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetUniformFloat,
			_value);
		return self;
	};

	/// @func set_uniform_float2(_v1, _v2)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformFloat2} command into the queue.
	/// @param {Real} _v1 The value of the first component.
	/// @param {Real} _v2 The value of the second component.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_uniform_float2 = function (_v1, _v2) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetUniformFloat2,
			_v1,
			_v2);
		return self;
	};

	/// @func set_uniform_float3(_v1, _v2, _v3)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformFloat3} command into the queue.
	/// @param {Real} _v1 The value of the first component.
	/// @param {Real} _v2 The value of the second component.
	/// @param {Real} _v3 The value of the third component.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_uniform_float3 = function (_v1, _v2, _v3) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetUniformFloat3,
			_v1,
			_v2,
			_v3);
		return self;
	};

	/// @func set_uniform_float4(_v1, _v2, _v3, _v4)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformFloat4} command into the queue.
	/// @param {Real} _v1 The value of the first component.
	/// @param {Real} _v2 The value of the second component.
	/// @param {Real} _v3 The value of the third component.
	/// @param {Real} _v4 The value of the fourth component.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_uniform_float4 = function (_v1, _v2, _v3, _v4) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetUniformFloat4,
			_v1,
			_v2,
			_v3,
			_v4);
		return self;
	};

	/// @func set_uniform_float_array(_array)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformFloatArray} command into the queue.
	/// @param {Array.Real} _array The array of values.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_uniform_float_array = function (_array) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetUniformFloatArray,
			_array);
		return self;
	};

	/// @func set_uniform_int(_value)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformInt} command into the queue.
	/// @param {Real} _value The new uniform value.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_uniform_int = function (_value) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetUniformInt,
			_value);
		return self;
	};

	/// @func set_uniform_int2(_v1, _v2)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformInt2} command into the queue.
	/// @param {Real} _v1 The value of the first component.
	/// @param {Real} _v2 The value of the second component.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_uniform_int2 = function (_v1, _v2) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetUniformInt2,
			_v1,
			_v2);
		return self;
	};

	/// @func set_uniform_int3(_v1, _v2, _v3)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformInt3} command into the queue.
	/// @param {Real} _v1 The value of the first component.
	/// @param {Real} _v2 The value of the second component.
	/// @param {Real} _v3 The value of the third component.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_uniform_int3 = function (_v1, _v2, _v3) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetUniformInt3,
			_v1,
			_v2,
			_v3);
		return self;
	};

	/// @func set_uniform_int4(_v1, _v2, _v3, _v4)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformInt4} command into the queue.
	/// @param {Real} _v1 The value of the first component.
	/// @param {Real} _v2 The value of the second component.
	/// @param {Real} _v3 The value of the third component.
	/// @param {Real} _v4 The value of the fourth component.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_uniform_int4 = function (_v1, _v2, _v3, _v4) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetUniformInt4,
			_v1,
			_v2,
			_v3,
			_v4);
		return self;
	};

	/// @func set_uniform_int_array(_array)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformIntArray} command into the queue.
	/// @param {Array.Real} _array The array of values.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_uniform_int_array = function (_array) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetUniformIntArray,
			_array);
		return self;
	};

	/// @func set_uniform_matrix()
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformMatrix} command into the queue.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_uniform_matrix = function () {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetUniformMatrix);
		return self;
	};

	/// @func set_uniform_matrix_array(_array)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetUniformMatrixArray} command into the queue.
	/// @param {Array.Real} _array The array of values.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_uniform_matrix_array = function (_array) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetUniformMatrixArray,
			_array);
		return self;
	};

	/// @func set_view_matrix(_matrix)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetViewMatrix} command into the queue.
	/// @param {Array.Real} _matrix The new view matrix.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_view_matrix = function (_matrix) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetViewMatrix,
			_matrix);
		return self;
	};

	/// @func set_world_matrix(_matrix)
	/// @desc Adds a {@link BBMOD_ERenderCommand.SetWorldMatrix} command into the queue.
	/// @param {Array.Real} _matrix The new world matrix.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	static set_world_matrix = function (_matrix) {
		gml_pragma("forceinline");
		ds_list_add(
			RenderCommands,
			BBMOD_ERenderCommand.SetWorldMatrix,
			_matrix);
		return self;
	};

	/// @func is_empty()
	/// @desc Checks whether the render queue is empty.
	/// @return {Bool} Returns `true` if there are no commands in the render queue.
	static is_empty = function () {
		gml_pragma("forceinline");
		return ds_list_empty(RenderCommands);
	};

	/// @func submit()
	/// @desc Submits all commands.
	/// @return {Struct.BBMOD_RenderQueue} Returns `self`.
	/// @see BBMOD_RenderQueue.clear
	static submit = function () {
		var i = 0;
		var _renderCommands = RenderCommands;
		var _renderCommandsCount = ds_list_size(_renderCommands);
		var _condition = false;

		while (i < _renderCommandsCount)
		{
			switch (_renderCommands[| i++])
			{
			case BBMOD_ERenderCommand.ApplyMaterial:
				if (!_renderCommands[| i++].apply())
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
						switch (_renderCommands[| i++])
						{
						case BBMOD_ERenderCommand.BeginConditionalBlock:
							++_counter;
							break;

						case BBMOD_ERenderCommand.EndConditionalBlock:
							--_counter;
							break;
						}
					}
				}
				break;

			case BBMOD_ERenderCommand.DrawMesh:
				var _material = _renderCommands[| i++];
				if (!_material.apply())
				{
					i += 2;
					_condition = false;
					continue;
				}
				matrix_set(matrix_world, _renderCommands[| i++]);
				vertex_submit(_renderCommands[| i++], pr_trianglelist, _material.BaseOpacity);
				break;

			case BBMOD_ERenderCommand.DrawMeshAnimated:
				var _material = _renderCommands[| i++];
				if (!_material.apply())
				{
					i += 3;
					_condition = false;
					continue;
				}
				matrix_set(matrix_world, _renderCommands[| i++]);
				BBMOD_SHADER_CURRENT.set_bones(_renderCommands[| i++]);
				vertex_submit(_renderCommands[| i++], pr_trianglelist, _material.BaseOpacity);
				break;

			case BBMOD_ERenderCommand.DrawMeshBatched:
				var _material = _renderCommands[| i++];
				if (!_material.apply())
				{
					i += 3;
					_condition = false;
					continue;
				}
				matrix_set(matrix_world, _renderCommands[| i++]);
				BBMOD_SHADER_CURRENT.set_batch_data(_renderCommands[| i++]);
				vertex_submit(_renderCommands[| i++], pr_trianglelist, _material.BaseOpacity);
				break;

			case BBMOD_ERenderCommand.EndConditionalBlock:
				show_error("Found unmatching end of conditional block in render queue " + Name + "!", true);
				break;
			}

			_condition = true;
		}

		return self;
	};

	/// @func clear()
	/// @desc Clears the render queue.
	/// @return {Struct.BBMOD_Material} Returns `self`.
	static clear = function () {
		gml_pragma("forceinline");
		ds_list_clear(RenderCommands);
		return self;
	};

	static destroy = function () {
		method(self, Super_Class.destroy)();
		__bbmod_remove_render_queue(self);
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

function bbmod_get_default_render_queue()
{
	static _renderQueue = new BBMOD_RenderQueue("Default");
	return _renderQueue;
}
