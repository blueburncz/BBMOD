// @include BBMOD_GammaToLinear

/// @desc Applies fog effect to a color based on depth.
/// @param color The input color to apply fog to.
/// @param depth The depth value (typically from v_vPosition.z).
/// @return Color with fog applied.
/// @note Requires uniforms: bbmod_FogColor, bbmod_FogIntensity, bbmod_FogStart, bbmod_FogRcpRange,
///       bbmod_LightAmbientUp, bbmod_LightAmbientDown, bbmod_LightDirectionalColor.
vec3 BBMOD_Fog(vec3 color, float depth)
{
	vec3 ambientUp = BBMOD_GammaToLinear(bbmod_LightAmbientUp.rgb) * bbmod_LightAmbientUp.a;
	vec3 ambientDown = BBMOD_GammaToLinear(bbmod_LightAmbientDown.rgb) * bbmod_LightAmbientDown.a;
	vec3 directionalLightColor = BBMOD_GammaToLinear(bbmod_LightDirectionalColor.rgb) * bbmod_LightDirectionalColor.a;
	vec3 fogColor = BBMOD_GammaToLinear(bbmod_FogColor.rgb) * (ambientUp + ambientDown + directionalLightColor);
	float fogStrength = clamp((depth - bbmod_FogStart) * bbmod_FogRcpRange, 0.0, 1.0) * bbmod_FogColor.a;
	return mix(color, fogColor, fogStrength * bbmod_FogIntensity);
}
