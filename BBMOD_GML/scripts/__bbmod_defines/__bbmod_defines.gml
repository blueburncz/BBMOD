/// @module Core

////////////////////////////////////////////////////////////////////////////////
//
// BBMOD release version
//

/// @macro {Real} The major version number of this BBMOD release.
#macro BBMOD_RELEASE_MAJOR 3

/// @macro {Real} The minor version number of this BBMOD release.
#macro BBMOD_RELEASE_MINOR 20

/// @macro {Real} The patch version number of this BBMOD release.
#macro BBMOD_RELEASE_PATCH 0

/// @macro {String} The version of this BBMOD release as a string ("major.minor.patch" format).
#macro BBMOD_RELEASE_STRING $"{BBMOD_RELEASE_MAJOR}.{BBMOD_RELEASE_MINOR}.{BBMOD_RELEASE_PATCH}"

////////////////////////////////////////////////////////////////////////////////
//
// File format versioning
//

/// @macro {Real} The supported major version of BBMOD and BBANIM files.
/// @see BBMOD_VERSION_MINOR
#macro BBMOD_VERSION_MAJOR 3

/// @macro {Real} The current minor version of BBMOD and BBANIM files.
/// @see BBMOD_VERSION_MAJOR
#macro BBMOD_VERSION_MINOR 4

////////////////////////////////////////////////////////////////////////////////
//
// Vertex normals generation
//

/// @macro {Real} A value used to tell that no normals should be generated
/// if the model does not have any.
/// @see BBMOD_NORMALS_FLAT
/// @see BBMOD_NORMALS_SMOOTH
#macro BBMOD_NORMALS_NONE 0

/// @macro {Real} A value used to tell that flat normals should be generated
/// if the model does not have any.
/// @see BBMOD_NORMALS_NONE
/// @see BBMOD_NORMALS_SMOOTH
#macro BBMOD_NORMALS_FLAT 1

/// @macro {Real} A value used to tell that smooth normals should be generated
/// if the model does not have any.
/// @see BBMOD_NORMALS_NONE
/// @see BBMOD_NORMALS_FLAT
#macro BBMOD_NORMALS_SMOOTH 2
