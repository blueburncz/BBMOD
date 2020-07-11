/// @func bbmod_static_batch_freeze(static_batch)
/// @desc Freezes a static batch. This makes it render faster but disables
/// adding more models to the batch.
/// @param {array} static_batch The static batch.
gml_pragma("forceinline");
vertex_freeze(argument0[BBMOD_EStaticBatch.VertexBuffer]);