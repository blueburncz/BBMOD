varying vec2 vTexCoord;

uniform float bbmod_ZFar;

// Fog colour, alpha = max fog opacity
uniform vec4  bbmod_FogColor;
// Master fog intensity multiplier
uniform float bbmod_FogIntensity;
// Distance at which fog begins (near cutoff)
uniform float bbmod_FogStart;
// 1.0 / (fogEnd - fogStart) — controls the linear near-ramp width
uniform float bbmod_FogRcpRange;
// Exponential height fog density at base height
uniform float bbmod_FogDensity;
// Height falloff coefficient (0 = uniform, higher = fog hugs the ground)
uniform float bbmod_FogFalloff;
// World Z of the fog baseline
uniform float bbmod_FogHeight;
// Aerial perspective sun glow strength
uniform float bbmod_FogAerialIntensity;

uniform vec4 bbmod_LightAmbientUp;
uniform vec4 bbmod_LightAmbientDown;
uniform vec3 bbmod_LightDirectionalDir;
uniform vec4 bbmod_LightDirectionalColor;

// Camera world position (set globally by BBMOD each frame)
uniform vec3  bbmod_CamPos;

// Camera basis vectors and projection params — needed to reconstruct the
// per-pixel view direction so aerial perspective is correct across the screen.
// Set these as global shader uniforms from OMain alongside the cloud renderer.
uniform vec3  bbmod_FogCamForward;
uniform vec3  bbmod_FogCamRight;
uniform vec3  bbmod_FogCamUp;
uniform float bbmod_FogTanHalfFovY;
uniform float bbmod_FogAspect;

uniform sampler2D uDepth;

#define X_GAMMA 2.2

vec3 xGammaToLinear(vec3 rgb) { return pow(rgb, vec3(X_GAMMA)); }
vec3 xLinearToGamma(vec3 rgb) { return pow(rgb, vec3(1.0 / X_GAMMA)); }

float xDecodeDepth(vec3 c)
{
	return dot(c, vec3(1.0, 1.0 / 255.0, 1.0 / 65025.0));
}

void Fog(float depth, vec3 viewDir)
{
	vec3 ambientUp   = xGammaToLinear(bbmod_LightAmbientUp.rgb)   * bbmod_LightAmbientUp.a;
	vec3 ambientDown = xGammaToLinear(bbmod_LightAmbientDown.rgb) * bbmod_LightAmbientDown.a;
	vec3 sunColor    = xGammaToLinear(bbmod_LightDirectionalColor.rgb) * bbmod_LightDirectionalColor.a;
	vec3 fogBase     = xGammaToLinear(bbmod_FogColor.rgb) * (ambientUp + ambientDown + sunColor);

	// Aerial perspective: forward-scattered sun glow.
	float cosTheta = dot(viewDir, -normalize(bbmod_LightDirectionalDir));
	float sunGlow  = max(0.0, cosTheta);
	sunGlow = sunGlow * sunGlow * sunGlow * sunGlow;
	vec3 fogColor  = fogBase + sunColor * sunGlow * bbmod_FogAerialIntensity;

	// Reconstruct approximate fragment world Z from view direction and depth.
	float fragZ = bbmod_CamPos.z + viewDir.z * depth;

	// Analytical exponential height fog (same formula as Fog.xsh).
	float camH  = max(bbmod_CamPos.z - bbmod_FogHeight, 0.0);
	float fragH = max(fragZ          - bbmod_FogHeight, 0.0);
	float e0 = exp(-bbmod_FogFalloff * camH);
	float e1 = exp(-bbmod_FogFalloff * fragH);
	float dh = fragZ - bbmod_CamPos.z;

	float integral;
	if (abs(dh) > 0.01 && bbmod_FogFalloff > 0.0001)
	{
		integral = bbmod_FogDensity * depth * abs(e0 - e1) / (bbmod_FogFalloff * abs(dh));
	}
	else
	{
		integral = bbmod_FogDensity * (bbmod_FogFalloff > 0.0001 ? e0 : 1.0) * depth;
	}

	integral *= clamp((depth - bbmod_FogStart) * bbmod_FogRcpRange, 0.0, 1.0);

	float fogAmount = clamp(1.0 - exp(-integral), 0.0, 1.0) * bbmod_FogColor.a * bbmod_FogIntensity;
	gl_FragColor.rgb = mix(gl_FragColor.rgb, fogColor, fogAmount);
}

void main()
{
	// Reconstruct per-pixel view direction from camera frustum parameters.
	vec2 ndc     = vTexCoord * 2.0 - 1.0;
	vec3 viewDir = normalize(
		bbmod_FogCamForward
		+ bbmod_FogCamRight * ndc.x * bbmod_FogTanHalfFovY * bbmod_FogAspect
		+ bbmod_FogCamUp    * ndc.y * bbmod_FogTanHalfFovY);

	float depth = xDecodeDepth(texture2D(uDepth, vTexCoord).rgb) * bbmod_ZFar;
	gl_FragColor = vec4(texture2D(gm_BaseTexture, vTexCoord).rgb, (depth < bbmod_ZFar) ? 1.0 : 0.0);
	Fog(depth, viewDir);
}
