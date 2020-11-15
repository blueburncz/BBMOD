/// @macro {undefined} An empty value. This is for example used in the legacy
/// functions as a return value when animation/model loading fails or to unassign
/// an existing one.
/// @example
/// ```gml
/// model = bbmod_load("model.bbmod");
/// if (model == BBMOD_NONE)
/// {
///     // Model loading failed!
///     exit;
/// }
///
/// // Destroy and unassign an existing model
/// bbmod_model_destroy(model);
/// model = BBMOD_NONE;
/// ```
#macro BBMOD_NONE undefined

/// @func bbmod_load(_file[, _sha1])
/// @desc Loads a model/animation from a BBMOD/BBANIM file.
/// @param {string} _file The path to the file.
/// @param {string} [_sha1] Expected SHA1 of the file. If the actual one does
/// not match with this, then the model will not be loaded.
/// @return {BBMOD_Model/BBMOD_Animation/BBMOD_NONE} The loaded model/animation on success or
/// {@link BBMOD_NONE} on fail.
/// @deprecated This function is deprecated. Please use {@link BBMOD_Model}
/// and {@link BBMOD_Animation} instead to load resources.
function bbmod_load(_file, _sha1)
{
	var _ext = filename_ext(_file);

	if (_ext == ".bbmod")
	{
		try
		{
			return new BBMOD_Model(_file, _sha1);
		}
		catch (e)
		{
			return BBMOD_NONE;
		}
	}

	if (_ext == ".bbanim")
	{
		try
		{
			return new BBMOD_Animation(_file, _sha1);
		}
		catch (e)
		{
			return BBMOD_NONE;
		}
	}

	return BBMOD_NONE;
}