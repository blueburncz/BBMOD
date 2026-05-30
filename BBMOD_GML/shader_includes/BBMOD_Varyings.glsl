varying vec3 v_vVertex;

// @if defined(BBMOD_COLOR) || defined(BBMOD_2D) || defined(BBMOD_PARTICLES)
varying vec4 v_vColor;
// @endif

varying vec2 v_vTexCoord;

// @if defined(BBMOD_LIGHTMAP)
varying vec2 v_vTexCoord2;
// @endif

varying mat3 v_mTBN;
varying vec4 v_vPosition;
varying float v_fDitherSeed;
varying float v_fDitherFadeMultiplier;

// @if !defined(BBMOD_UNLIT) && !defined(BBMOD_OUTPUT_DEPTH) && !defined(BBMOD_2D)
varying vec4 v_vPosShadowmap;
// @endif

// @if defined(BBMOD_TERRAIN)
varying vec2 v_vSplatmapCoord;
// @endif

// @if defined(BBMOD_ID) && defined(BBMOD_BATCHED)
varying vec4 v_vInstanceID;
// @endif

// @if defined(BBMOD_PBR)
varying vec4 v_vEye;
// @endif
