/// @var {Array<Struct.BBMOD_ReflectionProbe>}
/// @private
global.__bbmodReflectionProbes = [];

/// @var {Pointer.Texture}
/// @private
global.__bbmodReflectionProbeTexture = pointer_null;

/// @func BBMOD_ReflectionProbe([_position[, _sprite]])
///
/// @extends BBMOD_Class
///
/// @desc
///
/// @param {Struct.BBMOD_Vec3} [_position]
/// @param {Asset.GMSprite} [_sprite]
///
/// @see bbmod_reflection_probe_add
/// @see bbmod_reflection_probe_count
/// @see bbmod_reflection_probe_get
/// @see bbmod_reflection_probe_remove
/// @see bbmod_reflection_probe_remove_index
/// @see bbmod_reflection_probe_clear
function BBMOD_ReflectionProbe(_position=undefined, _sprite=undefined)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Class_destroy = destroy;

	/// @var {Bool}
	Enabled = true;

	/// @var {Struct.BBMOD_Vec3}
	/// @readonly
	/// @see BBMOD_ReflectionProbe.set_position
	Position = _position ?? new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3}
	/// @readonly
	/// @see BBMOD_ReflectionProbe.set_size
	Size = new BBMOD_Vec3(0.5);

	/// @var {Bool}
	/// @private
	__positionSizeChanged = true;

	/// @var {Asset.GMSprite}
	/// @readonly
	/// @see BBMOD_ReflectionProbe.set_sprite
	Sprite = _sprite;

	/// @var {Real}
	Resolution = (_sprite != undefined) ? sprite_get_height(_sprite) : 128;

	/// @var {Bool}
	NeedsUpdate = (_sprite == undefined);

	/// @var {Bool}
	HDR = false;

	/// @func set_position(_position)
	///
	/// @desc
	///
	/// @param {Struct.BBMOD_Vec3} _position
	///
	/// @return {Struct.BBMOD_ReflectionProbe} Returns `self`.
	static set_position = function (_position) {
		Position = _position;
		__positionSizeChanged = true;
		return self;
	};

	/// @func set_size(_size)
	///
	/// @desc
	///
	/// @param {Struct.BBMOD_Vec3} _size
	///
	/// @return {Struct.BBMOD_ReflectionProbe} Returns `self`.
	static set_size = function (_size) {
		Size = _size;
		__positionSizeChanged = true;
		return self;
	};

	/// @func set_sprite(_sprite)
	///
	/// @desc
	///
	/// @param {Asset.GMSprite} _sprite
	///
	/// @return {Struct.BBMOD_ReflectionProbe} Returns `self`.
	static set_sprite = function (_sprite) {
		if (Sprite != undefined)
		{
			sprite_delete(Sprite);
		}
		Sprite = _sprite;
		return self;
	};

	static destroy = function () {
		Class_destroy();
		if (Sprite != undefined)
		{
			sprite_delete(Sprite);
		}
		return undefined;
	};
}

/// @func bbmod_reflection_probe_add(_reflectionProbe)
///
/// @desc Adds a reflection probe to be sent to shaders.
///
/// @param {Struct.BBMOD_ReflectionProbe} _reflectionProbe The reflection probe.
///
/// @see bbmod_reflection_probe_add
/// @see bbmod_reflection_probe_count
/// @see bbmod_reflection_probe_get
/// @see bbmod_reflection_probe_find
/// @see bbmod_reflection_probe_remove
/// @see bbmod_reflection_probe_remove_index
/// @see bbmod_reflection_probe_clear
function bbmod_reflection_probe_add(_reflectionProbe)
{
	gml_pragma("forceinline");
	array_push(global.__bbmodReflectionProbes, _reflectionProbe);
}

/// @func bbmod_reflection_probe_count()
///
/// @desc Retrieves number of reflection probes added to be sent to shaders.
///
/// @return {Real} The number of reflection probes added to be sent to shaders.
///
/// @see bbmod_reflection_probe_add
/// @see bbmod_reflection_probe_get
/// @see bbmod_reflection_probe_find
/// @see bbmod_reflection_probe_remove
/// @see bbmod_reflection_probe_remove_index
/// @see bbmod_reflection_probe_clear
function bbmod_reflection_probe_count()
{
	gml_pragma("forceinline");
	return array_length(global.__bbmodReflectionProbes);
}

/// @func bbmod_reflection_probe_get(_index)
///
/// @desc Retrieves a reflection probe at given index.
///
/// @param {Real} _index The index of the reflection probe.
///
/// @return {Struct.BBMOD_ReflectionProbe} The reflection probe.
///
/// @see bbmod_reflection_probe_add
/// @see bbmod_reflection_probe_count
/// @see bbmod_reflection_probe_find
/// @see bbmod_reflection_probe_remove
/// @see bbmod_reflection_probe_remove_index
/// @see bbmod_reflection_probe_clear
function bbmod_reflection_probe_get(_index)
{
	gml_pragma("forceinline");
	return global.__bbmodReflectionProbes[_index];
}

/// @func bbmod_reflection_probe_find(_position)
///
/// @desc Finds a reflection probe at given position.
///
/// @param {Struct.BBMOD_Vec3} _position The position to find a reflection probe at.
///
/// @return {Struct.BBMOD_ReflectionProbe} The found reflection probe or `undefined`.
///
/// @see bbmod_reflection_probe_add
/// @see bbmod_reflection_probe_count
/// @see bbmod_reflection_probe_get
/// @see bbmod_reflection_probe_remove
/// @see bbmod_reflection_probe_remove_index
/// @see bbmod_reflection_probe_clear
function bbmod_reflection_probe_find(_position)
{
	gml_pragma("forceinline");
	var _reflectionProbes = global.__bbmodReflectionProbes;
	var i = 0;
	repeat (array_length(_reflectionProbes))
	{
		with (_reflectionProbes[i])
		{
			if (!Enabled)
			{
				continue;
			}
			var _min = Position.Sub(Size);
			var _max = Position.Add(Size);
			if (_position.X < _min.X || _position.X > _max.X
				|| _position.Y < _min.Y || _position.Y > _max.Y
				|| _position.Z < _min.Z || _position.Z > _max.Z)
			{
				continue;
			}
			return self;
		}
		++i;
	}
	return undefined;
}

/// @func bbmod_reflection_probe_remove(_reflectionProbe)
///
/// @desc Removes a reflection probe so it is not sent to shaders anymore.
///
/// @param {Struct.BBMOD_ReflectionProbe} _reflectionProbe The reflection probe to remove.
///
/// @return {Bool} Returns `true` if the reflection probe was removed or `false` if it  was not found.
///
/// @see bbmod_reflection_probe_add
/// @see bbmod_reflection_probe_count
/// @see bbmod_reflection_probe_get
/// @see bbmod_reflection_probe_find
/// @see bbmod_reflection_probe_remove_index
/// @see bbmod_reflection_probe_clear
function bbmod_reflection_probe_remove(_reflectionProbe)
{
	gml_pragma("forceinline");
	var _reflectionProbes = global.__bbmodReflectionProbes;
	var i = 0;
	repeat (array_length(_reflectionProbes))
	{
		if (_reflectionProbes[i] == _reflectionProbe)
		{
			array_delete(_reflectionProbes, i, 1);
			return true;
		}
		++i;
	}
	return false;
}

/// @func bbmod_reflection_probe_remove_index(_index)
///
/// @desc Removes a reflection probe so it is not sent to shaders anymore.
///
/// @param {Real} _index The index to remove the reflection probe at.
///
/// @return {Bool} Always returns `true`.
///
/// @see bbmod_reflection_probe_add
/// @see bbmod_reflection_probe_count
/// @see bbmod_reflection_probe_get
/// @see bbmod_reflection_probe_find
/// @see bbmod_reflection_probe_remove
/// @see bbmod_reflection_probe_clear
function bbmod_reflection_probe_remove_index(_index)
{
	gml_pragma("forceinline");
	array_delete(global.__bbmodReflectionProbes, _index, 1);
	return true;
}

/// @func bbmod_reflection_probe_clear()
///
/// @desc Removes all reflection probes sent to shaders.
///
/// @see bbmod_reflection_probe_add
/// @see bbmod_reflection_probe_count
/// @see bbmod_reflection_probe_get
/// @see bbmod_reflection_probe_find
/// @see bbmod_reflection_probe_remove
/// @see bbmod_reflection_probe_remove_index
function bbmod_reflection_probe_clear()
{
	gml_pragma("forceinline");
	global.__bbmodReflectionProbes = [];
}
