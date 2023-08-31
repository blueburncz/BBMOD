randomize();
global.day = choose(true, false);

BBMOD_MATERIAL_TERRAIN.set_shader(
	BBMOD_ERenderPass.DepthOnly, BBMOD_SHADER_DEFAULT_DEPTH);
BBMOD_MATERIAL_DEFAULT.set_shader(
	BBMOD_ERenderPass.DepthOnly, BBMOD_SHADER_DEFAULT_DEPTH);

// Used to easily load, retrieve and free resources from memory.
global.resourceManager = new BBMOD_ResourceManager();

////////////////////////////////////////////////////////////////////////////////
// Create terrain
var _dirt = new BBMOD_TerrainLayer()
_dirt.BaseOpacity = sprite_get_texture(SprDirt, 0);
_dirt.NormalSmoothness = sprite_get_texture(SprDirt, 1);

var _sand = new BBMOD_TerrainLayer()
_sand.BaseOpacity = sprite_get_texture(SprSand, 0);
_sand.NormalSmoothness = sprite_get_texture(SprSand, 1);

global.terrain = new BBMOD_Terrain(SprHeightmap);
global.terrain.Scale = new BBMOD_Vec3(4.0, 4.0, 1.0);
global.terrain.TextureRepeat = new BBMOD_Vec2(32.0);
global.terrain.Layer[@ 0] = _sand;
global.terrain.Layer[@ 1] = _dirt;
global.terrain.Splatmap = sprite_get_texture(SprSplatmap, 0);
global.terrain.build_layer_index();

room_goto(RmDemo);
