/// @func bbmod_static_batch_begin(static_batch)
/// @param {array} static_batch
gml_pragma("forceinline");
var _static_batch = argument0;
vertex_begin(_static_batch[BBMOD_EStaticBatch.VertexBuffer],
	_static_batch[BBMOD_EStaticBatch.VertexFormat]);