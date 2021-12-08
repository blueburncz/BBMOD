/// @func BBMOD_Shader(_shader, _vertexFormat)
/// @extends BBMOD_BaseShader
/// @desc Base class for shaders used by BBMOD materials.
/// @param {shader} _shader The shader resource.
/// @param {BBMOD_VertexFormat} _vertexFormat The vertex format required by the shader.
/// @see BBMOD_Material
function BBMOD_Shader(_shader, _vertexFormat)
	: BBMOD_BaseShader(_shader, _vertexFormat) constructor
{
	UTextureOffset = get_uniform("bbmod_TextureOffset");

	UTextureScale = get_uniform("bbmod_TextureScale");

	UBones = get_uniform("bbmod_Bones");

	UBatchData = get_uniform("bbmod_BatchData");

	UAlphaTest = get_uniform("bbmod_AlphaTest");

	/// @func set_texture_offset(_offset)
	/// @desc Sets the `bbmod_TextureOffset` uniform to the given offset.
	/// @param {BBMOD_Vec2} _offset The new texture offset.
	/// @return {BBMOD_Shader} Returns `self`.
	static set_texture_offset = function (_offset) {
		gml_pragma("forceinline");
		return set_uniform_f2(UTextureOffset, _offset.X, _offset.Y);
	};

	/// @func set_texture_scale(_scale)
	/// @desc Sets the `bbmod_TextureScale` uniform to the given scale.
	/// @param {BBMOD_Vec2} _scale The new texture scale.
	/// @return {BBMOD_Shader} Returns `self`.
	static set_texture_scale = function (_scale) {
		gml_pragma("forceinline");
		return set_uniform_f2(UTextureScale, _scale.X, _scale.Y);
	};

	/// @func set_bones(_bones)
	/// @desc Sets the `bbmod_Bones` uniform.
	/// @param {real[]} _bones The array of new bone transforms.
	/// @return {BBMOD_Shader} Returns `self`.
	/// @see BBMOD_AnimationPlayer.get_transform
	static set_bones = function (_bones) {
		gml_pragma("forceinline");
		return set_uniform_f_array(UBones, _bones);
	};

	/// @func set_batch_data(_data)
	/// @desc Sets the `bbmod_BatchData` uniform.
	/// @param {real[]} _data The new dynamic batch data.
	/// @return {BBMOD_Shader} Returns `self`.
	static set_batch_data = function (_data) {
		gml_pragma("forceinline");
		return set_uniform_f_array(UBatchData, _data);
	};

	/// @func set_alpha_test(_value)
	/// @desc Sets the `bbmod_AlphaTest` uniform.
	/// @param {real} _value The new alpha test value.
	/// @return {BBMOD_Shader} Returns `self`.
	static set_alpha_test = function (_value) {
		gml_pragma("forceinline");
		return set_uniform_f(UAlphaTest, _value);
	};

	/// @func set_material(_material)
	/// @desc Sets shader uniforms using values from the material.
	/// @param {BBMOD_Material} _material The material to take the values from.
	/// @return {BBMOD_Shader} Returns `self`.
	/// @see BBMOD_Material
	static set_material = function (_material) {
		gml_pragma("forceinline");
		set_alpha_test(_material.AlphaTest);
		set_texture_offset(_material.TextureOffset);
		set_texture_scale(_material.TextureScale);
		return self;
	};
}