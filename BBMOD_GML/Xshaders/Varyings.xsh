varying vec3 v_vVertex;

#if defined(X_2D) || defined(X_PARTICLES)
varying vec4 v_vColor;
#endif

varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying float v_fDepth;

#if !defined(X_OUTPUT_DEPTH) && !defined(X_PBR)
varying vec3 v_vLight;
#if !defined(X_2D)
varying vec3 v_vPosShadowmap;
#if defined(X_TERRAIN)
varying vec2 v_vSplatmapCoord;
#endif
#endif
#endif
