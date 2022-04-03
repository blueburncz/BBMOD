/// @func BBMOD_StaticBatch(_vformat)
///
/// @extends BBMOD_Class
///
/// @desc A static batch is a structure that allows you to compose static models
/// into a single one. Compared to {@link BBMOD_Model.submit}, this drastically
/// reduces draw calls and increases performance, but requires more memory.
/// Current limitation is that the added models must use the same single material.
///
/// @param {Struct.BBMOD_VertexFormat} _vformat The vertex format of the static batch.
/// All models added to the same static batch must have the same vertex format.
/// This vertex format must not contain bone data!
///
/// @example
/// ```gml
/// modTree = new BBMOD_Model("Tree.bbmod");
/// var _vformat = modTree.get_vertex_format();
/// batch = new BBMOD_StaticBatch(_vformat);
/// batch.start();
/// with (OTree)
/// {
///     var _transform = matrix_build(x, y, z, 0, 0, direction, 1, 1, 1);
///     other.batch.add(other.modTree, _transform);
/// }
/// batch.finish();
/// batch.freeze();
/// ```
///
/// @see BBMOD_Model.get_vertex_format
/// @see BBMOD_DynamicBatch
function BBMOD_StaticBatch(_vformat)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Super_Class = {
		destroy: destroy,
	};

	/// @var {Id.VertexBuffer} A vertex buffer.
	/// @private
	VertexBuffer = vertex_create_buffer();

	/// @var {Struct.BBMOD_VertexFormat} The format of the vertex buffer.
	/// @private
	VertexFormat = _vformat;

	/// @func start()
	/// @desc Begins adding models into the static batch.
	/// @see BBMOD_StaticBatch.add
	/// @see BBMOD_StaticBatch.finish
	/// @return {Struct.BBMOD_StaticBatch} Returns `self`.
	static start = function () {
		gml_pragma("forceinline");
		vertex_begin(VertexBuffer, VertexFormat.Raw);
		return self;
	};

	/// @func add(_model, _transform)
	/// @desc Adds a model to the static batch.
	/// @param {Struct.BBMOD_Model} _model The model.
	/// @param {Array.Real} _transform A transformation matrix of the model.
	/// @return {Struct.BBMOD_StaticBatch} Returns `self`.
	/// @example
	/// ```gml
	/// modTree = new BBMOD_Model("Tree.bbmod");
	/// var _vformat = modTree.get_vertex_format();
	/// batch = new BBMOD_StaticBatch(_vformat);
	/// batch.start();
	/// with (OTree)
	/// {
	///     var _transform = matrix_build(x, y, z, 0, 0, direction, 1, 1, 1);
	///     other.batch.add(other.modTree, _transform);
	/// }
	/// batch.finish();
	/// batch.freeze();
	/// ```
	/// @note You must first call {@link BBMOD_StaticBatch.begin} before using this
	/// function!
	/// @see BBMOD_StaticBatch.finish
	static add = function (_model, _transform) {
		gml_pragma("forceinline");
		_model.to_static_batch(self, _transform);
		return self;
	};

	/// @func finish()
	/// @desc Ends adding models into the static batch.
	/// @return {Struct.BBMOD_StaticBatch} Returns `self`.
	/// @see BBMOD_StaticBatch.start
	static finish = function () {
		gml_pragma("forceinline");
		vertex_end(VertexBuffer);
		return self;
	};

	/// @func freeze()
	/// @desc Freezes the static batch. This makes it render faster, but disables
	/// adding more models.
	/// @return {Struct.BBMOD_StaticBatch} Returns `self`.
	static freeze = function () {
		gml_pragma("forceinline");
		vertex_freeze(VertexBuffer);
		return self;
	};

	/// @func submit(_material)
	///
	/// @desc Immediately submits the static batch for rendering.
	///
	/// @param {Struct.BBMOD_BaseMaterial} _material A material.
	///
	/// @return {Struct.BBMOD_StaticBatch} Returns `self`.
	///
	/// @note The static batch is *not* submitted if the material used is not
	/// compatible with the current render pass!
	///
	/// @see BBMOD_StaticBatch.render
	/// @see BBMOD_BaseMaterial
	/// @see BBMOD_ERenderPass
	static submit = function (_material) {
		gml_pragma("forceinline");
		if (!_material.apply())
		{
			return self;
		}
		vertex_submit(VertexBuffer, pr_trianglelist, _material.BaseOpacity);
		return self;
	};

	/// @func render(_material)
	/// @desc Enqueues the static batch for rendering.
	/// @param {Struct.BBMOD_BaseMaterial} _material A material.
	/// @return {Struct.BBMOD_StaticBatch} Returns `self`.
	/// @see BBMOD_StaticBatch.submit
	/// @see BBMOD_BaseMaterial
	static render = function (_material) {
		gml_pragma("forceinline");
		//var _renderCommand = new BBMOD_RenderCommand();
		//_renderCommand.VertexBuffer = VertexBuffer;
		//_renderCommand.Material = _material;
		//_renderCommand.Matrix = matrix_get(matrix_world);
		//_material.RenderQueue.add(_renderCommand);
		_material.RenderQueue.draw_mesh(VertexBuffer, matrix_get(matrix_world), _material);
		return self;
	};

	static destroy = function () {
		method(self, Super_Class.destroy)();
		vertex_delete_buffer(VertexBuffer);
	};
}