useDeferredRenderer = bbmod_deferred_renderer_is_supported();

z = 1;

camera = new BBMOD_Camera();
camera.Exposure = 2;
camera.MouseSensitivity = 0.5;
camera.FollowObject = self;

x = 19.55;
y = -4.31;
z = 4.5;
camera.Direction = -134;
camera.DirectionUp = -23.5;

if (useDeferredRenderer)
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
//renderer.ShadowmapNormalOffset = 0.01;
renderer.EnableSSAO = true;
renderer.SSAODepthRange = 1.5;
renderer.SSAORadius = 64;
renderer.SSAOPower = 2;

gizmo = new BBMOD_Gizmo();
renderer.Gizmo = gizmo;
renderer.EditMode = true;

postProcessor = new BBMOD_PostProcessor();
postProcessor.LensDirtStrength = 0.1;

//var _dof = new BBMOD_DepthOfFieldEffect();
//_dof.AutoFocus = true;
//_dof.AutoFocusRange = 3;
//_dof.BlurRangeNear = 1;
//_dof.BlurRangeFar = 1;
//_dof.BlurScaleNear = 0.5;
//_dof.BlurScaleFar = 0.5;
//postProcessor.add_effect(_dof);

postProcessor.add_effect(new BBMOD_LightBloomEffect(undefined, new BBMOD_Vec3(0.2)));

directionalBlur = new BBMOD_DirectionalBlurEffect();
postProcessor.add_effect(directionalBlur);

if (useDeferredRenderer)
{
	postProcessor.add_effect(new BBMOD_ExposureEffect());
	postProcessor.add_effect(new BBMOD_ReinhardTonemapEffect());
	postProcessor.add_effect(new BBMOD_GammaCorrectEffect());
}

sunshafts = new BBMOD_SunShaftsEffect();
sunshafts.Color.Alpha = 0.3;
postProcessor.add_effect(sunshafts);

postProcessor.add_effect(new BBMOD_ChromaticAberrationEffect(2));
postProcessor.add_effect(new BBMOD_FXAAEffect());
postProcessor.add_effect(new BBMOD_LensFlaresEffect());
postProcessor.add_effect(new BBMOD_VignetteEffect(0.5));
renderer.PostProcessor = postProcessor;

modSphere = BBMOD_RESOURCE_MANAGER.load_sync("Data/BBMOD/Models/Sphere.bbmod");
batchSphere = new BBMOD_DynamicBatch(modSphere);
modSphere.freeze();

var _baseMaterial = undefined;
if (useDeferredRenderer)
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
BBMOD_RESOURCE_MANAGER.add("MatSphere", matSphere);

matSphereMetallic = _baseMaterial.clone();
matSphereMetallic.BaseOpacity = sprite_get_texture(BBMOD_SprWhite, 0);
matSphereMetallic.set_metallic_ao(1, 1);
BBMOD_RESOURCE_MANAGER.add("MatSphereMetallic", matSphereMetallic);

matSphereEmissive = _baseMaterial.clone();
matSphereEmissive.BaseOpacity = sprite_get_texture(BBMOD_SprBlack, 0);
matSphereEmissive.set_normal_roughness(BBMOD_VEC3_UP, 1.0);
matSphereEmissive.set_emissive(new BBMOD_Color(255 * 1.1, 127 * 1.1, 0));
BBMOD_RESOURCE_MANAGER.add("MatSphereEmissive", matSphereEmissive);

////////////////////////////////////////////////////////////////////////////////
//
// Lighting
//

var _env = bbmod_environment_get_current();

_env.AmbientLightColorUp = BBMOD_C_BLACK;
_env.AmbientLightColorDown = BBMOD_C_BLACK;

var _sprIBL = BBMOD_RESOURCE_MANAGER.load_sync("Data/BBMOD/Skies/IBL+40.png");
var _sprSky = BBMOD_RESOURCE_MANAGER.load_sync("Data/BBMOD/Skies/Sky+40.png");

matSky = BBMOD_MATERIAL_SKY.clone();
matSky.BaseOpacity = sprite_get_texture(_sprSky.Raw, 0);
BBMOD_RESOURCE_MANAGER.add("MatSky", matSky);

_env.ImageBasedLight = new BBMOD_ImageBasedLight(sprite_get_texture(_sprIBL.Raw, 0));

sun = new BBMOD_DirectionalLight();
sun.Direction.Set(0.44, 0.63, -0.64);
sun.CastShadows = true;
sun.ShadowmapArea = 100;
sun.ShadowmapResolution = 2048;
_env.LightDirectional = sun;

probe = new BBMOD_ReflectionProbe(new BBMOD_Vec3(0, 0, 1));
probe.Infinite = true;
_env.add_reflection_probe(probe);

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

var _light = new BBMOD_PointLight();
_light.Color = BBMOD_C_AQUA;
_light.Position = new BBMOD_Vec3(22, 22, 2.5);
_light.Range = 10;
_env.add_punctual_light(_light);

var _lensFlare = new BBMOD_LensFlare();
_lensFlare.Range = 20;
_lensFlare.Position = _light.Position;
_lensFlare.add_ghosts(BBMOD_SprLensFlareHeptagon, 0, 8, 0.1, 1.0, 0.25, 0.1, 1.5, BBMOD_C_AQUA.Mix(BBMOD_C_BLACK, 0.8));
bbmod_lens_flare_add(_lensFlare);

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

var _matTerrain = useDeferredRenderer ? BBMOD_MATERIAL_TERRAIN_DEFERRED.clone() : BBMOD_MATERIAL_TERRAIN.clone();
if (!useDeferredRenderer)
{
	_matTerrain.set_shader(BBMOD_ERenderPass.DepthOnly, BBMOD_SHADER_DEFAULT_DEPTH);
}
terrain.Material = _matTerrain;
BBMOD_RESOURCE_MANAGER.add("MatTerrain", _matTerrain);

terrain.Colormap = sprite_get_texture(SprColormap, 0);

var _layer = new BBMOD_TerrainLayer();
_layer.BaseOpacity = sprite_get_texture(BBMOD_SprCheckerboard, 0);
terrain.Layer[@ 0] = _layer;
