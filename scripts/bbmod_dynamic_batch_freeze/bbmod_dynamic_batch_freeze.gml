/// @func bbmod_dynamic_batch_freeze(dynamic_batch)
/// @desc Freezes a dynamic batch, which makes it render faster.
/// @param {array} dynamic_batch A DynamicBatch structure.
gml_pragma("forceinline");
vertex_freeze(argument0[BBMOD_EStaticBatch.VertexBuffer]);