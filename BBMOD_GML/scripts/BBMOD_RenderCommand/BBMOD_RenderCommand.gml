/// @func BBMOD_RenderCommand()
/// @desc A render command struct. Each {@link BBMOD_Material} has its own
/// render queue. When you call {@link BBMOD_Model.render}, new render commands
/// are added to appropriate queues based on which material the model uses. These
/// commands can then be submitted using {@link BBMOD_Material.submit_queue}.
/// This effectively implements sorting draw calls by material, which decreases
/// texture swaps and shader uniform changes to minimum.
function BBMOD_RenderCommand() constructor
{
	static _matIdenity = matrix_build_identity();

	/// @var {vertex_buffer} The vertex buffer to submit.
	VertexBuffer = undefined;

	/// @var {ptr} The `gm_BaseTexture` used for the vertex buffer. Defaults to
	/// `pointer_null`.
	Texture = pointer_null;

	/// @var {real[]/undefined} An array of bone transforms (dual quaternions)
	/// or `undefined`.
	BoneTransform = undefined;

	/// @var {array} Dynamic batch data.
	BatchData = undefined;

	/// @var {real[16]} The world matrix. Defaults to the identity matrix.
	Matrix = _matIdenity;
}