varying vec3 v_vVertex;

#if defined(X_2D) || defined(X_PARTICLES)
varying vec4 v_vColor;
#endif

varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying vec4 v_vPosition;

#if !defined(X_UNLIT) && !defined(X_OUTPUT_DEPTH) && !defined(X_2D)
varying vec3 v_vPosShadowmap;
#endif

#if defined(X_TERRAIN)
varying vec2 v_vSplatmapCoord;
#endif
