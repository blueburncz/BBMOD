/// @var {Id.DsMap<Real, Id.DsMap<String, Real>>}
/// @private
global.__bbmodObjectProperties = ds_map_create();

/// @func bbmod_object_add_property(_object, _property, _type)
///
/// @desc
///
/// @param {Asset.GMObject} _object
/// @param {String} _property
/// @param {Real} _type
function bbmod_object_add_property(_object, _property, _type)
{
	if (!ds_map_exists(global.__bbmodObjectProperties, _object))
	{
		ds_map_add_map(global.__bbmodObjectProperties, _object, ds_map_create());
	}

	global.__bbmodObjectProperties[? _object][? _property] = _type;
}

/// @func bbmod_object_get_properties(_object, _dest)
///
/// @desc
///
/// @param {Asset.GMObject} _object
/// @param {Id.DsMap<String, Real>} _dest
///
/// @return {Real}
function bbmod_object_get_properties(_object, _dest)
{
	// TODO: Cache!!!
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

/// @func bbmod_instance_to_buffer(_instance, _buffer)
///
/// @desc
///
/// @param {Id.Instance} _instance
/// @param {Id.Buffer} _buffer
function bbmod_instance_to_buffer(_instance, _buffer)
{
	static _properties = ds_map_create();

	with (_instance)
	{
		buffer_write(_buffer, buffer_string, object_get_name(object_index));
		buffer_write(_buffer, buffer_f32, x);
		buffer_write(_buffer, buffer_f32, y);
		buffer_write(_buffer, buffer_string, layer_get_name(layer));

		ds_map_clear(_properties);
		var _propertyCount = bbmod_object_get_properties(object_index, _properties);

		buffer_write(_buffer, buffer_u32, _propertyCount);

		if (_propertyCount > 0)
		{
			var _propertyName = ds_map_find_first(_properties);

			repeat (_propertyCount)
			{
				var _propertyType = _properties[? _propertyName];

				buffer_write(_buffer, buffer_string, _propertyName);
				buffer_write(_buffer, buffer_u32, _propertyType);

				switch (_propertyType)
				{
				default:
					break;
				}

				_propertyName = ds_map_find_next(_properties, _propertyName);
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

			switch (buffer_read(_buffer, buffer_u32)) // Property type
			{
			default:
				throw new BBMOD_Exception("Invalid property type!");
			}
		}

		return self;
	}
}

bbmod_object_add_property(OObject3D, "z", BBMOD_EPropertyType.Float);
bbmod_object_add_property(OCharacter, "team", BBMOD_EPropertyType.Int);
bbmod_object_add_property(OPlayer, "name", BBMOD_EPropertyType.String);

var _props = ds_map_create();

bbmod_object_get_properties(OCharacter, _props);
show_debug_message(json_encode(_props));
ds_map_clear(_props);

bbmod_object_get_properties(OPlayer, _props);
show_debug_message(json_encode(_props));
ds_map_clear(_props);
