/// @var {Id.DsMap<Asset.GMObject, Id.DsMap<String, Struct.BBMOD_Property>>}
/// @private
global.__bbmodObjectProperties = ds_map_create();

/// @func bbmod_object_add_property(_object, _property)
///
/// @desc
///
/// @param {Asset.GMObject} _object
/// @param {Struct.BBMOD_Property} _property
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
/// @desc
///
/// @param {Asset.GMObject} _object
/// @param {Id.DsMap<String, Struct.BBMOD_Property>} _dest
///
/// @return {Real}
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
/// @desc
///
/// @param {Id.Instance} _instance
/// @param {Id.Buffer} _buffer
/// @param {Id.DsMap<String, Struct.BBMOD_Property>} [_properties] If not
/// defined, then they are retrieved using {@link bbmod_object_get_properties}.
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
				var _propertyType = _props[? _propertyName];

				buffer_write(_buffer, buffer_string, _propertyName);
				buffer_write(_buffer, buffer_u32, _propertyType);

				switch (_propertyType)
				{
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
/// @desc
///
/// @param {Id.Buffer} _buffer
///
/// @return {Id.Instance}
///
/// @throws {BBMOD_Exception}
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
				var _array = array_create(_size);
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
function bbmod_save_instances_to_buffer(_object, _buffer)
{
	var _props = ds_map_create();

	buffer_write(_buffer, buffer_u64, instance_number(_object));

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
}

/// @func bbmod_load_instances_from_buffer(_buffer[, _idsOut])
///
/// @desc
///
/// @param {Id.Buffer} _buffer
/// @param {Array<Id.Instance>} [_idsOut]
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
