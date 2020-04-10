/// @func bbmod_node()
/// @desc Contains definition of the Node structure.
/// @see BBMOD_ENode

/// @enum An enumeration of members of a Node structure.
enum BBMOD_ENode
{
	/// @member The name of the node.
	Name,
	/// @member An array of Mesh structures.
	Meshes,
	/// @member An array of child Node structures.
	Children,
	/// @member The size of the Node structure.
	SIZE
};