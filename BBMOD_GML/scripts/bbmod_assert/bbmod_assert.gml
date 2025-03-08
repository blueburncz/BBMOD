/// @func bbmod_assert(_expr[, _error])
///
/// @desc Show an error if given expression is false and quits the game.
///
/// @param {Bool} _expr The expression to check.
/// @param {String} _error The error message to show.
function bbmod_assert(_expr, _error = "")
{
	gml_pragma("forceinline");
	if (!_expr)
	{
		show_error(_error, true);
	}
}
