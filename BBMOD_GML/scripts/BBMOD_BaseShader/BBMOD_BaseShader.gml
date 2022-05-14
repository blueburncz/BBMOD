/// @func BBMOD_BaseShader(_shader, _vertexFormat)
/// @extends BBMOD_Shader
/// @desc Base class for BBMOD shaders.
/// @param {Resource.GMShader} _shader The shader resource.
/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format required by the shader.
/// @see BBMOD_VertexFormat
function BBMOD_BaseShader(_shader, _vertexFormat)
	: BBMOD_Shader(_shader, _vertexFormat) constructor
{
	UBaseOpacityMultiplier = get_uniform("bbmod_BaseOpacityMultiplier");

	UTextureOffset = get_uniform("bbmod_TextureOffset");

	UTextureScale = get_uniform("bbmod_TextureScale");

	UBones = get_uniform("bbmod_Bones");

	UBatchData = get_uniform("bbmod_BatchData");

	UAlphaTest = get_uniform("bbmod_AlphaTest");

	UCamPos = get_uniform("bbmod_CamPos");

	UZFar = get_uniform("bbmod_ZFar");

	UExposure = get_uniform("bbmod_Exposure");

	UInstanceID = get_uniform("bbmod_InstanceID");

	/// @func set_texture_offset(_offset)
	/// @desc Sets the `bbmod_TextureOffset` uniform to the given offset.
	/// @param {Struct.BBMOD_Vec2} _offset The texture offset.
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	static set_texture_offset = function (_offset) {
		gml_pragma("forceinline");
		return set_uniform_f2(UTextureOffset, _offset.X, _offset.Y);
	};

	/// @func set_texture_scale(_scale)
	/// @desc Sets the `bbmod_TextureScale` uniform to the given scale.
	/// @param {Struct.BBMOD_Vec2} _scale The texture scale.
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	static set_texture_scale = function (_scale) {
		gml_pragma("forceinline");
		return set_uniform_f2(UTextureScale, _scale.X, _scale.Y);
	};

	/// @func set_bones(_bones)
	/// @desc Sets the `bbmod_Bones` uniform.
	/// @param {Array<Real>} _bones The array of bone transforms.
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	/// @see BBMOD_AnimationPlayer.get_transform
	static set_bones = function (_bones) {
		gml_pragma("forceinline");
		return set_uniform_f_array(UBones, _bones);
	};

	/// @func set_batch_data(_data)
	/// @desc Sets the `bbmod_BatchData` uniform.
	/// @param {Array<Real>} _data The dynamic batch data.
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	static set_batch_data = function (_data) {
		gml_pragma("forceinline");
		return set_uniform_f_array(UBatchData, _data);
	};

	/// @func set_alpha_test(_value)
	/// @desc Sets the `bbmod_AlphaTest` uniform.
	/// @param {Real} _value The alpha test value.
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	static set_alpha_test = function (_value) {
		gml_pragma("forceinline");
		return set_uniform_f(UAlphaTest, _value);
	};

	/// @func set_cam_pos([_pos])
	/// @desc Sets a fragment shader uniform `bbmod_CamPos` to the given position.
	/// @param {Struct.BBMOD_Vec3} [_pos] The camera position. If `undefined`,
	/// then the value set by {@link bbmod_camera_set_position} is used.
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	static set_cam_pos = function (_pos=undefined) {
		gml_pragma("forceinline");
		_pos ??= global.__bbmodCameraPosition;
		return set_uniform_f3(UCamPos, _pos.X, _pos.Y, _pos.Z);
	};

	/// @func set_zfar([_value])
	/// @desc Sets a fragment shader uniform `bbmod_ClipFar` to the given value.
	/// @param {Struct.BBMOD_Vec3} [_value] The distance to the far clipping
	/// plane. If `undefined`, then the value set by {@link bbmod_camera_set_zfar}
	/// is used.
	/// @return {Struct.BBMOD_Shader} Returns `self`.

	/// @func set_exposure([_value])
	/// @desc Sets the `bbmod_Exposure` uniform.
	/// @param {Real} [_value] The camera exposure. If `undefined`,
	/// then the value set by {@link bbmod_camera_set_exposure} is used.
	/// @return {Struct.BBMOD_BaseShader} Returns `self`.
	static set_exposure = function (_value=undefined) {
		gml_pragma("forceinline");
		_value ??= global.__bbmodCameraExposure;
		return set_uniform_f(UExposure, _value);
	};

	/// @func set_instance_id([_id])
	/// @desc Sets the `bbmod_InstanceID` uniform.
	/// @param {Id.Instance} [_id] The instance ID. If `undefined`,
	/// then the value set by {@link bbmod_set_instance_id} is used.
	/// @return {Struct.BBMOD_BaseShader} Returns `self`.
	static set_instance_id = function (_id=undefined) {
		gml_pragma("forceinline");
		_id ??= global.__bbmodInstanceID;
		return set_uniform_f4(
			UInstanceID,
			((_id & $000000FF) >> 0) / 255,
			((_id & $0000FF00) >> 8) / 255,
			((_id & $00FF0000) >> 16) / 255,
			((_id & $FF000000) >> 24) / 255);
	};

	static on_set = function () {
		gml_pragma("forceinline");
		set_cam_pos();
		set_exposure();
	};

	/// @func set_material(_material)
	/// @desc Sets shader uniforms using values from the material.
	/// @param {Struct.BBMOD_BaseMaterial} _material The material to take the values from.
	/// @return {Struct.BBMOD_BaseShader} Returns `self`.
	/// @see BBMOD_BaseMaterial
	static set_material = function (_material) {
		gml_pragma("forceinline");
		set_uniform_f4(
			UBaseOpacityMultiplier,
			_material.BaseOpacityMultiplier.Red / 255.0,
			_material.BaseOpacityMultiplier.Green / 255.0,
			_material.BaseOpacityMultiplier.Blue / 255.0,
			_material.BaseOpacityMultiplier.Alpha);
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

/// @var {Struct.BBMOD_Vec3}
/// @private
global.__bbmodCameraPosition = new BBMOD_Vec3();

/// @var {Real} Distance to the far clipping plane.
/// @private
global.__bbmodZFar = 1.0;

/// @var {Real}
/// @private
global.__bbmodCameraExposure = 1.0;

/// @func bbmod_camera_get_position()
/// @desc Retrieves the position of the camera that is passed to shaders.
/// @return {Struct.BBMOD_Vec3} The camera position.
/// @see bbmod_camera_set_position
function bbmod_camera_get_position()
{
	gml_pragma("forceinline");
	return global.__bbmodCameraPosition;
}

/// @func bbmod_camera_set_position(_position)
/// @desc Defines position of the camera passed to shaders.
/// @param {Struct.BBMOD_Vec3} _position The new camera position.
/// @see bbmod_camera_get_position
function bbmod_camera_set_position(_position)
{
	gml_pragma("forceinline");
	global.__bbmodCameraPosition = _position;
}

/// @func bbmod_camera_get_zfar()
/// @desc Retrieves distance to the far clipping plane passed to shaders.
/// @return {Real} The distance to the far clipping plane.
/// @see bbmod_camera_set_zfar
function bbmod_camera_get_zfar()
{
	gml_pragma("forceinline");
	return global.__bbmodZFar;
}

/// @func bbmod_camera_set_zfar(_value)
/// @desc Defines distance to the far clipping plane passed to shaders.
/// @param {Real} _value The new distance to the far clipping plane.
/// @see bbmod_camera_get_zfar
function bbmod_camera_set_zfar(_value)
{
	gml_pragma("forceinline");
	global.__bbmodZFar = _value;
}

/// @func bbmod_camera_get_exposure()
/// @desc Retrieves camera exposure value passed to shaders.
/// @return {Real} The camera exposure value.
/// @see bbmod_camera_set_exposure
function bbmod_camera_get_exposure()
{
	gml_pragma("forceinline");
	return global.__bbmodCameraExposure;
}

/// @func bbmod_camera_set_exposure(_exposure)
/// @desc Defines camera exposure value passed to shaders.
/// @param {Real} _exposure The new camera exposure value.
/// @see bbmod_camera_get_exposure
function bbmod_camera_set_exposure(_exposure)
{
	gml_pragma("forceinline");
	global.__bbmodCameraExposure = _exposure;
}