/// @func BBMOD_DynamicBatch(_model, _size)
///
/// @extends BBMOD_Class
///
/// @desc A dynamic batch is a structure that allows you to render multiple
/// instances of a single model at once, each with its own position, scale and
/// rotation. Compared to {@link BBMOD_Model.submit}, this drastically reduces
/// draw calls and increases performance, but requires more memory. Current
/// limitations are that the model must not have bones (it cannot be animated)
/// and it can use only a single material. Number of model instances per batch
/// is also affected by maximum number of uniforms that a vertex shader can
/// accept.
///
/// @param {BBMOD_Model} _model The model to create a dynamic batch of. Must
/// use a single material and must not have bones.
/// @param {real} _size Number of model instances in the batch.
///
/// @example
/// Following code renders all instances of a car object in batches of 64.
/// ```gml
/// /// @desc Create event
/// modCar = new BBMOD_Model("Car.bbmod");
/// matCar = new BBMOD_Material(BBMOD_ShDefaultBatched, sprite_get_texture(SprCar, 0));
/// carBatch = new BBMOD_DynamicBatch(modCar, 64);
///
/// /// @desc Draw event
/// carBatch.render_object(OCar, matCar);
/// ```
///
/// @see BBMOD_StaticBatch
function BBMOD_DynamicBatch(_model, _size)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Super_Class = {
		destroy: destroy,
	};

	/// @var {BBMOD_Model} A model that is being batched.
	/// @readonly
	Model = _model

	/// @var {real} Number of model instances in the batch.
	/// @readonly
	Size = _size;

	/// @var {vertex_buffer} A vertex buffer.
	/// @private
	VertexBuffer = vertex_create_buffer();

	/// @var {real} The format of the vertex buffer.
	/// @private
	VertexFormat = Model.get_vertex_format(false, true);

	vertex_begin(VertexBuffer, VertexFormat.Raw);
	Model.to_dynamic_batch(self);
	vertex_end(VertexBuffer);

	/// @func freeze()
	/// @desc Freezes the dynamic batch. This makes it render faster.
	/// @return {BBMOD_DynamicBatch} Returns `self`.
	static freeze = function () {
		gml_pragma("forceinline");
		vertex_freeze(VertexBuffer);
		return self;
	};

	/// @func submit(_material, _data)
	///
	/// @desc Immediately submits the dynamic batch for rendering.
	///
	/// @param {BBMOD_BaseMaterial} _material A material. Must use a shader that
	/// expects ids in the vertex format.
	/// @param {real[]} _data An array containing data for each rendered instance.
	///
	/// @return {BBMOD_DynamicBatch} Returns `self`.
	///
	/// @note The dynamic batch is *not* submitted if the material used is not
	/// compatible with the current render pass!
	///
	/// @see BBMOD_DynamicBatch.submit_object
	/// @see BBMOD_DynamicBatch.render
	/// @see BBMOD_DynamicBatch.render_object
	/// @see BBMOD_BaseMaterial
	/// @see BBMOD_ERenderPass
	static submit = function (_material, _data) {
		gml_pragma("forceinline");
		if (!_material.apply())
		{
			return self;
		}
		BBMOD_SHADER_CURRENT.set_batch_data(_data);
		vertex_submit(VertexBuffer, pr_trianglelist, _material.BaseOpacity);
		return self;
	};

	/// @func render(_material, _data)
	/// @desc Enqueues the dynamic batch for rendering.
	/// @param {BBMOD_BaseMaterial} _material A material. Must use a shader that
	/// expects ids in the vertex format.
	/// @param {real[]} _data An array containing data for each rendered instance.
	/// @return {BBMOD_DynamicBatch} Returns `self`.
	/// @see BBMOD_DynamicBatch.submit
	/// @see BBMOD_DynamicBatch.submit_object
	/// @see BBMOD_DynamicBatch.render_object
	/// @see BBMOD_BaseMaterial
	static render = function (_material, _data) {
		gml_pragma("forceinline");
		var _renderCommand = new BBMOD_RenderCommand();
		_renderCommand.VertexBuffer = VertexBuffer;
		_renderCommand.Texture = _material.BaseOpacity;
		_renderCommand.BatchData = _data;
		_renderCommand.Matrix = matrix_get(matrix_world);
		_material.RenderQueue.add(_renderCommand);
		return self;
	};

	/// @func default_fn(_data, _index)
	/// @desc The default function used in {@link BBMOD_DynamicBatch.render_object}.
	/// Uses instance's variables `x`, `y`, `z` for position, `image_xscale` for
	/// uniform scale and `image_angle` for rotation around the `z` axis.
	/// @param {real[]} _data An array to which the function will write instance
	/// data. The data layout is compatible with shader `BBMOD_ShDefaultBatched`
	/// and hence with material {@link BBMOD_MATERIAL_DEFAULT_BATCHED}.
	/// @param {real} _index An index at which the first variable will be written.
	/// @return {real} Number of slots it has written to. Always equals 8.
	/// @see BBMOD_DynamicBatch.submit_object
	/// @see BBMOD_DynamicBatch.render_object
	static default_fn = function (_data, _index) {
		// Position
		_data[@ _index] = x;
		_data[@ _index + 1] = y;
		_data[@ _index + 2] = z;
		// Uniform scale
		_data[@ _index + 3] = image_xscale;
		// Rotation
		var _quat = new BBMOD_Quaternion()
			.FromAxisAngle(new BBMOD_Vec3(0, 0, 1), image_angle);
		_quat.ToArray(_data, _index + 4);
		// Written 8 slots in total
		return 8;
	};

	static _draw_object = function (_method, _object, _material, _fn) {
		gml_pragma("forceinline");

		_fn = (_fn != undefined) ? _fn : default_fn;

		var _dataSize = Size * 8;
		var _data = array_create(_dataSize, 0);
		var _index = 0;

		with (_object)
		{
			_index += method(self, _fn)(_data, _index);
			if (_index >= _dataSize)
			{
				_method(_material, _data);
				_data = array_create(_dataSize, 0);
				_index = 0;
			}
		}

		if (_index > 0)
		{
			_method(_material, _data);
		}
	};

	/// @func submit_object(_object, _material[, _fn])
	/// @desc Immediately submits all instances of an object for rendering in
	/// batches of {@link BBMOD_DynamicBatch.size}.
	/// @param {real} _object An object to submit.
	/// @param {BBMOD_BaseMaterial} _material A material to use.
	/// @param {func} [_fn] A function that writes instance data to an array
	/// which is then passed to the material's shader. Must return number of
	/// slots it has written to. Defaults to {@link BBMOD_DynamicBatch.default_fn}.
	/// @return {BBMOD_DynamicBatch} Returns `self`.
	/// @example
	/// ```gml
	/// carBatch.submit_object(OCar, mat_car, function (_data, _index) {
	///     // Position
	///     _data[@ _index] = x;
	///     _data[@ _index + 1] = y;
	///     _data[@ _index + 2] = z;
	///     // Uniform scale
	///     _data[@ _index + 3] = image_xscale;
	///     // Rotation
	///     var _quat = new BBMOD_Quaternion()
	///         .FromAxisAngle(new BBMOD_Vec3(0, 0, 1), image_angle);
	///         _quat.ToArray(_data, _index + 4);
	///     // Written 8 slots in total
	///     return 8;
	/// });
	/// ```
	/// The function defined in this example is actually the implementation of
	/// {@link BBMOD_DynamicBatch.default_fn}. You can use this to create you own
	/// variation of it.
	/// @see BBMOD_DynamicBatch.submit
	/// @see BBMOD_DynamicBatch.render
	/// @see BBMOD_DynamicBatch.render_object
	/// @see BBMOD_DynamicBatch.default_fn
	static submit_object = function (_object, _material, _fn) {
		_draw_object(method(self, submit), _object, _material, _fn);
		return self;
	};

	/// @func render_object(_object, _material[, _fn])
	/// @desc Enqueues all instances of an object for rendering in batches of
	/// {@link BBMOD_DynamicBatch.size}.
	/// @param {real} _object An object to render.
	/// @param {BBMOD_BaseMaterial} _material A material to use.
	/// @param {func} [_fn] A function that writes instance data to an array
	/// which is then passed to the material's shader. Must return number of
	/// slots it has written to. Defaults to {@link BBMOD_DynamicBatch.default_fn}.
	/// @return {BBMOD_DynamicBatch} Returns `self`.
	/// @example
	/// ```gml
	/// carBatch.render_object(OCar, mat_car, function (_data, _index) {
	///     // Position
	///     _data[@ _index] = x;
	///     _data[@ _index + 1] = y;
	///     _data[@ _index + 2] = z;
	///     // Uniform scale
	///     _data[@ _index + 3] = image_xscale;
	///     // Rotation
	///     var _quat = new BBMOD_Quaternion()
	///         .FromAxisAngle(new BBMOD_Vec3(0, 0, 1), image_angle);
	///         _quat.ToArray(_data, _index + 4);
	///     // Written 8 slots in total
	///     return 8;
	/// });
	/// ```
	/// The function defined in this example is actually the implementation of
	/// {@link BBMOD_DynamicBatch.default_fn}. You can use this to create you own
	/// variation of it.
	/// @see BBMOD_DynamicBatch.submit
	/// @see BBMOD_DynamicBatch.submit_object
	/// @see BBMOD_DynamicBatch.render
	/// @see BBMOD_DynamicBatch.default_fn
	static render_object = function (_object, _material, _fn) {
		_draw_object(method(self, render), _object, _material, _fn);
		return self;
	};

	static destroy = function () {
		method(self, Super_Class.destroy)();
		vertex_delete_buffer(VertexBuffer);
	};
}