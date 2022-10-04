/// @func __bbmod_shader_get_map()
///
/// @desc Retrieves a map of registered shader.
///
/// @return {Id.DsMap<String, Struct.BBMOD_Shader>} The map of registered
/// shader.
///
/// @private
function __bbmod_shader_get_map()
{
	static _map = ds_map_create();
	return _map;
}

/// @func bbmod_shader_register(_name, _shader)
///
/// @desc Registers a shader.
///
/// @param {String} _name The name of the shader.
/// @param {Struct.BBMOD_Shader} _shader The shader.
function bbmod_shader_register(_name, _shader)
{
	gml_pragma("forceinline");
	static _map =__bbmod_shader_get_map();
	_map[? _name] = _shader;
	_shader.Name = _name;
}

/// @func bbmod_shader_exists(shader)
///
/// @desc Checks if there is a shader registered under the name.
///
/// @param {String} _name The name of the shader.
///
/// @return {Bool} Returns `true` if there is a shader registered under the
/// name.
function bbmod_shader_exists(_name)
{
	gml_pragma("forceinline");
	static _map =__bbmod_shader_get_map();
	return ds_map_exists(_map, _name);
}

/// @func bbmod_shader_get(_name)
///
/// @desc Retrieves a shader registered under the name.
///
/// @param {String} _name The name of the shader.
///
/// @return {Struct.BBMOD_Shader} The shader or `undefined` if no
/// shader registered under the given name exists.
function bbmod_shader_get(_name)
{
	gml_pragma("forceinline");
	static _map =__bbmod_shader_get_map();
	return _map[? _name];
}

/// @var {Struct.BBMOD_Shader}
/// @private
global.__bbmodShaderCurrent = undefined;

/// @macro {Struct.BBMOD_Shader} The current shader in use or
/// `undefined`.
/// @readonly
#macro BBMOD_SHADER_CURRENT global.__bbmodShaderCurrent

/// @func BBMOD_Shader(_shader, _vertexFormat)
///
/// @desc Base class for wrappers of raw GameMaker shader resources.
///
/// @param {Asset.GMShader} _shader The shader resource.
/// @param {Struct.BBMOD_VertexFormat} _vertexFormat The vertex format required
/// by the shader.
///
/// @see BBMOD_VertexFormat
function BBMOD_Shader(_shader, _vertexFormat) constructor
{
	/// @var {String} The name under which is the shader registered or
	/// `undefined`.
	/// @private
	Name = undefined;

	/// @var {Asset.GMShader} The shader resource.
	/// @readonly
	Raw = _shader;

	/// @var {Struct.BBMOD_VertexFormat} The vertex format required by the
	/// shader.
	/// @readonly
	VertexFormat = _vertexFormat;

	/// @func get_name()
	///
	/// @desc Retrieves the name of the shader.
	///
	/// @return {String} The name of the shader.
	static get_name = function () {
		gml_pragma("forceinline");
		return shader_get_name(Raw);
	};

	/// @func is_compiled()
	///
	/// @desc Checks whether the shader is compiled.
	///
	/// @return {Bool} Returns `true` if the shader is compiled.
	static is_compiled = function () {
		gml_pragma("forceinline");
		return shader_is_compiled(Raw);
	};

	/// @func get_uniform(_name)
	///
	/// @desc Retrieves a handle of a shader uniform.
	///
	/// @param {String} _name The name of the shader uniform.
	///
	/// @return {Id.Uniform} The handle of the shader uniform.
	static get_uniform = function (_name) {
		gml_pragma("forceinline");
		return shader_get_uniform(Raw, _name);
	};

	/// @func set_uniform_f(_handle, _value)
	///
	/// @desc Sets a `float` uniform.
	///
	/// @param {Id.Uniform} _handle The handle of the shader uniform.
	/// @param {Real} _value The new uniform value.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	///
	/// @see BBMOD_Shader.get_uniform
	///
	/// @deprecated Please use built-in `shader_set_uniform_f` instead!
	static set_uniform_f = function (_handle, _value) {
		gml_pragma("forceinline");
		shader_set_uniform_f(_handle, _value);
		return self;
	};

	/// @func set_uniform_f2(_handle, _val1, _val2)
	///
	/// @desc Sets a `vec2` uniform.
	///
	/// @param {Id.Uniform} _handle The handle of the shader uniform.
	/// @param {Real} _val1 The first vector component.
	/// @param {Real} _val2 The second vector component.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	///
	/// @see BBMOD_Shader.get_uniform
	///
	/// @deprecated Please use built-in `shader_set_uniform_f` instead!
	static set_uniform_f2 = function (_handle, _val1, _val2) {
		gml_pragma("forceinline");
		shader_set_uniform_f(_handle, _val1, _val2);
		return self;
	};

	/// @func set_uniform_f3(_handle, _val1, _val2, _val3)
	///
	/// @desc Sets a `vec3` uniform.
	///
	/// @param {Id.Uniform} _handle The handle of the shader uniform.
	/// @param {Real} _val1 The first vector component.
	/// @param {Real} _val2 The second vector component.
	/// @param {Real} _val3 The third vector component.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	///
	/// @see BBMOD_Shader.get_uniform
	///
	/// @deprecated Please use built-in `shader_set_uniform_f` instead!
	static set_uniform_f3 = function (_handle, _val1, _val2, _val3) {
		gml_pragma("forceinline");
		shader_set_uniform_f(_handle, _val1, _val2, _val3);
		return self;
	};

	/// @func set_uniform_f4(_handle, _val1, _val2, _val3, _val4)
	///
	/// @desc Sets a `vec4` uniform.
	///
	/// @param {Id.Uniform} _handle The handle of the shader uniform.
	/// @param {Real} _val1 The first vector component.
	/// @param {Real} _val2 The second vector component.
	/// @param {Real} _val3 The third vector component.
	/// @param {Real} _val4 The fourth vector component.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	///
	/// @see BBMOD_Shader.get_uniform
	///
	/// @deprecated Please use built-in `shader_set_uniform_f` instead!
	static set_uniform_f4 = function (_handle, _val1, _val2, _val3, _val4) {
		gml_pragma("forceinline");
		shader_set_uniform_f(_handle, _val1, _val2, _val3, _val4);
		return self;
	};

	/// @func set_uniform_f_array(_handle, _array)
	///
	/// @desc Sets a `float[]` uniform.
	///
	/// @param {Id.Uniform} _handle The handle of the shader uniform.
	/// @param {Array<Real>} _array The array of new values.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	///
	/// @see BBMOD_Shader.get_uniform
	///
	/// @deprecated Please use built-in `shader_set_uniform_f_array` instead!
	static set_uniform_f_array = function (_handle, _array) {
		gml_pragma("forceinline");
		shader_set_uniform_f_array(_handle, _array);
		return self;
	};

	/// @func set_uniform_i(_handle, _value)
	///
	/// @desc Sets an `int` uniform.
	///
	/// @param {Id.Uniform} _handle The handle of the shader uniform.
	/// @param {Real} _value The new uniform value.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	///
	/// @see BBMOD_Shader.get_uniform
	///
	/// @deprecated Please use built-in `shader_set_uniform_i` instead!
	static set_uniform_i = function (_handle, _value) {
		gml_pragma("forceinline");
		shader_set_uniform_i(_handle, _value);
		return self;
	};

	/// @func set_uniform_i2(_handle, _val1, _val2)
	///
	/// @desc Sets an `ivec2` uniform.
	///
	/// @param {Id.Uniform} _handle The handle of the shader uniform.
	/// @param {Real} _val1 The first vector component.
	/// @param {Real} _val2 The second vector component.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	///
	/// @see BBMOD_Shader.get_uniform
	///
	/// @deprecated Please use built-in `shader_set_uniform_i` instead!
	static set_uniform_i2 = function (_handle, _val1, _val2) {
		gml_pragma("forceinline");
		shader_set_uniform_i(_handle, _val1, _val2);
		return self;
	};

	/// @func set_uniform_i3(_handle, _val1, _val2, _val3)
	///
	/// @desc Sets an `ivec3` uniform.
	///
	/// @param {Id.Uniform} _handle The handle of the shader uniform.
	/// @param {Real} _val1 The first vector component.
	/// @param {Real} _val2 The second vector component.
	/// @param {Real} _val3 The third vector component.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	///
	/// @see BBMOD_Shader.get_uniform
	///
	/// @deprecated Please use built-in `shader_set_uniform_i` instead!
	static set_uniform_i3 = function (_handle, _val1, _val2, _val3) {
		gml_pragma("forceinline");
		shader_set_uniform_i(_handle, _val1, _val2, _val3);
		return self;
	};

	/// @func set_uniform_i4(_handle, _val1, _val2, _val3, _val4)
	///
	/// @desc Sets an `ivec4` uniform.
	///
	/// @param {Id.Uniform} _handle The handle of the shader uniform.
	/// @param {Real} _val1 The first vector component.
	/// @param {Real} _val2 The second vector component.
	/// @param {Real} _val3 The third vector component.
	/// @param {Real} _val4 The fourth vector component.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	///
	/// @see BBMOD_Shader.get_uniform
	///
	/// @deprecated Please use built-in `shader_set_uniform_i` instead!
	static set_uniform_i4 = function (_handle, _val1, _val2, _val3, _val4) {
		gml_pragma("forceinline");
		shader_set_uniform_i(_handle, _val1, _val2, _val3, _val4);
		return self;
	};

	/// @func set_uniform_i_array(_handle, _array)
	///
	/// @desc Sets an `int[]` uniform.
	///
	/// @param {Id.Uniform} _handle The handle of the shader uniform.
	/// @param {Array<Real>} _array The array of new values.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	///
	/// @see BBMOD_Shader.get_uniform
	///
	/// @deprecated Please use built-in `shader_set_uniform_i_array` instead!
	static set_uniform_i_array = function (_handle, _array) {
		gml_pragma("forceinline");
		shader_set_uniform_i_array(_handle, _array);
		return self;
	};

	/// @func set_uniform_matrix(_handle)
	///
	/// @desc Sets a shader uniform to the current transform matrix.
	///
	/// @param {Id.Uniform} _handle The handle of the shader uniform.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	///
	/// @see BBMOD_Shader.get_uniform
	///
	/// @deprecated Please use built-in `shader_set_uniform_matrix` instead!
	static set_uniform_matrix = function (_handle) {
		gml_pragma("forceinline");
		shader_set_uniform_matrix(_handle);
		return self;
	};

	/// @func set_uniform_matrix_array(_handle, _array)
	///
	/// @desc Sets a shader uniform to hold an array of matrix values.
	///
	/// @param {Id.Uniform} _handle The handle of the shader uniform.
	/// @param {Array<Real>} _array An array of real values.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	///
	/// @see BBMOD_Shader.get_uniform
	///
	/// @deprecated Please use built-in `shader_set_uniform_matrix_array` instead!
	static set_uniform_matrix_array = function (_handle, _array) {
		gml_pragma("forceinline");
		shader_set_uniform_matrix_array(_handle, _array);
		return self;
	};

	/// @func get_sampler_index(_name)
	///
	/// @desc Retrieves an index of a texture sampler.
	///
	/// @param {String} _name The name of the sampler.
	///
	/// @return {Real} The index of the texture sampler.
	static get_sampler_index = function (_name) {
		gml_pragma("forceinline");
		return shader_get_sampler_index(Raw, _name);
	};

	/// @func set_sampler(_index, _texture)
	///
	/// @desc Sets a texture sampler to the given texture.
	///
	/// @param {Real} _index The index of the texture sampler.
	/// @param {Pointer.Texture} _texture The new texture to sample.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	///
	/// @deprecated Please use built-in `texture_set_stage` instead!
	static set_sampler = function (_index, _texture) {
		gml_pragma("forceinline");
		texture_set_stage(_index, _texture);
		return self;
	};

	/// @func on_set()
	///
	/// @desc A function executed when the shader is set.
	static on_set = function () {
	};

	/// @func set()
	///
	/// @desc Sets the shader as the current shader.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	///
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
		on_set();
		__bbmod_shader_set_globals(Raw);
		return self;
	};

	/// @func set_material(_material)
	///
	/// @desc Sets shader uniforms using values from the material.
	///
	/// @param {Struct.BBMOD_BaseMaterial} _material The material to take the
	/// values from.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	///
	/// @see BBMOD_BaseMaterial
	static set_material = function (_material) {
		return self;
	};

	/// @func is_current()
	///
	/// @desc Checks if the shader is currently in use.
	///
	/// @return {Bool} Returns `true` if the shader is currently in use.
	///
	/// @see BBMOD_Shader.set
	static is_current = function () {
		gml_pragma("forceinline");
		return (BBMOD_SHADER_CURRENT == self);
	};

	/// @func on_reset()
	///
	/// @desc A function executed when the shader is reset.
	static on_reset = function () {
	};

	/// @func reset()
	///
	/// @desc Unsets the shaders.
	///
	/// @return {Struct.BBMOD_Shader} Returns `self`.
	///
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
///
/// @desc
///
/// @return {Array}
///
/// @private
function __bbmod_shader_get_globals()
{
	static _globals = [];
	return _globals;
}

/// @func __bbmod_shader_set_globals(_shader)
///
/// @desc
///
/// @param {Asset.GMShader} _shader
///
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
			case BBMOD_EShaderUniformType.Float:
				shader_set_uniform_f(shader_get_uniform(_shader, _globals[i]), _value);
				break;

			case BBMOD_EShaderUniformType.Float2:
				shader_set_uniform_f(shader_get_uniform(_shader, _globals[i]), _value[0], _value[1]);
				break;

			case BBMOD_EShaderUniformType.Float3:
				shader_set_uniform_f(shader_get_uniform(_shader, _globals[i]), _value[0], _value[1], _value[2]);
				break;

			case BBMOD_EShaderUniformType.Float4:
				shader_set_uniform_f(shader_get_uniform(_shader, _globals[i]), _value[0], _value[1], _value[2], _value[3]);
				break;

			case BBMOD_EShaderUniformType.FloatArray:
				shader_set_uniform_f_array(shader_get_uniform(_shader, _globals[i]), _value);
				break;

			case BBMOD_EShaderUniformType.Int:
				shader_set_uniform_i(shader_get_uniform(_shader, _globals[i]), _value);
				break;

			case BBMOD_EShaderUniformType.Int2:
				shader_set_uniform_i(shader_get_uniform(_shader, _globals[i]), _value[0], _value[1]);
				break;

			case BBMOD_EShaderUniformType.Int3:
				shader_set_uniform_i(shader_get_uniform(_shader, _globals[i]), _value[0], _value[1], _value[2]);
				break;

			case BBMOD_EShaderUniformType.Int4:
				shader_set_uniform_i(shader_get_uniform(_shader, _globals[i]), _value[0], _value[1], _value[2], _value[3]);
				break;

			case BBMOD_EShaderUniformType.IntArray:
				shader_set_uniform_i_array(shader_get_uniform(_shader, _globals[i]), _value);
				break;

			case BBMOD_EShaderUniformType.Matrix:
				shader_set_uniform_matrix(shader_get_uniform(_shader, _globals[i]));
				break;

			case BBMOD_EShaderUniformType.MatrixArray:
				shader_set_uniform_matrix_array(shader_get_uniform(_shader, _globals[i]), _value);
				break;

			case BBMOD_EShaderUniformType.Sampler:
				var _index = shader_get_sampler_index(_shader, _globals[i]);
				texture_set_stage(_index, _value.Texture);

				var _temp = _value.Filter;
				if (_temp != undefined)
				{
					gpu_set_tex_filter_ext(_index, _temp);
				}

				_temp = _value.MaxAniso;
				if (_temp != undefined)
				{
					gpu_set_tex_max_aniso_ext(_index, _temp);
				}

				_temp = _value.MaxMip;
				if (_temp != undefined)
				{
					gpu_set_tex_max_mip_ext(_index, _temp);
				}

				_temp = _value.MinMip;
				if (_temp != undefined)
				{
					gpu_set_tex_min_mip_ext(_index, _temp);
				}

				_temp = _value.MipBias;
				if (_temp != undefined)
				{
					gpu_set_tex_mip_bias_ext(_index, _temp);
				}

				_temp = _value.MipEnable;
				if (_temp != undefined)
				{
					gpu_set_tex_mip_enable_ext(_index, _temp);
				}

				_temp = _value.MipFilter;
				if (_temp != undefined)
				{
					gpu_set_tex_mip_filter_ext(_index, _temp);
				}

				_temp = _value.Repeat;
				if (_temp != undefined)
				{
					gpu_set_tex_repeat_ext(_index, _temp);
				}
				break;
			}
		}

		i += 3;
	}
}

/// @func bbmod_shader_clear_globals()
///
/// @desc Clears all global uniforms.
function bbmod_shader_clear_globals()
{
	gml_pragma("forceinline");
	static _globals = __bbmod_shader_get_globals();
	array_delete(_globals, 0, array_length(_globals));
}

/// @func bbmod_shader_get_global(_name)
///
/// @desc Retrieves the value of a global shader uniform.
///
/// @param {String} _name The name of the uniform.
///
/// @return {Any} The value of the uniform or `undefined` if it is not set.
/// The type of the returned value changes based on the type of the uniform.
function bbmod_shader_get_global(_name)
{
	gml_pragma("forceinline");
	static _globals = __bbmod_shader_get_globals();
	var i = 0;
	repeat (array_length(_globals) / 3)
	{
		if (_globals[i] == _name)
		{
			return _globals[i + 2];
		}
		i += 3;
	}
	return undefined;
}

/// @func __bbmod_shader_set_global_impl(_name, _type, _value)
///
/// @desc
///
/// @param {String} _name
/// @param {Real} _type
/// @param {Any} _value
///
/// @private
function __bbmod_shader_set_global_impl(_name, _type, _value)
{
	gml_pragma("forceinline");
	static _globals = __bbmod_shader_get_globals();
	var i = 0;
	repeat (array_length(_globals) / 3)
	{
		if (_globals[i] == _name)
		{
			_globals[@ i + 1] = _type;
			_globals[@ i + 2] = _value;
			return;
		}
		i += 3;
	}
	array_push(_globals, _name, _type, _value);
}

/// @func bbmod_shader_set_global_f(_name, _value)
///
/// @desc Sets a value of a global shader uniform of type float.
///
/// @param {String} _name The name of the uniform.
/// @param {Real} _value The new value of the uniform.
function bbmod_shader_set_global_f(_name, _value)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, BBMOD_EShaderUniformType.Float, _value);
}

/// @func bbmod_shader_set_global_f2(_name, _v1, _v2)
///
/// @desc Sets a value of a global shader uniform of type float2.
///
/// @param {String} _name The name of the uniform.
/// @param {Real} _v1 The first component of the new value.
/// @param {Real} _v2 The second component of the new value.
function bbmod_shader_set_global_f2(_name, _v1, _v2)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, BBMOD_EShaderUniformType.Float2, [_v1, _v2]);
}

/// @func bbmod_shader_set_global_f3(_name, _v1, _v2, _v3)
///
/// @desc Sets a value of a global shader uniform of type float3.
///
/// @param {String} _name The name of the uniform.
/// @param {Real} _v1 The first component of the new value.
/// @param {Real} _v2 The second component of the new value.
/// @param {Real} _v3 The third component of the new value.
function bbmod_shader_set_global_f3(_name, _v1, _v2, _v3)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, BBMOD_EShaderUniformType.Float3, [_v1, _v2, _v3]);
}

/// @func bbmod_shader_set_global_f4(_name, _v1, _v2, _v3)
///
/// @desc Sets a value of a global shader uniform of type float4.
///
/// @param {String} _name The name of the uniform.
/// @param {Real} _v1 The first component of the new value.
/// @param {Real} _v2 The second component of the new value.
/// @param {Real} _v3 The third component of the new value.
/// @param {Real} _v4 The fourth component of the new value.
function bbmod_shader_set_global_f4(_name, _v1, _v2, _v3, _v4)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, BBMOD_EShaderUniformType.Float4, [_v1, _v2, _v3, _v4]);
}

/// @func bbmod_shader_set_global_f_array(_name, _fArray)
///
/// @desc Sets a value of a global shader uniform of type float array.
///
/// @param {String} _name The name of the uniform.
/// @param {Array<Real>} _fArray The new array of values.
function bbmod_shader_set_global_f_array(_name, _fArray)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, BBMOD_EShaderUniformType.FloatArray, _fArray);
}

/// @func bbmod_shader_set_global_i(_name, _value)
///
/// @desc Sets a value of a global shader uniform of type int.
///
/// @param {String} _name The name of the uniform.
/// @param {Real} _value The new value of the uniform.
function bbmod_shader_set_global_i(_name, _value)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, BBMOD_EShaderUniformType.Int, _value);
}

/// @func bbmod_shader_set_global_i2(_name, _v1, _v2)
///
/// @desc Sets a value of a global shader uniform of type int2.
///
/// @param {String} _name The name of the uniform.
/// @param {Real} _v1 The first component of the new value.
/// @param {Real} _v2 The second component of the new value.
function bbmod_shader_set_global_i2(_name, _v1, _v2)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, BBMOD_EShaderUniformType.Int2, [_v1, _v2]);
}

/// @func bbmod_shader_set_global_i3(_name, _v1, _v2, _v3)
///
/// @desc Sets a value of a global shader uniform of type int3.
///
/// @param {String} _name The name of the uniform.
/// @param {Real} _v1 The first component of the new value.
/// @param {Real} _v2 The second component of the new value.
/// @param {Real} _v3 The third component of the new value.
function bbmod_shader_set_global_i3(_name, _v1, _v2, _v3)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, BBMOD_EShaderUniformType.Int3, [_v1, _v2, _v3]);
}

/// @func bbmod_shader_set_global_i4(_name, _v1, _v2, _v3)
///
/// @desc Sets a value of a global shader uniform of type int4.
///
/// @param {String} _name The name of the uniform.
/// @param {Real} _v1 The first component of the new value.
/// @param {Real} _v2 The second component of the new value.
/// @param {Real} _v3 The third component of the new value.
/// @param {Real} _v4 The fourth component of the new value.
function bbmod_shader_set_global_i4(_name, _v1, _v2, _v3, _v4)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, BBMOD_EShaderUniformType.Int4, [_v1, _v2, _v3, _v4]);
}

/// @func bbmod_shader_set_global_i_array(_name, _iArray)
///
/// @desc Sets a value of a global shader uniform of type int array.
///
/// @param {String} _name The name of the uniform.
/// @param {Array<Real>} _iArray The new array of values.
function bbmod_shader_set_global_i_array(_name, _iArray)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, BBMOD_EShaderUniformType.IntArray, _iArray);
}

/// @func bbmod_shader_set_global_matrix(_name)
///
/// @desc Enables passing of the current transform matrix to a global shader uniform.
///
/// @param {String} _name The name of the uniform.
function bbmod_shader_set_global_matrix(_name)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, BBMOD_EShaderUniformType.Matrix, true);
}

/// @func bbmod_shader_set_global_matrix_array(_name, _matrixArray)
///
/// @desc Sets a value of a global shader uniform of type matrix array.
///
/// @param {String} _name The name of the uniform.
/// @param {Array<Real>} _matrixArray The new array of values.
function bbmod_shader_set_global_matrix_array(_name, _matrixArray)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, BBMOD_EShaderUniformType.MatrixArray, _matrixArray);
}

/// @func bbmod_shader_set_global_sampler(_name, _texture)
///
/// @desc Sets a global shader texture sampler.
///
/// @param {String} _name The name of the sampler.
/// @param {Pointer.Texture} _texture The new texture.
function bbmod_shader_set_global_sampler(_name, _texture)
{
	gml_pragma("forceinline");
	__bbmod_shader_set_global_impl(_name, BBMOD_EShaderUniformType.Sampler,
		{
			Texture: _texture,
			Filter: undefined,
			MaxAniso: undefined,
			MaxMip: undefined,
			MinMip: undefined,
			MipBias: undefined,
			MipEnable: undefined,
			MipFilter: undefined,
			Repeat: undefined,
		});
}

/// @func bbmod_shader_set_global_sampler_filter(_name, _filter)
///
/// @desc Enables/disables linear filtering of a global texture sampler.
///
/// @param {String} _name The name of the sampler.
/// @param {Bool} _filter Use `true`/`false` to enable/disable linear texture
/// filtering or `undefined` to unset.
///
/// @note The sampler must be first set using
/// {@link bbmod_shader_set_global_sampler}!
function bbmod_shader_set_global_sampler_filter(_name, _filter)
{
	gml_pragma("forceinline");
	bbmod_shader_get_global(_name).Filter = _filter;
}

/// @func bbmod_shader_set_global_sampler_max_aniso(_name, _value)
///
/// @desc Sets maximum anisotropy level of a global texture sampler.
///
/// @param {String} _name The name of the sampler.
/// @param {Real} _value The new maximum anisotropy. Use `undefined` to unset.
///
/// @note The sampler must be first set using
/// {@link bbmod_shader_set_global_sampler}!
function bbmod_shader_set_global_sampler_max_aniso(_name, _value)
{
	gml_pragma("forceinline");
	bbmod_shader_get_global(_name).MaxAniso = _value;
}

/// @func bbmod_shader_set_global_sampler_max_mip(_name, _value)
///
/// @desc Sets maximum mipmap level of a global texture sampler.
///
/// @param {String} _name The name of the sampler.
/// @param {Real} _value The new maxmimum mipmap level or `undefined` to unset.
///
/// @note The sampler must be first set using
/// {@link bbmod_shader_set_global_sampler}!
function bbmod_shader_set_global_sampler_max_mip(_name, _value)
{
	gml_pragma("forceinline");
	bbmod_shader_get_global(_name).MaxMip = _value;
}

/// @func bbmod_shader_set_global_sampler_min_mip(_name, _value)
///
/// @desc Sets minimum mipmap level of a global texture sampler.
///
/// @param {String} _name The name of the sampler.
/// @param {Real} _value The new minimum mipmap level or `undefined` to unset.
///
/// @note The sampler must be first set using
/// {@link bbmod_shader_set_global_sampler}!
function bbmod_shader_set_global_sampler_min_mip(_name, _value)
{
	gml_pragma("forceinline");
	bbmod_shader_get_global(_name).MinMip = _value;
}

/// @func bbmod_shader_set_global_sampler_mip_bias(_name, _value)
///
/// @desc Sets mipmap bias of a global texture sampler.
///
/// @param {String} _name The name of the sampler.
/// @param {Real} _value The new bias or `undefined` to unset.
///
/// @note The sampler must be first set using
///
/// {@link bbmod_shader_set_global_sampler}!
function bbmod_shader_set_global_sampler_mip_bias(_name, _value)
{
	gml_pragma("forceinline");
	bbmod_shader_get_global(_name).MipBias = _value;
}

/// @func bbmod_shader_set_global_sampler_mip_enable(_name, _enable)
///
/// @desc Enable/disable mipmapping of a global texture sampler.
///
/// @param {String} _name The name of the sampler.
/// @param {Bool} _enable Use `true`/`false` to enable/disable mipmapping or
/// `undefined` to unset.
///
/// @note The sampler must be first set using
/// {@link bbmod_shader_set_global_sampler}!
function bbmod_shader_set_global_sampler_mip_enable(_name, _enable)
{
	gml_pragma("forceinline");
	bbmod_shader_get_global(_name).MipEnable = _enable;
}

/// @func bbmod_shader_set_global_sampler_mip_filter(_name, _filter)
///
/// @desc Sets mipmap filter function of a global texture sampler.
///
/// @param {String} _name The name of the sampler.
/// @param {Constant.MipFilter} _filter The new mipmap filter or `undefined` to
/// unset.
///
/// @note The sampler must be first set using
/// {@link bbmod_shader_set_global_sampler}!
function bbmod_shader_set_global_sampler_mip_filter(_name, _filter)
{
	gml_pragma("forceinline");
	bbmod_shader_get_global(_name).MipFilter = _filter;
}

/// @func bbmod_shader_set_global_sampler_repeat(_name, _enable)
///
/// @desc Enable/disable repeat of a global texture sampler.
///
/// @param {String} _name The name of the sampler.
/// @param {Bool} _enable Use `true`/`false` to enable/disable texture repeat or
/// `undefined` to unset.
///
/// @note The sampler must be first set using
/// {@link bbmod_shader_set_global_sampler}!
function bbmod_shader_set_global_sampler_repeat(_name, _enable)
{
	gml_pragma("forceinline");
	bbmod_shader_get_global(_name).Repeat = _enable;
}

/// @func bbmod_shader_unset_global(_name)
///
/// @desc Unsets a value of a global shader uniform.
///
/// @param {String} _name The name of the uniform.
function bbmod_shader_unset_global(_name)
{
	gml_pragma("forceinline");
	static _globals = __bbmod_shader_get_globals();
	var i = 0;
	repeat (array_length(_globals) / 3)
	{
		if (_globals[i] == _name)
		{
			array_delete(_globals, i, 3);
			return;
		}
		i += 3;
	}
}
