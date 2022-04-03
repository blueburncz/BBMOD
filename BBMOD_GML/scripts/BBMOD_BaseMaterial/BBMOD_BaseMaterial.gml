/// @func BBMOD_BaseMaterial([_shader])
/// @extends BBMOD_Material
/// @desc A material that can be used when rendering models.
/// @param {Struct.BBMOD_Shader/Undefined} [_shader] A shader that the material uses in
/// the {@link BBMOD_ERenderPass.Forward} pass. Leave `undefined` if you would
/// like to use {@link BBMOD_BaseMaterial.set_shader} to specify shaders used in
/// specific render passes.
/// @see BBMOD_Shader
function BBMOD_BaseMaterial(_shader=undefined)
	: BBMOD_Material(_shader) constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Super_Material = {
		copy: copy,
		destroy: destroy,
	};

	/// @var {Pointer.Texture} A texture with a base color in the RGB channels
	/// and opacity in the alpha channel.
	BaseOpacity = pointer_null;

	BaseOpacitySprite = undefined;

	/// @var {Struct.BBMOD_Vec2} An offset of texture UV coordinates. Defaults to `[0, 0]`.
	/// Using this you can control texture's position within texture page.
	TextureOffset = new BBMOD_Vec2(0.0);

	/// @var {Struct.BBMOD_Vec2} A scale of texture UV coordinates. Defaults to `[1, 1]`.
	/// Using this you can control texture's size within texture page.
	TextureScale = new BBMOD_Vec2(1.0);

	/// @func copy(_dest)
	/// @desc Copies properties of this material into another material.
	/// @param {Struct.BBMOD_BaseMaterial} _dest The destination material.
	/// @return {Struct.BBMOD_BaseMaterial} Returns `self`.
	static copy = function (_dest) {
		method(self, Super_Material.copy)(_dest);

		if (_dest.BaseOpacitySprite != undefined)
		{
			sprite_delete(_dest.BaseOpacitySprite);
			_dest.BaseOpacitySprite = undefined;
		}

		if (BaseOpacitySprite != undefined)
		{
			_dest.BaseOpacitySprite = sprite_duplicate(BaseOpacitySprite);
			_dest.BaseOpacity = sprite_get_texture(_dest.BaseOpacitySprite, 0);
		}
		else
		{
			_dest.BaseOpacity = BaseOpacity;
		}

		_dest.TextureOffset = TextureOffset.Clone();
		_dest.TextureScale = TextureScale.Clone();

		return self;
	};

	/// @func clone()
	/// @desc Creates a clone of the material.
	/// @return {Struct.BBMOD_BaseMaterial} The created clone.
	static clone = function () {
		var _clone = new BBMOD_BaseMaterial();
		copy(_clone);
		return _clone;
	};

	static _make_sprite = function (_r, _g, _b, _a) {
		gml_pragma("forceinline");
		static _sur = noone;
		if (!surface_exists(_sur))
		{
			_sur = surface_create(1, 1);
		}
		surface_set_target(_sur);
		draw_clear_alpha(make_color_rgb(_r, _g, _b), _a);
		surface_reset_target();
		return sprite_create_from_surface(_sur, 0, 0, 1, 1, false, false, 0, 0);
	};

	/// @func set_base_opacity(_color)
	/// @desc Changes the base color and opacity to a uniform value for the
	/// entire material.
	/// @param {Struct.BBMOD_Color} _color The new base color and opacity.
	/// @return {Struct.BBMOD_BaseMaterial} Returns `self`.
	static set_base_opacity = function (_color) {
		if (BaseOpacitySprite != undefined)
		{
			sprite_delete(BaseOpacitySprite);
		}
		var _isReal = is_real(_color);
		BaseOpacitySprite = _make_sprite(
			_isReal ? color_get_red(_color) : _color.Red,
			_isReal ? color_get_green(_color) : _color.Green,
			_isReal ? color_get_blue(_color) : _color.Blue,
			_isReal ? argument[1] : _color.Alpha,
		);
		BaseOpacity = sprite_get_texture(BaseOpacitySprite, 0);
		return self;
	};

	/// @func has_commands()
	/// @desc Checks whether the material has any render commands waiting for
	/// submission.
	/// @return {Bool} Always returns `false`.
	/// @obsolete Render commands are now stored in {@link BBMOD_RenderQueue}s.
	/// Please use {@link BBMOD_RenderQueue.is_empty} instead.
	static has_commands = function () {
		return false;
	};

	/// @func submit_queue()
	/// @desc Submits all render commands without clearing the render queue.
	/// @return {Struct.BBMOD_BaseMaterial} Returns `self`.
	/// @obsolete Render commands are now stored in {@link BBMOD_RenderQueue}s.
	/// Please use {@link BBMOD_RenderQueue.submit} instead.
	static submit_queue = function () {
		return self;
	};

	/// @func clear_queue()
	/// @desc Clears the queue of render commands.
	/// @obsolete Render commands are now stored in {@link BBMOD_RenderQueue}s.
	/// @return {Struct.BBMOD_BaseMaterial} Returns `self`.
	/// Please use {@link BBMOD_RenderQueue.clear} instead.
	static clear_queue = function () {
		return self;
	};

	static destroy = function () {
		method(self, Super_Material.destroy)();
		if (BaseOpacitySprite != undefined)
		{
			sprite_delete(BaseOpacitySprite);
		}
	};
}