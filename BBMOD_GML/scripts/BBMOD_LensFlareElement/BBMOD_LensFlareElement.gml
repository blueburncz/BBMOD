/// @module PostProcessing

/// @func BBMOD_LensFlareElement([_sprite[, _subimage[, _offset[, _scale[, _scaleByDistanceMin[, _scaleByDistanceMax[, _color[, _applyTint[, _angle[, _angleRelative[, _fadeOut[, _applyStarburst]]]]]]]]]]]])
///
/// @desc A single lens flare element (sprite).
///
/// @param {Asset.GMSprite} [_sprite] The sprite of the lens flare element.
/// Defaults to `BBMOD_SprLensFlareGhost`.
/// @param {Real} [_subimage] The sprite subimage. Defaults to 0.
/// @param {Struct.BBMOD_Vec2} [_offset] The offset from the lights position on
/// the screen, where `(0, 0)` is the light's position, `(0.5, 0.5)` is the
/// screen center and `(1, 1)` is the lights position inverted around the screen
/// center. Defaults to `(0, 0)` if `undefined`.
/// @param {Struct.BBMOD_Vec2} [_scale] The scale of the lens flare sprite.
/// Defaults to `(1, 1)` if `undefined`.
/// @param {Struct.BBMOD_Vec2} [_scaleByDistanceMin] Scale multiplier when the
/// lens flare's normalized distance from the light's position on screen is 0.
/// Defaults to `(1, 1)` if `undefined`.
/// @param {Struct.BBMOD_Vec2} [_scaleByDistanceMax] Scale multiplier when the
/// lens flare's normalized distance from the light's position on screen is 1.
/// Defaults to `(1, 1)` if `undefined`.
/// @param {Struct.BBMOD_Color} [_color] The color of the lens flare. Defaults
/// to {@link BBMOD_C_WHITE} if `undefined`.
/// @param {Bool} [_applyTint] If `true` then {@link BBMOD_LensFlare.Tint} is
/// applied to `Color`. Defaults to `true`.
/// @param {Real} [_angle] The rotation of the lens flare. Defaults to 0.
/// @param {Bool} [_angleRelative] If `true` then the lens flare angle is
/// relative to the direction to the light's position on screen. Defaults to
/// `false`.
/// @param {Bool} [_fadeOut] Whether to fade out the lens flare on screen edges.
/// Defaults to `false`.
/// @param {Bool} [_applyStarburst] Whether to apply starburst. Defaults to
/// `false`.
///
/// @see BBMOD_LensFlare
/// @see BBMOD_PostProcessor.Starburst
function BBMOD_LensFlareElement(
	_sprite=BBMOD_SprLensFlareGhost,
	_subimage=0,
	_offset=undefined,
	_scale=undefined,
	_scaleByDistanceMin=undefined,
	_scaleByDistanceMax=undefined,
	_color=undefined,
	_applyTint=false,
	_angle=0.0,
	_angleRelative=false,
	_fadeOut=false,
	_applyStarburst=false
) constructor
{
	/// @var {Asset.GMSprite} The sprite of the lens flare element. Default
	/// value is `BBMOD_SprLensFlareGhost`.
	Sprite = _sprite;

	/// @var {Real} The sprite subimage. Default value is 0.
	Subimage = _subimage;

	/// @var {Struct.BBMOD_Vec2} The offset from the lights position on the
	/// screen, where `(0, 0)` is the light's position, `(0.5, 0.5)` is the
	/// screen center and `(1, 1)` is the lights position inverted around the
	/// screen center. Default value is `(0, 0)`.
	Offset = _offset ?? new BBMOD_Vec2();

	/// @var {Struct.BBMOD_Vec2} The scale of the lens flare sprite. Default
	/// value is to `(1, 1)`.
	Scale = _scale ?? new BBMOD_Vec2(1.0);

	/// @var {Struct.BBMOD_Vec2} Scale multiplier when the lens flare's
	/// normalized distance from the light's position on screen is 0. Default
	/// value is `(1, 1)`.
	ScaleByDistanceMin = _scaleByDistanceMin ?? new BBMOD_Vec2(1.0);

	/// @var {Struct.BBMOD_Vec2} Scale multiplier when the lens flare's
	/// normalized distance from the light's position on screen is 1. Default
	/// value is `(1, 1)`.
	ScaleByDistanceMax = _scaleByDistanceMax ?? new BBMOD_Vec2(1.0);

	/// @var {Struct.BBMOD_Color} The color of the lens flare. Default value is
	/// {@link BBMOD_C_WHITE}.
	Color = _color ?? BBMOD_C_WHITE;

	/// @var {Bool} If `true` then {@link BBMOD_LensFlare.Tint} is applied to
	/// `Color`. Default value is `true`.
	/// @see BBMOD_LensFlareElement.Color
	ApplyTint = true;

	/// @var {Real} The rotation of the lens flare. Default value is 0.
	Angle = _angle;

	/// @var {Bool} If `true` then the lens flare angle is relative to the
	/// direction to the light's position on screen. Default value is `false`.
	AngleRelative = _angleRelative;

	/// @var {Bool} Whether to fade out the lens flare on screen edges. Default
	/// value is `false`.
	FadeOut = _fadeOut;

	/// @var {Bool} Whether to apply starburst. Default value is `false`.
	ApplyStarburst = _applyStarburst;
}
