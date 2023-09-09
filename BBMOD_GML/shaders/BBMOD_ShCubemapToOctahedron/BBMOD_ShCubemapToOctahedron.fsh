varying vec2 v_vTexCoord;

uniform vec2 u_vTexel;

#define X_CUBEMAP_POS_X 0
#define X_CUBEMAP_NEG_X 1
#define X_CUBEMAP_POS_Y 2
#define X_CUBEMAP_NEG_Y 3
#define X_CUBEMAP_POS_Z 4
#define X_CUBEMAP_NEG_Z 5

/// @param dir Sampling direction vector in world-space.
/// @param texel Texel size on cube side. Used to inset uv coordinates for
/// seamless filtering on edges. Use 0 to disable.
/// @return UV coordinates for the following cubemap layout:
/// +---------------------------+
/// |+X|-X|+Y|-Y|+Z|-Z|None|None|
/// +---------------------------+
vec2 xVec3ToCubeUv(vec3 dir, vec2 texel)
{
	vec3 dirAbs = abs(dir);

	int i = dirAbs.x > dirAbs.y ?
		(dirAbs.x > dirAbs.z ? 0 : 2) :
		(dirAbs.y > dirAbs.z ? 1 : 2);

	float uc, vc, ma;
	float o = 0.0;

	if (i == 0)
	{
		if (dir.x > 0.0)
		{
			uc = dir.y;
		}
		else
		{
			uc = -dir.y;
			o = 1.0;
		}
		vc = -dir.z;
		ma = dirAbs.x;
	}
	else if (i == 1)
	{
		if (dir.y > 0.0)
		{
			uc = -dir.x;
		}
		else
		{
			uc = dir.x;
			o = 1.0;
		}
		vc = -dir.z;
		ma = dirAbs.y;
	}
	else
	{
		uc = dir.y;
		if (dir.z > 0.0)
		{
			vc = +dir.x;
		}
		else
		{
			vc = -dir.x;
			o = 1.0;
		}
		ma = dirAbs.z;
	}

	float invL = 1.0 / length(ma);
	vec2 uv = (vec2(uc, vc) * invL + 1.0) * 0.5;
	uv = mix(texel * 1.5, 1.0 - texel * 1.5, uv);
	uv.x = (float(i) * 2.0 + o + uv.x) * 0.125;
	return uv;
}

// Source: https://gamedev.stackexchange.com/questions/169508/octahedral-impostors-octahedral-mapping

/// @desc Converts octahedron UV into a world-space vector.
vec3 xOctahedronUvToVec3Normalized(vec2 uv)
{
	vec3 position = vec3(2.0 * (uv - 0.5), 0);
	vec2 absolute = abs(position.xy);
	position.z = 1.0 - absolute.x - absolute.y;
	if (position.z < 0.0)
	{
		position.xy = sign(position.xy) * vec2(1.0 - absolute.y, 1.0 - absolute.x);
	}
	return position;
}

void main()
{
	vec3 dir = xOctahedronUvToVec3Normalized(v_vTexCoord);
	gl_FragColor = texture2D(gm_BaseTexture, xVec3ToCubeUv(dir, u_vTexel));
}
