/// @func bbmod_static_batch_create(vformat)
/// @desc Creates a new static batch.
/// @param {real} vformat The vertex format of the static batch. Must not have
/// bones!
/// @return {array} The created static batch.
/// @see bbmod_model_get_vertex_format
var _static_batch = array_create(BBMOD_EStaticBatch.SIZE, 0);
_static_batch[@ BBMOD_EStaticBatch.VertexBuffer] = vertex_create_buffer();
_static_batch[@ BBMOD_EStaticBatch.VertexFormat] = argument0;
return _static_batch;