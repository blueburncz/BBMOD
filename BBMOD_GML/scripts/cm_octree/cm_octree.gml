// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
enum CM_OCTREE
{
	TYPE,
	AABB,
	SIZE,
	ISROOT,
	REGIONSIZE,
	MAXOBJECTS,
	SUBDIVIDED,
	OBJECTLIST,
	CHILD1,
	CHILD2,
	CHILD3,
	CHILD4,
	CHILD5,
	CHILD6,
	CHILD7,
	CHILD8,
	NUM
}

#macro CM_OCTREE_BEGIN		var octree = array_create(CM_OCTREE.NUM, CM_OBJECTS.OCTREE)
#macro CM_OCTREE_TYPE		octree[@ CM_OCTREE.TYPE]
#macro CM_OCTREE_AABB		octree[@ CM_OCTREE.AABB]
#macro CM_OCTREE_SIZE		octree[@ CM_OCTREE.SIZE]
#macro CM_OCTREE_ISROOT		octree[@ CM_OCTREE.ISROOT]
#macro CM_OCTREE_REGIONSIZE	octree[@ CM_OCTREE.REGIONSIZE]
#macro CM_OCTREE_MAXOBJECTS	octree[@ CM_OCTREE.MAXOBJECTS]
#macro CM_OCTREE_SUBDIVIDED	octree[@ CM_OCTREE.SUBDIVIDED]
#macro CM_OCTREE_OBJECTLIST	octree[@ CM_OCTREE.OBJECTLIST]
#macro CM_OCTREE_END		return octree

function cm_octree(regionsize, maxobjectsperregion = 5)
{
	CM_OCTREE_BEGIN;
	CM_OCTREE_AABB = [0, 0, 0, regionsize, regionsize, regionsize];
	CM_OCTREE_ISROOT = true;
	CM_OCTREE_SIZE = regionsize;
	CM_OCTREE_REGIONSIZE = regionsize;
	CM_OCTREE_MAXOBJECTS = maxobjectsperregion;
	CM_OCTREE_SUBDIVIDED = false;
	CM_OCTREE_OBJECTLIST = cm_list();
	CM_OCTREE_END;
}