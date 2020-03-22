/// @func b_bbmod_load(file[, sha1])
/// @desc Loads a model from a BBMOD version 1 file.
/// @param {string} file The path to the BBMOD file.
/// @param {string} [sha1] Expected SHA1 of the BBMOD file. If the actual one
/// does not match with this, then the model will not be loaded. Default is
/// `undefined`.
/// @return {array/B_BBMOD_NONE} The loaded model on success or `B_BBMOD_NONE` on fail.
var _file = argument[0];
var _sha1 = (argument_count > 2) ? argument[2] : undefined;

if (!is_undefined(_sha1))
{
	if (sha1_file(_file) != _sha1)
	{
		return -1;
	}
}

var _bbmod = B_BBMOD_NONE;
var _buffer = buffer_load(_file);
buffer_seek(_buffer, buffer_seek_start, 0);

var _type = buffer_read(_buffer, buffer_string);
var _version = buffer_read(_buffer, buffer_u8);

if (_version == 1)
{
	switch (_type)
	{
	case "bbmod":
		_bbmod = b_bbmod_load_(_buffer);
		break;

	case "bbanim":
		_bbmod = b_bbmod_animation_load(_buffer);
		break;

	default:
		break;
	}
}

buffer_delete(_buffer);

return _bbmod;