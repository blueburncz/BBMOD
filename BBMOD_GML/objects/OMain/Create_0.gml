//window_set_size(1024, 576);
//window_set_position(0, 64);

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
renderer.ShadowmapNormalOffset = 0.2;
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
//postProcessor.add_effect(_dof);

postProcessor.add_effect(new BBMOD_LightBloomEffect(1.2));

directionalBlur = new BBMOD_DirectionalBlurEffect();
postProcessor.add_effect(directionalBlur);

if (_useDeferredRenderer)
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

// Enable new global dither controls used by queue snapshots.
bbmod_dither_set_enabled(true);
bbmod_dither_set_value(1.0);

ditherTriggerEnterDistance = 28.0;
ditherTriggerExitDistance = 36.0;
ditherFadeInSeconds = 0.35;
ditherFadeOutSeconds = 0.55;
ditherFadeInRate = 1.0 / max(ditherFadeInSeconds, 0.001);
ditherFadeOutRate = 1.0 / max(ditherFadeOutSeconds, 0.001);
ditherDistanceScratch = new BBMOD_Vec3(0.0);
ditherFrustum = new BBMOD_FrustumCollider();
ditherRegularStates = [
	{ X: 0.0, Y: 0.0, Z: 1.0, IsInside: true, Fade: 1.0, WasVisible: true },
	{ X: 4.0, Y: 0.0, Z: 1.0, IsInside: true, Fade: 1.0, WasVisible: true },
	{ X: 8.0, Y: 0.0, Z: 1.0, IsInside: true, Fade: 1.0, WasVisible: true },
	{ X: 0.0, Y: -8.0, Z: 0.0, IsInside: true, Fade: 1.0, WasVisible: true },
];

showRenderStatistics = false;
show_debug_overlay(showRenderStatistics, true);
renderStatisticsSnapshot = new BBMOD_RenderStatistics();

modSphere = BBMOD_RESOURCE_MANAGER.load_sync("Data/BBMOD/Models/Sphere.bbmod");
modSphere.Meshes[0].update_bbox(); // For frustum culling
batchSphere = new BBMOD_DynamicBatch(modSphere, 48, 16);
modSphere.freeze();

batchSphereInstances = [];
batchSphereOrbitTime = 0.0;

var _batchSphereInstanceCount = 48;
for (var i = 0; i < _batchSphereInstanceCount; ++i)
{
	var _instance = {
		id: 50000 + i,
		x: 0.0,
		y: 0.0,
		z: 2.0,
		image_xscale: 0.5,
		image_angle: 0.0,
		OrbitAngle: (i / _batchSphereInstanceCount) * 360.0,
		OrbitSpeed: 8.0 + ((i mod 5) * 2.0),
		OrbitRadius: 24.0 + ((i mod 6) * 4.0),
		OrbitHeight: 1.5 + ((i mod 4) * 0.75),
		DitherInside: true,
		DitherWasVisible: true,
	};
	_instance[$  BBMOD_DITHER_VALUE] = 1.0;

	array_push(batchSphereInstances, _instance);
	batchSphere.add_instance(_instance);
}

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
matSphereEmissive.set_emissive(new BBMOD_Color(255 * 1.1, 127 * 1.1, 0));

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

punctualLightsTest = [];

var _pointLightCount = 8;
for (var i = 0; i < _pointLightCount; ++i)
{
	var _pointLight = new BBMOD_PointLight(
		new BBMOD_Color(255, 220, 180),
		new BBMOD_Vec3(),
		30.0
	);

	_pointLight.CastShadows = ((i mod 4) == 0);
	_pointLight.ShadowmapResolution = 256;
	_pointLight.RenderPass = (1 << BBMOD_ERenderPass.Forward)
		| (1 << BBMOD_ERenderPass.Alpha)
		| (1 << BBMOD_ERenderPass.ReflectionCapture);

	// Demonstrates GML-side light fade/cull optimization.
	_pointLight.DistanceFadeStart = 42.0 + ((i mod 4) * 4.0);
	_pointLight.DistanceFadeEnd = _pointLight.DistanceFadeStart + 20.0;

	_pointLight[$ "OrbitAngle"] = (i / _pointLightCount) * 360.0;
	_pointLight[$ "OrbitSpeed"] = 10.0 + (i mod 3) * 4.0;
	_pointLight[$ "OrbitRadius"] = 40.0 + (i mod 4) * 8.0;
	_pointLight[$ "OrbitHeight"] = 4.0 + (i mod 3) * 2.0;

	bbmod_light_punctual_add(_pointLight);
	array_push(punctualLightsTest, _pointLight);
}

spotLightTest = new BBMOD_SpotLight(
	new BBMOD_Color(180, 220, 255),
	new BBMOD_Vec3(0, 0, 14),
	42.0,
	new BBMOD_Vec3(0.0, 0.0, -1.0),
	16.0,
	28.0
);
spotLightTest.CastShadows = true;
spotLightTest.ShadowmapResolution = 512;
spotLightTest.RenderPass = (1 << BBMOD_ERenderPass.Forward)
	| (1 << BBMOD_ERenderPass.Alpha)
	| (1 << BBMOD_ERenderPass.ReflectionCapture);
spotLightTest.DistanceFadeStart = 56.0;
spotLightTest.DistanceFadeEnd = 84.0;
spotLightTest[$ "OrbitAngle"] = 0.0;
spotLightTest[$ "OrbitSpeed"] = 14.0;
spotLightTest[$ "OrbitRadius"] = 30.0;
spotLightTest[$ "OrbitHeight"] = 18.0;

bbmod_light_punctual_add(spotLightTest);

////////////////////////////////////////////////////////////////////////////////
//
// Terrain
//

terrainMaterial = _useDeferredRenderer
	? BBMOD_MATERIAL_TERRAIN_DEFERRED.clone()
	: BBMOD_MATERIAL_TERRAIN.clone();

if (!_useDeferredRenderer)
{
	terrainMaterial.set_shader(BBMOD_ERenderPass.DepthOnly, BBMOD_SHADER_DEFAULT_DEPTH);
}

terrainLayer = new BBMOD_TerrainLayer();
terrainLayer.BaseOpacity = sprite_get_texture(BBMOD_SprCheckerboard, 0);

var _terrainInfo = new BBMOD_TerrainInfo();
_terrainInfo.Heightmap = SprHeightmap;
_terrainInfo.SmoothHeight = 3;
_terrainInfo.ChunkSize = 64;
_terrainInfo.ChunkRadius = 5;
_terrainInfo.EnableLazyBuild = true;
_terrainInfo.LazyBuildBudget = 1;
//_terrainInfo.LazyBuildInterval = 4;
_terrainInfo.EnableBuildProfiler = true;
_terrainInfo.Scale.Set(16);
_terrainInfo.TextureRepeat.Set(32);
_terrainInfo.Material = terrainMaterial;
_terrainInfo.Colormap = sprite_get_texture(SprColormap, 0);
_terrainInfo.Layer[@ 0] = terrainLayer;

terrain = new BBMOD_Terrain(_terrainInfo);

// Center terrain around world origin
terrain.Position.Set(
	-terrain.Size.X * terrain.Scale.X * 0.5,
	-terrain.Size.Y * terrain.Scale.Y * 0.5,
	0);

////////////////////////////////////////////////////////////////////////////////
//
// Fog
//

var _terrainMaxScale = max(terrain.Scale.X, terrain.Scale.Y);
var _terrainChunkWorldSize = max(terrain.ChunkSize * _terrainMaxScale, 1.0);
var _terrainChunkMaxRange = terrain.ChunkRadius * _terrainChunkWorldSize;
var _fogStart = _terrainChunkMaxRange * 0.7;
var _fogEnd = _terrainChunkMaxRange * 0.9;

bbmod_fog_set(BBMOD_C_SILVER, 0.9, _fogStart, _fogEnd);

////////////////////////////////////////////////////////////////////////////////
//
// Particle module showcase test
//

particleModuleShowcaseEnabled = true;
particleModuleShowcaseSystems = [];
particleModuleShowcaseEmitters = [];
particleModuleShowcaseNames = [];
particleModuleShowcaseCollisionCount = 0;

particleModuleShowcaseColumns = 9;
particleModuleShowcaseSpacingX = 18.0;
particleModuleShowcaseSpacingY = 20.0;
particleModuleShowcaseOriginX = -((particleModuleShowcaseColumns - 1) * particleModuleShowcaseSpacingX * 0.5);
particleModuleShowcaseOriginY = -52.0;
particleModuleShowcaseOffsetY = -200.0;
particleModuleShowcaseBaseZ = 7.0;
particleModuleShowcaseRowZStep = 1.5;

_particle_showcase_emit_module = function (_count = 2, _interval = 0.08)
{
	var _module = new BBMOD_ParticleModule();
	_module[$ "Count"] = _count;
	_module[$ "Interval"] = _interval;
	_module[$ "Timer"] = 0.0;

	_module.on_update = method(_module, function (_emitter, _deltaTime)
	{
		var _timer = self[$ "Timer"];
		if (_timer == undefined)
		{
			_timer = 0.0;
		}

		var _interval = self[$ "Interval"];
		if (_interval == undefined || _interval <= 0.0)
		{
			_interval = 0.08;
		}

		_timer += _deltaTime * 0.000001;
		while (_timer >= _interval)
		{
			_timer -= _interval;
			var i = 0;
			repeat(self[$ "Count"])
			{
				_emitter.spawn_particle();
				++i;
			}
		}

		self[$ "Timer"] = _timer;
	});

	return _module;
};

_particle_showcase_init_module = function (_speedMin = 2.0, _speedMax = 6.0,
	_scale = 0.3, _bounce = 0.35, _downward = false)
{
	var _module = new BBMOD_ParticleModule();
	_module[$ "SpeedMin"] = _speedMin;
	_module[$ "SpeedMax"] = _speedMax;
	_module[$ "Scale"] = _scale;
	_module[$ "Bounce"] = _bounce;
	_module[$ "Downward"] = _downward;

	_module.on_particle_start = method(_module, function (_emitter, _particleIndex)
	{
		var _particles = _emitter.Particles;
		var _angle = random(360.0);
		var _speedXY = random_range(self[$ "SpeedMin"], self[$ "SpeedMax"]);
		var _speedZ = self[$ "Downward"]
			? -random_range(self[$ "SpeedMin"], self[$ "SpeedMax"])
			: random_range(self[$ "SpeedMin"] * 0.25, self[$ "SpeedMax"]);

		_particles[# BBMOD_EParticle.Health, _particleIndex] = 1.0;
		_particles[# BBMOD_EParticle.HealthLeft, _particleIndex] = 1.0;
		_particles[# BBMOD_EParticle.Mass, _particleIndex] = 1.0;
		_particles[# BBMOD_EParticle.Drag, _particleIndex] = 0.12;
		_particles[# BBMOD_EParticle.Bounce, _particleIndex] = self[$ "Bounce"];

		_particles[# BBMOD_EParticle.VelocityX, _particleIndex] = lengthdir_x(_speedXY, _angle);
		_particles[# BBMOD_EParticle.VelocityY, _particleIndex] = lengthdir_y(_speedXY, _angle);
		_particles[# BBMOD_EParticle.VelocityZ, _particleIndex] = _speedZ;

		_particles[# BBMOD_EParticle.ScaleX, _particleIndex] = self[$ "Scale"];
		_particles[# BBMOD_EParticle.ScaleY, _particleIndex] = self[$ "Scale"];
		_particles[# BBMOD_EParticle.ScaleZ, _particleIndex] = self[$ "Scale"];

		_particles[# BBMOD_EParticle.ColorR, _particleIndex] = 255.0;
		_particles[# BBMOD_EParticle.ColorG, _particleIndex] = 255.0;
		_particles[# BBMOD_EParticle.ColorB, _particleIndex] = 255.0;
		_particles[# BBMOD_EParticle.ColorA, _particleIndex] = 1.0;
	});

	return _module;
};

_particle_showcase_decay_module = function (_lifetime = 2.5, _gravityZ = -6.0)
{
	var _module = new BBMOD_ParticleModule();
	_module[$ "Lifetime"] = max(_lifetime, 0.001);
	_module[$ "GravityZ"] = _gravityZ;

	_module.on_update = method(_module, function (_emitter, _deltaTime)
	{
		var _alive = _emitter.ParticlesAlive;
		if (_alive <= 0)
		{
			return;
		}

		var _particles = _emitter.Particles;
		var _deltaSeconds = _deltaTime * 0.000001;
		ds_grid_add_region(
			_particles,
			BBMOD_EParticle.HealthLeft, 0,
			BBMOD_EParticle.HealthLeft, _alive - 1,
			-_deltaSeconds / self[$ "Lifetime"]);
		ds_grid_add_region(
			_particles,
			BBMOD_EParticle.AccelerationZ, 0,
			BBMOD_EParticle.AccelerationZ, _alive - 1,
			self[$ "GravityZ"]);
	});

	return _module;
};

_particle_showcase_add = function (_name, _modules, _options = undefined)
{
	_options ??= {};

	var _useBaseEmission = _options[$ "UseBaseEmission"];
	if (_useBaseEmission == undefined)
	{
		_useBaseEmission = true;
	}

	var _useBaseDecay = _options[$ "UseBaseDecay"];
	if (_useBaseDecay == undefined)
	{
		_useBaseDecay = true;
	}

	var _duration = _options[$ "Duration"];
	if (_duration == undefined)
	{
		_duration = 2.5;
	}

	var _positionZ = _options[$ "PositionZ"];
	if (_positionZ == undefined)
	{
		_positionZ = particleModuleShowcaseBaseZ;
	}

	var _particleCount = _options[$ "ParticleCount"];
	if (_particleCount == undefined)
	{
		_particleCount = 48;
	}

	var _initModule = _options[$ "InitModule"];
	if (_initModule == undefined)
	{
		_initModule = _particle_showcase_init_module();
	}

	var _system = new BBMOD_ParticleSystem(
		BBMOD_MODEL_PARTICLE,
		BBMOD_MATERIAL_PARTICLE_UNLIT,
		_particleCount,
		16);
	_system.Duration = _duration;
	_system.Loop = true;

	if (_useBaseEmission)
	{
		_system.add_modules(_particle_showcase_emit_module());
	}

	_system.add_modules(_initModule);

	if (is_array(_modules))
	{
		var _moduleIndex = 0;
		repeat(array_length(_modules))
		{
			var _module = _modules[_moduleIndex++];
			if (_module != undefined)
			{
				_system.add_modules(_module);
			}
		}
	}
	else if (_modules != undefined)
	{
		_system.add_modules(_modules);
	}

	if (_useBaseDecay)
	{
		_system.add_modules(_particle_showcase_decay_module());
	}

	var _index = array_length(particleModuleShowcaseEmitters);
	var _column = _index mod particleModuleShowcaseColumns;
	var _row = _index div particleModuleShowcaseColumns;
	var _position = new BBMOD_Vec3(
		particleModuleShowcaseOriginX + (_column * particleModuleShowcaseSpacingX),
		particleModuleShowcaseOriginY + particleModuleShowcaseOffsetY + (_row * particleModuleShowcaseSpacingY),
		_positionZ + ((_row mod 2) * particleModuleShowcaseRowZStep));
	var _emitter = new BBMOD_ParticleEmitter(_position, _system);

	array_push(particleModuleShowcaseSystems, _system);
	array_push(particleModuleShowcaseEmitters, _emitter);
	array_push(particleModuleShowcaseNames, _name);
};

var _quatIdentity = new BBMOD_Quaternion();
var _quatUp180 = new BBMOD_Quaternion().FromAxisAngle(BBMOD_VEC3_UP, 180.0);
var _quatXAxis90 = new BBMOD_Quaternion().FromAxisAngle(new BBMOD_Vec3(1.0, 0.0, 0.0), 90.0);
var _collisionCallback = function (_emitter, _particleIndex)
{
	++particleModuleShowcaseCollisionCount;
	var _particles = _emitter.Particles;
	_particles[# BBMOD_EParticle.ColorR, _particleIndex] = 255.0;
	_particles[# BBMOD_EParticle.ColorG, _particleIndex] = 80.0;
	_particles[# BBMOD_EParticle.ColorB, _particleIndex] = 255.0;
	_particles[# BBMOD_EParticle.ColorA, _particleIndex] = 1.0;
};

// Emission modules
_particle_showcase_add("BBMOD_EmissionModule", [
	new BBMOD_EmissionModule(10)
],
{
	UseBaseEmission: false,
	Duration: 0.8,
});
_particle_showcase_add("BBMOD_EmissionOverTimeModule", [
	new BBMOD_EmissionOverTimeModule(2, 0.15)
],
{
	UseBaseEmission: false,
});
_particle_showcase_add("BBMOD_MixEmissionModule", [
	new BBMOD_MixEmissionModule(4, 12)
],
{
	UseBaseEmission: false,
	Duration: 1.2,
});

// Spawn-shape modules
_particle_showcase_add("BBMOD_SphereEmissionModule", [
	new BBMOD_SphereEmissionModule(3.2, true)
]);
_particle_showcase_add("BBMOD_AABBEmissionModule", [
	new BBMOD_AABBEmissionModule(
		new BBMOD_Vec3(-2.5, -2.5, -0.8),
		new BBMOD_Vec3(2.5, 2.5, 0.8),
		true)
]);

// Physics and force modules
_particle_showcase_add("BBMOD_GravityModule", [
	new BBMOD_GravityModule(new BBMOD_Vec3(0.0, 0.0, -14.0))
]);
_particle_showcase_add("BBMOD_DragModule", [
	new BBMOD_DragModule(),
	new BBMOD_SetRealModule(BBMOD_EParticle.Drag, 0.9)
]);
_particle_showcase_add("BBMOD_AttractorModule", [
	new BBMOD_AttractorModule(new BBMOD_Vec3(0.0, 0.0, 3.5), true, 12.0, 8.0)
]);

// Real modules
_particle_showcase_add("BBMOD_SetRealModule", [
	new BBMOD_SetRealModule(BBMOD_EParticle.ColorA, 0.35)
]);
_particle_showcase_add("BBMOD_MixRealModule", [
	new BBMOD_MixRealModule(BBMOD_EParticle.ColorA, 0.15, 1.0)
]);
_particle_showcase_add("BBMOD_MixRealOverTimeModule", [
	new BBMOD_MixRealOverTimeModule(BBMOD_EParticle.ColorA, 1.0, 0.0, 2.0)
]);
_particle_showcase_add("BBMOD_MixRealFromHealthModule", [
	new BBMOD_MixRealFromHealthModule(BBMOD_EParticle.ColorA, 1.0, 0.0)
]);
_particle_showcase_add("BBMOD_MixRealFromSpeedModule", [
	new BBMOD_MixRealFromSpeedModule(BBMOD_EParticle.ColorA, 0.2, 1.0, 0.0, 8.0)
]);
_particle_showcase_add("BBMOD_AddRealOverTimeModule", [
	new BBMOD_AddRealOverTimeModule(BBMOD_EParticle.ScaleX, -0.15, 1.0)
]);

// Color and vec4 modules
_particle_showcase_add("BBMOD_SetColorModule", [
	new BBMOD_SetColorModule(BBMOD_EParticle.ColorR, new BBMOD_Color(255, 140, 64))
]);
_particle_showcase_add("BBMOD_MixColorModule", [
	new BBMOD_MixColorModule(
		BBMOD_EParticle.ColorR,
		new BBMOD_Color(255, 64, 64),
		new BBMOD_Color(64, 160, 255))
]);
_particle_showcase_add("BBMOD_MixColorOverTimeModule", [
	new BBMOD_MixColorOverTimeModule(
		BBMOD_EParticle.ColorR,
		new BBMOD_Color(255, 255, 255),
		new BBMOD_Color(255, 96, 16),
		2.0)
]);
_particle_showcase_add("BBMOD_MixColorFromHealthModule", [
	new BBMOD_MixColorFromHealthModule(
		BBMOD_EParticle.ColorR,
		new BBMOD_Color(64, 255, 96),
		new BBMOD_Color(255, 64, 64))
]);
_particle_showcase_add("BBMOD_MixColorFromSpeedModule", [
	new BBMOD_MixColorFromSpeedModule(
		BBMOD_EParticle.ColorR,
		new BBMOD_Color(32, 128, 255),
		new BBMOD_Color(255, 32, 96),
		0.0,
		8.0)
]);
_particle_showcase_add("BBMOD_SetVec4Module", [
	new BBMOD_SetVec4Module(BBMOD_EParticle.ColorR, new BBMOD_Vec4(255.0, 220.0, 80.0, 0.9))
]);
_particle_showcase_add("BBMOD_MixVec4Module", [
	new BBMOD_MixVec4Module(
		BBMOD_EParticle.ColorR,
		new BBMOD_Vec4(255.0, 64.0, 64.0, 0.6),
		new BBMOD_Vec4(64.0, 160.0, 255.0, 1.0),
		false)
]);
_particle_showcase_add("BBMOD_MixVec4OverTimeModule", [
	new BBMOD_MixVec4OverTimeModule(
		BBMOD_EParticle.ColorR,
		new BBMOD_Vec4(255.0, 255.0, 255.0, 1.0),
		new BBMOD_Vec4(96.0, 32.0, 255.0, 0.0),
		2.0)
]);
_particle_showcase_add("BBMOD_MixVec4FromHealthModule", [
	new BBMOD_MixVec4FromHealthModule(
		BBMOD_EParticle.ColorR,
		new BBMOD_Vec4(64.0, 255.0, 64.0, 1.0),
		new BBMOD_Vec4(255.0, 32.0, 32.0, 0.0))
]);
_particle_showcase_add("BBMOD_MixVec4FromSpeedModule", [
	new BBMOD_MixVec4FromSpeedModule(
		BBMOD_EParticle.ColorR,
		new BBMOD_Vec4(64.0, 128.0, 255.0, 0.4),
		new BBMOD_Vec4(255.0, 255.0, 80.0, 1.0),
		0.0,
		8.0)
]);
_particle_showcase_add("BBMOD_AddVec4OverTimeModule", [
	new BBMOD_AddVec4OverTimeModule(BBMOD_EParticle.ColorR, new BBMOD_Vec4(-60.0, -80.0, 0.0, -0.2), 1.2)
]);

// Vec2 modules
_particle_showcase_add("BBMOD_SetVec2Module", [
	new BBMOD_SetVec2Module(BBMOD_EParticle.ScaleX, new BBMOD_Vec2(0.15, 0.65))
]);
_particle_showcase_add("BBMOD_MixVec2Module", [
	new BBMOD_MixVec2Module(
		BBMOD_EParticle.ScaleX,
		new BBMOD_Vec2(0.1, 0.1),
		new BBMOD_Vec2(0.7, 0.25),
		true)
]);
_particle_showcase_add("BBMOD_MixVec2OverTimeModule", [
	new BBMOD_MixVec2OverTimeModule(
		BBMOD_EParticle.ScaleX,
		new BBMOD_Vec2(0.7, 0.7),
		new BBMOD_Vec2(0.1, 0.1),
		2.0)
]);
_particle_showcase_add("BBMOD_MixVec2FromHealthModule", [
	new BBMOD_MixVec2FromHealthModule(
		BBMOD_EParticle.ScaleX,
		new BBMOD_Vec2(0.8, 0.8),
		new BBMOD_Vec2(0.2, 0.2))
]);
_particle_showcase_add("BBMOD_MixVec2FromSpeedModule", [
	new BBMOD_MixVec2FromSpeedModule(
		BBMOD_EParticle.ScaleX,
		new BBMOD_Vec2(0.2, 0.2),
		new BBMOD_Vec2(0.85, 0.85),
		0.0,
		8.0)
]);
_particle_showcase_add("BBMOD_AddVec2OverTimeModule", [
	new BBMOD_AddVec2OverTimeModule(BBMOD_EParticle.VelocityX, new BBMOD_Vec2(1.5, 0.0), 1.0)
]);

// Vec3 modules
_particle_showcase_add("BBMOD_SetVec3Module", [
	new BBMOD_SetVec3Module(BBMOD_EParticle.ScaleX, new BBMOD_Vec3(0.22, 0.5, 0.9))
]);
_particle_showcase_add("BBMOD_MixVec3Module", [
	new BBMOD_MixVec3Module(
		BBMOD_EParticle.VelocityX,
		new BBMOD_Vec3(-3.0, -1.5, 4.0),
		new BBMOD_Vec3(3.0, 1.5, 8.0),
		true)
]);
_particle_showcase_add("BBMOD_MixVec3OverTimeModule", [
	new BBMOD_MixVec3OverTimeModule(
		BBMOD_EParticle.ScaleX,
		new BBMOD_Vec3(0.2, 0.2, 0.2),
		new BBMOD_Vec3(0.9, 0.9, 0.9),
		2.0)
]);
_particle_showcase_add("BBMOD_MixVec3FromHealthModule", [
	new BBMOD_MixVec3FromHealthModule(
		BBMOD_EParticle.ScaleX,
		new BBMOD_Vec3(0.9, 0.9, 0.9),
		new BBMOD_Vec3(0.2, 0.2, 0.2))
]);
_particle_showcase_add("BBMOD_MixVec3FromSpeedModule", [
	new BBMOD_MixVec3FromSpeedModule(
		BBMOD_EParticle.ScaleX,
		new BBMOD_Vec3(0.2, 0.2, 0.2),
		new BBMOD_Vec3(1.0, 1.0, 1.0),
		0.0,
		8.0)
]);
_particle_showcase_add("BBMOD_AddVec3OverTimeModule", [
	new BBMOD_AddVec3OverTimeModule(BBMOD_EParticle.VelocityX, new BBMOD_Vec3(0.0, 0.0, 6.0), 1.0)
]);

// Quaternion and rotation modules
_particle_showcase_add("BBMOD_SetQuaternionModule", [
	new BBMOD_SetQuaternionModule(BBMOD_EParticle.RotationX, _quatXAxis90.Clone())
]);
_particle_showcase_add("BBMOD_MixQuaternionModule", [
	new BBMOD_MixQuaternionModule(BBMOD_EParticle.RotationX, _quatIdentity.Clone(), _quatUp180.Clone())
]);
_particle_showcase_add("BBMOD_MixQuaternionOverTimeModule", [
	new BBMOD_MixQuaternionOverTimeModule(BBMOD_EParticle.RotationX, _quatIdentity.Clone(), _quatUp180.Clone(),
		2.0)
]);
_particle_showcase_add("BBMOD_MixQuaternionFromHealthModule", [
	new BBMOD_MixQuaternionFromHealthModule(BBMOD_EParticle.RotationX, _quatIdentity.Clone(), _quatUp180
		.Clone())
]);
_particle_showcase_add("BBMOD_MixQuaternionFromSpeedModule", [
	new BBMOD_MixQuaternionFromSpeedModule(BBMOD_EParticle.RotationX, _quatIdentity.Clone(), _quatXAxis90
		.Clone(), 0.0, 8.0)
]);
_particle_showcase_add("BBMOD_RandomRotationModule", [
	new BBMOD_RandomRotationModule(BBMOD_VEC3_UP, 0.0, 360.0)
]);
_particle_showcase_add("BBMOD_MixSpeedModule", [
	new BBMOD_MixSpeedModule(1.5, 10.0)
]);

// Collision and on-collision modules
_particle_showcase_add("BBMOD_TerrainCollisionModule", [
	new BBMOD_TerrainCollisionModule(terrain)
],
{
	InitModule: _particle_showcase_init_module(1.0, 2.6, 0.28, 0.65, true),
	PositionZ: 14.0,
});
_particle_showcase_add("BBMOD_CollisionEventModule", [
	new BBMOD_TerrainCollisionModule(terrain),
	new BBMOD_CollisionEventModule(_collisionCallback)
],
{
	InitModule: _particle_showcase_init_module(1.0, 2.6, 0.28, 0.65, true),
	PositionZ: 14.0,
});
_particle_showcase_add("BBMOD_AddRealOnCollisionModule", [
	new BBMOD_TerrainCollisionModule(terrain),
	new BBMOD_AddRealOnCollisionModule(BBMOD_EParticle.HealthLeft, -0.4)
],
{
	InitModule: _particle_showcase_init_module(1.0, 2.6, 0.28, 0.65, true),
	PositionZ: 14.0,
});
_particle_showcase_add("BBMOD_AddVec2OnCollisionModule", [
	new BBMOD_TerrainCollisionModule(terrain),
	new BBMOD_AddVec2OnCollisionModule(BBMOD_EParticle.VelocityX, new BBMOD_Vec2(0.8, 0.0))
],
{
	InitModule: _particle_showcase_init_module(1.0, 2.6, 0.28, 0.65, true),
	PositionZ: 14.0,
});
_particle_showcase_add("BBMOD_AddVec3OnCollisionModule", [
	new BBMOD_TerrainCollisionModule(terrain),
	new BBMOD_AddVec3OnCollisionModule(BBMOD_EParticle.VelocityX, new BBMOD_Vec3(0.0, 0.0, 2.0))
],
{
	InitModule: _particle_showcase_init_module(1.0, 2.6, 0.28, 0.65, true),
	PositionZ: 14.0,
});
_particle_showcase_add("BBMOD_AddVec4OnCollisionModule", [
	new BBMOD_TerrainCollisionModule(terrain),
	new BBMOD_AddVec4OnCollisionModule(BBMOD_EParticle.ColorR, new BBMOD_Vec4(-120.0, 0.0, 120.0, 0.0))
],
{
	InitModule: _particle_showcase_init_module(1.0, 2.6, 0.28, 0.65, true),
	PositionZ: 14.0,
});
_particle_showcase_add("BBMOD_CollisionKillModule", [
	new BBMOD_TerrainCollisionModule(terrain),
	new BBMOD_CollisionKillModule()
],
{
	InitModule: _particle_showcase_init_module(1.0, 2.6, 0.28, 0.65, true),
	UseBaseDecay: false,
	PositionZ: 14.0,
});

show_debug_message("Particle module showcase emitters: " + string(array_length(particleModuleShowcaseEmitters)));
if (array_length(particleModuleShowcaseEmitters) != 51)
{
	show_debug_message("WARNING: Expected 51 particle module showcase emitters.");
}

////////////////////////////////////////////////////////////////////////////////
//
// Animation player test
//

modCharacter = BBMOD_RESOURCE_MANAGER.load_sync("Data/Character/Character.bbmod");
//modCharacter.Meshes[0].update_bbox(); // For frustum culling

{
	var _material = undefined;
	if (_useDeferredRenderer)
	{
		_material = BBMOD_MATERIAL_DEFERRED.clone();
	}
	else
	{
		_material = BBMOD_MATERIAL_DEFAULT.clone();
		_material.set_shader(BBMOD_ERenderPass.DepthOnly, BBMOD_SHADER_DEFAULT_DEPTH);
	}
	_material.set_shader(BBMOD_ERenderPass.Shadows, BBMOD_SHADER_DEFAULT_DEPTH);
	_material.BaseOpacity = sprite_get_texture(SprCyborgFemaleA, 0);
	modCharacter.Materials[@ 0] = _material;
}

animCharacterIdle = BBMOD_RESOURCE_MANAGER.load_sync("Data/Character/Character_Idle.bbanim");
animCharacterWalk = BBMOD_RESOURCE_MANAGER.load_sync("Data/Character/Character_Walk.bbanim");
animCharacterRun = BBMOD_RESOURCE_MANAGER.load_sync("Data/Character/Character_Run.bbanim");
animCharacterShoot = BBMOD_RESOURCE_MANAGER.load_sync("Data/Character/Character_Shoot.bbanim");

characterPlayer = new BBMOD_AnimationPlayer(modCharacter);
characterPlayer.EnableTransitions = true;
characterPlayer.play(animCharacterIdle, true);

characterBurstRunHoldDuration = 600000;
characterBurstRunHoldRemaining = 0;
characterLocomotionSpeedCurrent = 0.0;
characterLocomotionAccelRate = 14.0;
characterLocomotionDecelRate = 8.0;
characterIsShooting = false;
characterDesiredAnimation = animCharacterIdle;
characterDesiredLoops = true;
