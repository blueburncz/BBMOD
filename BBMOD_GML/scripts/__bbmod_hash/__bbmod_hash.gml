/// @module Core

/// @func bbmod_hash_combine(_hash1, _hash2)
///
/// @desc Combines two hashes into a new hash.
///
/// @param {Any} _hash1 The first hash.
/// @param {Any} _hash2 The second hash.
///
/// @return {Real} The combination of the two hashes.
function bbmod_hash_combine(_hash1, _hash2)
{
	gml_pragma("forceinline");
	_hash1 = int64(_hash1);
	return (_hash1 ^ (int64(_hash2) + 0x9E3779B9 + (_hash1 << 6) + (_hash1 >> 2)));
}

/// @func bbmod_hash_array(_array)
///
/// @desc Uses {@link bbmod_hash_combine} to combine all entries of given array
/// into a single hash. Supports nested
/// arrays.
///
/// @param {Array} _array The target array.
///
/// @return {Real} The created hash.
function bbmod_hash_array(_array)
{
	gml_pragma("forceinline");
	var _hash = 0;
	var _index = 0;
	repeat(array_length(_array))
	{
		var _value = _array[_index++];
		_hash = bbmod_hash_combine(_hash, is_array(_value) ? bbmod_hash_array(_value) : _value);
	}
	return _hash;
}
