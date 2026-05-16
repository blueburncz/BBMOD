// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
enum CM_SPATIALHASH
{
	TYPE,
	MAP,
	AABB, 
	REGIONSIZE,
	OBJECTS,
	NUM
}

#macro CM_SPATIALHASH_BEGIN			var spatialhash = array_create(CM_SPATIALHASH.NUM, CM_OBJECTS.SPATIALHASH)
#macro CM_SPATIALHASH_TYPE			spatialhash[@ CM_SPATIALHASH.TYPE]
#macro CM_SPATIALHASH_MAP			spatialhash[@ CM_SPATIALHASH.MAP]
#macro CM_SPATIALHASH_REGIONSIZE	spatialhash[@ CM_SPATIALHASH.REGIONSIZE]
#macro CM_SPATIALHASH_AABB			spatialhash[@ CM_SPATIALHASH.AABB]
#macro CM_SPATIALHASH_END			return spatialhash

function cm_spatialhash(regionsize)
{
	CM_SPATIALHASH_BEGIN;
	CM_SPATIALHASH_MAP = {};
	CM_SPATIALHASH_REGIONSIZE = regionsize;
	CM_SPATIALHASH_AABB = undefined;
	CM_SPATIALHASH_END;
}