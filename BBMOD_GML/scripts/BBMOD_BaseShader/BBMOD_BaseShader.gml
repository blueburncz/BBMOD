/// @func BBMOD_BaseShader(_shader, _vertexFormat)
/// @extends BBMOD_Shader
/// @desc Base class for BBMOD shaders.
/// @param {shader} _shader The shader resource.
/// @param {BBMOD_VertexFormat} _vertexFormat The vertex format required by the shader.
/// @see BBMOD_VertexFormat
function BBMOD_BaseShader(_shader, _vertexFormat)
	: BBMOD_Shader(_shader, _vertexFormat) constructor
{
	UTextureOffset = get_uniform("bbmod_TextureOffset");

	UTextureScale = get_uniform("bbmod_TextureScale");

	UBones = get_uniform("bbmod_Bones");

	UBatchData = get_uniform("bbmod_BatchData");

	UAlphaTest = get_uniform("bbmod_AlphaTest");

	UCamPos = get_uniform("bbmod_CamPos");

	UZFar = get_uniform("bbmod_ZFar");

	UExposure = get_uniform("bbmod_Exposure");

	/// @func set_texture_offset(_offset)
	/// @desc Sets the `bbmod_TextureOffset` uniform to the given offset.
	/// @param {BBMOD_Vec2} _offset The texture offset.
	/// @return {BBMOD_Shader} Returns `self`.
	static set_texture_offset = function (_offset) {
		gml_pragma("forceinline");
		return set_uniform_f2(UTextureOffset, _offset.X, _offset.Y);
	};

	/// @func set_texture_scale(_scale)
	/// @desc Sets the `bbmod_TextureScale` uniform to the given scale.
	/// @param {BBMOD_Vec2} _scale The texture scale.
	/// @return {BBMOD_Shader} Returns `self`.
	static set_texture_scale = function (_scale) {
		gml_pragma("forceinline");
		return set_uniform_f2(UTextureScale, _scale.X, _scale.Y);
	};

	/// @func set_bones(_bones)
	/// @desc Sets the `bbmod_Bones` uniform.
	/// @param {real[]} _bones The array of bone transforms.
	/// @return {BBMOD_Shader} Returns `self`.
	/// @see BBMOD_AnimationPlayer.get_transform
	static set_bones = function (_bones) {
		gml_pragma("forceinline");
		return set_uniform_f_array(UBones, _bones);
	};

	/// @func set_batch_data(_data)
	/// @desc Sets the `bbmod_BatchData` uniform.
	/// @param {real[]} _data The dynamic batch data.
	/// @return {BBMOD_Shader} Returns `self`.
	static set_batch_data = function (_data) {
		gml_pragma("forceinline");
		return set_uniform_f_array(UBatchData, _data);
	};

	/// @func set_alpha_test(_value)
	/// @desc Sets the `bbmod_AlphaTest` uniform.
	/// @param {real} _value The alpha test value.
	/// @return {BBMOD_Shader} Returns `self`.
	static set_alpha_test = function (_value) {
		gml_pragma("forceinline");
		return set_uniform_f(UAlphaTest, _value);
	};

	/// @func set_cam_pos([_pos])
	/// @desc Sets a fragment shader uniform `bbmod_CamPos` to the given position.
	/// @param {BBMOD_Vec3} [_pos] The camera position. Defaults to the value
	/// defined using {@link bbmod_camera_set_position}.
	/// @return {BBMOD_Shader} Returns `self`.
	static set_cam_pos = function (_pos=undefined) {
		gml_pragma("forceinline");
		_pos ??= global.bbmod_camera_position;
		return set_uniform_f3(UCamPos, _pos.X, _pos.Y, _pos.Z);
	};

	/// @func set_zfar([_value])
	/// @desc Sets a fragment shader uniform `bbmod_ClipFar` to the given position.
	/// @param {BBMOD_Vec3} [_pos] The distance to the far clipping plane. Defaults
	/// to the value defined using {@link bbmod_camera_set_zfar}.
	/// @return {BBMOD_Shader} Returns `self`.
	static set_zfar = function (_value=undefined) {
		gml_pragma("forceinline");
		_value ??= global.__bbmodZFar;
		return set_uniform_f(UZFar, _value);
	};

	/// @func set_exposure([_value])
	/// @desc Sets the `bbmod_Exposure` uniform.
	/// @param {real} [_value] The camera exposure. Defaults to the value
	/// defined using {@link bbmod_camera_set_exposure}.
	/// @return {BBMOD_PBRShader} Returns `self`.
	static set_exposure = function (_value=undefined) {
		gml_pragma("forceinline");
		_value ??= global.bbmod_camera_exposure;
		return set_uniform_f(UExposure, _value);
	};

	static on_set = function () {
		gml_pragma("forceinline");
		set_cam_pos();
		set_exposure();
	};

	/// @func set_material(_material)
	/// @desc Sets shader uniforms using values from the material.
	/// @param {BBMOD_BaseMaterial} _material The material to take the values from.
	/// @return {BBMOD_BaseShader} Returns `self`.
	/// @see BBMOD_BaseMaterial
	static set_material = function (_material) {
		gml_pragma("forceinline");
		set_alpha_test(_material.AlphaTest);
		set_texture_offset(_material.TextureOffset);
		set_texture_scale(_material.TextureScale);
		return self;
	};
}

////////////////////////////////////////////////////////////////////////////////
//
// Camera
//

/// @var {BBMOD_Vec3} The current position of the camera. This should be
/// updated every frame before rendering models.
/// @deprecated Please use {@link bbmod_camera_get_position} and
/// {@link bbmod_camera_set_position} instead.
global.bbmod_camera_position = new BBMOD_Vec3();

/// @var {real} Distance to the far clipping plane.
/// @private
global.__bbmodZFar = 1.0;

/// @var {real} The current camera exposure.
/// @deprecated Please use {@link bbmod_camera_get_exposure} and
/// {@link bbmod_camera_set_exposure} instead.
global.bbmod_camera_exposure = 1.0;

/// @func bbmod_set_camera_position(_x, _y, _z)
/// @desc Changes camera position to given coordinates.
/// @param {real} _x The x position of the camera.
/// @param {real} _y The y position of the camera.
/// @param {real} _z The z position of the camera.
/// @deprecated Please use {@link bbmod_camera_set_position} instead.
function bbmod_set_camera_position(_x, _y, _z)
{
	gml_pragma("forceinline");
	var _position = global.bbmod_camera_position;
	_position.X = _x;
	_position.Y = _y;
	_position.Z = _z;
}

/// @func bbmod_camera_get_position()
/// @desc Retrieves the position of the camera that is passed to shaders.
/// @return {BBMOD_Vec3} The camera position.
/// @see bbmod_camera_set_position
function bbmod_camera_get_position()
{
	gml_pragma("forceinline");
	return global.bbmod_camera_position;
}

/// @func bbmod_camera_set_position(_position)
/// @desc Defines position of the camera passed to shaders.
/// @param {BBMOD_Vec3} _position The new camera position.
/// @see bbmod_camera_get_position
function bbmod_camera_set_position(_position)
{
	gml_pragma("forceinline");
	global.bbmod_camera_position = _position;
}

/// @func bbmod_camera_get_zfar()
/// @desc
/// @return {real}
/// @see bbmod_camera_set_zfar
function bbmod_camera_get_zfar()
{
	gml_pragma("forceinline");
	return global.__bbmodZFar;
}

/// @func bbmod_camera_set_zfar(_value)
/// @desc
/// @param {real} _value
/// @see bbmod_camera_get_zfar
function bbmod_camera_set_zfar(_value)
{
	gml_pragma("forceinline");
	global.__bbmodZFar = _value;
}

/// @func bbmod_camera_get_exposure()
/// @desc Retrieves camera exposure value passed to shaders.
/// @return {real} The camera exposure value.
/// @see bbmod_camera_set_exposure
function bbmod_camera_get_exposure()
{
	gml_pragma("forceinline");
	return global.bbmod_camera_exposure;
}

/// @func bbmod_camera_set_exposure(_exposure)
/// @desc Defines camera exposure value passed to shaders.
/// @param {real} _exposure The new camera exposure value.
/// @see bbmod_camera_get_exposure
function bbmod_camera_set_exposure(_exposure)
{
	gml_pragma("forceinline");
	global.bbmod_camera_exposure = _exposure;
}