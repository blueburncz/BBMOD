varying vec3 v_vVertex;

#if defined(X_COLOR) || defined(X_2D) || defined(X_PARTICLES)
varying vec4 v_vColor;
#endif

varying vec2 v_vTexCoord;
#if defined(X_LIGHTMAP)
varying vec2 v_vTexCoord2;
#endif
varying mat3 v_mTBN;
varying vec4 v_vPosition;

#if !defined(X_UNLIT) && !defined(X_OUTPUT_DEPTH) && !defined(X_2D)
varying vec4 v_vPosShadowmap;
#endif

#if defined(X_TERRAIN)
varying vec2 v_vSplatmapCoord;
#endif

#if defined(X_ID) && defined(X_BATCHED)
varying vec4 v_vInstanceID;
#endif

#if defined(X_PBR)
varying vec4 v_vEye;
#endif
