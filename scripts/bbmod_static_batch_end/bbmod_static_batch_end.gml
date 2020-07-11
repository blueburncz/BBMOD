/// @func bbmod_static_batch_end(static_batch)
/// @desc Ends adding models into a static batch.
/// @param {array} static_batch The static batch.
/// @see bbmod_static_batch_begin
gml_pragma("forceinline");
vertex_end(argument0[BBMOD_EStaticBatch.VertexBuffer]);