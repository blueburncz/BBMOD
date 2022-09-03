# Changelog 3.10.0
This release adds a new Save module, using which you can easily define serializable properties of objects and save and load instances to and from buffers.

## GML API:
### Core module:
* Added new enum `BBMOD_EPropertyType`, which is an enumeration of all types of serializable properties.
* Added new struct `BBMOD_Property`, which is a descriptor of a serializable property.

### Save module:
* Added new module - Save.
* Added new function `bbmod_object_add_property`, using which you can add a serializable property to an object.
* Added functions `bbmod_object_add_bool`, `bbmod_object_add_color`, `bbmod_object_add_gmfont`, `bbmod_object_add_gmobject`, `bbmod_object_add_gmpath`, `bbmod_object_add_gmroom`, `bbmod_object_add_gmscript`, `bbmod_object_add_gmshader`, `bbmod_object_add_gmsound`, `bbmod_object_add_gmsprite`, `bbmod_object_add_gmtileset`, `bbmod_object_add_gmtimeline`, `bbmod_object_add_matrix`, `bbmod_object_add_path`, `bbmod_object_add_quaternion`, `bbmod_object_add_real`, `bbmod_object_add_real_array`, `bbmod_object_add_string`, `bbmod_object_add_vec2`, `bbmod_object_add_vec3` and `bbmod_object_add_vec4`, which are shorthands for `bbmod_object_add_property`.
* Added function `bbmod_object_get_property_map`, using which you can retrieve a map of all serializable properties of an object.
* Added function `bbmod_object_get_property_array`, using which you can retrieve an array of all serializable properties of an object.
* Added function `bbmod_instance_to_buffer`, using which you can serialize an instance into a buffer.
* Added function `bbmod_instance_from_buffer`, using which you can deserialize an instance from a buffer.
* Added function `bbmod_save_instances_to_buffer`, using which you can save all instances of an object into a buffer.
* Added function `bbmod_load_instances_from_buffer`, using which you can load saved instances from a buffer.
