/// @module Core

/// @var {Struct.BBMOD_MaterialPropertyBlock}
/// @private
global.__bbmodMaterialProps = undefined;

/// @func BBMOD_MaterialPropertyBlock()
///
/// @desc A collection of material properties. Useful in case you want to use
/// the same material when rendering multiple models and only change some of
/// its properties for each model.
///
/// @example
/// ```gml
/// /// @desc Create event
/// // Controls for silhouette effect
/// silhouetteColor = BBMOD_C_RED;
/// silhouetteStrength = 1.0;
///
/// // Create a new material property block
/// materialProps = new BBMOD_MaterialPropertyBlock();
///
/// /// @desc Step event
/// // Update material property block's properties using the local variables
/// materialProps.set_color("u_vSilhouetteColor", silhouetteColor);
/// materialProps.set_float("u_fSilhouetteStrength", silhouetteStrength);
///
/// /// @desc Draw event
/// // Set the material property block as the current one
/// bbmod_material_props_set(materialProps);
/// // Render a model using the properties
/// model.render();
/// // Unset the properties so they aren't applied to other models too
/// bbmod_material_props_reset();
///
/// // Note: This works with method submit too, e.g.:
/// //bbmod_material_reset();
/// //bbmod_material_props_set(materialProps);
/// //model.submit();
/// //bbmod_material_props_reset();
/// //bbmod_material_reset();
/// ```
///
/// @see bbmod_material_props_set
/// @see bbmod_material_props_get
/// @see bbmod_material_props_reset
function BBMOD_MaterialPropertyBlock() constructor
{
	/// @var {Array<String>}
	/// @private
	__names = [];

	/// @var {Array<Real>}
	/// @private
	__types = [];

	/// @var {Array}
	/// @private
	__values = [];

	/// @func copy(_dest)
	///
	/// @desc Shallowly copies properties into another material property block.
	///
	/// @param {Struct.BBMOD_MaterialPropertyBlock} _dest The material property
	/// block to copy properties into.
	///
	/// @return {Struct.BBMOD_MaterialPropertyBlock} Returns `self`.
	///
	/// @example
	/// ```gml
	/// // Create one set of props
	/// var _materialPropsA = new BBMOD_MaterialPropertyBlock();
	/// _materialPropsA.set_float("u_fA", 1.0);
	///
	/// // Create a different set of props
	/// var _materialPropsB = new BBMOD_MaterialPropertyBlock();
	/// _materialPropsB.set_float("u_fB", 1.0);
	///
	/// // Override props B with props A
	/// _materialPropsA.copy(_materialPropsB);
	/// show_debug_message(_materialPropsA.get_names()); // Prints ["u_fA"]
	/// show_debug_message(_materialPropsB.get_names()); // Also prints ["u_fA"]!
	/// ```
	///
	/// @note This removes properties that the other material property block has
	/// before this one's are copied into it!
	static copy = function (_dest)
	{
		gml_pragma("forceinline");
		_dest.__names = bbmod_array_clone(__names);
		_dest.__types = bbmod_array_clone(__types);
		_dest.__values = bbmod_array_clone(__values);
		return self;
	};

	/// @func clone()
	///
	/// @desc Creates a shallow clone of the material property block.
	///
	/// @return {Struct.BBMOD_MaterialPropertyBlock} Returns the created clone.
	static clone = function ()
	{
		gml_pragma("forceinline");
		var _clone = new BBMOD_MaterialPropertyBlock();
		copy(_clone);
		return _clone;
	};

	/// @func set(_name, _type, _value)
	///
	/// @desc Sets a property to given value.
	///
	/// @param {String} _name The name of the property (shader uniform name).
	/// @param {Real} _type The property type. Use values from {@link BBMOD_EShaderUniformType}.
	/// @param {Any} _value The property value. Must match the shader uniform type!
	///
	/// @return {Struct.BBMOD_MaterialPropertyBlock} Returns `self`.
	///
	/// @example
	/// ```gml
	/// var _materialProps = new BBMOD_MaterialPropertyBlock();
	/// _materialProps.set("u_fOutlineStrength", BBMOD_EShaderUniformType.Float, 0.5);
	/// _materialProps.set("u_vOutlineColor", BBMOD_EShaderUniformType.Color, BBMOD_C_AQUA);
	/// ```
	///
	/// @note You cannot have multiple properties with the same name but
	/// a different type! The property type and value is overriden each time you
	/// use this method!
	///
	/// @see BBMOD_MaterialPropertyBlock.set_color
	/// @see BBMOD_MaterialPropertyBlock.set_float
	/// @see BBMOD_MaterialPropertyBlock.set_float2
	/// @see BBMOD_MaterialPropertyBlock.set_float3
	/// @see BBMOD_MaterialPropertyBlock.set_float4
	/// @see BBMOD_MaterialPropertyBlock.set_float_array
	/// @see BBMOD_MaterialPropertyBlock.set_int
	/// @see BBMOD_MaterialPropertyBlock.set_int2
	/// @see BBMOD_MaterialPropertyBlock.set_int3
	/// @see BBMOD_MaterialPropertyBlock.set_int4
	/// @see BBMOD_MaterialPropertyBlock.set_int_array
	/// @see BBMOD_MaterialPropertyBlock.set_matrix
	/// @see BBMOD_MaterialPropertyBlock.set_matrix_array
	/// @see BBMOD_MaterialPropertyBlock.set_sampler
	static set = function (_name, _type, _value)
	{
		gml_pragma("forceinline");
		for (var i = array_length(__names) - 1; i >= 0; --i)
		{
			if (__names[i] == _name)
			{
				__types[@ i] = _type;
				__values[@ i] = _value;
				return self;
			}
		}
		array_push(__names, _name);
		array_push(__types, _type);
		array_push(__values, _value);
		return self;
	};

	/// @func set_color(_name, _value)
	///
	/// @desc Sets a value of a {@link BBMOD_EShaderUniformType.Color} property.
	///
	/// @param {String} _name The name of the property (shader uniform name).
	/// @param {Struct.BBMOD_Color} _value The property value.
	///
	/// @return {Struct.BBMOD_MaterialPropertyBlock} Returns `self`.
	///
	/// @example
	/// ```gml
	/// var _materialProps = new BBMOD_MaterialPropertyBlock();
	/// _materialProps.set_color("u_vColor", BBMOD_C_AQUA);
	/// ```
	///
	/// @note This is a shorthand for
	/// `set(name, BBMOD_EShaderUniformType.Color, value)`.
	///
	/// @see BBMOD_MaterialPropertyBlock.set
	static set_color = function (_name, _value)
	{
		gml_pragma("forceinline");
		set(_name, BBMOD_EShaderUniformType.Color, _value);
		return self;
	};

	/// @func set_float(_name, _value)
	///
	/// @desc Sets a value of a {@link BBMOD_EShaderUniformType.Float} property.
	///
	/// @param {String} _name The name of the property (shader uniform name).
	/// @param {Real} _value The property value.
	///
	/// @return {Struct.BBMOD_MaterialPropertyBlock} Returns `self`.
	///
	/// @example
	/// ```gml
	/// var _materialProps = new BBMOD_MaterialPropertyBlock();
	/// _materialProps.set_float("u_fFloat", 1.0);
	/// ```
	///
	/// @note This is a shorthand for
	/// `set(name, BBMOD_EShaderUniformType.Float, value)`.
	///
	/// @see BBMOD_MaterialPropertyBlock.set
	static set_float = function (_name, _value)
	{
		gml_pragma("forceinline");
		set(_name, BBMOD_EShaderUniformType.Float, _value);
		return self;
	};

	/// @func set_float2(_name, _value)
	///
	/// @desc Sets a value of a {@link BBMOD_EShaderUniformType.Float2} property.
	///
	/// @param {String} _name The name of the property (shader uniform name).
	/// @param {Struct.BBMOD_Vec2} _value The property value.
	///
	/// @return {Struct.BBMOD_MaterialPropertyBlock} Returns `self`.
	///
	/// @example
	/// ```gml
	/// var _materialProps = new BBMOD_MaterialPropertyBlock();
	/// _materialProps.set_float2("u_vFloat2", new BBMOD_Vec2(1.0, 2.0));
	/// ```
	///
	/// @note This is a shorthand for
	/// `set(name, BBMOD_EShaderUniformType.Float2, value)`.
	///
	/// @see BBMOD_MaterialPropertyBlock.set
	static set_float2 = function (_name, _value)
	{
		gml_pragma("forceinline");
		set(_name, BBMOD_EShaderUniformType.Float2, _value);
		return self;
	};

	/// @func set_float3(_name, _value)
	///
	/// @desc Sets a value of a {@link BBMOD_EShaderUniformType.Float3} property.
	///
	/// @param {String} _name The name of the property (shader uniform name).
	/// @param {Struct.BBMOD_Vec3} _value The property value.
	///
	/// @return {Struct.BBMOD_MaterialPropertyBlock} Returns `self`.
	///
	/// @example
	/// ```gml
	/// var _materialProps = new BBMOD_MaterialPropertyBlock();
	/// _materialProps.set_float3("u_vFloat3", new BBMOD_Vec3(1.0, 2.0, 3.0));
	/// ```
	///
	/// @note This is a shorthand for
	/// `set(name, BBMOD_EShaderUniformType.Float3, value)`.
	///
	/// @see BBMOD_MaterialPropertyBlock.set
	static set_float3 = function (_name, _value)
	{
		gml_pragma("forceinline");
		set(_name, BBMOD_EShaderUniformType.Float3, _value);
		return self;
	};

	/// @func set_float4(_name, _value)
	///
	/// @desc Sets a value of a {@link BBMOD_EShaderUniformType.Float4} property.
	///
	/// @param {String} _name The name of the property (shader uniform name).
	/// @param {Struct.BBMOD_Vec4, Struct.BBMOD_Quaternion} _value The property
	/// value.
	///
	/// @return {Struct.BBMOD_MaterialPropertyBlock} Returns `self`.
	///
	/// @example
	/// ```gml
	/// var _materialProps = new BBMOD_MaterialPropertyBlock();
	/// _materialProps.set_float4("u_vFloat4", new BBMOD_Vec4(1.0, 2.0, 3.0, 4.0));
	/// _materialProps.set_float4("u_vQuaternion", new BBMOD_Quaternion());
	/// ```
	///
	/// @note This is a shorthand for
	/// `set(name, BBMOD_EShaderUniformType.Float4, value)`.
	///
	/// @see BBMOD_MaterialPropertyBlock.set
	static set_float4 = function (_name, _value)
	{
		gml_pragma("forceinline");
		set(_name, BBMOD_EShaderUniformType.Float4, _value);
		return self;
	};

	/// @func set_float_array(_name, _value)
	///
	/// @desc Sets a value of a {@link BBMOD_EShaderUniformType.FloatArray}
	/// property.
	///
	/// @param {String} _name The name of the property (shader uniform name).
	/// @param {Array<Real>} _value The property value.
	///
	/// @return {Struct.BBMOD_MaterialPropertyBlock} Returns `self`.
	///
	/// @example
	/// ```gml
	/// var _materialProps = new BBMOD_MaterialPropertyBlock();
	/// _materialProps.set_float_array("u_vFloatArray", [1.0, 2.0, 3.0, 4.0, 5.0]);
	/// ```
	///
	/// @note This is a shorthand for
	/// `set(name, BBMOD_EShaderUniformType.FloatArray, value)`.
	///
	/// @see BBMOD_MaterialPropertyBlock.set
	static set_float_array = function (_name, _value)
	{
		gml_pragma("forceinline");
		set(_name, BBMOD_EShaderUniformType.FloatArray, _value);
		return self;
	};

	/// @func set_int(_name, _value)
	///
	/// @desc Sets a value of a {@link BBMOD_EShaderUniformType.Int} property.
	///
	/// @param {String} _name The name of the property (shader uniform name).
	/// @param {Real} _value The property value.
	///
	/// @return {Struct.BBMOD_MaterialPropertyBlock} Returns `self`.
	///
	/// @example
	/// ```gml
	/// var _materialProps = new BBMOD_MaterialPropertyBlock();
	/// _materialProps.set_int("u_iInt", 1);
	/// ```
	///
	/// @note This is a shorthand for
	/// `set(name, BBMOD_EShaderUniformType.Int, value)`.
	///
	/// @see BBMOD_MaterialPropertyBlock.set
	static set_int = function (_name, _value)
	{
		gml_pragma("forceinline");
		set(_name, BBMOD_EShaderUniformType.Int, _value);
		return self;
	};

	/// @func set_int2(_name, _value)
	///
	/// @desc Sets a value of a {@link BBMOD_EShaderUniformType.Int2} property.
	///
	/// @param {String} _name The name of the property (shader uniform name).
	/// @param {Struct.BBMOD_Vec2} _value The property value.
	///
	/// @return {Struct.BBMOD_MaterialPropertyBlock} Returns `self`.
	///
	/// @example
	/// ```gml
	/// var _materialProps = new BBMOD_MaterialPropertyBlock();
	/// _materialProps.set_int2("u_vInt2", new BBMOD_Vec2(1, 2));
	/// ```
	///
	/// @note This is a shorthand for
	/// `set(name, BBMOD_EShaderUniformType.Int2, value)`.
	///
	/// @see BBMOD_MaterialPropertyBlock.set
	static set_int2 = function (_name, _value)
	{
		gml_pragma("forceinline");
		set(_name, BBMOD_EShaderUniformType.Int2, _value);
		return self;
	};

	/// @func set_int3(_name, _value)
	///
	/// @desc Sets a value of a {@link BBMOD_EShaderUniformType.Int3} property.
	///
	/// @param {String} _name The name of the property (shader uniform name).
	/// @param {Struct.BBMOD_Vec3} _value The property value.
	///
	/// @return {Struct.BBMOD_MaterialPropertyBlock} Returns `self`.
	///
	/// @example
	/// ```gml
	/// var _materialProps = new BBMOD_MaterialPropertyBlock();
	/// _materialProps.set_int3("u_vInt3", new BBMOD_Vec3(1, 2, 3));
	/// ```
	///
	/// @note This is a shorthand for
	/// `set(name, BBMOD_EShaderUniformType.Int3, value)`.
	///
	/// @see BBMOD_MaterialPropertyBlock.set
	static set_int3 = function (_name, _value)
	{
		gml_pragma("forceinline");
		set(_name, BBMOD_EShaderUniformType.Int3, _value);
		return self;
	};

	/// @func set_int4(_name, _value)
	///
	/// @desc Sets a value of a {@link BBMOD_EShaderUniformType.Int4} property.
	///
	/// @param {String} _name The name of the property (shader uniform name).
	/// @param {Struct.BBMOD_Vec4} _value The property value.
	///
	/// @return {Struct.BBMOD_MaterialPropertyBlock} Returns `self`.
	///
	/// @example
	/// ```gml
	/// var _materialProps = new BBMOD_MaterialPropertyBlock();
	/// _materialProps.set_int4("u_vInt4", new BBMOD_Vec4(1, 2, 3, 4));
	/// ```
	///
	/// @note This is a shorthand for
	/// `set(name, BBMOD_EShaderUniformType.Int4, value)`.
	///
	/// @see BBMOD_MaterialPropertyBlock.set
	static set_int4 = function (_name, _value)
	{
		gml_pragma("forceinline");
		set(_name, BBMOD_EShaderUniformType.Int4, _value);
		return self;
	};

	/// @func set_int_array(_name, _value)
	///
	/// @desc Sets a value of a {@link BBMOD_EShaderUniformType.IntArray}
	/// property.
	///
	/// @param {String} _name The name of the property (shader uniform name).
	/// @param {Array<Real>} _value The property value.
	///
	/// @return {Struct.BBMOD_MaterialPropertyBlock} Returns `self`.
	///
	/// @example
	/// ```gml
	/// var _materialProps = new BBMOD_MaterialPropertyBlock();
	/// _materialProps.set_int_array("u_vIntArray", [1, 2, 3, 4, 5]);
	/// ```
	///
	/// @note This is a shorthand for
	/// `set(name, BBMOD_EShaderUniformType.IntArray, value)`.
	///
	/// @see BBMOD_MaterialPropertyBlock.set
	static set_int_array = function (_name, _value)
	{
		gml_pragma("forceinline");
		set(_name, BBMOD_EShaderUniformType.IntArray, _value);
		return self;
	};

	/// @func set_matrix(_name)
	///
	/// @desc Sets a value of a {@link BBMOD_EShaderUniformType.Matrix} property.
	///
	/// @param {String} _name The name of the property (shader uniform name).
	///
	/// @return {Struct.BBMOD_MaterialPropertyBlock} Returns `self`.
	///
	/// @example
	/// ```gml
	/// var _materialProps = new BBMOD_MaterialPropertyBlock();
	/// _materialProps.set_matrix("u_mMatrix");
	/// ```
	///
	/// @note This is a shorthand for
	/// `set(name, BBMOD_EShaderUniformType.Matrix, undefined)`.
	///
	/// @see BBMOD_MaterialPropertyBlock.set
	static set_matrix = function (_name)
	{
		gml_pragma("forceinline");
		set(_name, BBMOD_EShaderUniformType.Matrix, undefined);
		return self;
	};

	/// @func set_matrix_array(_name, _value)
	///
	/// @desc Sets a value of a {@link BBMOD_EShaderUniformType.MatrixArray}
	/// property.
	///
	/// @param {String} _name The name of the property (shader uniform name).
	/// @param {Array<Real>} _value The property value.
	///
	/// @return {Struct.BBMOD_MaterialPropertyBlock} Returns `self`.
	///
	/// @example
	/// ```gml
	/// var _materialProps = new BBMOD_MaterialPropertyBlock();
	/// _materialProps.set_matrix_array("u_mMatrixArray1", matrix_build_identity());
	/// _materialProps.set_matrix_array("u_mMatrixArray2", new BBMOD_Matrix().Raw);
	/// ```
	///
	/// @note This is a shorthand for
	/// `set(name, BBMOD_EShaderUniformType.MatrixArray, value)`.
	///
	/// @see BBMOD_MaterialPropertyBlock.set
	/// @see BBMOD_Matrix
	static set_matrix_array = function (_name, _value)
	{
		gml_pragma("forceinline");
		set(_name, BBMOD_EShaderUniformType.MatrixArray, _value);
		return self;
	};

	/// @func set_sampler(_name, _value)
	///
	/// @desc Sets a value of a {@link BBMOD_EShaderUniformType.Sampler}
	/// property.
	///
	/// @param {String} _name The name of the property (shader uniform name).
	/// @param {Pointer.Texture} _value The property value.
	///
	/// @return {Struct.BBMOD_MaterialPropertyBlock} Returns `self`.
	///
	/// @example
	/// ```gml
	/// var _materialProps = new BBMOD_MaterialPropertyBlock();
	/// _materialProps.set_sampler("u_texSampler", sprite_get_texture(SprTexture, 0));
	/// ```
	///
	/// @note This is a shorthand for
	/// `set(name, BBMOD_EShaderUniformType.Sampler, value)`.
	///
	/// @see BBMOD_MaterialPropertyBlock.set
	static set_sampler = function (_name, _value)
	{
		gml_pragma("forceinline");
		set(_name, BBMOD_EShaderUniformType.Sampler, _value);
		return self;
	};

	/// @func has(_name)
	///
	/// @desc Checks whether the material property block has a property
	/// with given name.
	///
	/// @param {String} _name The name of the property to check.
	///
	/// @return {Bool} Returns `true` if the material property block has
	/// a property with given name.
	static has = function (_name)
	{
		gml_pragma("forceinline");
		for (var i = array_length(__names) - 1; i >= 0; --i)
		{
			if (__names[i] == _name)
			{
				return true;
			}
		}
		return false;
	};

	/// @func get(_name)
	///
	/// @desc Retrieves a value of a property.
	///
	/// @param {String} _name The property to get value of.
	///
	/// @return {Any} The property value.
	static get = function (_name)
	{
		gml_pragma("forceinline");
		for (var i = array_length(__names) - 1; i >= 0; --i)
		{
			if (__names[i] == _name)
			{
				return __values[i];
			}
		}
		return undefined;
	};

	/// @func get_names()
	///
	/// @desc Retreives an array of names of properties that the material
	/// property block has.
	///
	/// @return {Array<String>} The array of property names.
	static get_names = function ()
	{
		gml_pragma("forceinline");
		return __names;
	};

	/// @func remove(_name)
	///
	/// @desc Removes a property with given name.
	///
	/// @param {String} _name The name of the property to remove.
	///
	/// @return {Struct.BBMOD_MaterialPropertyBlock} Returns `self`.
	static remove = function (_name)
	{
		gml_pragma("forceinline");
		for (var i = array_length(__names) - 1; i >= 0; --i)
		{
			if (__names[i] == _name)
			{
				array_delete(__names, i, 1);
				array_delete(__types, i, 1);
				array_delete(__values, i, 1);
				break;
			}
		}
		return self;
	};

	/// @func clear()
	///
	/// @desc Removes all properties.
	///
	/// @return {Struct.BBMOD_MaterialPropertyBlock} Returns `self`.
	static clear = function ()
	{
		gml_pragma("forceinline");
		__names = [];
		__types = [];
		__values = [];
		return self;
	};

	/// @func apply([_shader])
	///
	/// @desc Applies properties to a shader.
	///
	/// @param {Asset.GMShader} [_shader] The shader to apply properties to.
	/// Defaults to the current shader if `undefined`.
	///
	/// @return {Struct.BBMOD_MaterialPropertyBlock} Returns `self`.
	static apply = function (_shader=undefined)
	{
		_shader ??= shader_current();
		var _names = __names;
		var _types = __types;
		var _values = __values;

		var i = 0;
		repeat (array_length(_names))
		{
			var _propName = _names[i];
			var _propType = _types[i];
			var _propValue = _values[i];

			if (_propType == BBMOD_EShaderUniformType.Sampler)
			{
				var _propIndex = shader_get_sampler_index(_shader, _propName);
				if (_propIndex != -1)
				{
					texture_set_stage(_propIndex, _propValue);
				}
			}
			else
			{
				var _propIndex = shader_get_uniform(_shader, _propName);
				if (_propIndex != -1)
				{
					switch (_propType)
					{
					case BBMOD_EShaderUniformType.Color:
						shader_set_uniform_f(
							_propIndex,
							_propValue.Red / 255.0,
							_propValue.Green / 255.0,
							_propValue.Blue / 255.0,
							_propValue.Alpha);
						break;

					case BBMOD_EShaderUniformType.Float:
						shader_set_uniform_f(_propIndex, _propValue);
						break;

					case BBMOD_EShaderUniformType.Float2:
						shader_set_uniform_f(_propIndex, _propValue.X, _propValue.Y);
						break;

					case BBMOD_EShaderUniformType.Float3:
						shader_set_uniform_f(_propIndex, _propValue.X, _propValue.Y, _propValue.Z);
						break;

					case BBMOD_EShaderUniformType.Float4:
						shader_set_uniform_f(_propIndex, _propValue.X, _propValue.Y, _propValue.Z, _propValue.W);
						break;

					case BBMOD_EShaderUniformType.FloatArray:
						shader_set_uniform_f_array(_propIndex, _propValue);
						break;

					case BBMOD_EShaderUniformType.Int:
						shader_set_uniform_i(_propIndex, _propValue);
						break;

					case BBMOD_EShaderUniformType.Int2:
						shader_set_uniform_i(_propIndex, _propValue.X, _propValue.Y);
						break;

					case BBMOD_EShaderUniformType.Int3:
						shader_set_uniform_i(_propIndex, _propValue.X, _propValue.Y, _propValue.Z);
						break;

					case BBMOD_EShaderUniformType.Int4:
						shader_set_uniform_i(_propIndex, _propValue.X, _propValue.Y, _propValue.Z, _propValue.W);
						break;

					case BBMOD_EShaderUniformType.IntArray:
						shader_set_uniform_i_array(_propIndex, _propValue);
						break;

					case BBMOD_EShaderUniformType.Matrix:
						shader_set_uniform_matrix(_propIndex);
						break;

					case BBMOD_EShaderUniformType.MatrixArray:
						shader_set_uniform_matrix_array(_propIndex, _propValue);
						break;

					default:
						break;
					}
				}
			}

			++i;
		}

		return self;
	};
}

/// @func bbmod_material_props_set(_materialPropertyBlock)
///
/// @desc Sets a material property block as the current one. Its properties are
/// then applied to all rendered materials until it is reset again using
/// {@link bbmod_material_props_reset}.
///
/// @param {Struct.BBMOD_MaterialPropertyBlock} _materialPropertyBlock The
/// material property block to set as the current one.
///
/// @example
/// ```gml
/// var _materialProps = new BBMOD_MaterialPropertyBlock();
/// materialProps.set_color("u_vSilhouetteColor", BBMOD_C_RED);
/// materialProps.set_float("u_fSilhouetteStrength", 1.0);
/// bbmod_material_props_set(_materialProps);
/// model.render();
/// bbmod_material_props_reset();
/// ```
///
/// @note The current material property block is applied automatically every
/// time {@link BBMOD_Material.apply} is called. If the applied material has an
/// [OnApply](./BBMOD_Material.OnApply.html) property, it is executed *afer* the
/// material property block is applied.
///
/// @see bbmod_material_props_get
/// @see bbmod_material_props_reset
/// @see BBMOD_MaterialPropertyBlock
function bbmod_material_props_set(_materialPropertyBlock)
{
	gml_pragma("forceinline");
	global.__bbmodMaterialProps = _materialPropertyBlock;
}

/// @func bbmod_material_props_get()
///
/// @desc Retrieves the current material property block.
///
/// @return {Struct.BBMOD_MaterialPropertyBlock} The current material property
/// block or `undefined`.
///
/// @example
/// ```gml
/// var _materialProps = new BBMOD_MaterialPropertyBlock();
/// bbmod_material_props_set(_materialProps);
/// bbmod_material_props_get(); // => _materialProps
/// bbmod_material_props_reset();
/// bbmod_material_props_get(); // => undefined
/// ```
///
/// @see bbmod_material_props_set
/// @see bbmod_material_props_reset
/// @see BBMOD_MaterialPropertyBlock
function bbmod_material_props_get()
{
	gml_pragma("forceinline");
	return global.__bbmodMaterialProps;
}

/// @func bbmod_material_props_reset()
///
/// @desc Unsets the current material property block.
///
/// @example
/// ```gml
/// var _materialProps = new BBMOD_MaterialPropertyBlock();
/// bbmod_material_props_set(_materialProps);
/// bbmod_material_props_get(); // => _materialProps
/// bbmod_material_props_reset();
/// bbmod_material_props_get(); // => undefined
/// ```
///
/// @see bbmod_material_props_set
/// @see bbmod_material_props_get
/// @see BBMOD_MaterialPropertyBlock
function bbmod_material_props_reset()
{
	gml_pragma("forceinline");
	global.__bbmodMaterialProps = undefined;
}
