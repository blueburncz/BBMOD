// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
#macro CM_DEBUG true	//Set to false if you don't want the ColMesh system to output debug messages
#macro CM_MAX_RECURSIONS 10	//The maximum recursion depth. Applies when you place a ColMesh inside itself
#macro CM_FIRST_PASS_RADIUS 1.2 //The radius for the first pass when doing precise collision checking. It's useful to check a slightly larger radius when doing the first pass.
#macro CM_TREE_MAXDEPTH 32

//Groups
#macro CM_GROUP_SOLID		(1 << 0) //This is the only group that must NOT be removed! The rest can be modified.
#macro CM_GROUP_TRIGGER		(1 << 1)
#macro CM_GROUP_OTHER		(1 << 2)
#macro CM_GROUP_LEVEL		(1 << 3)
#macro CM_GROUP_GRAVITY		(1 << 4)

global.cm_recursion = 0;
#macro CM_RECURSION global.cm_recursion

global.cm_priority = array_create(CM_MAX_RECURSIONS, -1);
#macro CM_PRIORITY global.cm_priority

global.cm_raymap = array_create(CM_MAX_RECURSIONS, -1);
#macro CM_RAYMAP global.cm_raymap

#macro CM_TYPE 0
#macro CM_GROUP 1

enum CM_OBJECTS
{
	//Containers
	DYNAMIC,
	LIST,
	SPATIALHASH,
	QUADTREE,
	OCTREE,
	CONTAINERNUM,
	
	//Colliders
	COLLIDERCAPSULE,
	COLLIDERCYLINDER, //unused for the moment
	COLLIDERBOX,	  //unused for the moment
	RAY,
	
	//Primitives
	FLSSTRIANGLE, //flat single-sided triangle
	FLDSTRIANGLE, //flat double-sided triangle
	SMSSTRIANGLE, //smooth single-sided triangle
	SMDSTRIANGLE, //smooth double-sided triangle
	SPHERE, 
	CAPSULE, 
	CYLINDER,
	AAB,
	BOX,
	DISK,
	TORUS,
	
	NUM
}

//Array storing the array positions of the various primitives that can be used for custom properties
global.cm_custom_pos = array_create(CM_OBJECTS.NUM, -1);
#macro CM_CUSTOM_POS global.cm_custom_pos
CM_CUSTOM_POS[CM_OBJECTS.COLLIDERCAPSULE]	= CM.NUM;
CM_CUSTOM_POS[CM_OBJECTS.DYNAMIC]			= CM_DYNAMIC.NUM;
CM_CUSTOM_POS[CM_OBJECTS.SPATIALHASH]		= CM_SPATIALHASH.NUM;
CM_CUSTOM_POS[CM_OBJECTS.QUADTREE]			= CM_QUADTREE.NUM;
CM_CUSTOM_POS[CM_OBJECTS.OCTREE]			= CM_OCTREE.NUM;
CM_CUSTOM_POS[CM_OBJECTS.FLSSTRIANGLE]		= CM_TRIANGLE.NUM;
CM_CUSTOM_POS[CM_OBJECTS.FLDSTRIANGLE]		= CM_TRIANGLE.NUM;
CM_CUSTOM_POS[CM_OBJECTS.SMSSTRIANGLE]		= CM_ARGS_SMOOTHTRIANGLE.NUM;
CM_CUSTOM_POS[CM_OBJECTS.SMDSTRIANGLE]		= CM_ARGS_SMOOTHTRIANGLE.NUM;
CM_CUSTOM_POS[CM_OBJECTS.SPHERE]			= CM_SPHERE.NUM;
CM_CUSTOM_POS[CM_OBJECTS.CAPSULE]			= CM_CAPSULE.NUM;
CM_CUSTOM_POS[CM_OBJECTS.CYLINDER]			= CM_CYLINDER.NUM;
CM_CUSTOM_POS[CM_OBJECTS.AAB]				= CM_AAB.NUM;
CM_CUSTOM_POS[CM_OBJECTS.BOX]				= CM_BOX.NUM;
CM_CUSTOM_POS[CM_OBJECTS.DISK]				= CM_DISK.NUM;
CM_CUSTOM_POS[CM_OBJECTS.TORUS]				= CM_TORUS.NUM;

function cm_debug_message(str)
{
	if (CM_DEBUG)
	{
		show_debug_message(str);
	}
}

//Initialize vertex buffers
vertex_format_begin();
vertex_format_add_position_3d();
vertex_format_add_normal();
vertex_format_add_texcoord();
vertex_format_add_color();
global.cm_format = vertex_format_end();

global.cm_vbuffers = array_create(CM_OBJECTS.NUM, -1);
global.cm_vbuffers_wf = array_create(CM_OBJECTS.NUM, -1);

//Check if the given object is a container
function __cmi_is_container(object)
{
	var type = object[CM_TYPE];
	return (type == CM_OBJECTS.DYNAMIC || type == CM_OBJECTS.LIST || type == CM_OBJECTS.SPATIALHASH || type == CM_OBJECTS.QUADTREE || type == CM_OBJECTS.OCTREE);
}

////////////////////////////////////////
// -- Get priority --
var default_function = function(object, collider, mask){return 0;}
global.__cmi_get_priority = array_create(CM_OBJECTS.NUM, default_function);
global.__cmi_get_priority[CM_OBJECTS.DYNAMIC]			= __cmi_dynamic_get_priority;
global.__cmi_get_priority[CM_OBJECTS.FLSSTRIANGLE]		= __cmi_triangle_get_priority;
global.__cmi_get_priority[CM_OBJECTS.FLDSTRIANGLE]		= __cmi_triangle_get_priority;
global.__cmi_get_priority[CM_OBJECTS.SMSSTRIANGLE]		= __cmi_triangle_get_priority;
global.__cmi_get_priority[CM_OBJECTS.SMDSTRIANGLE]		= __cmi_triangle_get_priority;
global.__cmi_get_priority[CM_OBJECTS.SPHERE]			= __cmi_sphere_get_priority;
global.__cmi_get_priority[CM_OBJECTS.CAPSULE]			= __cmi_capsule_get_priority;
global.__cmi_get_priority[CM_OBJECTS.CYLINDER]			= __cmi_cylinder_get_priority;
global.__cmi_get_priority[CM_OBJECTS.AAB]				= __cmi_aab_get_priority;
global.__cmi_get_priority[CM_OBJECTS.BOX]				= __cmi_box_get_priority;
global.__cmi_get_priority[CM_OBJECTS.DISK]				= __cmi_disk_get_priority;
global.__cmi_get_priority[CM_OBJECTS.TORUS]				= __cmi_torus_get_priority;
#macro CM_GET_PRIORITY global.__cmi_get_priority[object[0]]
function cm_get_priority(object, collider, mask = 0)
{
	return CM_GET_PRIORITY(object, collider, mask);
}

////////////////////////////////////////
// -- Intersects cube --
default_function = function(object, hsize, bX, bY, bZ)
{
	var aabb = cm_get_aabb(object);
	if (aabb[0] > bX + hsize || aabb[1] > bY + hsize || aabb[2] > bZ + hsize || aabb[3] < bX - hsize || aabb[4] < bY - hsize || aabb[5] < bZ - hsize) return false;
	return true;
}
global.__cmi_intersects_cube = array_create(CM_OBJECTS.NUM, default_function);
global.__cmi_intersects_cube[CM_OBJECTS.FLSSTRIANGLE]	= __cmi_triangle_intersects_cube;
global.__cmi_intersects_cube[CM_OBJECTS.FLDSTRIANGLE]	= __cmi_triangle_intersects_cube;
global.__cmi_intersects_cube[CM_OBJECTS.SMSSTRIANGLE]	= __cmi_triangle_intersects_cube;
global.__cmi_intersects_cube[CM_OBJECTS.SMDSTRIANGLE]	= __cmi_triangle_intersects_cube;
global.__cmi_intersects_cube[CM_OBJECTS.SPHERE]			= __cmi_sphere_intersects_cube;
global.__cmi_intersects_cube[CM_OBJECTS.CAPSULE]		= __cmi_capsule_intersects_cube;
global.__cmi_intersects_cube[CM_OBJECTS.CYLINDER]		= __cmi_cylinder_intersects_cube;
global.__cmi_intersects_cube[CM_OBJECTS.AAB]			= __cmi_aab_intersects_cube;
global.__cmi_intersects_cube[CM_OBJECTS.BOX]			= __cmi_box_intersects_cube;
global.__cmi_intersects_cube[CM_OBJECTS.DISK]			= __cmi_disk_intersects_cube;
global.__cmi_intersects_cube[CM_OBJECTS.TORUS]			= __cmi_torus_intersects_cube;
#macro CM_INTERSECTS_CUBE global.__cmi_intersects_cube[object[0]]
function cm_intersects_cube(object, hsize, bX, bY, bZ)
{
	return CM_INTERSECTS_CUBE(object, hsize, bX, bY, bZ);
}