/// @func BBMOD_Importer()
/// @desc Base class for model importers.
function BBMOD_Importer() constructor
{
	/// @var {bool} If true then UV texture coordinates of imported models
	/// will be flipped horizontally. Defaults to false.
	FlipUVHorizontally = false;

	/// @var {bool} If true then UV texture coordinates of imported models
	/// will be flipped vertically. Defaults to false.
	FlipUVVertically = false;

	/// @func can_import(_path)
	/// @desc Checks whether a file can be imported.
	/// @param {string} _path The path to the file to import.
	/// @return {bool} Returns `true` if the importer can import the file.
	/// @throws {BBMOD_NotImplementedException} If the method is not implemented.
	static can_import = function (_path) {
		throw new BBMOD_NotImplementedException();
	};

	/// @func import(_path)
	/// @desc Imports a model from a file.
	/// @param {string} _path The path to the file to import.
	/// @return {BBMOD_Model} The imported model.
	/// @throws {BBMOD_Exception} If the file could not be imported.
	/// @throws {BBMOD_NotImplementedException} If the method is not implemented.
	static import = function (_path) {
		throw new BBMOD_NotImplementedException();
	};

	/// @func destroy()
	/// @desc Frees resources used by the importer from memory.
	static destroy = function () {
	};
}