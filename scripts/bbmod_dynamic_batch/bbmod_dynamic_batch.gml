/// @func BBMOD_DynamicBatch(_model, _size)
///
/// @desc A dynamic batch is a structure that allows you to render multiple
/// instances of a single model at once, each with its own position, scale and
/// rotation. Compared to {@link BBMOD_Model.render}, this drastically reduces
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
/// mod_car = new BBMOD_Model("Car.bbmod");
/// mat_car = new BBMOD_Material(BBMOD_ShDefaultBatched, sprite_get_texture(SprCar, 0));
/// car_batch = new BBMOD_DynamicBatch(mod_car, 64);
///
/// /// @desc Draw event
/// car_batch.render_object(OCar, mat_car);
/// ```
///
/// @see BBMOD_StaticBatch
function BBMOD_DynamicBatch(_model, _size) constructor
{
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
	static freeze = function () {
		gml_pragma("forceinline");
		vertex_freeze(VertexBuffer);
	};

	/// @func render(_material, _data)
	/// @desc Submits the dynamic batch for rendering.
	/// @param {BBMOD_Material} _material A material. Must use a shader that
	/// expects ids in the vertex format.
	/// @param {real[]} _data An array containing data for each rendered instance.
	/// @see BBMOD_DynamicBatch.render_object
	static render = function (_material, _data) {
		if ((_material.RenderPath & global.bbmod_render_pass) == 0)
		{
			// Do not render the mesh if it doesn't use a material that can be used
			// in the current render path.
			return;
		}
		_material.apply();
		_bbmod_shader_set_dynamic_batch_data(_material.Shader, _data);
		vertex_submit(VertexBuffer, pr_trianglelist, _material.BaseOpacity);
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
	/// @see BBMOD_DynamicBatch.render_object
	static default_fn = function (_data, _index) {
		// Position
		_data[@ _index] = x;
		_data[@ _index + 1] = y;
		_data[@ _index + 2] = z;
		// Uniform scale
		_data[@ _index + 3] = image_xscale;
		// Rotation
		var _quat = ce_quaternion_create_from_axisangle([0, 0, 1], image_angle);
		array_copy(_data, _index + 4, _quat, 0, 4);
		// Written 8 slots in total
		return 8;
	};

	/// @func render_object(_object, _material[, _fn])
	/// @desc Renders all instances of an object in batches of
	/// {@link BBMOD_DynamicBatch.size}.
	/// @param {real} _object An object to render.
	/// @param {BBMOD_Material} _material A material to use.
	/// @param {function} [_fn] A function that writes instance data to an array
	/// which is then passed to the material's shader. Must return number of
	/// slots it has written to. Defaults to {@link BBMOD_DynamicBatch.default_fn}.
	/// @example
	/// ```gml
	/// car_batch.render_object(OCar, mat_car, function (_data, _index) {
	///     // Position
	///     _data[@ _index] = x;
	///     _data[@ _index + 1] = y;
	///     _data[@ _index + 2] = z;
	///     // Uniform scale
	///     _data[@ _index + 3] = image_xscale;
	///     // Rotation
	///     var _quat = ce_quaternion_create_from_axisangle([0, 0, 1], image_angle);
	///     array_copy(_data, _index + 4, _quat, 0, 4);
	///     // Written 8 slots in total
	///     return 8;
	/// });
	/// ```
	/// The function defined in this example is actually the implementation of
	/// {@link BBMOD_DynamicBatch.default_fn}. You can use this to create you own
	/// variation of it.
	/// @see BBMOD_DynamicBatch.render
	/// @see BBMOD_DynamicBatch.default_fn
	static render_object = function (_object, _material) {
		var _fn = (argument_count > 2) ? argument[2] : default_fn;
		var _find = 0;
		var _data_size = Size * 8;
		var _data_empty = array_create(_data_size, 0);
		var _data = array_create(_data_size, 0)
		repeat (ceil(instance_number(_object) / Size))
		{
			array_copy(_data, 0, _data_empty, 0, _data_size);
			var _index = 0;
			repeat (Size)
			{
				var _instance = instance_find(_object, _find++);
				if (_instance == noone)
				{
					break;
				}
				_index += method(_instance, _fn)(_data, _index);
			}
			render(_material, _data);
		}
	};

	/// @func destroy()
	/// @desc Frees memory used by the dynamic batch. Use this in combination with
	/// `delete` to destroy a dynamic batch struct.
	/// @example
	/// ```gml
	/// dynamic_batch.destroy();
	/// delete dynamic_batch;
	/// ```
	static destroy = function () {
		gml_pragma("forceinline");
		vertex_delete_buffer(VertexBuffer);
	};
}