/// @macro {real}
/// @private
#macro BBMOD_RGBM_RANGE 6.0

/// @macro {real} The maximum value of a single channel when using RGBM encoded
/// colors. This is always at least 255.
#macro BBMOD_RGBM_VALUE_MAX (255.0 * BBMOD_RGBM_RANGE)

/// @func BBMOD_Color([_red, _green, _blue])
/// @desc A color with support for high dynamic range.
/// @param {real} [_red] The value of the red channel. Use values in range
/// 0..`BBMOD_RGBM_VALUE_MAX`. Defaults to 255.
/// @param {real} [_green] The value of the green channel. Use values in range
/// 0..`BBMOD_RGBM_VALUE_MAX`. Defaults to 255.
/// @param {real} [_blue] The value of the blue channel. Use values in range
/// 0..`BBMOD_RGBM_VALUE_MAX`. Defaults to 255.
/// @param {real} [_alpha] The value of the alpha channel. Use values in range 0..1.
/// Defaults to 1.
/// @see BBMOD_RGBM_VALUE_MAX
function BBMOD_Color(_red=255.0, _green=255.0, _blue=255.0, _alpha=1.0) constructor
{
	/// @var {real} The value of the red color channel.
	Red = _red;

	/// @var {real} The value of the green color channel.
	Green = _green;

	/// @var {real} The value of the blue color channel.
	Blue = _blue;

	/// @var {real} The value of the alpha channel.
	Alpha = _alpha;

	/// @func FromConstant(_color)
	/// @desc Initializes the color using a color constant.
	/// @param {uint} _color The color constant.
	/// @return {BBMOD_Color} Returns `self`.
	/// @example
	/// ```gml
	/// var _red = new BBMOD_Color().FromConstant(c_red);
	/// ```
	static FromConstant = function (_color) {
		gml_pragma("forceinline");
		Red = color_get_red(_color);
		Green = color_get_green(_color);
		Blue = color_get_blue(_color);
		return self;
	};

	/// @func FromRGBA(_red, _green, _blue[, _alpha])
	/// @desc Initializes the color using RGBA.
	/// @param {real} _red The value of the red channel. Use values in range
	/// 0..`BBMOD_RGBM_VALUE_MAX`.
	/// @param {real} _green The value of the green channel. Use values in range
	/// 0..`BBMOD_RGBM_VALUE_MAX`.
	/// @param {real} _blue The value of the blue channel. Use values in range
	/// 0..`BBMOD_RGBM_VALUE_MAX`.
	/// @param {real} [_alpha] The value of the alpha channel. Defaults to 1.
	/// @return {BBMOD_Color} Returns `self`.
	static FromRGBA = function (_red, _green, _blue, _alpha=1.0) {
		gml_pragma("forceinline");
		Red = _red;
		Green = _green;
		Blue = _blue;
		Alpha = _alpha;
		return self;
	};

	/// @func FromHSV(_hue, _saturation, _value)
	/// @desc Initializes the color using HSV. Alpha channel is set to 1.
	/// @param {real} _hue Color hue. Use values in range 0..255.
	/// @param {real} _saturation Color saturation. Use values in range 0..255.
	/// @param {real} _value Color value. Use values in range 0..255.
	/// @return {BBMOD_Color} Returns `self`.
	static FromHSV = function (_hue, _saturation, _value) {
		gml_pragma("forceinline");
		var _hsv = make_color_hsv(_hue, _saturation, _value);
		Red = color_get_red(_hsv);
		Green = color_get_green(_hsv);
		Blue = color_get_blue(_hsv);
		Alpha = 1.0;
		return self;
	};

	/// @func Mix(_color, _factor)
	/// @desc Mixes two colors.
	/// @param {BBMOD_Color} _color The other color to mix this one with.
	/// @param {real} _factor The mixing factor. Use values in range 0..1,
	/// where 0 would result into this color, 1 would be the other color and
	/// 0.5 would return a merge of both colors equally.
	/// @return {BBMOD_Color} The new color.
	static Mix = function (_color, _factor) {
		gml_pragma("forceinline");
		return new BBMOD_Color(
			lerp(Red, Color.Red, _factor),
			lerp(Green, Color.Green, _factor),
			lerp(Blue, Color.Blue, _factor),
			lerp(Alpha, Color.Alpha, _factor));
	};

	/// @func ToConstant()
	/// @desc Encodes the color into a single value, compatible with the GM
	/// color constants. Ignores the alpha channel.
	/// @return {uint} The color as a single value.
	/// @example
	/// ```gml
	/// var _red = new BBMOD_Color(255, 0, 0);
	/// show_debug_message(_red.ToConstant() == c_red); // Prints true
	/// ```
	static ToConstant = function () {
		gml_pragma("forceinline");
		return make_color_rgb(Red, Green, Blue);
	};

	/// @func ToHSV([_array[, _index]])
	/// @desc Encodes the color into HSV format, ignoring the alpha channel.
	/// @param {real[]} [_array] The array to output the values to. A new one
	/// is created if not defined.
	/// @param {uint} [_index] The index to start writing the values to. Defaults
	/// to 0.
	/// @return {real[]} Returns the array with HSV values.
	static ToHSV = function (_array, _index) {
		gml_pragma("forceinline");
		_array = (_array != undefined) ? _array : array_create(3, 0);
		_index = (_index != undefined) ? _index : 0;
		var _rgb = make_color_rgb(Red, Green, Blue);
		_array[@ _index] = color_get_hue(_rgb);
		_array[@ _index + 1] = color_get_saturation(_rgb);
		_array[@ _index + 2] = color_get_value(_rgb);
		return _array;
	};

	/// @func ToRGBM([_array[, _index]])
	/// @desc Encodes the color into RGBM format, ignoring the alpha channel.
	/// @param {real[]} [_array] The array to output the values to. A new one
	/// is created if not defined.
	/// @param {uint} [_index] The index to start writing the values to. Defaults
	/// to 0.
	/// @return {real[]} Returns the array with RGBM values.
	static ToRGBM = function (_array, _index) {
		gml_pragma("forceinline");
		_array = (_array != undefined) ? _array : array_create(4, 0);
		_index = (_index != undefined) ? _index : 0;
		var _red = min(Red / BBMOD_RGBM_VALUE_MAX, 1.0);
		var _green = min(Green / BBMOD_RGBM_VALUE_MAX, 1.0);
		var _blue = min(Blue / BBMOD_RGBM_VALUE_MAX, 1.0);
		var _alpha = clamp(max(_red, _green, _blue, 0.000001), 0.0, 1.0);
		_alpha = ceil(_alpha * 255.0) / 255.0;
		_array[@ _index] = _red / _alpha;
		_array[@ _index + 1] = _green / _alpha;
		_array[@ _index + 2] = _blue / _alpha;
		_array[@ _index + 3] = _alpha;
		return _array;
	};
}