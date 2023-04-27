/// @module Core

/// @func bbmod_vertex_buffer_load(_file, _vformat)
///
/// @desc Loads a vertex buffer from a file.
///
/// @param {String} _file The path to the file to load the vertex buffer from.
/// @param {Struct.BBMOD_VertexFormat} _vformat The vertex format of the vertex
/// buffer.
///
/// @return {Id.VertexBuffer, Undefined} Returns the loaded vertex buffer or
/// `undefined` if loading fails.
///
/// @example
/// ```gml
/// /// @desc Create event
/// model = bbmod_vertex_buffer_load("model.bin", BBMOD_VFORMAT_DEFAULT);
/// vertex_free(model);
///
/// /// @desc Draw event
/// vertex_submit(model, pr_trianglelist, -1);
///
/// /// @desc Clean Up event
/// vertex_delete_buffer(model);
/// ```
///
/// @see BBMOD_VFORMAT_DEFAULT
function bbmod_vertex_buffer_load(_file, _vformat)
{
	gml_pragma("forceinline");
	var _buffer = buffer_load(_file);
	if (_buffer == -1)
	{
		return undefined;
	}
	var _vbuffer = vertex_create_buffer_from_buffer(_buffer, _vformat.Raw);
	buffer_delete(_buffer);
	return _vbuffer;
}
