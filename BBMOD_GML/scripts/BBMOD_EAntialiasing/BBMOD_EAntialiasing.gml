/// @module Rendering.PostProcessing

/// @enum Enumeration of anti-aliasing techniques.
/// @deprecated Please use {@link BBMOD_FXAAEffect} instead.
enum BBMOD_EAntialiasing
{
	/// @member Anti-aliasing is turned off.
	None,
	/// @member Use fast approximate anti-aliasing.
	/// Requires the [FXAA submodule](./FXAASubmodule.html)!
	FXAA,
};
