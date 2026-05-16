// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
enum CM_QUADTREE
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
	NUM
}

#macro CM_QUADTREE_BEGIN		var quadtree = array_create(CM_QUADTREE.NUM, CM_OBJECTS.QUADTREE)
#macro CM_QUADTREE_TYPE			quadtree[@ CM_QUADTREE.TYPE]
#macro CM_QUADTREE_AABB			quadtree[@ CM_QUADTREE.AABB]
#macro CM_QUADTREE_SIZE			quadtree[@ CM_QUADTREE.SIZE]
#macro CM_QUADTREE_ISROOT		quadtree[@ CM_QUADTREE.ISROOT]
#macro CM_QUADTREE_REGIONSIZE	quadtree[@ CM_QUADTREE.REGIONSIZE]
#macro CM_QUADTREE_MAXOBJECTS	quadtree[@ CM_QUADTREE.MAXOBJECTS]
#macro CM_QUADTREE_SUBDIVIDED	quadtree[@ CM_QUADTREE.SUBDIVIDED]
#macro CM_QUADTREE_OBJECTLIST	quadtree[@ CM_QUADTREE.OBJECTLIST]
#macro CM_QUADTREE_END		return quadtree

function cm_quadtree(regionsize, maxobjectsperregion = 5)
{
	CM_QUADTREE_BEGIN;
	CM_QUADTREE_AABB = [0, 0, 0, regionsize, regionsize, regionsize];
	CM_QUADTREE_ISROOT = true;
	CM_QUADTREE_SIZE = regionsize;
	CM_QUADTREE_REGIONSIZE = regionsize;
	CM_QUADTREE_MAXOBJECTS = maxobjectsperregion;
	CM_QUADTREE_SUBDIVIDED = false;
	CM_QUADTREE_OBJECTLIST = cm_list();
	CM_QUADTREE_END;
}