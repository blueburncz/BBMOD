var _useDeferredRenderer = bbmod_deferred_renderer_is_supported();

z = 1;

camera = new BBMOD_Camera();
camera.Exposure = 2;
camera.MouseSensitivity = 0.5;
camera.FollowObject = self;

if (_useDeferredRenderer)
{
	renderer = new BBMOD_DeferredRenderer();
}
else
{
	renderer = new BBMOD_DefaultRenderer();
	renderer.EnableGBuffer = true;
}
renderer.UseAppSurface = true;
renderer.EnableShadows = true;
renderer.ShadowmapNormalOffset = 0.01;
renderer.EnableSSAO = true;
renderer.SSAODepthRange = 1.5;
renderer.SSAORadius = 64;
renderer.SSAOPower = 2;

gizmo = new BBMOD_Gizmo();
renderer.Gizmo = gizmo;

postProcessor = new BBMOD_PostProcessor();
postProcessor.LensDirtStrength = 0.0;

//var _dof = new BBMOD_DepthOfFieldEffect();
//_dof.AutoFocus = true;
//postProcessor.add_effect(_dof);

postProcessor.add_effect(new BBMOD_LightBloomEffect());

directionalBlur = new BBMOD_DirectionalBlurEffect();
postProcessor.add_effect(directionalBlur);

if (_useDeferredRenderer)
{
	postProcessor.add_effect(new BBMOD_ExposureEffect());
	postProcessor.add_effect(new BBMOD_ReinhardTonemapEffect());
	postProcessor.add_effect(new BBMOD_GammaCorrectEffect());
}

sunshafts = new BBMOD_SunShaftsEffect();
sunshafts.Color.Alpha = 0.1;
postProcessor.add_effect(sunshafts);

postProcessor.add_effect(new BBMOD_ChromaticAberrationEffect(2));
postProcessor.add_effect(new BBMOD_FXAAEffect());
postProcessor.add_effect(new BBMOD_LensFlaresEffect());
postProcessor.add_effect(new BBMOD_VignetteEffect(0.5));
renderer.PostProcessor = postProcessor;

batchSphere = undefined;

modSphere = BBMOD_RESOURCE_MANAGER.load("Data/BBMOD/Models/Sphere.bbmod", function (_err, _model)
{
	bbmod_assert(_err == undefined, "Failed to load Sphere model!");
	batchSphere = new BBMOD_DynamicBatch(modSphere);
	modSphere.freeze();
});

var _baseMaterial = undefined;
if (_useDeferredRenderer)
{
	_baseMaterial = BBMOD_MATERIAL_DEFERRED.clone();
}
else
{
	_baseMaterial = BBMOD_MATERIAL_DEFAULT.clone();
	_baseMaterial.set_shader(BBMOD_ERenderPass.DepthOnly, BBMOD_SHADER_DEFAULT_DEPTH);
}
_baseMaterial.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEFAULT_DEPTH);

matSphere = _baseMaterial.clone();
matSphere.BaseOpacity = sprite_get_texture(BBMOD_SprWhite, 0);
matSphere.BaseOpacityMultiplier = BBMOD_C_SILVER;
matSphere.set_normal_roughness(BBMOD_VEC3_UP, 0.2);

matSphereMetallic = _baseMaterial.clone();
matSphereMetallic.BaseOpacity = sprite_get_texture(BBMOD_SprWhite, 0);
matSphereMetallic.set_metallic_ao(1, 1);

matSphereEmissive = _baseMaterial.clone();
matSphereEmissive.BaseOpacity = sprite_get_texture(BBMOD_SprBlack, 0);
matSphereEmissive.set_normal_roughness(BBMOD_VEC3_UP, 1.0);
matSphereEmissive.set_emissive(new BBMOD_Color(0, 127 * 1.2, 255 * 1.2));

////////////////////////////////////////////////////////////////////////////////
//
// Lighting
//

bbmod_light_ambient_set(BBMOD_C_BLACK);

sprIBL = sprite_add("Data/BBMOD/Skies/IBL+40.png", 1, false, false, 0, 0);
sprSky = sprite_add("Data/BBMOD/Skies/Sky+40.png", 1, false, false, 0, 0);

matSky = BBMOD_MATERIAL_SKY.clone();
matSky.BaseOpacity = sprite_get_texture(sprSky, 0);

ibl = new BBMOD_ImageBasedLight(sprite_get_texture(sprIBL, 0));
bbmod_ibl_set(ibl);

sun = new BBMOD_DirectionalLight();
sun.Direction.Set(0.44, 0.63, -0.64);
sun.CastShadows = true;
sun.ShadowmapArea = 100;
sun.ShadowmapResolution = 2048;
bbmod_light_directional_set(sun);

probe = new BBMOD_ReflectionProbe(new BBMOD_Vec3(0, 0, 1));
probe.Infinite = true;
bbmod_reflection_probe_add(probe);

sunshafts.LightDirection = sun.Direction;

lensFlare = new BBMOD_LensFlare();
lensFlare.Direction = sun.Direction;
lensFlare.add_ghosts(BBMOD_SprLensFlareHeptagon, 0, 8, 0.1, 1.0, 0.5, 0.1, 3.0, BBMOD_C_BLUE);

var _e;

//_e = new BBMOD_LensFlareElement(BBMOD_SprLensFlareStreak, 0, new BBMOD_Vec2(0.0));
//_e.Scale.Set(2.0, 1.0);
//_e.Color = BBMOD_C_ORANGE;
//_e.Color.Alpha = 0.5;
//lensFlare.add_element(_e);

_e = new BBMOD_LensFlareElement(BBMOD_SprLensFlareHoop, 0, new BBMOD_Vec2(0.75));
_e.Scale.Set(5.0);
_e.ScaleByDistanceMin.Set(0.0);
_e.ScaleByDistanceMax.Set(1.0);
_e.ApplyStarburst = true;
_e.AngleRelative = true;
_e.Color.Alpha = 0.5;
lensFlare.add_element(_e);

bbmod_lens_flare_add(lensFlare);

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

terrainMaterial = _useDeferredRenderer ? BBMOD_MATERIAL_TERRAIN_DEFERRED.clone() : BBMOD_MATERIAL_TERRAIN.clone();
if (!_useDeferredRenderer)
{
	terrainMaterial.set_shader(BBMOD_ERenderPass.DepthOnly, BBMOD_SHADER_DEFAULT_DEPTH);
}
terrain.Material = terrainMaterial;

terrain.Colormap = sprite_get_texture(SprColormap, 0);

terrainLayer = new BBMOD_TerrainLayer();
terrainLayer.BaseOpacity = sprite_get_texture(BBMOD_SprCheckerboard, 0);

terrain.Layer[@ 0] = terrainLayer;
