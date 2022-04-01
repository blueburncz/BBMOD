global.__bbmodShaderCurrent = undefined;

/// @macro {Struct.BBMOD_Shader/Undefined} The current shader in use or `undefined`.
/// @readonly
#macro BBMOD_SHADER_CURRENT global.__bbmodShaderCurrent

/// @func BBMOD_Shader(_shader, _vertexFormat)
/// @desc Base class for wrappers of raw GameMaker shader resources.
/// @param {Resource.GMShader} _shader The shader resource.
/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format required by the shader.
/// @see BBMOD_VertexFormat
function BBMOD_Shader(_shader, _vertexFormat) constructor
{
	/// @var {Resource.GMShader} The shader resource.
	/// @readonly
	Raw = _shader;

	/// @var {Struct.BBMOD_VertexFormat} The vertex format required by the shader.
	/// @readonly
	VertexFormat = _vertexFormat;

	/// @func get_name()
	/// @desc Retrieves the name of the shader.
	/// @return {String} The name of the shader.
	static get_name = function () {
		gml_pragma("forceinline");
		return shader_get_name(Raw);
	};

	/// @func is_compiled()
	/// @desc Checks whether the shader is compiled.
	/// @return {Bool} Returns `true` if the shader is compiled.
	static is_compiled = function () {
		gml_pragma("forceinline");
		return shader_is_compiled(Raw);
	};

	/// @func get_uniform(_name)
	/// @desc Retrieves a handle of a shader uniform.
	/// @param {String} _name The name of the shader uniform.
	/// @return {Id.Uniform} The handle of the shader uniform.
	static get_uniform = function (_name) {
		gml_pragma("forceinline");
		return shader_get_uniform(Raw, _name);
	};

	/// @func set_uniform_f(_handle, _value)
	/// @desc Sets a `float` uniform.
	/// @param {Id.Uniform} _handle The handle of the shader uniform.
	/// @param {Real} _value The new uniform value.
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	/// @see BBMOD_Shader.get_uniform
	static set_uniform_f = function (_handle, _value) {
		gml_pragma("forceinline");
		shader_set_uniform_f(_handle, _value);
		return self;
	};

	/// @func set_uniform_f2(_handle, _val1, _val2)
	/// @desc Sets a `vec2` uniform.
	/// @param {Id.Uniform} _handle The handle of the shader uniform.
	/// @param {Real} _val1 The first vector component.
	/// @param {Real} _val2 The second vector component.
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	/// @see BBMOD_Shader.get_uniform
	static set_uniform_f2 = function (_handle, _val1, _val2) {
		gml_pragma("forceinline");
		shader_set_uniform_f(_handle, _val1, _val2);
		return self;
	};

	/// @func set_uniform_f3(_handle, _val1, _val2, _val3)
	/// @desc Sets a `vec3` uniform.
	/// @param {Id.Uniform} _handle The handle of the shader uniform.
	/// @param {Real} _val1 The first vector component.
	/// @param {Real} _val2 The second vector component.
	/// @param {Real} _val3 The third vector component.
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	/// @see BBMOD_Shader.get_uniform
	static set_uniform_f3 = function (_handle, _val1, _val2, _val3) {
		gml_pragma("forceinline");
		shader_set_uniform_f(_handle, _val1, _val2, _val3);
		return self;
	};

	/// @func set_uniform_f4(_handle, _val1, _val2, _val3, _val4)
	/// @desc Sets a `vec4` uniform.
	/// @param {Id.Uniform} _handle The handle of the shader uniform.
	/// @param {Real} _val1 The first vector component.
	/// @param {Real} _val2 The second vector component.
	/// @param {Real} _val3 The third vector component.
	/// @param {Real} _val4 The fourth vector component.
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	/// @see BBMOD_Shader.get_uniform
	static set_uniform_f4 = function (_handle, _val1, _val2, _val3, _val4) {
		gml_pragma("forceinline");
		shader_set_uniform_f(_handle, _val1, _val2, _val3, _val4);
		return self;
	};

	/// @func set_uniform_f_array(_handle, _array)
	/// @desc Sets a `float[]` uniform.
	/// @param {Id.Uniform} _handle The handle of the shader uniform.
	/// @param {Array.Real} _array The array of new values.
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	/// @see BBMOD_Shader.get_uniform
	static set_uniform_f_array = function (_handle, _array) {
		gml_pragma("forceinline");
		shader_set_uniform_f_array(_handle, _array);
		return self;
	};

	/// @func set_uniform_i(_handle, _value)
	/// @desc Sets an `int` uniform.
	/// @param {Id.Uniform} _handle The handle of the shader uniform.
	/// @param {Real} _value The new uniform value.
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	/// @see BBMOD_Shader.get_uniform
	static set_uniform_i = function (_handle, _value) {
		gml_pragma("forceinline");
		shader_set_uniform_i(_handle, _value);
		return self;
	};

	/// @func set_uniform_i2(_handle, _val1, _val2)
	/// @desc Sets an `ivec2` uniform.
	/// @param {Id.Uniform} _handle The handle of the shader uniform.
	/// @param {Real} _val1 The first vector component.
	/// @param {Real} _val2 The second vector component.
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	/// @see BBMOD_Shader.get_uniform
	static set_uniform_i2 = function (_handle, _val1, _val2) {
		gml_pragma("forceinline");
		shader_set_uniform_i(_handle, _val1, _val2);
		return self;
	};

	/// @func set_uniform_i3(_handle, _val1, _val2, _val3)
	/// @desc Sets an `ivec3` uniform.
	/// @param {Id.Uniform} _handle The handle of the shader uniform.
	/// @param {Real} _val1 The first vector component.
	/// @param {Real} _val2 The second vector component.
	/// @param {Real} _val3 The third vector component.
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	/// @see BBMOD_Shader.get_uniform
	static set_uniform_i3 = function (_handle, _val1, _val2, _val3) {
		gml_pragma("forceinline");
		shader_set_uniform_i(_handle, _val1, _val2, _val3);
		return self;
	};

	/// @func set_uniform_i4(_handle, _val1, _val2, _val3, _val4)
	/// @desc Sets an `ivec4` uniform.
	/// @param {Id.Uniform} _handle The handle of the shader uniform.
	/// @param {Real} _val1 The first vector component.
	/// @param {Real} _val2 The second vector component.
	/// @param {Real} _val3 The third vector component.
	/// @param {Real} _val4 The fourth vector component.
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	/// @see BBMOD_Shader.get_uniform
	static set_uniform_i4 = function (_handle, _val1, _val2, _val3, _val4) {
		gml_pragma("forceinline");
		shader_set_uniform_i(_handle, _val1, _val2, _val3, _val4);
		return self;
	};

	/// @func set_uniform_i_array(_handle, _array)
	/// @desc Sets an `int[]` uniform.
	/// @param {Id.Uniform} _handle The handle of the shader uniform.
	/// @param {Array.Real} _array The array of new values.
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	/// @see BBMOD_Shader.get_uniform
	static set_uniform_i_array = function (_handle, _array) {
		gml_pragma("forceinline");
		shader_set_uniform_i_array(_handle, _array);
		return self;
	};

	/// @func set_uniform_matrix(_handle)
	/// @desc Sets a shader uniform to the current transform matrix.
	/// @param {Id.Uniform} _handle The handle of the shader uniform.
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	/// @see BBMOD_Shader.get_uniform
	static set_uniform_matrix = function (_handle) {
		gml_pragma("forceinline");
		shader_set_uniform_matrix(_handle);
		return self;
	};

	/// @func set_uniform_matrix_array(_hande, _array)
	/// @desc Sets a shader uniform to hold an array of matrix values.
	/// @param {Array.Real} _array An array of real values.
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	/// @see BBMOD_Shader.get_uniform
	static set_uniform_matrix_array = function (_handle, _array) {
		gml_pragma("forceinline");
		shader_set_uniform_matrix_array(_handle, _array);
		return self;
	};

	/// @func get_sampler_index(_name)
	/// @desc Retrieves an index of a texture sampler.
	/// @param {String} _name The name of the sampler.
	/// @return {Real} The index of the texture sampler.
	static get_sampler_index = function (_name) {
		gml_pragma("forceinline");
		return shader_get_sampler_index(Raw, _name);
	};

	/// @func set_sampler(_index, _texture)
	/// @desc Sets a texture sampler to the given texture.
	/// @param {Real} _index The index of the texture sampler.
	/// @param {Pointer.Texture} _texture The new texture to sample.
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	static set_sampler = function (_index, _texture) {
		gml_pragma("forceinline");
		texture_set_stage(_index, _texture);
		return self;
	};

	/// @func on_set()
	/// @desc A function executed when the shader is set.
	static on_set = function () {
	};

	/// @func set()
	/// @desc Sets the shader as the current shader.
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	/// @throws {Struct.BBMOD_Exception} If there is another shader already in use.
	static set = function () {
		gml_pragma("forceinline");
		if (BBMOD_SHADER_CURRENT != undefined)
		{
			if (BBMOD_SHADER_CURRENT != self)
			{
				throw new BBMOD_Exception("Another shader is already active!");
			}
			return self;
		}
		shader_set(Raw);
		BBMOD_SHADER_CURRENT = self;
		on_set();
		return self;
	};

	/// @func is_current()
	/// @desc Checks if the shader is currently in use.
	/// @return {Bool} Returns `true` if the shader is currently in use.
	/// @see BBMOD_Shader.set
	static is_current = function () {
		gml_pragma("forceinline");
		return (BBMOD_SHADER_CURRENT == self);
	};

	/// @func on_reset()
	/// @desc A function executed when the shader is reset.
	static on_reset = function () {
	};

	/// @func reset()
	/// @desc Unsets the shaders.
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	/// @throws {Struct.BBMOD_Exception} If the shader is not currently in use.
	static reset = function () {
		gml_pragma("forceinline");
		if (!is_current())
		{
			throw new BBMOD_Exception("Cannot reset a shader which is not active!");
		}
		shader_reset();
		BBMOD_SHADER_CURRENT = undefined;
		on_reset();
		return self;
	};
}