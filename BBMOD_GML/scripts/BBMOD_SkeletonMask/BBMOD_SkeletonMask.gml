/// @module Core

/// @func BBMOD_SkeletonMask(_model)
///
/// @desc
///
/// @param {Struct.BBMOD_Model} _model
function BBMOD_SkeletonMask(_model) constructor
{
	/// @var {Struct.BBMOD_Model}
	/// @readonly
	Model = _model;

	/// @var {Array<Bool>}
	/// @readonly
	MaskArray = array_create(_model.NodeCount, true);

	/// @func get_node_mask(_idOrName)
	///
	/// @desc
	///
	/// @param {Real, String} _idOrName
	///
	/// @return {Bool}
	static get_node_mask = function (_idOrName)
	{
		gml_pragma("forceinline");
		return MaskArray[Model.find_node(_idOrName).Index];
	};

	/// @func set_node_mask(_idOrName, _enable)
	///
	/// @desc
	///
	/// @param {Real, String} _idOrName
	/// @param {Bool} _enable
	///
	/// @return {Struct.BBMOD_SkeletonMask} Returns `self`.
	static set_node_mask = function (_idOrName, _enable)
	{
		gml_pragma("forceinline");
		var _index = is_string(_idOrName) ? Model.find_node(_idOrName).Index : _idOrName;
		MaskArray[@ _index] = _enable;
		return self;
	};

	static __set_node_mask_recursive_impl = function (_node, _enable, _excludeSelf)
	{
		if (!_excludeSelf)
		{
			MaskArray[@ _node.Index] = _enable;
		}
		var _index = 0;
		repeat(array_length(_node.Children))
		{
			__set_node_mask_recursive_impl(_node.Children[_index++], _enable, false);
		}
	};

	/// @func set_node_mask_recursive(_idOrName, _enable[, _excludeSelf])
	///
	/// @desc
	///
	/// @param {Real, String} _idOrName
	/// @param {Bool} _enable
	/// @param {Bool} [_excludeSelf] Defaults to `false`.
	///
	/// @return {Struct.BBMOD_SkeletonMask} Returns `self`.
	static set_node_mask_recursive = function (_idOrName, _enable, _excludeSelf = false)
	{
		gml_pragma("forceinline");
		__set_node_mask_recursive_impl(Model.find_node(_idOrName), _enable, _excludeSelf);
		return self;
	};
}
