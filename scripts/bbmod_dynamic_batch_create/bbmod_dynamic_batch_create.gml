/// @func bbmod_dynamic_batch_create(model, size)
/// @param {array} model
/// @param {real} size
/// @return {array}
var _model = argument0;
var _size = argument1;
var _buffer = vertex_create_buffer();
var _format = bbmod_model_get_vertex_format(_model, true);

var _dynamic_batch = array_create(BBMOD_EDynamicBatch.SIZE, 0);
_dynamic_batch[@ BBMOD_EDynamicBatch.VertexBuffer] = _buffer;
_dynamic_batch[@ BBMOD_EDynamicBatch.VertexFormat] = _format;
_dynamic_batch[@ BBMOD_EDynamicBatch.Model] = _model;
_dynamic_batch[@ BBMOD_EDynamicBatch.Size] = _size;

vertex_begin(_buffer, _format);
_bbmod_model_to_dynamic_batch(_model, _dynamic_batch);
vertex_end(_buffer);

return _dynamic_batch;