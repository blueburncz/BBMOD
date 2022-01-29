/// @func BBMOD_RenderCommand()
/// @desc A render command struct. Each {@link BBMOD_Material} has its own
/// {@link BBMOD_RenderQueue}. When you call {@link BBMOD_Model.render}, new
/// render commands are added to appropriate queues based on which material
/// the model uses. These commands can then be submitted using
/// {@link BBMOD_RenderQueue.submit}. This effectively implements sorting draw
/// calls by material, which decreases texture swaps and shader uniform changes to minimum.
function BBMOD_RenderCommand() constructor
{
	/// @var {vertex_buffer/undefined} The vertex buffer to submit.
	VertexBuffer = undefined;

	/// @var {ptr} The `gm_BaseTexture` used for the vertex buffer. Defaults to
	/// `pointer_null`.
	Texture = pointer_null;

	/// @var {real[]/undefined} An array of bone transforms (dual quaternions).
	BoneTransform = undefined;

	/// @var {array/undefined} Dynamic batch data.
	BatchData = undefined;

	/// @var {real[16]/undefined} A transformation matrix.
	Matrix = undefined;
}