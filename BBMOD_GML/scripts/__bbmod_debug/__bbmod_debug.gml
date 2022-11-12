/// @macro {Struct.BBMOD_VertexFormat} A vertex format useful for debugging
/// purposes, like drawing wireframe previews of colliders.
#macro BBMOD_VFORMAT_WIREFRAME __bbmod_vformat_wireframe()

/// @var {Id.VertexBuffer}
/// @private
global.__bbmodVBufferDebug = vertex_create_buffer();

function __bbmod_vformat_wireframe()
{
	static _vformat = new BBMOD_VertexFormat({
		Colors: true,
	});
	return _vformat;
}
