/// @func bbmod_model()
/// @desc Contains definition of the Model structure.
/// @see BBMOD_EModel

/// @enum An enumeration of members of a Model structure.
enum BBMOD_EModel
{
	/// @member The version of the model file.
	Version,
	/// @member True if the model has vertices (always true).
	HasVertices,
	/// @member True if the model has normal vectors.
	HasNormals,
	/// @member True if the model has texture coordinates.
	HasTextureCoords,
	/// @member True if the model has vertex colors.
	HasColors,
	/// @member True if the model has tangent vectors and bitangent sign.
	HasTangentW,
	/// @member True if the model has vertex weights and bone indices.
	HasBones,
	/// @member The global inverse transform matrix.
	InverseTransformMatrix,
	/// @member The root Node structure.
	RootNode,
	/// @member Number of bones.
	BoneCount,
	/// @member The root Bone structure.
	Skeleton,
	/// @member Number of materials that the model uses.
	MaterialCount,
	/// @member Array of material names.
	MaterialNames,
	/// @member The size of the Model structure.
	SIZE
};