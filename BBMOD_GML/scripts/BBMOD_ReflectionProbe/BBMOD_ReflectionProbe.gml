/// @module Core

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
/// @desc Used to capture surrounding scene at a specific position into a texture
/// which is then used for reflections.
///
/// @param {Struct.BBMOD_Vec3} [_position] The position of the reflection probe.
/// Defaults to vector `(0, 0, 0)` if `undefined`.
/// @param {Asset.GMSprite} [_sprite] Pre-captured reflection probe sprite. Useful
/// for example if you want to skip your game with pre-baked probes instead of
/// capturing them on runtime. **The sprite is deleted when the probe is re-captured
/// or destroyed!**
///
/// @example
/// A reflection probe object:
/// ```gml
/// /// @desc Create event
/// reflectionProbe = new BBMOD_ReflectionProbe();
/// reflectionProbe.set_position(new BBMOD_Vec3(x, y, z));
/// reflectionProbe.set_size(new BBMOD_Vec3(100, 100, 20));
/// bbmod_reflection_probe_add(reflectionProbe);
///
/// /// @desc Step event
/// if (x != xprevious || y != yprevious || z != zprevious)
/// {
///     // Re-capture the reflection probe if its position changes
///     reflectionProbe.set_position(new BBMOD_Vec3(x, y, z));
///     reflectionProbe.NeedsUpdate = true;
/// }
///
/// /// @desc Clean Up event
/// bbmod_reflection_probe_remove(reflectionProbe);
/// reflectionProbe = reflectionProbe.destroy();
/// ```
///
/// A model captured into reflection probes:
/// ```gml
/// /// @desc Create event
/// material = BBMOD_MATERIAL_DEFAULT.clone();
/// // Add a shader for the ReflectionCapture render pass to make the model
/// // visible during reflection capture!
/// material.set_shader(BBMOD_ERenderPass.ReflectionCapture, BBMOD_SHADER_DEFAULT);
/// model.set_material("Material", material);
///
/// /// @desc Draw event
/// model.render();
/// ```
///
/// @note You need to be using a {@link BBMOD_BaseRenderer} for reflection probes
/// to work! By default only materials {@link BBMOD_MATERIAL_TERRAIN} and
/// {@link BBMOD_MATERIAL_SKY} are captured into reflection probes!
///
/// @see BBMOD_ERenderPass.ReflectionCapture
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

	/// @var {Bool} If `false` then the probe is disabled and unused. Default
	/// value is `true`.
	Enabled = true;

	/// @var {Struct.BBMOD_Vec3} The position in the world. Default value is
	/// `(0, 0, 0)`.
	/// @readonly
	/// @see BBMOD_ReflectionProbe.set_position
	Position = _position ?? new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3} Size of AABB on each axis that marks the
	/// probe's area of influence. The probe is active only when camera enters
	/// this area. Default value is `(0.5, 0.5, 0.5)`, i.e. a 1x1x1 box.
	/// @readonly
	/// @see BBMOD_ReflectionProbe.set_size
	Size = new BBMOD_Vec3(0.5);

	/// @var {Bool} If `true` then the position or size has changed.
	/// @private
	__positionSizeChanged = true;

	/// @var {Asset.GMSprite} The captured sprite used for reflections.
	/// @readonly
	/// @see BBMOD_ReflectionProbe.set_sprite
	Sprite = _sprite;

	/// @var {Real} The resolution of a cubemap used when capturing the probe.
	Resolution = (_sprite != undefined) ? sprite_get_height(_sprite) : 128;

	/// @var {Bool} If `true` then the reflection probe needs to be re-captured.
	/// Equals `true` when `_sprite` is not passed to the constructor. **Setting
	/// this to `true` every frame has severe impact on performance, even for a
	/// single reflection probe!**
	NeedsUpdate = (_sprite == undefined);

	/// @var {Bool} If `true` then the scene is captured into a high-precision
	/// texture (if available on the current platform). Default value is `true`.
	HDR = true;

	/// @func set_position(_position)
	///
	/// @desc Changes the position of the reflection probe.
	///
	/// @param {Struct.BBMOD_Vec3} _position The new position.
	///
	/// @return {Struct.BBMOD_ReflectionProbe} Returns `self`.
	static set_position = function (_position)
	{
		Position = _position;
		__positionSizeChanged = true;
		return self;
	};

	/// @func set_size(_size)
	///
	/// @desc Changes the probe's area of influence.
	///
	/// @param {Struct.BBMOD_Vec3} _size The new area of influence.
	///
	/// @return {Struct.BBMOD_ReflectionProbe} Returns `self`.
	static set_size = function (_size)
	{
		Size = _size;
		__positionSizeChanged = true;
		return self;
	};

	/// @func set_sprite(_sprite)
	///
	/// @desc Destroys the reflection probe's sprite and replaces it with a new one.
	///
	/// @param {Asset.GMSprite} _sprite The new sprite.
	///
	/// @return {Struct.BBMOD_ReflectionProbe} Returns `self`.
	static set_sprite = function (_sprite)
	{
		if (Sprite != undefined)
		{
			sprite_delete(Sprite);
		}
		Sprite = _sprite;
		return self;
	};

	static destroy = function ()
	{
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
/// @desc Finds an enabled reflection probe at given position.
///
/// @param {Struct.BBMOD_Vec3} _position The position to find a reflection probe at.
///
/// @return {Struct.BBMOD_ReflectionProbe} The found reflection probe or `undefined`.
///
/// @see BBMOD_ReflectionProbe.Enabled
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
