/// @func BBMOD_RenderCommand()
/// @desc A render command struct.
/// @obsolete Render queue system has changed. Please see
/// {@link BBMOD_ERenderCommand} and {@link BBMOD_RenderQueue}.
function BBMOD_RenderCommand() constructor
{
	/// @var {Id.VertexBuffer/Undefined} The vertex buffer to submit.
	VertexBuffer = undefined;

	/// @var {Pointer.Texture} The `gm_BaseTexture` used for the vertex buffer.
	/// Defaults to `pointer_null`.
	Texture = pointer_null;

	/// @var {Aarray.Real/Undefined} An array of bone transforms (dual quaternions).
	BoneTransform = undefined;

	/// @var {Array.Real/Undefined} Dynamic batch data.
	BatchData = undefined;

	/// @var {Array.Real/Undefined} A transformation matrix.
	Matrix = undefined;
}