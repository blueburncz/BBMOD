/// @func BBMOD_Class()
/// @desc Base for BBMOD structs that require more OOP functionality.
function BBMOD_Class() constructor
{
	/// @var {func[]} An array of implemented interfaces.
	/// @private
	Interfaces = [];

	/// @var {func[]} An array of functions executed when the destroy method
	/// is called.
	/// @private
	OnDestroy = [];

	/// @func implement(_interface)
	/// @desc Implements an interface into the struct.
	/// @return {BBMOD_Class} Returns `self`.
	/// @throws {BBMOD_Exception} If the struct already implements the interface.
	static implement = function (_interface) {
		gml_pragma("forceinline");
		if (implements(_interface))
		{
			throw new BBMOD_Exception("Interface already implemented!");
			return self;
		}
		array_push(Interfaces, _interface);
		method(self, _interface)();
		return self;
	};

	/// @func implements(_interface)
	/// @desc Checks whether the struct implements an interface.
	/// @param {func} _interface The interface to check.
	/// @return {bool} Returns `true` if the struct implements the interface.
	static implements = function (_interface) {
		gml_pragma("forceinline");
		var i = 0;
		repeat (array_length(Interfaces))
		{
			if (Interfaces[i++] == _interface)
			{
				return true;
			}
		}
		return false;
	};

	/// @func destroy()
	/// @desc Frees resources used by the struct from memory.
	static destroy = function () {
		var i = 0;
		repeat (array_length(OnDestroy))
		{
			method(self, OnDestroy[i++])();
		}
	};
}