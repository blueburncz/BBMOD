/// @macro The default material.
#macro BBMOD_MATERIAL_DEFAULT global.__bbmod_material_default

/// @macro The default material for animated models.
#macro BBMOD_MATERIAL_DEFAULT_ANIMATED global.__bbmod_material_default_animated

/// @macro The default material for dynamically batched models.
#macro BBMOD_MATERIAL_DEFAULT_BACTHED global.__bbmod_material_default_batched

/// @macro A value returned when loading fails or to destroy an existing
/// model/animation.
#macro BBMOD_NONE undefined

/// @macro {string} An event triggered on animation end. The event data
/// will containg the animation that was finished playing.
#macro BBMOD_EV_ANIMATION_END "bbmod_ev_animation_end"

/// @macro A flag used to tell that a model is rendered in a forward render
/// path.
#macro BBMOD_RENDER_FORWARD (1)

/// @macro A flag used to tell that a model is rendered in a deferred render
/// path.
#macro BBMOD_RENDER_DEFERRED (1 << 1)

/// @macro How many bites to shift to read/write a "has vertices" predicate
/// from/to a vertex format mask.
#macro BBMOD_VFORMAT_VERTEX 0

/// @macro How many bites to shift to read/write a "has normals" predicate
/// from/to a vertex format mask.
#macro BBMOD_VFORMAT_NORMAL 1

/// @macro How many bites to shift to read/write a "has texture coodrinates"
/// predicate from/to a vertex format mask.
#macro BBMOD_VFORMAT_TEXCOORD 2

/// @macro How many bites to shift to read/write a "has colors" predicate
/// from/to a vertex format mask.
#macro BBMOD_VFORMAT_COLOR 3

/// @macro How many bites to shift to read/write a "has tangent and bitangent
/// sign" predicate from/to a vertex format mask.
#macro BBMOD_VFORMAT_TANGENTW 4

/// @macro How many bites to shift to read/write a "has bone indices and vertex
/// weights" predicate from/to a vertex format mask.
#macro BBMOD_VFORMAT_BONES 5

/// @macro How many bites to shift to read/write a "has ids for dynamic batching"
/// predicate from/to a vertex format mask.
#macro BBMOD_VFORMAT_IDS 6

/// @macro An index of the last found AnimationKey, updated by
/// [bbmod_find_animation_key](./bbmod_find_animation_key.html).
#macro BBMOD_KEY_INDEX_LAST global.__bbmod_key_index_last

/// @var {real} Mapping of vertex format masks to existing vertex formats.
global.__bbmod_vertex_formats = ds_map_create();

/// @var {real} The default material.
global.__bbmod_material_default = bbmod_material_create(BBMOD_ShDefault);

/// @var {real} The default material for animated models.
global.__bbmod_material_default_animated = bbmod_material_create(BBMOD_ShDefaultAnimated);

/// @var {real} The default material for dynamically batched models.
global.__bbmod_material_default_batched = bbmod_material_create(BBMOD_ShDefaultBatched);

/// @var {array/undefined} The currently applied material.
global.__bbmod_material_current = undefined;

/// @var {real} A stack used when posing skeletons to avoid recursion.
global.__bbmod_anim_stack = ds_stack_create();

/// @var {real} An index of the last found AnimationKey.
global.__bbmod_key_index_last = 0;

/// @var {real} The current render pass.
global.bbmod_render_pass = BBMOD_RENDER_FORWARD;

/// @var {array} The current position of the camera.
global.bbmod_camera_position = [0, 0, 0];

/// @var {real} The current camera exposure.
global.bbmod_camera_exposure = 0.1;

/// @var {ptr} The texture that is currently used for IBL.
global.__bbmod_ibl_texture = pointer_null;

/// @var {ptr} A texel size of the IBL texture.
global.__bbmod_ibl_texel = 0;

/// @func bbmod_load(_file[, _sha1])
/// @desc Loads a model/animation from a BBMOD/BBANIM file.
/// @param {string} _file The path to the file.
/// @param {string} [_sha1] Expected SHA1 of the file. If the actual one
/// does not match with this, then the model will not be loaded. Default is
/// `undefined`.
/// @return {array/BBMOD_NONE} The loaded model/animation on success or
/// `BBMOD_NONE` on fail.
function bbmod_load()
{
	var _file = argument[0];
	var _sha1 = (argument_count > 2) ? argument[2] : undefined;
	var _bbmod = BBMOD_NONE;

	if (!file_exists(_file))
	{
		return _bbmod;
	}

	if (!is_undefined(_sha1))
	{
		if (sha1_file(_file) != _sha1)
		{
			return _bbmod;
		}
	}

	var _buffer = buffer_load(_file);
	buffer_seek(_buffer, buffer_seek_start, 0);

	var _type = buffer_read(_buffer, buffer_string);
	var _version = buffer_read(_buffer, buffer_u8);

	if (_version == 1)
	{
		switch (_type)
		{
		case "bbmod":
			_bbmod = bbmod_model_load(_buffer, _version);
			break;

		case "bbanim":
			_bbmod = bbmod_animation_load(_buffer, _version);
			break;

		default:
			break;
		}
	}

	buffer_delete(_buffer);

	return _bbmod;
}

/// @func bbmod_set_camera_position(_x, _y, _z)
/// @desc Changes camera position to given coordinates.
/// @param {real} _x The x position of the camera.
/// @param {real} _y The y position of the camera.
/// @param {real} _z The z position of the camera.
/// @note This should be called each frame before rendering, since it is required
/// for proper functioning of PBR shaders!
function bbmod_set_camera_position(_x, _y, _z)
{
	gml_pragma("forceinline");
	var _position = global.bbmod_camera_position;
	_position[@ 0] = _x;
	_position[@ 1] = _y;
	_position[@ 2] = _z;
}

/// @func bbmod_set_ibl_sprite(_sprite, _subimage)
/// @desc Changes a texture used for image based lighting using a sprite.
/// @param {real} _sprite The sprite index.
/// @param {real} _subimage The sprite subimage to use.
/// @note This texture must be a stripe of eight prefiltered octahedrons, the
/// first seven being used for specular lighting and the last one for diffuse
/// lighting.
function bbmod_set_ibl_sprite(_sprite, _subimage)
{
	gml_pragma("forceinline");
	var _texel = 1 / sprite_get_height(_sprite);
	bbmod_set_ibl_texture(sprite_get_texture(_sprite, _subimage), _texel);
}

/// @func bbmod_set_ibl_texture(_texture, _texel)
/// @desc Changes a texture used for image based lighting.
/// @param {real} _texture The texture.
/// @param {real} _texel A size of one texel.
/// @note This texture must be a stripe of eight prefiltered octahedrons, the
/// first seven being used for specular lighting and the last one for diffuse
/// lighting.
function bbmod_set_ibl_texture(_texture, _texel)
{
	global.__bbmod_ibl_texture = _texture;
	global.__bbmod_ibl_texel = _texel;

	if (_texture != pointer_null)
	{
		var _material = global.__bbmod_material_current;
		if (_material != undefined)
		{
			var _shader = _material[BBMOD_EMaterial.Shader];
			_bbmod_shader_set_ibl(_shader, _texture, _texel);
		}
	}
}