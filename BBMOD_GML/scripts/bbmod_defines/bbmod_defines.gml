/// @macro {int} The supported version of BBMOD and BBANIM files.
#macro BBMOD_VERSION 3

/// @macro {undefined} An empty value.
#macro BBMOD_NONE undefined

/// @macro {real} A value used to tell that no normals should be generated
/// if the model does not have any.
/// @see BBMOD_NORMALS_FLAT
/// @see BBMOD_NORMALS_SMOOTH
#macro BBMOD_NORMALS_NONE 0

/// @macro {real} A value used to tell that flat normals should be generated
/// if the model does not have any.
/// @see BBMOD_NORMALS_NONE
/// @see BBMOD_NORMALS_SMOOTH
#macro BBMOD_NORMALS_FLAT 1

/// @macro {real} A value used to tell that smooth normals should be generated
/// if the model does not have any.
/// @see BBMOD_NORMALS_NONE
/// @see BBMOD_NORMALS_FLAT
#macro BBMOD_NORMALS_SMOOTH 2