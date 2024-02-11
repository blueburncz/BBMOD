/// @module LensFlares

/// @func BBMOD_LensFlareElement(_offset, _sprite[, _subimage])
///
/// @desc A lens flare element.
///
/// @param {Struct.BBMOD_Vec2} _offset
/// @param {Asset.GMSprite} _sprite
/// @param {Real} [_subimage]
///
/// @see BBMOD_LensFlare
function BBMOD_LensFlareElement(_offset, _sprite, _subimage=0) constructor
{
	/// @var {Struct.BBMOD_Vec2}
	Offset = _offset;

	/// @var {Asset.GMSprite}
	Sprite = _sprite;

	/// @var {Real} Default value is 0.
	Subimage = _subimage;

	/// @var {Struct.BBMOD_Vec2} Default value is `(1, 1)`.
	Scale = new BBMOD_Vec2(1.0);

	/// @var {Struct.BBMOD_Color} Default value is {@link BBMOD_C_WHITE}.
	Color = BBMOD_C_WHITE;

	/// @var {Real} Default value is 0.
	Angle = 0.0;

	/// @var {Bool} Default value is `false`.
	AngleRelative = false;

	/// @var {Constant.BlendMode} Default value is `bm_add`.
	BlendMode = bm_add;

	/// @var {Bool} Default value is `false`.
	FadeOut = false;

	/// @var {Bool} Default value is `false`.
	FlareRays = false;
}
