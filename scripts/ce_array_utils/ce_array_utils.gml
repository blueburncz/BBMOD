CE_PRAGMA_ONCE;

/// @func ce_array_clear(_array, _value)
/// @desc Replaces all values in an array with given value.
/// @param {array} _array The array.
/// @param {any} _value The new value.
function ce_array_clear(_array, _value)
{
	var i = 0;
	repeat (array_length(_array))
	{
		_array[@ i++] = _value;
	}
}

/// @func ce_array_clear_range(_array, _from, _to, _value)
/// @desc Replaces values at indices within specified range with given value.
/// @param {array} _array The array.
/// @param {real} _from The starting index.
/// @param {real} _to The ending index.
/// @param {any} _value The new value.
/// @example
/// ```gml
/// var _array = [1, 2, 3, 4, 5];
/// ce_array_clear_range(_array, 1, 3, 0);
/// // _array is now [1, 0, 0, 0, 5]
/// ```
function ce_array_clear_range(_array, _from, _to, _value)
{
	for (var i = _from; i <= _to; ++i)
	{
		_array[@ i] = _value;
	}
}

/// @func ce_array_clone(_array)
/// @desc Creates a shallow copy of the array.
/// @param {array} _array The array to copy.
/// @return {array} The created array.
function ce_array_clone(_array)
{
	var _size = array_length(_array);
	var _clone = array_create(_size, 0);
	array_copy(_clone, 0, _array, 0, _size);
	return _clone;
}

/// @func ce_array_create_range(_from, _to)
/// @desc Creates a new array with values in range <_from, _to>.
/// @param {int} _from The starting value. Must be less or equal to argument to.
/// @param {int} _to The ending value. Must be greater or equal to argument from.
/// @return {array} The created array.
/// @example
/// This will create an array `[2, 3, 4, 5, 6]`.
/// ```gml
/// var _arr = ce_array_create_range(2, 6);
/// ```
function ce_array_create_range(_from, _to)
{
	var _size = _to - _from + 1;
	var _array = array_create(_size, 0);
	var i = 0;
	repeat (_size)
	{
		_array[@ i] = _from++;
	}
	return _array;
}

/// @func ce_array_filter(_array, _callback)
/// @desc Creates a new array containing values from the given array for which the
/// callback script returns true.
/// @param {array} _array The array to filter.
/// @param {function} _callback A script that returns `true` to keep the value or
/// `false` to discard it. Takes the original value as the first argument and
/// optionally its index as the second argument.
/// @example
/// This code creates a new array `[0, 2, 4]`.
/// ```gml
/// var _even = ce_array_filter([0, 1, 2, 3, 4], ce_real_is_even);
/// ```
function ce_array_filter(_array, _callback)
{
	var _size = array_length(_array);
	var _temp = array_create(_size, 0);
	var i = 0;
	var j = 0;
	repeat (_size)
	{
		var _val = _array[i];
		if (_callback(_val, i))
		{
			_temp[j++] = _val;
		}
	}
	var _filtered = array_create(j, 0);
	array_copy(_filtered, 0, _temp, 0, j);
	return _filtered;
}

/// @func ce_array_find_index(_array, _value)
/// @desc Finds index at which the array contains the value.
/// @param {array} _array The array to search in.
/// @param {any} _value The value to search for.
/// @return {real} The index at which the value was found or -1 if the array does
/// not contain the value.
function ce_array_find_index(_array, _value)
{
	var i = 0;
	repeat (array_length(_array))
	{
		if (_array[i] == _value)
		{
			return i;
		}
		++i;
	}
	return -1;
}

/// @func ce_array_find_index_last(_array, _value)
/// @desc Finds the last index at which the array contains the value.
/// @param {array} _array The array to search in.
/// @param {any} _value The value to search for.
/// @return {real} The index at which the value was found or -1 if the array does
/// not contain the value.
function ce_array_find_index_last(_array, _value)
{
	var _size = array_length(_array);
	var i = _size - 1;
	repeat (_size)
	{
		if (_array[i] == _value)
		{
			return i;
		}
		--i;
	}
	return -1;
}

/// @func ce_array_foreach(_array, _callback)
/// @desc Executes a function for each value in an array.
/// @param {array} _array The array.
/// @param {function} _callback The function to execute. It will be given two
/// arguments - the array item and its index in the array.
/// @example
/// Following code will print out array values and their indices to the console.
/// ```gml
/// ce_array_foreach([1, 2, 3], method(undefined, function (_value, _index) {
///     show_debug_message("value: " + string(_value) + ", "
///         + "index: " + string(_index));
/// }));
/// ```
function ce_array_foreach(_array, _callback)
{
	gml_pragma("forceinline");
	var i = 0;
	repeat (array_length(_array))
	{
		_callback(_array[i], i);
		++i;
	}
}

/// @func ce_array_get(_array, _index[, _default])
/// @desc Retrieves a value at given index of an array.
/// @param {array} _array The array.
/// @param {real} _index The index.
/// @param {any} [_default] The default value.
/// @return {any} Value at given index or the default value if is specified and
/// the index does not exist.
/// @example
/// ```gml
/// var _array = [1, 2];
/// ce_array_get(_array, 0); // => 1
/// ce_array_get(_array, 1, 1); // => 2
/// ce_array_get(_array, 2, 3); // => 3
/// ce_array_get(_array, 2); // ERROR!
/// ```
function ce_array_get(_array, _index)
{
	var _size = array_length(_array);
	if (argument_count > 2
		&& (_index < 0 || _index >= _size))
	{
		return argument[2];
	}
	return _array[_index];
}

/// @func ce_array_intelligent_design_sort(_array)
/// @desc Sorts the array in-place in $$O(1)$$ time using the Intelligent Design
/// Sort algorithm. Praise the Sorter!
/// @param {array} array The array to sort.
/// @source http://www.dangermouse.net/esoteric/intelligentdesignsort.html
function ce_array_intelligent_design_sort(_array)
{
}

/// @func ce_array_map(_array, _callback)
/// @desc Creates a new array containing the results of calling the script on
/// every value in the given array.
/// @param {array} _array The array to map.
/// @param {function} _callback The script that produces a value of the new
/// array taking the original value as the first argument and optionally its
/// index as the second argument.
function ce_array_map(_array, _callback)
{
	var _size = array_length(_array);
	var _mapped = array_create(_size, 0)
	var i = 0;
	repeat (_size)
	{
		_mapped[i] = _callback(_array[i], i);
		++i;
	}
	return _mapped;
}

/// @func ce_array_merge(_a1, _a2)
/// @desc Merges two arrays into a new one, appending values from the second
/// array to the end of the first array.
/// @param {array} _a1 The first array.
/// @param {array} _a2 The second array.
/// @return {array} The created array.
/// @example
/// The array `_a3` will contain values values `1, 2, 3, 3, 4, 5`.
/// ```gml
/// var _a1 = [1, 2, 3];
/// var _a2 = [3, 4, 5];
/// var _a3 = ce_array_merge(_a1, _a2);
/// ```
function ce_array_merge(_a1, _a2)
{
	var _s1 = array_length(_a1);
	var _s2 = array_length(_a2);
	var _merged = array_create(_s1 + _s2, 0);
	array_copy(_merged, 0, _a1, 0, _s1);
	array_copy(_merged, _s1, _a2, 0, _s2);
	return _merged;
}

/// @func ce_array_reduce(_array, _callback[, _initial_value])
/// @desc Reduces the array from left to right, applying the callback script on
/// each value, resulting into a single value.
/// @param {array} _array The array to reduce.
/// @param {function} _callback The reducer function. It takes the accumulator (which
/// is the `initial_value` at start) as the first argument, the current value as
/// the second argument and optionally the current index as the third argument.
/// @param {any} [_initial_value] The initial value. If not specified, the first
/// value in the array is taken.
/// @return {any} The result of the reduction.
/// @example
/// ```gml
/// // Here the script scr_reduce_add(a, b) returns a + b
/// var _a = [1, 2, 3, 4];
/// var _r1 = ce_array_reduce(_a, scr_reduce_add); // Results to 10
/// var _r2 = ce_array_reduce(_a, scr_reduce_add, 5); // Results to 15
/// ```
/// @see ce_array_reduce_right
function ce_array_reduce(_array, _callback)
{
	var i = 0;
	var _accumulator = (argument_count > 2) ? argument[2] : _array[i++];
	var _size = array_length(_array);
	for (/**/; i < _size; ++i)
	{
		_accumulator = _callback(_accumulator, _array[i], i);
	}
	return _accumulator;
}

/// @func ce_array_reduce_right(_array, _callback[, _initial_value])
/// @desc Reduces the array from right to left, applying the callback script on
/// each value, resulting into a single value.
/// @param {array} _array The array to reduce.
/// @param {function} _callback The reducer function. It takes the accumulator (which
/// is the `initial_value` at start) as the first argument, the current value as
/// the second argument and optionally the current index as the third argument.
/// @param {any} [_initial_value] The initial value. If not specified, the last
/// value in the array is taken.
/// @return {any} The result of the reduction.
/// @example
/// ```gml
/// // Here the script scr_reduce_subtract(a, b) returns a - b
/// var _a = [1, 2, 3, 4];
/// var _r1 = ce_array_reduce(_a, scr_reduce_subtract); // Results to -8
/// var _r2 = ce_array_reduce_right(_a, scr_reduce_subtract); // Results to -2
/// ```
/// @see ce_array_reduce
function ce_array_reduce_right(_array, _callback)
{
	var i = array_length(_array) - 1;
	var _accumulator = (argument_count > 2) ? argument[2] : _array[i--];
	for (/**/; i >= 0; --i)
	{
		_accumulator = _callback(_accumulator, _array[i], i);
	}
	return _accumulator;
}

/// @func ce_array_reverse(_array)
/// @desc Creates a new array with values from the given array, but in a reverse
/// order.
/// @param {array} _array The array to reverse.
/// @return {array} The created array.
/// @example
/// This will create an array `[3, 2, 1]`.
/// ```gml
/// var _reversed = ce_array_reverse([1, 2, 3]);
/// ```
function ce_array_reverse(_array)
{
	var _size = array_length(_array);
	var _reversed = array_create(_size, 0)
	var i = 0;
	repeat (_size)
	{
		_reversed[i] = _array[_size - i - 1];
		++i;
	}
	return _reversed;
}

/// @func ce_array_shuffle(_array)
/// @desc Shuffles the values within the array, ordering them randomly.
/// @param {array} _array The array to shuffle.
function ce_array_shuffle(_array)
{
	var _length = array_length(_array);
	var _length_minus1 = _length - 1;
	var _seed = random_get_seed();
	randomize();
	repeat (_length)
	{
		ce_array_swap(_array, irandom(_length_minus1), irandom(_length_minus1));
	}
	random_set_seed(_seed);
}

/// @func ce_array_sort(_array, _ascending)
/// @desc Sorts the array.
/// @param {array} _array The array to sort.
/// @param {bool} _ascending True to sort the values in ascending order, false
/// for descending.
/// @source https://www.geeksforgeeks.org/iterative-quick-sort/
function ce_array_sort(_array, _ascending)
{
	var _size = array_length(_array);
	var _l = 0;
	var _h = _size - 1;
	var _stack = array_create(_h - _l + 1);
	var _top = -1;

	_stack[++_top] = _l;
	_stack[++_top] = _h;

	while (_top >= 0)
	{
		_h = _stack[_top--];
		_l = _stack[_top--];

		#region Partition
		var _x = _array[_h];
		var i = _l - 1;
		for (var j = _l; j <= _h - 1; ++j)
		{
			if (_ascending
				? _array[j] <= _x
				: _array[j] >= _x)
			{
				++i;
				ce_array_swap(_array, i, j);
			}
		}
		ce_array_swap(_array, i + 1, _h);
		var _p = i + 1;
		#endregion Partition

		if (_p - 1 > _l)
		{
			_stack[++_top] = _l;
			_stack[++_top] = _p - 1;
		}

		if (_p + 1 < _h)
		{
			_stack[++_top] = _p + 1;
			_stack[++_top] = _h ;
		}
	}
}

/// @func ce_array_swap(_array, _i, _j)
/// @desc Swaps values at given indices in the array.
/// @param {array} _array The array to swap values within.
/// @param {real} _i The first index.
/// @param {real} _j The second index.
/// @example
/// ```gml
/// var _array = [1, 2, 3];
/// ce_array_swap(_array, 0, 2); // Swaps 1 and 3, making the array [3, 2, 1].
/// ```
function ce_array_swap(_array, _i, _j)
{
	gml_pragma("forceinline");
	var _temp = _array[_i];
	_array[@ _i] = _array[_j];
	_array[@ _j] = _temp;
}