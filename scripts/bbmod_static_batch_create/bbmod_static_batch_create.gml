/// @func bbmod_static_batch_create(vformat)
/// @param {real} vformat
/// @return {array}
var _static_batch = array_create(BBMOD_EStaticBatch.SIZE, 0);
_static_batch[@ BBMOD_EStaticBatch.VertexBuffer] = vertex_create_buffer();
_static_batch[@ BBMOD_EStaticBatch.VertexFormat] = argument0;
return _static_batch;