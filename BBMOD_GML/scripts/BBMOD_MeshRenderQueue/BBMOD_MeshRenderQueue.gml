/// @module Core

/// @func BBMOD_MeshRenderQueue([_name[, _priority]])
///
/// @extends BBMOD_RenderQueue
///
/// @desc A render queue specialized for rendering of multiple instances of a
/// model, where all instances are using the same material. You can use this
/// instead of {@link BBMOD_RenderQueue} to increase rendering performance.
///
/// @param {String} [_name] The name of the render queue. Defaults to
/// "RenderQueue" + number of created render queues - 1 (e.g. "RenderQueue0",
/// "RenderQueue1" etc.) if `undefined`.
/// @param {Real} [_priority] The priority of the render queue. Defaults to 0.
///
/// @deprecated This render queue is deprecated. Use {@link BBMOD_RenderQueue} instead.
function BBMOD_MeshRenderQueue(_name = undefined, _priority = 0): BBMOD_RenderQueue(_name, _priority) constructor {}
