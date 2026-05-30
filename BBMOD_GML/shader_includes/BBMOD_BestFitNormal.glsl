/// @desc Encodes a normal using best-fit encoding for improved precision in
/// G-buffer storage.
/// @param normal The normal vector to encode.
/// @param tex Best-fit normal lookup texture.
/// @return Scaled normal vector suitable for G-buffer storage.
/// @source http://advances.realtimerendering.com/s2010/Kaplanyan-CryEngine3(SIGGRAPH%202010%20Advanced%20RealTime%20Rendering%20Course).pdf
vec3 BBMOD_BestFitNormal(vec3 normal, sampler2D tex)
{
	normal = normalize(normal);
	vec3 normalUns = abs(normal);
	float maxNAbs = max(max(normalUns.x, normalUns.y), normalUns.z);
	vec2 texCoord = normalUns.z < maxNAbs
		? (normalUns.y < maxNAbs ? normalUns.yz : normalUns.xz)
		: normalUns.xy;
	texCoord = texCoord.x < texCoord.y ? texCoord.yx : texCoord.xy;
	texCoord.y /= texCoord.x;
	normal /= maxNAbs;
	float fittingScale = texture2D(tex, texCoord).r;
	return normal * fittingScale;
}
