# Changelog

## Editor

* Added `bbmod_array_remove`, which removes the first matching value from an array and reports whether it was found.
* Added new struct `BBMOD_Scene`, which owns scene nodes and scene-wide render state including cameras, models, lights, reflection probes, terrain, particle emitters, fog, ambient light, image-based lighting, and scene lightmaps.
* Added new struct `BBMOD_SceneNode`, which provides scene ownership, parent-child hierarchy, transform fields, editor metadata, transform dirty tracking, and local/world matrix helpers for runtime scene objects.
* `BBMOD_LensFlare` now acts as a `BBMOD_SceneNode`, with scene-owned lens flare registration and rendering; its public `DirectionalLight` member can follow a directional light automatically, and legacy `bbmod_lens_flare_*` APIs remain available as deprecated wrappers for the current scene.
* Lens flare nodes are selectable and transformable in edit mode with `BBMOD_Gizmo`; directional flares retain their mode when translated and update `Direction` when rotated.
* Editor icons now use scene-node world transforms, so child nodes follow their parents in edit mode.
* `BBMOD_Scene` exposes typed helper methods for punctual lights, the directional light, and reflection probes, backed by scene-node registration.
* Added new struct `BBMOD_ReferenceCounted`, which provides generic `ref` and `free` behavior for shared runtime data while keeping resource persistence local to `BBMOD_Resource`.
* Added `BBMOD_Model.make_instance`, which creates model instances with cloned node and material data while sharing reference-counted mesh data.
* `BBMOD_Node` now inherits from `BBMOD_SceneNode` as `BBMOD_ESceneNodeType.ModelNode`, allowing arbitrary scene nodes to be attached to model nodes while model traversal ignores non-model children.
* `BBMOD_Model` now acts as a scene root node and registers its root model-node hierarchy when added to a scene.
* Renderers enqueue scene-owned models, particle emitters, and terrain from the current scene, while preserving explicit renderer renderables and direct rendering APIs. Scene-owned models use their scene world transform by default.
* Scene model instances can use `BBMOD_AnimationPlayer.ApplyToModelNodes` to apply parent-space animation to model-node local transforms, so attached scene nodes follow animated model nodes.
* Model-node attachments are detached as runtime scene data when model node trees are replaced or destroyed, and removing a model from a scene unregisters its whole subtree without promoting descendants to scene roots.
* Cameras, lights, reflection probes, particle emitters, and terrain now initialize scene-node metadata and can be registered in scene node caches.
* Added new enum `BBMOD_EEditorFlag`, which defines editor transform capabilities and edit-complete side effects.
* Scene nodes expose `SceneNodeKind`, `EditorFlags`, `EditorIconSprite`, `EditorIconIndex`, `EditorPickPriority`, `EditorIconFadeStart`, `EditorIconFadeEnd`, and `EditorOffset` for edit-mode icon display, picking, transform behavior, and distance fade-out.
* Added `BBMOD_Gizmo.SelectedNodes`, which stores selected scene nodes separately from the existing `BBMOD_Gizmo.Selected` instance-ID selection list.
* Legacy light, reflection probe, fog, ambient light, image-based light, lightmap, particle emitter, and terrain editor APIs now operate on the current scene.
* Point lights, spot lights, directional lights, reflection probes, particle emitters, and terrains can be selected from edit-mode icons and transformed with `BBMOD_Gizmo` according to their `EditorFlags`.
* Point light scale gizmo edits update `Range` uniformly regardless of the dragged scale axis.
* Spot light scale gizmo edits update `Range`, inner cone radius, and outer cone radius separately, deriving `AngleInner` and `AngleOuter` from the resulting cone geometry.
* Directional light gizmo translations update `Position`; directional and spot light rotation edits update `Direction`.
* Reflection probe gizmo edits update probe position and size through setter methods, keeping capture and influence internals in sync.
* Terrain gizmo edits support translation through `Position` and scaling through `Scale` without rebuilding terrain chunk mesh data.
* Particle emitters and terrains are automatically available for edit-mode selection while they exist.
* Scene nodes with `BBMOD_EEditorFlag.RefreshReflectionProbes` mark reflection probes dirty after completed transform edits that change the target.
* Static shadow-casting light transform and direction edits mark the light shadowmap dirty when the light changes.
* Added optional native BBMOD wireframe debug geometry for selected lights and finite reflection probes.
* Selected point lights draw range spheres, spot lights draw inner and outer cones, directional lights draw arrows along their direction, and finite reflection probes draw their bounds.
