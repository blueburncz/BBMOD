/// @var {Id.DsMap<Asset.GMObject, Id.DsMap<String, Struct.BBMOD_Property>>}
/// @private
global.__bbmodObjectProperties = ds_map_create();

/// @func bbmod_object_add_property(_object, _property)
///
/// @desc Adds a serializable property to an object.
///
/// @param {Asset.GMObject} _object The object to add the property to.
/// @param {Struct.BBMOD_Property} _property The property to add.
///
/// @see BBMOD_Property
function bbmod_object_add_property(_object, _property)
{
	if (!ds_map_exists(global.__bbmodObjectProperties, _object))
	{
		ds_map_add_map(global.__bbmodObjectProperties, _object, ds_map_create());
	}

	global.__bbmodObjectProperties[? _object][? _property.Name] = _property;
}

/// @func bbmod_object_get_properties(_object, _dest)
///
/// @desc Retrieves all serializable properties of an object.
///
/// @param {Asset.GMObject} _object The object to get serializable properties of.
/// @param {Id.DsMap<String, Struct.BBMOD_Property>} _dest A map to store the
/// properties to. It is not automatically cleared before the properties are added!
///
/// @return {Real} Number of serializable properties that the object has.
function bbmod_object_get_properties(_object, _dest)
{
	var _count = 0;
	var _current = _object;

	while (object_exists(_current))
	{
		if (ds_map_exists(global.__bbmodObjectProperties, _current))
		{
			var _properties = global.__bbmodObjectProperties[? _current];
			var _propertyName = ds_map_find_first(_properties);

			repeat (ds_map_size(_properties))
			{
				if (!ds_map_exists(_dest, _propertyName))
				{
					_dest[? _propertyName] = _properties[? _propertyName];
					++_count;
				}

				_propertyName = ds_map_find_next(_properties, _propertyName);
			}
		}

		_current = object_get_parent(_current);
	}

	return _count;
}

/// @func bbmod_instance_to_buffer(_instance, _buffer[, _properties])
///
/// @desc Serializes an instance to a buffer.
///
/// @param {Id.Instance} _instance The instance to serialize.
/// @param {Id.Buffer} _buffer The buffer to serialize the instance to.
/// @param {Id.DsMap<String, Struct.BBMOD_Property>} [_properties] Map of
/// properties to serialize. If not defined, it is retrieved using
/// {@link bbmod_object_get_properties}.
function bbmod_instance_to_buffer(_instance, _buffer, _properties=undefined)
{
	static _dest = ds_map_create();

	with (_instance)
	{
		buffer_write(_buffer, buffer_string, object_get_name(object_index));
		buffer_write(_buffer, buffer_f32, x);
		buffer_write(_buffer, buffer_f32, y);
		buffer_write(_buffer, buffer_string, layer_get_name(layer));

		var _props;
		var _propsCount;

		if (_properties == undefined)
		{
			ds_map_clear(_dest);
			_props = _dest;
			_propsCount = bbmod_object_get_properties(object_index, _dest);
		}
		else
		{
			_props = _properties;
			_propsCount = ds_map_size(_props);
		}

		buffer_write(_buffer, buffer_u32, _propsCount);

		if (_propsCount > 0)
		{
			var _propertyName = ds_map_find_first(_props);

			repeat (_propsCount)
			{
				var _propertyType = _props[? _propertyName].Type;

				buffer_write(_buffer, buffer_string, _propertyName);
				buffer_write(_buffer, buffer_u32, _propertyType);

				switch (_propertyType)
				{
				case BBMOD_EPropertyType.Color:
					var _color = variable_instance_get(id, _propertyName);
					buffer_write(_buffer, buffer_f32, _color.Red);
					buffer_write(_buffer, buffer_f32, _color.Green);
					buffer_write(_buffer, buffer_f32, _color.Blue);
					buffer_write(_buffer, buffer_f32, _color.Alpha);
					break;

				case BBMOD_EPropertyType.GMFont:
					buffer_write(_buffer, buffer_string, font_get_name(variable_instance_get(id, _propertyName)));
					break;

				case BBMOD_EPropertyType.GMObject:
					buffer_write(_buffer, buffer_string, object_get_name(variable_instance_get(id, _propertyName)));
					break;

				case BBMOD_EPropertyType.GMPath:
					buffer_write(_buffer, buffer_string, path_get_name(variable_instance_get(id, _propertyName)));
					break;

				case BBMOD_EPropertyType.GMRoom:
					buffer_write(_buffer, buffer_string, room_get_name(variable_instance_get(id, _propertyName)));
					break;

				case BBMOD_EPropertyType.GMScript:
					buffer_write(_buffer, buffer_string, script_get_name(variable_instance_get(id, _propertyName)));
					break;

				case BBMOD_EPropertyType.GMShader:
					buffer_write(_buffer, buffer_string, shader_get_name(variable_instance_get(id, _propertyName)));
					break;

				case BBMOD_EPropertyType.GMSound:
					buffer_write(_buffer, buffer_string, audio_get_name(variable_instance_get(id, _propertyName)));
					break;

				case BBMOD_EPropertyType.GMSprite:
					buffer_write(_buffer, buffer_string, sprite_get_name(variable_instance_get(id, _propertyName)));
					break;

				case BBMOD_EPropertyType.GMTileSet:
					buffer_write(_buffer, buffer_string, tileset_get_name(variable_instance_get(id, _propertyName)));
					break;

				case BBMOD_EPropertyType.GMTimeline:
					buffer_write(_buffer, buffer_string, timeline_get_name(variable_instance_get(id, _propertyName)));
					break;

				case BBMOD_EPropertyType.Path:
					buffer_write(_buffer, buffer_string, variable_instance_get(id, _propertyName));
					break;

				case BBMOD_EPropertyType.Quaternion:
					var _quaternion = variable_instance_get(id, _propertyName);
					buffer_write(_buffer, buffer_f32, _quaternion.X);
					buffer_write(_buffer, buffer_f32, _quaternion.Y);
					buffer_write(_buffer, buffer_f32, _quaternion.Z);
					buffer_write(_buffer, buffer_f32, _quaternion.W);
					break;

				case BBMOD_EPropertyType.Matrix:
					var _matrix = variable_instance_get(id, _propertyName);
					var i = 0;
					repeat (16)
					{
						buffer_write(_buffer, buffer_f32, _matrix[i++]);
					}
					break;

				case BBMOD_EPropertyType.Real:
					buffer_write(_buffer, buffer_f32, variable_instance_get(id, _propertyName));
					break;

				case BBMOD_EPropertyType.RealArray:
					var _array = variable_instance_get(id, _propertyName);
					var _size = array_length(_size);
					buffer_write(_buffer, buffer_u32, _size);
					var i = 0;
					repeat (_size)
					{
						buffer_write(_buffer, buffer_f32, _array[i++]);
					}
					break;

				case BBMOD_EPropertyType.String:
					buffer_write(_buffer, buffer_string, variable_instance_get(id, _propertyName));
					break;

				case BBMOD_EPropertyType.Vec2:
					var _vec2 = variable_instance_get(id, _propertyName);
					buffer_write(_buffer, buffer_f32, _vec2.X);
					buffer_write(_buffer, buffer_f32, _vec2.Y);
					break;

				case BBMOD_EPropertyType.Vec3:
					var _vec3 = variable_instance_get(id, _propertyName);
					buffer_write(_buffer, buffer_f32, _vec3.X);
					buffer_write(_buffer, buffer_f32, _vec3.Y);
					buffer_write(_buffer, buffer_f32, _vec3.Z);
					break;

				case BBMOD_EPropertyType.Vec4:
					var _vec4 = variable_instance_get(id, _propertyName);
					buffer_write(_buffer, buffer_f32, _vec4.X);
					buffer_write(_buffer, buffer_f32, _vec4.Y);
					buffer_write(_buffer, buffer_f32, _vec4.Z);
					buffer_write(_buffer, buffer_f32, _vec4.W);
					break;

				default:
					throw new BBMOD_Exception("Invalid property type " + string(_propertyType) + "!");
				}

				_propertyName = ds_map_find_next(_props, _propertyName);
			}
		}
	}
}

/// @func bbmod_instance_from_buffer(_buffer)
///
/// @desc Deserializes an instance from a buffer.
///
/// @param {Id.Buffer} _buffer The buffer to deserialize an instance from.
///
/// @return {Id.Instance} The created instnace.
///
/// @throws {BBMOD_Exception} If an error occurs.
function bbmod_instance_from_buffer(_buffer)
{
	var _objectName = buffer_read(_buffer, buffer_string);
	var _objectIndex = asset_get_index(_objectName);

	if (_objectIndex == -1)
	{
		throw new BBMOD_Exception("Object \"" + _objectName + "\" not found!");
	}

	var _x = buffer_read(_buffer, buffer_f32);
	var _y = buffer_read(_buffer, buffer_f32);
	var _layerName = buffer_read(_buffer, buffer_string);

	with (instance_create_layer(_x, _y, _layerName, _objectIndex))
	{
		repeat (buffer_read(_buffer, buffer_u32)) // Property count
		{
			var _propertyName = buffer_read(_buffer, buffer_string);
			var _propertyType = buffer_read(_buffer, buffer_u32);

			switch (_propertyType)
			{
			case BBMOD_EPropertyType.Color:
				var _r = buffer_read(_buffer, buffer_f32);
				var _g = buffer_read(_buffer, buffer_f32);
				var _b = buffer_read(_buffer, buffer_f32);
				var _a = buffer_read(_buffer, buffer_f32);
				variable_instance_set(id, _propertyName, new BBMOD_Color(_r, _g, _b, _a));
				break;

			case BBMOD_EPropertyType.GMFont:
			case BBMOD_EPropertyType.GMObject:
			case BBMOD_EPropertyType.GMPath:
			case BBMOD_EPropertyType.GMRoom:
			case BBMOD_EPropertyType.GMScript:
			case BBMOD_EPropertyType.GMShader:
			case BBMOD_EPropertyType.GMSound:
			case BBMOD_EPropertyType.GMSprite:
			case BBMOD_EPropertyType.GMTileSet:
			case BBMOD_EPropertyType.GMTimeline:
				variable_instance_set(id, _propertyName, asset_get_index(buffer_read(_buffer, buffer_string)));
				break;

			case BBMOD_EPropertyType.Path:
				variable_instance_set(id, _propertyName, buffer_read(_buffer, buffer_string));
				break;

			case BBMOD_EPropertyType.Quaternion:
				var _x = buffer_read(_buffer, buffer_f32);
				var _y = buffer_read(_buffer, buffer_f32);
				var _z = buffer_read(_buffer, buffer_f32);
				var _w = buffer_read(_buffer, buffer_f32);
				variable_instance_set(id, _propertyName, new BBMOD_Quaternion(_x, _y, _z, _w));
				break;

			case BBMOD_EPropertyType.Matrix:
				var _matrix = array_create(16, 0);
				var i = 0;
				repeat (16)
				{
					_matrix[@ i++] = buffer_read(_buffer, buffer_f32);
				}
				variable_instance_set(id, _propertyName, _matrix);
				break;

			case BBMOD_EPropertyType.Real:
				variable_instance_set(id, _propertyName, buffer_read(_buffer, buffer_f32));
				break;

			case BBMOD_EPropertyType.RealArray:
				var _size = buffer_read(_buffer, buffer_u32);
				var _array = array_create(_size, 0);
				var i = 0;
				repeat (_size)
				{
					_array[@ i++] = buffer_read(_buffer, buffer_f32);
				}
				variable_instance_set(id, _propertyName, _array);
				break;

			case BBMOD_EPropertyType.String:
				variable_instance_set(id, _propertyName, buffer_read(_buffer, buffer_string));
				break;

			case BBMOD_EPropertyType.Vec2:
				var _x = buffer_read(_buffer, buffer_f32);
				var _y = buffer_read(_buffer, buffer_f32);
				variable_instance_set(id, _propertyName, new BBMOD_Vec2(_x, _y));
				break;

			case BBMOD_EPropertyType.Vec3:
				var _x = buffer_read(_buffer, buffer_f32);
				var _y = buffer_read(_buffer, buffer_f32);
				var _z = buffer_read(_buffer, buffer_f32);
				variable_instance_set(id, _propertyName, new BBMOD_Vec3(_x, _y, _z));
				break;

			case BBMOD_EPropertyType.Vec4:
				var _x = buffer_read(_buffer, buffer_f32);
				var _y = buffer_read(_buffer, buffer_f32);
				var _z = buffer_read(_buffer, buffer_f32);
				var _w = buffer_read(_buffer, buffer_f32);
				variable_instance_set(id, _propertyName, new BBMOD_Vec4(_x, _y, _z, _w));
				break;

			default:
				throw new BBMOD_Exception("Invalid property type " + string(_propertyType) + "!");
			}
		}

		return self;
	}
}

/// @func bbmod_save_instances_to_buffer(_object, _buffer)
///
/// @desc Saves all instances of an object to a buffer.
///
/// @param {Asset.GMObject} _object Use keyword `all` to save all existing
/// instances.
/// @param {Id.Buffer} _buffer The buffer to save the instances to.
///
/// @return {Real} Number of saved instances.
function bbmod_save_instances_to_buffer(_object, _buffer)
{
	var _props = ds_map_create();
	var _instanceCount = instance_number(_object);

	buffer_write(_buffer, buffer_u64, _instanceCount);

	with (_object)
	{
		var _instanceProps;

		if (!ds_map_exists(_props, object_index))
		{
			_instanceProps = ds_map_create();
			bbmod_object_get_properties(object_index, _instanceProps);
			ds_map_add_map(_props, object_index, _instanceProps);
		}
		else
		{
			_instanceProps = _props[? object_index];
		}

		bbmod_instance_to_buffer(id, _buffer, _instanceProps);
	}

	ds_map_destroy(_props);

	return _instanceCount;
}

/// @func bbmod_load_instances_from_buffer(_buffer[, _idsOut])
///
/// @desc Loads instances from a buffer.
///
/// @param {Id.Buffer} _buffer A buffer to load instances from.
/// @param {Array<Id.Instance>} [_idsOut] An array to hold all loaded
/// instances.
///
/// @return {Real} Returns number of loaded instances.
function bbmod_load_instances_from_buffer(_buffer, _idsOut=undefined)
{
	var _instanceCount = buffer_read(_buffer, buffer_u64);

	if (_idsOut == undefined)
	{
		repeat (_instanceCount)
		{
			bbmod_instance_from_buffer(_buffer);
		}
	}
	else
	{
		repeat (_instanceCount)
		{
			array_push(_idsOut, bbmod_instance_from_buffer(_buffer));
		}
	}

	return _instanceCount;
}

bbmod_object_add_property(OObject3D, new BBMOD_Property("position", BBMOD_EPropertyType.Vec3));
bbmod_object_add_property(OCharacter, new BBMOD_Property("team", BBMOD_EPropertyType.Real));
bbmod_object_add_property(OPlayer, new BBMOD_Property("name", BBMOD_EPropertyType.String));

var _props = ds_map_create();

bbmod_object_get_properties(OCharacter, _props);
show_debug_message(json_encode(_props));
ds_map_clear(_props);

bbmod_object_get_properties(OPlayer, _props);
show_debug_message(json_encode(_props));
ds_map_clear(_props);
