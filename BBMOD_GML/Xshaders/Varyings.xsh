varying vec3 v_vVertex;

#if defined(X_2D) || defined(X_PARTICLES)
varying vec4 v_vColor;
#endif

varying vec2 v_vTexCoord;
varying mat3 v_mTBN;
varying float v_fDepth;

#if !defined(X_OUTPUT_DEPTH) && !defined(X_PBR)
#if !defined(X_UNLIT)
varying vec3 v_vLight;
#if !defined(X_2D)
varying vec3 v_vPosShadowmap;
#endif // !X_2D
#endif // !X_UNLIT
#if defined(X_TERRAIN)
varying vec2 v_vSplatmapCoord;
#endif // !X_TERRAIN
#endif
