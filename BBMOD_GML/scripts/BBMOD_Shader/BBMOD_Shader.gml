/// @var {Struct.BBMOD_Shader/Undefined}
/// @private
global.__bbmodShaderCurrent = undefined;

/// @macro {Struct.BBMOD_Shader/Undefined} The current shader in use or
/// `undefined`.
/// @readonly
#macro BBMOD_SHADER_CURRENT global.__bbmodShaderCurrent

/// @func BBMOD_Shader(_shader, _vertexFormat)
/// @desc Base class for wrappers of raw GameMaker shader resources.
/// @param {Resource.GMShader} _shader The shader resource.
/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format required
/// by the shader.
/// @see BBMOD_VertexFormat
function BBMOD_Shader(_shader, _vertexFormat) constructor
{
	/// @var {Resource.GMShader} The shader resource.
	/// @readonly
	Raw = _shader;

	/// @var {Struct.BBMOD_VertexFormat} The vertex format required by the
	/// shader.
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
	/// @throws {BBMOD_Exception} If there is another shader already in use.
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
		__bbmod_shader_set_globals(Raw);
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
	/// @throws {BBMOD_Exception} If the shader is not currently in use.
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

/// @func __bbmod_shader_get_globals()
/// @desc
/// @return {Struct}
/// @private
function __bbmod_shader_get_globals()
{
	static _globals = [];
	return _globals;
}

/// @func __bbmod_shader_set_globals(_shader)
/// @desc
/// @param {Resource.GMShader} _shader
/// @private
function __bbmod_shader_set_globals(_shader)
{
	static _globals = __bbmod_shader_get_globals();
	var i = 0;
	repeat (array_length(_globals) / 3)
	{
		var _value = _globals[i + 2];
		if (_value != undefined)
		{
			switch (_globals[i + 1])
			{
			case BBMOD_EPropertyType.Float:
				shader_set_uniform_f(shader_get_uniform(_shader, _globals[i]), _value);
				break;

			case BBMOD_EPropertyType.Float2:
				shader_set_uniform_f(shader_get_uniform(_shader, _globals[i]), _value[0], _value[1]);
				break;

			case BBMOD_EPropertyType.Float3:
				shader_set_uniform_f(shader_get_uniform(_shader, _globals[i]), _value[0], _value[1], _value[2]);
				break;

			case BBMOD_EPropertyType.Float4:
				shader_set_uniform_f(shader_get_uniform(_shader, _globals[i]), _value[0], _value[1], _value[2], _value[3]);
				break;

			case BBMOD_EPropertyType.FloatArray:
				shader_set_uniform_f_array(shader_get_uniform(_shader, _globals[i]), _value);
				break;

			case BBMOD_EPropertyType.Int:
				shader_set_uniform_i(shader_get_uniform(_shader, _globals[i]), _value);
				break;

			case BBMOD_EPropertyType.Int2:
				shader_set_uniform_i(shader_get_uniform(_shader, _globals[i]), _value[0], _value[1]);
				break;

			case BBMOD_EPropertyType.Int3:
				shader_set_uniform_i(shader_get_uniform(_shader, _globals[i]), _value[0], _value[1], _value[2]);
				break;

			case BBMOD_EPropertyType.Int4:
				shader_set_uniform_i(shader_get_uniform(_shader, _globals[i]), _value[0], _value[1], _value[2], _value[3]);
				break;

			case BBMOD_EPropertyType.IntArray:
				shader_set_uniform_i_array(shader_get_uniform(_shader, _globals[i]), _value);
				break;

			case BBMOD_EPropertyType.Matrix:
				shader_set_uniform_matrix(shader_get_uniform(_shader, _globals[i]));
				break;

			case BBMOD_EPropertyType.MatrixArray:
				shader_set_uniform_matrix_array(shader_get_uniform(_shader, _globals[i]), _value);
				break;

			case BBMOD_EPropertyType.Sampler:
				texture_set_stage(shader_get_sampler_index(_shader, _globals[i]), _value);
				break;
			}
		}

		i += 3;
	}
}

/// @func __bbmod_shader_get_global_impl(_name, _type)
/// @desc
/// @param {String} _name
/// @param {BBMOD_EPropertyType} _name
/// @return {Real/Pointer.Texture/Undefined}
/// @private
function __bbmod_shader_get_global_impl(_name, _type)
{
	gml_pragma("forceinline");
	static _globals = __bbmod_shader_get_globals();
	var i = 0;
	repeat (array_length(_globals) / 3)
	{
		if (_globals[i] == _name && _globals[i + 1] == _type)
		{
			return _globals[i + 2];
		}
		i += 3;
	}
	return undefined;
}

/// @func __bbmod_shader_set_global_impl(_name, _type, _value)
/// @desc
/// @param {String} _name
/// @param {BBMOD_EPropertyType} _type
/// @param {Real/Pointer.Texture/Undefined} _value
/// @private
function __bbmod_shader_set_global_impl(_name, _type, _value)
{
	gml_pragma("forceinline");
	static _globals = __bbmod_shader_get_globals();
	var i = 0;
	repeat (array_length(_globals) / 3)
	{
		if (_globals[i] == _name && _globals[i + 1] == _type)
		{
			_globals[@ i + 2] = _value;
			return;
		}
		i += 3;
	}
	array_push(_globals, _name, _type, _value);
}

// TODO: Add docs

function bbmod_shader_get_global_f(_name)
{
	gml_pragma("forceinline");
	return __bbmod_shader_get_global_impl(_name, BBMOD_EPropertyType.Float);
}

function bbmod_shader_set_global_f(_name, _value)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, BBMOD_EPropertyType.Float, _value);
}

function bbmod_shader_get_global_f2(_name)
{
	gml_pragma("forceinline");
	return __bbmod_shader_get_global_impl(_name, BBMOD_EPropertyType.Float2);
}

function bbmod_shader_set_global_f2(_name, _v1, _v2)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, BBMOD_EPropertyType.Float2, [_v1, _v2]);
}

function bbmod_shader_get_global_f3(_name)
{
	gml_pragma("forceinline");
	return __bbmod_shader_get_global_impl(_name, BBMOD_EPropertyType.Float3);
}

function bbmod_shader_set_global_f3(_name, _v1, _v2, _v3)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, BBMOD_EPropertyType.Float3, [_v1, _v2, _v3]);
}

function bbmod_shader_get_global_f_array(_name)
{
	gml_pragma("forceinline");
	return __bbmod_shader_get_global_impl(_name, BBMOD_EPropertyType.FloatArray);
}

function bbmod_shader_set_global_f_array(_name, _fArray)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, BBMOD_EPropertyType.FloatArray, _fArray);
}

function bbmod_shader_get_global_i(_name)
{
	gml_pragma("forceinline");
	return __bbmod_shader_get_global_impl(_name, BBMOD_EPropertyType.Int);
}

function bbmod_shader_set_global_i(_name, _value)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, BBMOD_EPropertyType.Int, _value);
}

function bbmod_shader_get_global_i2(_name)
{
	gml_pragma("forceinline");
	return __bbmod_shader_get_global_impl(_name, BBMOD_EPropertyType.Int2);
}

function bbmod_shader_set_global_i2(_name, _v1, _v2)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, BBMOD_EPropertyType.Int2, [_v1, _v2]);
}

function bbmod_shader_get_global_i3(_name)
{
	gml_pragma("forceinline");
	return __bbmod_shader_get_global_impl(_name, BBMOD_EPropertyType.Int3);
}

function bbmod_shader_set_global_i3(_name, _v1, _v2, _v3)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, BBMOD_EPropertyType.Int3, [_v1, _v2, _v3]);
}

function bbmod_shader_get_global_i_array(_name)
{
	gml_pragma("forceinline");
	return __bbmod_shader_get_global_impl(_name, BBMOD_EPropertyType.IntArray);
}

function bbmod_shader_set_global_i_array(_name, _iArray)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, BBMOD_EPropertyType.IntArray, _iArray);
}

function bbmod_shader_get_global_matrix(_name)
{
	gml_pragma("forceinline");
	return __bbmod_shader_get_global_impl(_name, BBMOD_EPropertyType.Matrix);
}

function bbmod_shader_set_global_matrix(_name)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, BBMOD_EPropertyType.Matrix, true);
}

function bbmod_shader_get_global_matrix_array(_name)
{
	gml_pragma("forceinline");
	return __bbmod_shader_get_global_impl(_name, BBMOD_EPropertyType.MatrixArray);
}

function bbmod_shader_set_global_matrix_array(_name, _matrixArray)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, BBMOD_EPropertyType.MatrixArray, _matrixArray);
}

function bbmod_shader_get_global_sampler(_name)
{
	gml_pragma("forceinline");
	return __bbmod_shader_get_global_impl(_name, BBMOD_EPropertyType.Sampler);
}

function bbmod_shader_set_global_sampler(_name, _texture)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, BBMOD_EPropertyType.Sampler, _texture);
}
