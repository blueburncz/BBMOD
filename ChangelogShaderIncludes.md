* Renamed shaders to follow a new, more consistent system of naming:

| Old shader name                     | New shader name                            |
| ----------------------------------- | ------------------------------------------ |
| `BBMOD_ShDefault`                   | `BBMOD_ShStatic_Lit`                       |
| `BBMOD_ShDefaultAnimated`           | `BBMOD_ShAnimated_Lit`                     |
| `BBMOD_ShDefaultBatched`            | `BBMOD_ShBatched_Lit`                      |
| `BBMOD_ShDefaultColor`              | `BBMOD_ShStatic_Lit_VertexColors`          |
| `BBMOD_ShDefaultColorAnimated`      | `BBMOD_ShAnimated_Lit_VertexColors`        |
| `BBMOD_ShDefaultColorBatched`       | `BBMOD_ShBatched_Lit_VertexColors`         |
| `BBMOD_ShDefaultSprite`             | `BBMOD_ShSprite_Lit`                       |
| `BBMOD_ShDefaultLightmap`           | `BBMOD_ShLightmapped_Lit`                  |
| `BBMOD_ShDefaultUnlit`              | `BBMOD_ShStatic_Unlit`                     |
| `BBMOD_ShDefaultUnlitAnimated`      | `BBMOD_ShAnimated_Unlit`                   |
| `BBMOD_ShDefaultUnlitBatched`       | `BBMOD_ShBatched_Unlit`                    |
| `BBMOD_ShDefaultUnlitColor`         | `BBMOD_ShStatic_Unlit_VertexColors`        |
| `BBMOD_ShDefaultUnlitColorAnimated` | `BBMOD_ShAnimated_Unlit_VertexColors`      |
| `BBMOD_ShDefaultUnlitColorBatched`  | `BBMOD_ShBatched_Unlit_VertexColors`       |
| `BBMOD_ShDefaultDepth`              | `BBMOD_ShStatic_Depth`                     |
| `BBMOD_ShDefaultDepthAnimated`      | `BBMOD_ShAnimated_Depth`                   |
| `BBMOD_ShDefaultDepthBatched`       | `BBMOD_ShBatched_Depth`                    |
| `BBMOD_ShDefaultDepthColor`         | `BBMOD_ShStatic_Depth_VertexColor`         |
| `BBMOD_ShDefaultDepthColorAnimated` | `BBMOD_ShAnimated_Depth_VertexColors`      |
| `BBMOD_ShDefaultDepthColorBatched`  | `BBMOD_ShBatched_Depth_VertexColors`       |
| `BBMOD_ShDefaultDepthLightmap`      | `BBMOD_ShLightmapped_Depth`                |
| `BBMOD_ShDefaultDepthSprite`        | `BBMOD_ShSprite_Depth`                     |
| `BBMOD_ShGBuffer`                   | `BBMOD_ShStatic_GBuffer`                   |
| `BBMOD_ShGBufferAnimated`           | `BBMOD_ShAnimated_GBuffer`                 |
| `BBMOD_ShGBufferBatched`            | `BBMOD_ShBatched_GBuffer`                  |
| `BBMOD_ShGBufferColor`              | `BBMOD_ShStatic_GBuffer_VertexColors`      |
| `BBMOD_ShGBufferColorAnimated`      | `BBMOD_ShAnimated_GBuffer_VertexColors`    |
| `BBMOD_ShGBufferColorBatched`       | `BBMOD_ShBatched_GBuffer_VertexColors`     |
| `BBMOD_ShGBufferSprite`             | `BBMOD_ShSprite_GBuffer`                   |
| `BBMOD_ShGBufferTerrain`            | `BBMOD_ShTerrain_GBuffer`                  |
| `BBMOD_ShInstanceID`                | `BBMOD_ShStatic_InstanceID`                |
| `BBMOD_ShInstanceIDAnimated`        | `BBMOD_ShAnimated_InstanceID`              |
| `BBMOD_ShInstanceIDBatched`         | `BBMOD_ShBatched_InstanceID`               |
| `BBMOD_ShInstanceIDColor`           | `BBMOD_ShStatic_InstanceID_VertexColors`   |
| `BBMOD_ShInstanceIDColorAnimated`   | `BBMOD_ShAnimated_InstanceID_VertexColors` |
| `BBMOD_ShInstanceIDColorBatched`    | `BBMOD_ShBatched_InstanceID_VertexColors`  |
| `BBMOD_ShInstanceIDLightmap`        | `BBMOD_ShLightmapped_InstanceID`           |
| `BBMOD_ShTerrain`                   | `BBMOD_ShTerrain_Lit`                      |
| `BBMOD_ShTerrainUnlit`              | `BBMOD_ShTerrain_Unlit`                    |
| `BBMOD_ShParticleDepth`             | `BBMOD_ShParticle_Depth`                   |
| `BBMOD_ShParticleLit`               | `BBMOD_ShParticle_Lit`                     |
| `BBMOD_ShParticleUnlit`             | `BBMOD_ShParticle_Unlit`                   |

* Added compile-time shader feature defines `BBMOD_EMISSIVE` and `BBMOD_SUBSURFACE` in the shared shader include pipeline. Existing core shaders now compile with both features disabled by default, for better rendering performance.
* Added new shader variants with emissive and subsurface features enabled:

| New shader variant |
| ------------------ |
| `BBMOD_ShAnimated_GBuffer_Emissive` |
| `BBMOD_ShAnimated_GBuffer_Emissive_VertexColors` |
| `BBMOD_ShAnimated_Lit_Emissive` |
| `BBMOD_ShAnimated_Lit_Emissive_VertexColors` |
| `BBMOD_ShAnimated_Lit_Subsurface` |
| `BBMOD_ShAnimated_Lit_Subsurface_VertexColors` |
| `BBMOD_ShBatched_GBuffer_Emissive` |
| `BBMOD_ShBatched_GBuffer_Emissive_VertexColors` |
| `BBMOD_ShBatched_Lit_Emissive` |
| `BBMOD_ShBatched_Lit_Emissive_VertexColors` |
| `BBMOD_ShBatched_Lit_Subsurface` |
| `BBMOD_ShBatched_Lit_Subsurface_VertexColors` |
| `BBMOD_ShLightmapped_Lit_Emissive` |
| `BBMOD_ShParticle_Lit_Emissive` |
| `BBMOD_ShParticle_Lit_Subsurface` |
| `BBMOD_ShSprite_GBuffer_Emissive` |
| `BBMOD_ShSprite_Lit_Emissive` |
| `BBMOD_ShSprite_Lit_Subsurface` |
| `BBMOD_ShStatic_GBuffer_Emissive` |
| `BBMOD_ShStatic_GBuffer_Emissive_VertexColors` |
| `BBMOD_ShStatic_Lit_Emissive` |
| `BBMOD_ShStatic_Lit_Emissive_VertexColors` |
| `BBMOD_ShStatic_Lit_Subsurface` |
| `BBMOD_ShStatic_Lit_Subsurface_VertexColors` |

* Added new property `Material` to struct `BBMOD_OBJImporter`, which is the material to apply to loaded models. If `ImportMaterials` is enabled, then the material is cloned first before doing changes to it. Defaults to `BBMOD_MATERIAL_DEFAULT`.

* Fixed a crash in method `has_variant` of `BBMOD_Shader`.
