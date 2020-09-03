/// @enum An enumeration of members of a BBMOD_EDynamicBatch legacy struct.
enum BBMOD_EDynamicBatch
{
	/// @member The vertex buffer.
	VertexBuffer,
	/// @member The format of the vertex buffer.
	VertexFormat,
	/// @member A model that is being batched.
	Model,
	/// @member Number of model instances within the batch.
	Size,
	/// @member The size of the BBMOD_EDynamicBatch legacy struct.
	SIZE
};

/// @func bbmod_dynamic_batch_create(_model, _size)
/// @desc Creates a dynamic batch of a model.
/// @param {array} _model The model to create a dynamic batch of.
/// @param {real} _size Number of model instances in the batch.
/// @return {BBMOD_EDynamicBatch} The created dynamic batch.
function bbmod_dynamic_batch_create(_model, _size)
{
	var _buffer = vertex_create_buffer();
	var _format = bbmod_model_get_vertex_format(_model, false, true);

	var _dynamic_batch = array_create(BBMOD_EDynamicBatch.SIZE, 0);
	_dynamic_batch[@ BBMOD_EDynamicBatch.VertexBuffer] = _buffer;
	_dynamic_batch[@ BBMOD_EDynamicBatch.VertexFormat] = _format;
	_dynamic_batch[@ BBMOD_EDynamicBatch.Model] = _model;
	_dynamic_batch[@ BBMOD_EDynamicBatch.Size] = _size;

	vertex_begin(_buffer, _format);
	_bbmod_model_to_dynamic_batch(_model, _dynamic_batch);
	vertex_end(_buffer);

	return _dynamic_batch;
}

/// @func bbmod_dynamic_batch_destroy(_dynamic_batch)
/// @desc Destroys a dynamic batch.
/// @param {BBMOD_EDynamicBatch} _dynamic_batch The dynamic batch to destroy.
function bbmod_dynamic_batch_destroy(_dynamic_batch)
{
	vertex_delete_buffer(_dynamic_batch[BBMOD_EDynamicBatch.VertexBuffer]);
}

/// @func bbmod_dynamic_batch_freeze(_dynamic_batch)
/// @desc Freezes a dynamic batch, which makes it render faster.
/// @param {BBMOD_EDynamicBatch} _dynamic_batch A dynamic batch.
function bbmod_dynamic_batch_freeze(_dynamic_batch)
{
	gml_pragma("forceinline");
	vertex_freeze(_dynamic_batch[BBMOD_EStaticBatch.VertexBuffer]);
}

/// @func bbmod_dynamic_batch_render(_dynamic_batch, _material, _data)
/// @desc Submits a DynamitBatch for rendering.
/// @param {BBMOD_EDynamicBatch} _dynamic_batch A dynamic batch.
/// @param {BBMOD_EMaterial} _material A material. Must use a shader that
/// expects ids in the vertex format.
/// @param {array} _data An array containing data for each rendered instance.
function bbmod_dynamic_batch_render(_dynamic_batch, _material, _data)
{
	var _render_pass = global.bbmod_render_pass;

	if ((_material[BBMOD_EMaterial.RenderPath] & _render_pass) == 0)
	{
		// Do not render the mesh if it doesn't use a material that can be used
		// in the current render path.
		return;
	}

	bbmod_material_apply(_material);

	_bbmod_shader_set_dynamic_batch_data(_material[BBMOD_EMaterial.Shader], _data);

	var _tex_base = _material[BBMOD_EMaterial.BaseOpacity];
	vertex_submit(_dynamic_batch[BBMOD_EStaticBatch.VertexBuffer], pr_trianglelist, _tex_base);
}

/// @func BBMOD_DynamicBatch(_model, _size)
/// @desc An OOP wrapper around a {@link BBMOD_EDynamicBatch} legacy struct.
/// @param {BBMOD_Model} _model The model to create a dynamic batch of.
/// @param {real} _size Number of model instances in the batch.
function BBMOD_DynamicBatch(_model, _size) constructor
{
	/// @var {BBMOD_EDynamicBatch} The dynamic batch that this struct wraps.
	dynamic_batch = bbmod_dynamic_batch_create(_model.model, _size);

	/// @func freeze()
	static freeze = function () {
		bbmod_dynamic_batch_freeze(dynamic_batch);
	};

	/// @func render(_material, _data)
	/// @param {BBMOD_Material} _material A material. Must use a shader that
	/// expects ids in the vertex format.
	/// @param {array} _data An array containing data for each rendered instance.
	static render = function (_material, _data) {
		bbmod_dynamic_batch_render(dynamic_batch, _material.material, _data);
	};

	/// @func destroy()
	/// @desc Frees memory used by the dynamic batch.
	static destroy = function () {
		bbmod_static_batch_destroy(dynamic_batch);
	};
}