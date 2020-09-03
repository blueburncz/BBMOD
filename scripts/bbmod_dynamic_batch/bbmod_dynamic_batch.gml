/// @func BBMOD_DynamicBatch(_model, _size)
/// @desc A dynamic batch.
/// @param {BBMOD_Model} _model The model to create a dynamic batch of.
/// @param {real} _size Number of model instances in the batch.
function BBMOD_DynamicBatch(_model, _size) constructor
{
	/// @var {BBMOD_Model} A model that is being batched.
	/// @private
	model = _model

	/// @var {real} Number of model instances within the batch.
	/// @private
	size = _size;

	/// @var {real} A vertex buffer.
	/// @private
	vertex_buffer = vertex_create_buffer();

	/// @var {real} The format of the vertex buffer.
	/// @private
	vertex_format = model.get_vertex_format(false, true);

	vertex_begin(vertex_buffer, vertex_format);
	_bbmod_model_to_dynamic_batch(model.model, self);
	vertex_end(vertex_buffer);

	/// @func freeze()
	static freeze = function () {
		gml_pragma("forceinline");
		vertex_freeze(vertex_buffer);
	};

	/// @func render(_material, _data)
	/// @param {BBMOD_Material} _material A material. Must use a shader that
	/// expects ids in the vertex format.
	/// @param {array} _data An array containing data for each rendered instance.
	static render = function (_material, _data) {
		if ((_material.get_render_path() & global.bbmod_render_pass) == 0)
		{
			// Do not render the mesh if it doesn't use a material that can be used
			// in the current render path.
			return;
		}
		_material.apply();
		_bbmod_shader_set_dynamic_batch_data(_material.get_shader(), _data);
		var _tex_base = _material.get_base_opacity();
		vertex_submit(vertex_buffer, pr_trianglelist, _tex_base);
	};

	/// @func destroy()
	/// @desc Frees memory used by the dynamic batch.
	static destroy = function () {
		gml_pragma("forceinline");
		vertex_delete_buffer(vertex_buffer);
	};
}