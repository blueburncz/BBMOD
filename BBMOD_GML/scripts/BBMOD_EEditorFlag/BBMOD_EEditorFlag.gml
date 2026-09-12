/// @module Editor

/// @enum Editor transform capabilities and edit-complete side effects.
enum BBMOD_EEditorFlag
{
	/// @member The struct can be translated.
	Translate = 1,
		/// @member The struct can be rotated.
		Rotate = 2,
		/// @member The struct can be scaled.
		Scale = 4,
		/// @member Transform edits refresh reflection probes.
		RefreshReflectionProbes = 8,
		/// @member Total number of members of this enum.
		SIZE,
}
