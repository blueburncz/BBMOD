/// @func BBMOD_ParticleSystem(_model, _size)
/// @desc
/// @param {Struct.BBMOD_Model} _model
/// @param {Real} _size
function BBMOD_ParticleSystem(_model, _size)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Super_Class = {
		destroy: destroy,
	};

	/// @var {Struct.BBMOD_Model}
	/// @readonly
	Model = _model;

	/// @var {Real}
	/// @readonly
	Size = _size;

	/// @var {Bool}
	Sort = false;

	/// @var {Struct.BBMOD_DynamicBatch}
	/// @private
	DynamicBatch = new BBMOD_DynamicBatch(_model, _size);

	/// @var {Function} A function that takes a particle and delta time.
	OnUpdate = undefined;

	static destroy = function () {
		method(self, Super_Class.destroy)();
		DynamicBatch.destroy();
	};
}