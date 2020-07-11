/// @func bbmod_static_batch_begin(static_batch)
/// @desc Begins adding models into a static batch.
/// @param {array} static_batch The static batch.
/// @see bbmod_static_batch_add
/// @see bbmod_static_batch_end
gml_pragma("forceinline");
var _static_batch = argument0;
vertex_begin(_static_batch[BBMOD_EStaticBatch.VertexBuffer],
	_static_batch[BBMOD_EStaticBatch.VertexFormat]);