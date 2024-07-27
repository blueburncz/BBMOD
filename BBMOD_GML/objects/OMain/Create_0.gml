z = 1;

scene = new BBMOD_Scene();

camera = new BBMOD_Camera();
camera.Exposure = 2;
camera.MouseSensitivity = 0.5;
camera.FollowObject = self;
scene.add_camera(camera);
scene.CameraCurrent = camera;

renderer = new BBMOD_DeferredRenderer();
renderer.UseAppSurface = true;
renderer.EnableShadows = true;
renderer.ShadowmapNormalOffset = 0.1;
renderer.EnableSSAO = true;
renderer.SSAODepthRange = 1.5;
renderer.SSAORadius = 64;
renderer.SSAOPower = 2;

gizmo = new BBMOD_Gizmo();
renderer.Gizmo = gizmo;

postProcessor = new BBMOD_PostProcessor();
postProcessor.add_effect(new BBMOD_ExposureEffect());
postProcessor.add_effect(new BBMOD_GammaCorrectEffect());
postProcessor.add_effect(new BBMOD_ReinhardTonemapEffect());
postProcessor.add_effect(new BBMOD_ChromaticAberrationEffect(2));
postProcessor.add_effect(new BBMOD_FXAAEffect());
postProcessor.add_effect(new BBMOD_VignetteEffect(0.5));
renderer.PostProcessor = postProcessor;

batchSphere = undefined;

modSphere = BBMOD_RESOURCE_MANAGER.load("Data/BBMOD/Models/Sphere.bbmod", function (_err, _model) {
	bbmod_assert(_err == undefined, "Failed to load Sphere model!");
	batchSphere = new BBMOD_DynamicBatch(modSphere);
	modSphere.freeze();
});

matSphere = BBMOD_MATERIAL_DEFERRED.clone();
matSphere.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEFAULT_DEPTH);
matSphere.BaseOpacity = sprite_get_texture(BBMOD_SprWhite, 0);

var _nodeDesc = new BBMOD_SceneNodeDescriptor();
_nodeDesc.Model = "Data/BBMOD/Models/Sphere.bbmod";
_nodeDesc.Materials = [matSphere];
_nodeDesc.Position = new BBMOD_Vec3(0, 0, 1);

scene.create_node(_nodeDesc);

////////////////////////////////////////////////////////////////////////////////
//
// Lighting
//

scene.AmbientLightColorUp = BBMOD_C_BLACK;
scene.AmbientLightColorDown = BBMOD_C_BLACK;

sprIBL = sprite_add("Data/BBMOD/Skies/IBL+40.png", 1, false, false, 0, 0);
sprSky = sprite_add("Data/BBMOD/Skies/Sky+40.png", 1, false, false, 0, 0);

matSky = BBMOD_MATERIAL_SKY.clone();
matSky.BaseOpacity = sprite_get_texture(sprSky, 0);

scene.ImageBasedLight = new BBMOD_ImageBasedLight(sprite_get_texture(sprIBL, 0));

sun = new BBMOD_DirectionalLight();
sun.Direction.Set(0.44, 0.63, -0.64);
sun.CastShadows = true;
sun.ShadowmapArea = 100;
sun.ShadowmapResolution = 2048;
scene.LightDirectional = sun;

probe = new BBMOD_ReflectionProbe(new BBMOD_Vec3(0, 0, 1));
probe.Infinite = true;
scene.add_reflection_probe(probe);

////////////////////////////////////////////////////////////////////////////////
//
// Terrain
//

terrain = new BBMOD_Terrain(SprHeightmap);
terrain.Scale.Set(16);
terrain.Position.Set(
	-terrain.Size.X * terrain.Scale.X * 0.5,
	-terrain.Size.Y * terrain.Scale.Y * 0.5,
	0);
terrain.TextureRepeat.Set(32);

terrainMaterial = BBMOD_MATERIAL_TERRAIN_DEFERRED.clone();
terrain.Material = terrainMaterial;

terrain.Colormap = sprite_get_texture(SprColormap, 0);

terrainLayer = new BBMOD_TerrainLayer();
terrainLayer.BaseOpacity = sprite_get_texture(BBMOD_SprCheckerboard, 0);

terrain.Layer[@ 0] = terrainLayer;

scene.Terrain = terrain;
