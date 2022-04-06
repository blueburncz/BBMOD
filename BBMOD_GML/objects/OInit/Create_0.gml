// Used to easily load, retrieve and free resources from memory.
global.resourceManager = new BBMOD_ResourceManager();

////////////////////////////////////////////////////////////////////////////////
// Create terrain
var _rock = BBMOD_MATERIAL_TERRAIN.clone();
_rock.BaseOpacity = sprite_get_texture(SprRocks, 0);
_rock.NormalSmoothness = sprite_get_texture(SprRocks, 1);

var _dirt = BBMOD_MATERIAL_TERRAIN.clone();
_dirt.BaseOpacity = sprite_get_texture(SprDirt, 0);
_dirt.NormalSmoothness = sprite_get_texture(SprDirt, 1);

var _grass = BBMOD_MATERIAL_TERRAIN.clone();
_grass.BaseOpacity = sprite_get_texture(SprGrass, 0);
_grass.NormalSmoothness = sprite_get_texture(SprGrass, 1);

var _sand = BBMOD_MATERIAL_TERRAIN.clone();
_sand.BaseOpacity = sprite_get_texture(SprSand, 0);
_sand.NormalSmoothness = sprite_get_texture(SprSand, 1);

global.terrain = new BBMOD_Terrain(SprHeightmap);
global.terrain.Scale = new BBMOD_Vec3(4.0);
global.terrain.TextureRepeat = new BBMOD_Vec2(64.0);
global.terrain.Layer[0] = _grass;
global.terrain.Layer[1] = _dirt;
global.terrain.Layer[2] = _rock;
global.terrain.Layer[3] = _sand;
global.terrain.Splatmap = sprite_get_texture(SprSplatmap, 0);
global.terrain.build_layer_index();

room_goto(RmDemo);