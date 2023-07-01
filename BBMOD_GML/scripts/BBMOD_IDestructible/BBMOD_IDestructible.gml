/// @module Core

/// @func BBMOD_IDestructible()
///
/// @interface
///
/// @desc Interface for structs that need to be manually destroyed to properly
/// free used memory.
function BBMOD_IDestructible()
{
	/// @func destroy()
	///
	/// @desc Frees memory used by the struct.
	///
	/// @return {Undefined} Returns `undefined`.
	///
	/// @example
	/// ```gml
	/// var _struct = new MyStruct();
	/// // Use _struct here...
	/// _struct = struct.destroy();
	/// ```
	static destroy = function ()
	{
		return undefined;
	};
}
