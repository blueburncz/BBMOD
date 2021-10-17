/// @func BBMOD_PBRShader(_shader, _vertexFormat)
/// @extends BBMOD_Shader
/// @desc A wrapper for a raw GameMaker shader resource using PBR.
/// @param {shader} _shader The shader resource.
/// @param {BBMOD_VertexFormat} _vertexFormat The vertex format required by the shader.
function BBMOD_PBRShader(_shader, _vertexFormat)
	: BBMOD_Shader(_shader, _vertexFormat) constructor
{
	static Super_Shader = {
		set_material: set_material,
	};

	UCamPos = get_uniform("bbmod_CamPos");

	UExposure = get_uniform("bbmod_Exposure");

	UNormalRoughness = get_sampler_index("bbmod_NormalRoughness");

	UMetallicAO = get_sampler_index("bbmod_MetallicAO");

	USubsurface = get_sampler_index("bbmod_Subsurface");

	UEmissive = get_sampler_index("bbmod_Emissive");

	UBRDF = get_sampler_index("bbmod_BRDF");

	UIBL = get_sampler_index("bbmod_IBL");

	UIBLTexel = get_uniform("bbmod_IBLTexel");

	/// @func set_cam_pos(_x[, _y, _z])
	/// @desc Sets a fragment shader uniform `bbmod_CamPos` to the given position.
	/// @param {BBMOD_Vec3/real} _x Either a vector with the camera's position
	/// or the x position of the camera.
	/// @param {real} [_y] The y position of the camera.
	/// @param {real} [_z] The z position of the camera.
	/// @return {BBMOD_Shader} Returns `self`.
	static set_cam_pos = function (_x, _y, _z) {
		gml_pragma("forceinline");
		if (is_struct(_x))
		{
			set_uniform_f3(UCamPos, _x.X, _x.Y, _x.Z);
		}
		else
		{
			set_uniform_f3(UCamPos, _x, _y, _z);
		}
		return self;
	};

	/// @func set_exposure(_value)
	/// @desc Sets the `bbmod_Exposure` uniform.
	/// @param {real} _value The new camera exposure.
	/// @return {BBMOD_PBRShader} Returns `self`.
	static set_exposure = function (_value) {
		gml_pragma("forceinline");
		return set_uniform_f(UExposure, _value);
	};

	/// @func set_normal_roughness(_texture)
	/// @desc Sets the `bbmod_NormalRoughness` uniform.
	/// @param {real} _texture The new texture with normal vector in the RGB
	/// channels and roughness in the A channel.
	/// @return {BBMOD_PBRShader} Returns `self`.
	static set_normal_roughness = function (_texture) {
		gml_pragma("forceinline");
		return set_sampler(UNormalRoughness, _texture);
	};

	/// @func set_metallic_ao(_texture)
	/// @desc Sets the `bbmod_MetallicAO` uniform.
	/// @param {real} _texture The new texture with metalness in the R channel
	/// and ambient occlusion in the G channel.
	/// @return {BBMOD_PBRShader} Returns `self`.
	static set_metallic_ao = function (_texture) {
		gml_pragma("forceinline");
		return set_sampler(UMetallicAO, _texture);
	};

	/// @func set_subsurface(_texture)
	/// @desc Sets the `bbmod_Subsurface` uniform.
	/// @param {real} _texture The new texture with subsurface color in the
	/// RGB channels and its intensity in the A channel.
	/// @return {BBMOD_PBRShader} Returns `self`.
	static set_subsurface = function (_texture) {
		gml_pragma("forceinline");
		return set_sampler(USubsurface, _texture);
	};

	/// @func set_emissive(_texture)
	/// @desc Sets the `bbmod_Emissive` uniform.
	/// @param {real} _texture The new RGBM encoded emissive color.
	/// @return {BBMOD_PBRShader} Returns `self`.
	static set_emissive = function (_texture) {
		gml_pragma("forceinline");
		return set_sampler(UEmissive, _texture);
	};

	/// @func set_ibl()
	/// @desc Sets a fragment shader uniform `bbmod_IBLTexel` and samplers
	/// `bbmod_IBL` and `bbmod_BRDF`. These are required for image based
	/// lighting.
	/// @return {BBMOD_PBRShader} Returns `self`.
	/// @see bbmod_set_ibl_sprite
	/// @see bbmod_set_ibl_texture
	static set_ibl = function () {
		static _texBRDF = sprite_get_texture(BBMOD_SprEnvBRDF, 0);

		var _texture = global.__bbmodIblTexture;
		if (_texture == pointer_null)
		{
			return self;
		}

		gpu_set_tex_mip_enable_ext(UBRDF, mip_off);
		gpu_set_tex_filter_ext(UBRDF, true);
		gpu_set_tex_repeat_ext(UBRDF, false);
		set_sampler(UBRDF, _texBRDF);

		gpu_set_tex_mip_enable_ext(UIBL, mip_off);
		gpu_set_tex_filter_ext(UIBL, true);
		gpu_set_tex_repeat_ext(UIBL, false);
		set_sampler(UIBL, _texture);

		var _texel = global.__bbmodIblTexel;
		set_uniform_f(UIBLTexel, _texel, _texel);

		return self;
	};

	static set_material = function (_material) {
		gml_pragma("forceinline");
		method(self, Super_Shader.set_material)(_material);
		set_metallic_ao(_material.MetallicAO);
		set_normal_roughness(_material.NormalRoughness);
		set_subsurface(_material.Subsurface);
		set_emissive(_material.Emissive);
		set_cam_pos(global.bbmod_camera_position);
		set_exposure(global.bbmod_camera_exposure);
		set_ibl();
		return self;
	};
}

////////////////////////////////////////////////////////////////////////////////
//
// Camera
//

/// @var {real[]} The current `[x,y,z]` position of the camera. This should be
/// updated every frame before rendering models.
/// @see bbmod_set_camera_position
global.bbmod_camera_position = new BBMOD_Vec3();

/// @var {real} The current camera exposure.
global.bbmod_camera_exposure = 1.0;

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
	_position.X = _x;
	_position.Y = _y;
	_position.Z = _z;
}