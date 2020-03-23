/// @func b_bbmod_load(file[, sha1])
/// @desc Loads a model/animation from a BBMOD/BBANIM file.
/// @param {string} file The path to the file.
/// @param {string} [sha1] Expected SHA1 of the file. If the actual one
/// does not match with this, then the model will not be loaded. Default is
/// `undefined`.
/// @return {array/B_BBMOD_NONE} The loaded model/animation on success or
/// `B_BBMOD_NONE` on fail.
var _file = argument[0];
var _sha1 = (argument_count > 2) ? argument[2] : undefined;
var _bbmod = B_BBMOD_NONE;

if (!is_undefined(_sha1))
{
	if (sha1_file(_file) != _sha1)
	{
		return _bbmod;
	}
}

var _buffer = buffer_load(_file);
buffer_seek(_buffer, buffer_seek_start, 0);

var _type = buffer_read(_buffer, buffer_string);
var _version = buffer_read(_buffer, buffer_u8);

if (_version == 1)
{
	switch (_type)
	{
	case "bbmod":
		_bbmod = b_bbmod_model_load(_buffer, _version);
		break;

	case "bbanim":
		_bbmod = b_bbmod_animation_load(_buffer, _version);
		break;

	default:
		break;
	}
}

buffer_delete(_buffer);

return _bbmod;