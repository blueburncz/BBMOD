/// @func BBMOD_StaticBatch(_vformat)
/// @desc A static batch.
/// @param {real} _vformat The vertex format of the static batch. All models
/// added to the same static batch must have the same vertex format. This
/// vertex format must not contain bone data!
/// @see BBMOD_Model.get_vertex_format
function BBMOD_StaticBatch(_vformat) constructor
{
	/// @var {real} A vertex buffer.
	/// @private
	vertex_buffer = vertex_create_buffer();

	/// @var {real} The format of the vertex buffer.
	/// @private
	vertex_format = _vformat;

	/// @func start()
	/// @desc Begins adding models into the static batch.
	/// @see BBMOD_StaticBatch.add
	/// @see BBMOD_StaticBatch.finish
	static start = function () {
		gml_pragma("forceinline");
		vertex_begin(vertex_buffer, vertex_format);
	}

	/// @func add(_model, _transform)
	/// @desc Adds a model to the static batch.
	/// @param {BBMOD_Model} _model The model.
	/// @param {array} _transform A transformation matrix of the model.
	/// @example
	/// ```gml
	/// mod_tree = new BBMOD_Model("Tree.bbmod");
	/// var _vformat = mod_tree.get_vertex_format(false);
	/// batch = new BBMOD_StaticBatch(_vformat);
	/// batch.start();
	/// with (OTree)
	/// {
	///     var _transform = matrix_build(x, y, z, 0, 0, direction, 1, 1, 1);
	///     other.batch.add(other.mod_tree, _transform);
	/// }
	/// batch.finish();
	/// batch.freeze();
	/// ```
	/// @note You must first call {@link BBMOD_StaticBatch.begin} before using this
	/// function!
	/// @see BBMOD_StaticBatch.finish
	static add = function (_model, _transform) {
		gml_pragma("forceinline");
		_bbmod_model_to_static_batch(_model.model, self, _transform);
	}

	/// @func finish()
	/// @desc Ends adding models into the static batch.
	/// @see BBMOD_StaticBatch.start
	static finish = function () {
		gml_pragma("forceinline");
		vertex_end(vertex_buffer);
	}

	/// @func freeze()
	/// @desc Freezes the static batch. This makes it render faster, but disables
	/// adding more models.
	static freeze = function () {
		gml_pragma("forceinline");
		vertex_freeze(vertex_buffer);
	}

	
	/// @func render(_material)
	/// @desc Submits the static batch for rendering.
	/// @param {BBMOD_EMaterial} _material A material.
	static render = function (_material) {
		if ((_material.get_render_path() & global.bbmod_render_pass) == 0)
		{
			// Do not render the mesh if it doesn't use a material that can be used
			// in the current render path.
			return;
		}
		_material.apply();
		var _tex_base = _material.get_base_opacity();
		vertex_submit(vertex_buffer, pr_trianglelist, _tex_base);
	}

	/// @func destroy()
	/// @desc Frees memory used by the static batch.
	static destroy = function () {
		gml_pragma("forceinline");
		vertex_delete_buffer(vertex_buffer);
	};
}