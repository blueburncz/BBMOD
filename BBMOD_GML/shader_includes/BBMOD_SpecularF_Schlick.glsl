/// @desc Schlick Fresnel approximation.
/// @param f0 Reflectance at normal incidence (specular color).
/// @param VdotH Dot product of the view direction and half vector.
/// @return Fresnel factor.
/// @source https://en.wikipedia.org/wiki/Schlick%27s_approximation
vec3 BBMOD_SpecularF_Schlick(vec3 f0, float VdotH)
{
	float x = 1.0 - VdotH;
	return f0 + (1.0 - f0) * (x * x * x * x * x);
}
