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
renderer.ShadowmapNormalOffset = 0.01;
renderer.EnableSSAO = true;
renderer.SSAODepthRange = 1.5;
renderer.SSAORadius = 128;
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

postProcessor.add_effect(new BBMOD_LightBloomEffect(new BBMOD_Vec3(-1.1), new BBMOD_Vec3(0.1)));

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

modSphere = BBMOD_RESOURCE_MANAGER.load_sync("Data/BBMOD/Models/Sphere.bbmod").freeze();

////////////////////////////////////////////////////////////////////////////////
//
// Lighting
//

var _scene = bbmod_scene_get_current();

_scene.AmbientLightColorUp = BBMOD_C_BLACK;
_scene.AmbientLightColorDown = BBMOD_C_BLACK;

var _sprIBL = BBMOD_RESOURCE_MANAGER.load_sync("Data/BBMOD/Skies/IBL+40.png");
var _sprSky = BBMOD_RESOURCE_MANAGER.load_sync("Data/BBMOD/Skies/Sky+40.png");

matSky = BBMOD_MATERIAL_SKY.clone();
matSky.BaseOpacity = sprite_get_texture(_sprSky.Raw, 0);
BBMOD_RESOURCE_MANAGER.add("MatSky", matSky);

_scene.ImageBasedLight = new BBMOD_ImageBasedLight(sprite_get_texture(_sprIBL.Raw, 0));

sun = new BBMOD_DirectionalLight();
sun.Direction.Set(0.44, 0.63, -0.64);
sun.CastShadows = true;
sun.ShadowmapArea = 40;
sun.ShadowmapResolution = 4096;
_scene.LightDirectional = sun;

probe = new BBMOD_ReflectionProbe(new BBMOD_Vec3(0, 0, 1));
probe.Infinite = true;
_scene.add_reflection_probe(probe);

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
terrain.Scale.Set(16, 16, 1);
terrain.Position.Set(
	-terrain.Size.X * terrain.Scale.X * 0.5,
	-terrain.Size.Y * terrain.Scale.Y * 0.5,
	0);
terrain.TextureRepeat.Set(64);

var _matTerrain = useDeferredRenderer ? BBMOD_MATERIAL_TERRAIN_DEFERRED.clone() : BBMOD_MATERIAL_TERRAIN.clone();
if (!useDeferredRenderer)
{
	_matTerrain.set_shader(BBMOD_ERenderPass.DepthOnly, BBMOD_SHADER_DEFAULT_DEPTH);
}
terrain.Material = _matTerrain;
BBMOD_RESOURCE_MANAGER.add("MatTerrain", _matTerrain);

var _layer = new BBMOD_TerrainLayer();
_layer.BaseOpacity = sprite_get_texture(SprGrass, 0);
_layer.NormalRoughness = sprite_get_texture(SprGrass, 1);
terrain.Layer[@ 0] = _layer;
