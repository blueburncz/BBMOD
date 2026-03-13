// FIXME: Temporary fix!
precision highp float;

varying vec2 vTexCoord;

uniform vec2 uTexelSize;
uniform float uRadius;

// Tent filter (9-tap) upsampling for bloom
// Based on dual filtering approach from "Bandwidth-Efficient Rendering" (Marius Bjørge, ARM)
void main()
{
	// The filter kernel is applied with a radius of 1 texel
	float x = uRadius;
	float y = uRadius;

	// Take 9 samples around current texel:
	// a - b - c
	// d - e - f
	// g - h - i

	vec3 a = texture2D(gm_BaseTexture, vTexCoord + vec2(-x,  y) * uTexelSize).rgb;
	vec3 b = texture2D(gm_BaseTexture, vTexCoord + vec2( 0,  y) * uTexelSize).rgb;
	vec3 c = texture2D(gm_BaseTexture, vTexCoord + vec2( x,  y) * uTexelSize).rgb;

	vec3 d = texture2D(gm_BaseTexture, vTexCoord + vec2(-x,  0) * uTexelSize).rgb;
	vec3 e = texture2D(gm_BaseTexture, vTexCoord + vec2( 0,  0) * uTexelSize).rgb;
	vec3 f = texture2D(gm_BaseTexture, vTexCoord + vec2( x,  0) * uTexelSize).rgb;

	vec3 g = texture2D(gm_BaseTexture, vTexCoord + vec2(-x, -y) * uTexelSize).rgb;
	vec3 h = texture2D(gm_BaseTexture, vTexCoord + vec2( 0, -y) * uTexelSize).rgb;
	vec3 i = texture2D(gm_BaseTexture, vTexCoord + vec2( x, -y) * uTexelSize).rgb;

	// Apply weighted distribution (tent filter):
	// 1   2   1
	// 2   4   2  * 1/16
	// 1   2   1
	vec3 result = e * 4.0;
	result += (b + d + f + h) * 2.0;
	result += (a + c + g + i);
	result *= 0.0625; // Divide by 16

	gl_FragColor = vec4(result, 1.0);
}
