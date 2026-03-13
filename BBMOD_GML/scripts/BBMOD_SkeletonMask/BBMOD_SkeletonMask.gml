/// @module Extras.LayeredAnimationPlayer

/// @func BBMOD_SkeletonMask(_model)
///
/// @desc A struct that defines which nodes of a model are affected by an
/// animation layer.
///
/// @param {Struct.BBMOD_Model} _model The model to create the skeleton mask
/// for.
function BBMOD_SkeletonMask(_model) constructor
{
	/// @var {Struct.BBMOD_Model} The model that the skeleton mask is created
	/// for.
	/// @readonly
	Model = _model;

	/// @var {Array<Real>} An array of values in range 0..1 for each node that
	/// the model has. Value 0 means the node is not affected and 1 means the
	/// node is fully affected.
	/// @readonly
	MaskArray = array_create(_model.NodeCount, 0.0);

	/// @func get_node_mask(_idOrName)
	///
	/// @desc Retrieves the mask of a node with given ID or name.
	///
	/// @param {Real, String} _idOrName The ID or name of the node.
	///
	/// @return {Real} The mask value in range 0..1, where 0 means the node is
	/// not affected and 1 means the node is fully affected.
	static get_node_mask = function (_idOrName)
	{
		gml_pragma("forceinline");
		return MaskArray[Model.find_node(_idOrName).Index];
	};

	/// @func set_node_mask(_idOrName, _value)
	///
	/// @desc Changes the mask value of a node with given ID or name.
	///
	/// @param {Real, String} _idOrName The ID or the name of the node.
	/// @param {Real} _value The new mask value in range 0..1, where 0 means the
	/// node is not affected and 1 means the node is fully affected.
	///
	/// @return {Struct.BBMOD_SkeletonMask} Returns `self`.
	static set_node_mask = function (_idOrName, _value)
	{
		gml_pragma("forceinline");
		var _index = is_string(_idOrName) ? Model.find_node(_idOrName).Index : _idOrName;
		MaskArray[@ _index] = _value;
		return self;
	};

	static __set_node_mask_recursive_impl = function (_node, _value, _excludeSelf)
	{
		if (!_excludeSelf)
		{
			MaskArray[@ _node.Index] = _value;
		}
		var _index = 0;
		repeat(array_length(_node.Children))
		{
			__set_node_mask_recursive_impl(_node.Children[_index++], _value, false);
		}
	};

	/// @func set_node_mask_recursive(_idOrName, _value[, _excludeSelf])
	///
	/// @desc Recursively changes mask value of a node and/or its children.
	///
	/// @param {Real, String} _idOrName The ID or the name of the node.
	/// @param {Real} _value The new mask value in range 0..1, where 0 means the
	/// node is not affected and 1 means the node is fully affected.
	/// @param {Bool} [_excludeSelf] Whether to exclude the starting node and
	/// only affect the child nodes. Defaults to `false`.
	///
	/// @return {Struct.BBMOD_SkeletonMask} Returns `self`.
	static set_node_mask_recursive = function (_idOrName, _value, _excludeSelf = false)
	{
		gml_pragma("forceinline");
		__set_node_mask_recursive_impl(Model.find_node(_idOrName), _value, _excludeSelf);
		return self;
	};
}
