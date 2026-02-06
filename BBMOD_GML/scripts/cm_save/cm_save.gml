// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function cm_save(object, filename)
{
	ini_open(filename);
	ini_write_string("Colmesh v2.0", "By TheSnidr, 2023", json_stringify(object));
	ini_close();
}