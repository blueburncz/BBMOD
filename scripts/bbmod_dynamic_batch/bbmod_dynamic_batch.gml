/// @func bbmod_dynamic_batch()

/// @enum An enumeration of members of a StaticBatch structure.
enum BBMOD_EDynamicBatch
{
	/// @member The vertex buffer.
	VertexBuffer,
	/// @member The format of the vertex buffer.
	VertexFormat,
	/// @member A model that is being batched.
	Model,
	/// @member Number of model instances within the batch.
	Size,
	/// @member The size of the StaticBatch structure.
	SIZE
};