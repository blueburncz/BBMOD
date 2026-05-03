# Changelog dev

> This file is used to accumulate changes before a changelog for a release is created.

## 3.23.0

* Added new enum `BBMOD_ERenderQueue`, which defines render queue categories and their submission order (`Terrain`, `Opaque`, `Transparent`, `Sky`).
* Added new function `bbmod_render_queue_get(_index)`, which retrieves or lazily creates a render queue for a queue category value.
* Function `bbmod_render_queues_get()` is now sorted by render queue category values, which makes queue ordering deterministic for default and custom queues.
* Property `Priority` of struct `BBMOD_RenderQueue` is now **obsolete**! Use queue category values (`BBMOD_ERenderQueue.*`) instead.
* Method `set_priority(_p)` of struct `BBMOD_RenderQueue` is now **obsolete**! Use queue category values and queue-map APIs instead.
* Added command `DrawTerrain` to enum `BBMOD_ERenderCommand`, which allows terrain submission through pass-aware queue command flow.
* Methods `ApplyMaterial`, `ApplyMaterialProps`, `BeginConditionalBlock`, `CallFunction`, `CheckRenderPass`, `EndConditionalBlock`, `PopGpuState`, `PushGpuState`, `ResetMaterial`, `ResetMaterialProps`, `ResetShader`, `SetGpu*`, `SetMaterialProps`, `SetProjectionMatrix`, `SetSampler`, `SetShader`, `SetUniform*`, `SetViewMatrix`, `SetWorldMatrix`, `SubmitRenderQueue`, and `SubmitVertexBuffer` of struct `BBMOD_RenderQueue` are now **obsolete**! Use `Draw*` methods instead.
* Methods `DrawSprite`, `DrawSpriteExt`, `DrawSpriteGeneral`, `DrawSpritePart`, `DrawSpritePartExt`, `DrawSpritePos`, `DrawSpriteStretched`, `DrawSpriteStretchedExt`, `DrawSpriteTiled`, and `DrawSpriteTiledExt` of struct `BBMOD_RenderQueue` now **require material as the first argument**!
* Interface `BBMOD_IMeshRenderQueue` is now **obsolete**! Use struct `BBMOD_RenderQueue` instead.
* Struct `BBMOD_MeshRenderQueue` is now **deprecated** and implemented as a thin wrapper extending `BBMOD_RenderQueue`.
* Property `RenderQueue` of struct `BBMOD_Material` is now a queue category value (`BBMOD_ERenderQueue.*`) instead of a `BBMOD_RenderQueue` struct reference!
* Method `from_json(_json)` of struct `BBMOD_Material` now maps known render queue names to `BBMOD_ERenderQueue` values, warns on unknown/invalid values, and falls back to `BBMOD_ERenderQueue.Opaque`.
* Property `OnApply` of struct `BBMOD_Material` is now **obsolete**! Extend the material and implement custom `apply(_vertexFormat)` behavior instead.
* Added property `HashDirty` to struct `BBMOD_Material`, which enables cached material hashing.
* Added new method `get_hash()` to struct `BBMOD_Material`, which computes material-state hash only when `HashDirty` is true and otherwise returns cached hash.
* Added new method `get_hash()` to structs `BBMOD_BaseMaterial`, `BBMOD_DefaultMaterial`, `BBMOD_DefaultLightmapMaterial`, and `BBMOD_ParticleMaterial`, which extends cached hashing with type-specific material state.
* Added new functions `bbmod_hash_combine(_hash1, _hash2)` and `bbmod_hash_array(_array)`, which provide reusable hashing helpers for render batching and related systems.
* Struct `BBMOD_MaterialPropertyBlock` is now **obsolete** and unused in renderers!
* Function `bbmod_material_props_set(_materialPropertyBlock)` is now **obsolete** and a no-op.
* Function `bbmod_material_props_get()` is now **obsolete** and always returns `undefined`.
* Function `bbmod_material_props_reset()` is now **obsolete** and a no-op.
* Added properties `BoundingSphereCenter` and `BoundingSphereRadius` to struct `BBMOD_Mesh`, which store local-space bounding sphere data derived from mesh bounds.
* Added new functions `bbmod_get_frustum_culling()` and `bbmod_set_frustum_culling(_enable)`, which control automatic frustum culling.
* Added new method `get_distance(_point)` to struct `BBMOD_BaseCamera`, which returns signed view-space distance (depth) from the camera to a world-space `BBMOD_Vec3` with a cached-forward implementation optimized for hot-path use.
* Added properties `DistanceFadeStart` and `DistanceFadeEnd` to struct `BBMOD_PunctualLight`, which enable per-light camera-distance fade thresholds used by renderers for GML-side punctual-light upload culling.
* Added new global dither control API functions `bbmod_dither_set_enabled(_enable)`, `bbmod_dither_get_enabled()`, `bbmod_dither_set_value(_value)`, and `bbmod_dither_get_value()`, which replace temporal trigger/time controls in default mesh and render-queue workflows.
* `BBMOD_RenderQueue.DrawMesh`, `BBMOD_RenderQueue.DrawMeshAnimated`, and `BBMOD_RenderQueue.DrawMeshBatched` now snapshot dither enabled/value state at enqueue time, so queued commands keep deterministic per-command dither behavior.
* Added new property `DataFilter` and method `default_filter_fn(_mesh, _matrix, _batchData, _ids, _instances[, _visibleInstancesHint[, _ditherEnableSnapshot[, _ditherValueSnapshot]]])` to struct `BBMOD_DynamicBatch`, enabling layout-aware submit-time filtering of dynamic batch payloads. Methods `submit([_materials[, _batchData[, _ids[, _visibleInstances]]]])` and `render([_materials[, _batchData[, _ids[, _visibleInstances]]]])` now support an optional visible-instance hint for no-ID payloads. `BBMOD_RenderQueue` now requires dynamic-batch context for `DrawMeshBatched` commands and always executes `BBMOD_DynamicBatch.DataFilter` (no render-queue fallback filtering path). Default dynamic-batch filtering now uses batched-shader transform order (mesh matrix first, then per-instance quaternion/scale/position), reports `DistanceCulledInstances` separately from `FrustumCulledInstances`, and writes per-instance effective dither into batch payload slot 15 (16-float layout, 4 vec4 stride).
* Added new struct `BBMOD_RenderStatistics`, which provides pass-aware rendering statistics for draw outcomes, shadowmap updates/skips, and punctual-light usage/skip decisions.
* Added new functions `bbmod_render_statistics_start()`, `bbmod_render_statistics_end()`, and `bbmod_render_statistics_get()`, which provide lifecycle-based capture and direct access to renderer statistics for manual processing. Function `bbmod_render_statistics_start()` now activates capture and `bbmod_render_statistics_end()` disables capture, returns a snapshot, and automatically updates a built-in debug-overlay (`dbg_*`) statistics view with a top-level totals section followed by per-pass sections.
* Renderers now always use only active punctual lights visible in the camera frustum for shader light uniforms and deferred punctual-light rendering, sorted from closest to farthest by camera distance, and now apply per-light distance fade in GML (`DistanceFadeStart`/`DistanceFadeEnd`) so fully faded lights are not sent to shaders, regardless of `bbmod_set_frustum_culling(_enable)`.
* Renderers now always skip shadowmap updates for punctual lights outside the camera frustum and for punctual lights fully culled by distance fade thresholds, regardless of `bbmod_set_frustum_culling(_enable)`.
* Frustum-culling debug logging in render paths has been replaced by pass-aware statistics tracking for mesh, terrain, render-queue, light, and shadowmap decisions.
* Struct `BBMOD_Terrain` now uses `bbmod_render_queue_get(BBMOD_ERenderQueue.Terrain)` for terrain render queue access.
* Property `RenderQueue` of struct `BBMOD_Terrain` is now **deprecated**! Use `bbmod_render_queue_get(BBMOD_ERenderQueue.Terrain)` instead.
* Method `render()` of struct `BBMOD_Terrain` now enqueues terrain through `BBMOD_RenderQueue.DrawTerrain(self)`.
* Material `BBMOD_MATERIAL_SKY` now uses render queue `BBMOD_ERenderQueue.Sky`.
* Fixed a resize-related light bloom artifact where strong glow could appear on bottom/right screen edges after window resize by using deterministic integer bloom mip sizes, processing only mips generated in the current frame, and clearing intermediate bloom targets each pass.
