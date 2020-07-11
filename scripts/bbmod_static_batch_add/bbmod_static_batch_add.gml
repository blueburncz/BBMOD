/// @func bbmod_static_batch_add(static_batch, model, transform)
/// @desc Adds a model to a static batch.
/// @param {array} static_batch The static batch.
/// @param {array} model The model.
/// @param {array} transform A transformation matrix of the model.
/// @example
/// ```gml
/// mod_tree = bbmod_load("Tree.bbmod");
/// var _vformat = bbmod_model_get_vertex_format(mod_tree, false);
/// batch = bbmod_static_batch_create(_vformat);
/// bbmod_static_batch_begin(batch);
/// with (OTree)
/// {
///     var _transform = matrix_build(x, y, z, 0, 0, direction, 1, 1, 1);
///     bbmod_static_batch_add(other.batch, other.mod_tree, _transform);
/// }
/// bbmod_static_batch_end(batch);
/// bbmod_static_batch_freeze(batch);
/// ```
/// @note You must first call
/// [bbmod_static_batch_begin](./bbmod_static_batch_begin.html)
/// before using this function!
/// @see bbmod_static_batch_begin
/// @see bbmod_static_batch_end
gml_pragma("forceinline");
_bbmod_model_to_static_batch(argument1, argument0, argument2);