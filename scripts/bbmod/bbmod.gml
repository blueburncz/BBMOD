/// @macro {BBMOD_EMaterial} The default material.
#macro BBMOD_MATERIAL_DEFAULT global.__bbmod_material_default

/// @macro {BBMOD_EMaterial} The default material for animated models.
#macro BBMOD_MATERIAL_DEFAULT_ANIMATED global.__bbmod_material_default_animated

/// @macro {BBMOD_EMaterial} The default material for dynamically batched models.
/// @see BBMOD_DynamicBatch
#macro BBMOD_MATERIAL_DEFAULT_BATCHED global.__bbmod_material_default_batched

/// @macro {undefined} An empty value. This is for example used in the legacy
/// scripts as a return value when animation/model loading fails or to unassign
/// an existing one.
/// @example
/// ```gml
/// model = bbmod_load("model.bbmod");
/// if (model == BBMOD_NONE)
/// {
///     // Model loading failed!
///     exit;
/// }
///
/// // Destroy and unassign an existing model
/// bbmod_model_destroy(model);
/// model = BBMOD_NONE;
/// ```
#macro BBMOD_NONE undefined

/// @macro {string} An event triggered on animation end. The event data
/// will containg the animation that was finished playing.
/// @example
/// ```gml
/// /// @desc User event
/// switch (ce_get_event())
/// {
/// case BBMOD_EV_ANIMATION_END:
///     var _animation = ce_get_event_data();
///     // Do something when _animation ends...
///     break;
/// }
/// ```
#macro BBMOD_EV_ANIMATION_END "bbmod_ev_animation_end"

/// @macro {real} A flag used to tell that a model is rendered in a forward
/// render path.
/// @see BBMOD_RENDER_DEFERRED
/// @see global.bbmod_render_pass
/// @see BBMOD_Material.get_render_path
/// @see BBMOD_Material.set_render_path
#macro BBMOD_RENDER_FORWARD (1)

/// @macro {real} A flag used to tell that a model is rendered in a deferred
/// render path.
/// @see BBMOD_RENDER_FORWARD
/// @see global.bbmod_render_pass
/// @see BBMOD_Material.get_render_path
/// @see BBMOD_Material.set_render_path
#macro BBMOD_RENDER_DEFERRED (1 << 1)

/// @macro {real} How many bites to shift to read/write a "has vertices"
/// predicate from/to a vertex format mask.
/// @private
#macro BBMOD_VFORMAT_VERTEX 0

/// @macro {real} How many bites to shift to read/write a "has normals"
/// predicate from/to a vertex format mask.
/// @private
#macro BBMOD_VFORMAT_NORMAL 1

/// @macro {real} How many bites to shift to read/write a "has texture
/// coodrinates" predicate from/to a vertex format mask.
/// @private
#macro BBMOD_VFORMAT_TEXCOORD 2

/// @macro {real} How many bites to shift to read/write a "has colors" predicate
/// from/to a vertex format mask.
/// @private
#macro BBMOD_VFORMAT_COLOR 3

/// @macro {real} How many bites to shift to read/write a "has tangent and
/// bitangent sign" predicate from/to a vertex format mask.
/// @private
#macro BBMOD_VFORMAT_TANGENTW 4

/// @macro {real} How many bites to shift to read/write a "has bone indices and
/// vertex weights" predicate from/to a vertex format mask.
/// @private
#macro BBMOD_VFORMAT_BONES 5

/// @macro {real} How many bites to shift to read/write a "has ids for dynamic
/// batching"
/// predicate from/to a vertex format mask.
/// @private
#macro BBMOD_VFORMAT_IDS 6

/// @macro {real} An index of the last found animation key, updated by
/// {@link bbmod_find_animation_key}.
#macro BBMOD_KEY_INDEX_LAST global.__bbmod_key_index_last

/// @var {ds_map} Mapping of vertex format masks to existing vertex formats.
/// @private
global.__bbmod_vertex_formats = ds_map_create();

/// @var {BBMOD_EMaterial} The default material.
/// @see BBMOD_EMaterial
/// @private
global.__bbmod_material_default = bbmod_material_create(BBMOD_ShDefault);

/// @var {BBMOD_EMaterial} The default material for animated models.
/// @see BBMOD_EMaterial
/// @private
global.__bbmod_material_default_animated = bbmod_material_create(BBMOD_ShDefaultAnimated);

/// @var {BBMOD_EMaterial} The default material for dynamically batched models.
/// @see BBMOD_EMaterial
/// @private
global.__bbmod_material_default_batched = bbmod_material_create(BBMOD_ShDefaultBatched);

/// @var {BBMOD_EMaterial/BBMOD_NONE} The currently applied material.
/// @private
global.__bbmod_material_current = BBMOD_NONE;

/// @var {ds_stack} A stack used when posing skeletons to avoid recursion.
/// @private
global.__bbmod_anim_stack = ds_stack_create();

/// @var {real} An index of the last found animation key.
/// @private
global.__bbmod_key_index_last = 0;

/// @var {real} The current render pass.
/// @example
/// ```gml
/// if (global.bbmod_render_pass & BBMOD_RENDER_DEFERRED)
/// {
///     // Draw objects to a G-Buffer...
/// }
/// ```
/// @see BBMOD_RENDER_FORWARD
/// @see BBMOD_RENDER_DEFERRED
global.bbmod_render_pass = BBMOD_RENDER_FORWARD;

/// @var {real[]} The current `[x,y,z]` position of the camera. This should be
/// updated every frame before rendering models, otherwise the default PBR
/// shaders won't work properly!
/// @see bbmod_set_camera_position
global.bbmod_camera_position = [0, 0, 0];

/// @var {real} The current camera exposure.
global.bbmod_camera_exposure = 0.1;

/// @var {ptr} The texture that is currently used for IBL.
/// @private
global.__bbmod_ibl_texture = pointer_null;

/// @var {ptr} A texel size of the IBL texture.
/// @private
global.__bbmod_ibl_texel = 0;

/// @func bbmod_load(_file[, _sha1])
/// @desc Loads a model/animation from a BBMOD/BBANIM file.
/// @param {string} _file The path to the file.
/// @param {string} [_sha1] Expected SHA1 of the file. If the actual one does
/// not match with this, then the model will not be loaded.
/// @return {BBMOD_Model/BBMOD_Animation/BBMOD_NONE} The loaded model/animation on success or
/// {@link BBMOD_NONE} on fail.
/// @deprecated This function is deprecated. Please use {@link BBMOD_Model}
/// and {@link BBMOD_Animation} instead to load resources.
function bbmod_load(_file)
{
	var _sha1 = (argument_count > 1) ? argument[1] : undefined;
	var _ext = filename_ext(_file);

	if (_ext == ".bbmod")
	{
		try
		{
			return new BBMOD_Model(_file, _sha1);
		}
		catch (e)
		{
			return BBMOD_NONE;
		}
	}

	if (_ext == ".bbanim")
	{
		try
		{
			return new BBMOD_Animation(_file, _sha1);
		}
		catch (e)
		{
			return BBMOD_NONE;
		}
	}

	return BBMOD_NONE;
}

/// @func bbmod_set_camera_position(_x, _y, _z)
/// @desc Changes camera position to given coordinates.
/// @param {real} _x The x position of the camera.
/// @param {real} _y The y position of the camera.
/// @param {real} _z The z position of the camera.
/// @see global.bbmod_camera_position
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
/// @param {ptr} _texture The texture.
/// @param {real} _texel The size of a texel.
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
		if (_material != BBMOD_NONE)
		{
			var _shader = _material[BBMOD_EMaterial.Shader];
			_bbmod_shader_set_ibl(_shader, _texture, _texel);
		}
	}
}