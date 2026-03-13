useDeferredRenderer = bbmod_deferred_renderer_is_supported();

z = 1;

camera = new BBMOD_Camera();
camera.Exposure = 1;
camera.MouseSensitivity = 0.5;
camera.FollowObject = self;

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
renderer.ShadowmapNormalOffset = 0.03;
renderer.EnableSSAO = true;
renderer.SSAODepthRange = 1.5;
renderer.SSAORadius = 128;
renderer.SSAOPower = 2;

gizmo = new BBMOD_Gizmo();
renderer.Gizmo = gizmo;
renderer.EditMode = true;

postProcessor = new BBMOD_PostProcessor();
postProcessor.LensDirtStrength = 0.1;

//dof = new BBMOD_DepthOfFieldEffect();
//dof.AutoFocus = true;
//dof.AutoFocusRange = 3;
//dof.BlurRangeNear = 5;
//dof.BlurRangeFar = 5;
//dof.BlurScaleNear = 0.33;
//dof.BlurScaleFar = 0.33;
//postProcessor.add_effect(dof);

postProcessor.add_effect(new BBMOD_LightBloomEffect(new BBMOD_Vec3(-6.0)));

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

sun = new BBMOD_DirectionalLight();
sun.Direction.Set(0.44, 0.63, -0.64);
sun.CastShadows = true;
sun.ShadowmapArea = 40;
sun.ShadowmapResolution = 4096;
_scene.LightDirectional = sun;

////////////////////////////////////////////////////////////////////////////////
//
// Observer / astronomical clock
//

// Latitude and longitude of the virtual observer (degrees).
astroLat    = 49.5938;  // Olomouc, Czech Republic
astroLon    = 17.2509;
astroUTC    = 1;        // CET (UTC+1), or 2 during CEST

// Calendar date. Advance astroHour each step to animate the sky.
astroYear   = 2024;
astroMonth  = 6;
astroDay    = 14;       // First quarter moon — right half lit, visible all evening
astroHourAccum = 12.0; // Noon
astroJumped    = true; // force immediate update on first step to initialize sun/moon direction and color

// JD at astroHourAccum = 0 on the start date. Current JD = astroJdEpoch + astroHourAccum / 24.
// This avoids the midnight discontinuity that occurs when astroDay is fixed + hour wraps.
astroJdEpoch = bbmod_astronomy_julian_date(astroYear, astroMonth, astroDay, 0, 0, 0, astroUTC);

time = 0; // kept for legacy use; astronomy now drives sun/moon

clouds = new BBMOD_CloudRenderer();
clouds.Sun             = sun;
renderer.CloudRenderer = clouds;
//clouds.set_weather(BBMOD_ECloudWeather.Cloudy);

var _sprIBL = BBMOD_RESOURCE_MANAGER.load_sync("Data/BBMOD/Skies/IBL+40.png");
var _sprSky = BBMOD_RESOURCE_MANAGER.load_sync("Data/BBMOD/Skies/Sky+40.png");

matSky = BBMOD_MATERIAL_SKY_PHYSICAL.clone();

var _sunDir = sun.Direction.Normalize();

bbmod_shader_set_global_f3("bbmod_SunDirection", _sunDir.X, _sunDir.Y, _sunDir.Z);
bbmod_shader_set_global_f("bbmod_Turbidity", 1.0);
bbmod_shader_set_global_f("bbmod_SunIntensity", 20.0);

bbmod_shader_set_global_sampler(BBMOD_U_TRANSMITTANCE_LUT, bbmod_sky_transmittance_lut_get());
sun.Color = bbmod_sky_sun_transmittance_color(_sunDir.Z);

// Night sky
bbmod_shader_set_global_f3("bbmod_NightSkyHorizonColor", 0.005, 0.005, 0.015);
bbmod_shader_set_global_f3("bbmod_NightSkyZenithColor",  0.0,   0.0,   0.01);
bbmod_shader_set_global_f("bbmod_NightZenithShift",  0.5);
bbmod_shader_set_global_f("bbmod_NightIntensity",    0.0);
bbmod_shader_set_global_f("bbmod_LightDirectionalDiskSize", 0.0093); // sun diameter in radians
bbmod_shader_set_global_f("bbmod_StarIntensity",     1.0);
bbmod_shader_set_global_f("bbmod_StarDensity",       0.04);
bbmod_shader_set_global_f("bbmod_StarTime",          0.0);
bbmod_shader_set_global_f("bbmod_StarLST",           0.0);
// Celestial north pole direction in world space (Z-up, North = +Y): (0, cos(lat), sin(lat)).
// Polaris sits at altitude = latitude above the North horizon — this encodes that.
bbmod_shader_set_global_f3("bbmod_StarPole", 0.0, dcos(astroLat), dsin(astroLat));
bbmod_shader_set_global_f3("bbmod_MoonDirection",    -_sunDir.X, -_sunDir.Y, -_sunDir.Z);
bbmod_shader_set_global_f("bbmod_MoonAngularRadius", 0.0218); // ~1.25° for visibility
bbmod_shader_set_global_f3("bbmod_MoonColor",        0.9, 0.88, 0.82);
bbmod_shader_set_global_f4("bbmod_MoonInnerCorona",  0.25, 0.25, 0.2,  8000.0);
bbmod_shader_set_global_f4("bbmod_MoonOuterCorona",  0.08, 0.08, 0.06,  600.0);

// Exponential height fog + aerial perspective.
// FogColor/Intensity/Start/End are owned by BBMOD_Scene and pushed to shaders
// automatically each frame — set them here via the scene API.
var _fogColor = new BBMOD_Color(0.6, 0.65, 0.7);
_scene.FogColor     = _fogColor;
_scene.FogIntensity = 1.0;
_scene.FogStart     = 5.0;
_scene.FogEnd       = 200.0; // used as the near-ramp width end

// New exponential height fog uniforms — not managed by the scene, set globally.
bbmod_shader_set_global_f("bbmod_FogDensity",        0.001);
bbmod_shader_set_global_f("bbmod_FogFalloff",        0.003);
bbmod_shader_set_global_f("bbmod_FogHeight",         0.0);
bbmod_shader_set_global_f("bbmod_FogAerialIntensity",0.4);

//matSky = BBMOD_MATERIAL_SKY.clone();
//matSky.BaseOpacity = sprite_get_texture(_sprSky.Raw, 0);

BBMOD_RESOURCE_MANAGER.add("MatSky", matSky);

//_scene.ImageBasedLight = new BBMOD_ImageBasedLight(sprite_get_texture(_sprIBL.Raw, 0));

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

terrain = new BBMOD_Terrain(SprHeightmap, 0, 16);
terrain.Scale.Set(16, 16, 1);
terrain.Position.Set(
	-terrain.Size.X * terrain.Scale.X * 0.5,
	-terrain.Size.Y * terrain.Scale.Y * 0.5,
	0);
terrain.TextureRepeat.Set(128);

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

UI = new CGUI();
