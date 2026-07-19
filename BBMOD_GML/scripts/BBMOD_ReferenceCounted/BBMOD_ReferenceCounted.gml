/// @module Core

/// @func BBMOD_ReferenceCounted()
///
/// @implements {BBMOD_IDestructible}
///
/// @desc Base struct for objects that use simple reference counting.
function BBMOD_ReferenceCounted() constructor
{
	/// @var {Real} Number of references to this object. If it reaches 0, the
	/// object is destroyed.
	/// @private
	__counter = 1;

	/// @func ref()
	///
	/// @desc Retrieves a reference to the object.
	///
	/// @return {Struct.BBMOD_ReferenceCounted} Returns `self`.
	static ref = function ()
	{
		gml_pragma("forceinline");
		++__counter;
		return self;
	};

	/// @func free()
	///
	/// @desc Releases a reference to the object.
	///
	/// @return {Bool} Returns `true` if there are no other references and the
	/// object is destroyed.
	static free = function ()
	{
		gml_pragma("forceinline");
		if (--__counter == 0)
		{
			destroy();
			return true;
		}
		return false;
	};

	/// @func destroy()
	///
	/// @desc Destroys the object.
	///
	/// @return {Undefined} Returns `undefined`.
	static destroy = function ()
	{
		return undefined;
	};
}
