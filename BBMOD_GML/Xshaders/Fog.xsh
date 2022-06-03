void Fog(float depth)
{
	vec3 ambientUp = xGammaToLinear(xDecodeRGBM(bbmod_LightAmbientUp));
	vec3 ambientDown = xGammaToLinear(xDecodeRGBM(bbmod_LightAmbientDown));
	vec3 directionalLightColor = xGammaToLinear(xDecodeRGBM(bbmod_LightDirectionalColor));
	vec3 fogColor = xGammaToLinear(xDecodeRGBM(bbmod_FogColor))
		* (ambientUp + ambientDown + directionalLightColor);
	float fogStrength = clamp((depth - bbmod_FogStart) * bbmod_FogRcpRange, 0.0, 1.0);
	gl_FragColor.rgb = mix(gl_FragColor.rgb, fogColor, fogStrength * bbmod_FogIntensity);
}
