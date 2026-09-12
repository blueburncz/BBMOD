# Editor Features

This document defines the minimal editor layer for selectable BBMOD3 structs. It
intentionally does not introduce a scene graph or a separate editor registry.
The editor state is owned by one `BBMOD_Editor` struct.

## Scope

The editor supports:

- Selecting existing lights and reflection probes through editor icons.
- Transforming selected structs with `BBMOD_Gizmo`.
- Drawing BBMOD-owned wireframes for selected structs.

The editor does not promote structs to resources and does not change runtime
ownership or registration behavior.

## Architecture

`BBMOD_BaseRenderer` owns one optional `Editor` field. `BBMOD_Editor` owns the
editor gizmo, transient selection, icon projection and picking data, wireframe
settings, and edit-mode input. The renderer delegates editor work to that
struct; it does not separately own or configure a `BBMOD_Gizmo`.

Typical setup:

```gml
renderer.Editor = new BBMOD_Editor();
renderer.Editor.Enabled = true;
```

`BBMOD_Editor` does not own or destroy runtime lights, probes, emitters, or lens
flares. It queries their existing runtime registries directly.

The editor queries the existing BBMOD3 registries when editor mode is active:

- `global.__bbmodDirectionalLight`
- `global.__bbmodPunctualLights`
- `global.__bbmodReflectionProbes`
- `global.__bbmodParticleEmitters`

There is no editor registration API, editable-object registry, scene graph,
`BBMOD_SceneNode`, `BBMOD_IEditable`, or adapter struct. The editor does not own
the runtime registries; undoable deletion temporarily removes targets through
their existing registry APIs and restores them on undo.

## Supported Structs

The initial editor types are:

- `BBMOD_PointLight`
- `BBMOD_SpotLight`
- `BBMOD_DirectionalLight`
- `BBMOD_ReflectionProbe`
- `BBMOD_ParticleEmitter`
- `BBMOD_LensFlare`

Particle emitters and lens flares use editor icons only. They do not receive
wireframe geometry.

The editor enumerates these types explicitly from the existing registries. It
uses direct type branches for behavior instead of runtime reflection or generic
callback discovery.

## Editor Metadata

Editor icon metadata is stored directly on the supported structs:

- Icon sprite.
- Icon subimage.
- Icon pick priority.
- Icon fade start distance.
- Icon fade end distance.
- Icon world-space offset.

Defaults are defined by the struct constructors. The editor reads these fields
directly while drawing and picking icons.

## Selection Flow

When editor mode is active:

1. Enumerate the current directional light, punctual lights, reflection probes,
   particle emitters, and lens flares.
2. Draw each available editor icon at its world position plus icon offset.
3. Apply camera-distance fading and pick priority.
4. Store the selected struct directly in the existing gizmo selection state.
5. Clear selection when the selected struct is no longer present in its source registry.

The editor selection is transient and is not serialized.

Particle emitters use the normal BBMOD runtime registry API rather than implicit
editor discovery:

- `bbmod_particle_emitter_add(_emitter)`
- `bbmod_particle_emitter_count()`
- `bbmod_particle_emitter_get(_index)`
- `bbmod_particle_emitter_remove(_emitter)`
- `bbmod_particle_emitter_remove_index(_index)`
- `bbmod_particle_emitter_clear()`

The editor queries that runtime registry; it does not register emitters itself.
Lens flares already use the corresponding runtime registry API:

- `bbmod_lens_flare_add(_lensFlare)`
- `bbmod_lens_flare_count()`
- `bbmod_lens_flare_get(_index)`
- `bbmod_lens_flare_remove(_lensFlare)`
- `bbmod_lens_flare_remove_index(_index)`
- `bbmod_lens_flare_clear()`

`BBMOD_Editor` owns the following behavior:

- Runtime-registry enumeration.
- Icon projection, fading, drawing, and picking.
- Mixed struct/instance selection.
- Gizmo ownership, binding, and callback restoration.
- Wireframe mode and color settings.

The intended public editor surface is the `BBMOD_Editor` instance. The global
`bbmod_editor_*` helpers are not a second public editor API and are being
removed as their call sites migrate. The one intentional global exception is
`bbmod_editor_submit_instance_icon()`, which lets a draw event submit a
transient icon while the renderer owns the active editor.

Wireframe visibility is controlled globally by `BBMOD_BaseRenderer.EditorWireframeMode`:

- `BBMOD_EWireframeMode.Never` disables wireframes.
- `BBMOD_EWireframeMode.Selected` draws wireframes for selected structs only.
- `BBMOD_EWireframeMode.Always` draws all supported wireframes from the runtime registries.

Wireframe colors are configured through `EditorWireframeColor` for normal
wireframes and `EditorWireframeColorSelected` for selected wireframes.

Particle emitters and lens flares remain icon-only in every mode.

`BBMOD_BaseRenderer` invokes `Editor.update()` and `Editor.render_overlay()`
during edit-mode presentation. `BBMOD_Editor.Gizmo` is the sole gizmo instance.
The editor must preserve and restore the gizmo's original instance callbacks
when binding struct transforms.

## Gizmo Transforms

Use the existing `BBMOD_Gizmo`. Transform behavior is explicit per supported type:

- Point lights: translation updates `Position`; uniform scale updates `Range`.
- Spot lights: translation updates `Position`; rotation updates `Direction`; scale
  updates `Range`, `AngleInner`, and `AngleOuter`.
- Directional lights: translation updates `Position`; rotation updates `Direction`.
- Reflection probes: translation calls `set_position()`; scale calls `set_size()`.

After a completed edit:

- Static shadow-casting lights set `NeedsUpdate = true`.
- Reflection probes set `NeedsUpdate = true` when their transform changes.
- Probe setters are used so cached influence data remains synchronized.

## Undo and Redo

Undo and redo are editor-owned history operations. They must work for mixed
selections containing both GameMaker instances and BBMOD structs without adding
another authoritative object list or changing runtime ownership rules.

### History Commands

`BBMOD_Editor` owns bounded undo and redo stacks. Each completed user operation
is one atomic command. A command stores its target references and the state
needed to apply both the before and after values:

```gml
{
    Type: BBMOD_EEditorCommand.Transform,
    Targets: [...],
    Before: [...],
    After: [...],
}
```

Supported command types are:

- `Transform`: one gizmo drag across any mixed selection.
- `Delete`: deletion of the complete current selection.

Starting a new command clears the redo stack. Applying undo or redo sets an
internal history-application flag so restoring state does not create another
history command. History is cleared when the editor is destroyed, and discarded
commands release any retained snapshots or temporary resources.

### Transform History

The existing `BBMOD_Gizmo` edit lifecycle defines the command boundary:

1. `Gizmo.begin_edit()` captures the initial state of every selected target.
2. The gizmo applies its normal position, rotation, and scale callbacks.
3. `Gizmo.OnEditEnd()` captures the final state.
4. The editor adds one `Transform` command only if a value changed.

State capture and application use the existing editor transform callbacks. The
adapter must preserve all values controlled by the gizmo, including position,
rotation or direction, scale, light range, spot-light cone angles, and
reflection-probe size. Struct-specific setters remain responsible for cache
invalidation such as `NeedsUpdate`.

Undo applies `Before`; redo applies `After`. Both operations then remove dead
targets from selection, refresh the gizmo position, and restore the normal
editor highlighting and wireframe state.

### Target Adapters

History is target-agnostic and delegates target-specific behavior to private
editor callbacks:

- `CaptureTargetState(_target)`
- `ApplyTargetState(_target, _state)`
- `TargetExists(_target)`
- `DeleteTarget(_target)`
- `RestoreTarget(_snapshot)`

GameMaker instances use their native instance fields and the existing save
property system. BBMOD structs use their existing registry and setter APIs.
These callbacks must preserve the current mixed selection and gizmo callback
binding behavior.

### Delete and Restore

Delete is a single command for the current selection. It removes selected
targets from the same ownership systems that currently control them and clears
the active selection.

For registered BBMOD structs, the command stores the complete struct snapshot
and its registry position. Undo restores the struct and its original registry
ordering. Registry-specific add, remove, and destroy behavior must be explicit
for particle emitters and lens flares; the editor must not silently introduce a
second registry.

For GameMaker instances, delete snapshots reuse the existing save system:

- `bbmod_instance_to_buffer(_instance, _buffer, _properties)` captures the
  object asset, `x`, `y`, layer, and all properties registered with
  `bbmod_object_add_*()` on the object or its parents.
- `bbmod_instance_from_buffer(_buffer, _properties)` creates a replacement
  instance and restores those registered properties.
- The delete snapshot additionally stores editor-required native fields not
  covered by that format, including `z`, depth, rotation, image scale, image
  state, visibility, persistence, and any parent-instance relationship required
  by the editor workflow.

The original instance ID cannot be restored after destruction. Undo therefore
replaces it with the newly created instance ID, updates the selection, and
updates any transient submitted icon state. The snapshot must retain the
registered property schema alongside its buffer because deserialization needs
the same property definitions.

If an instance contains state that is not registered with the existing save
system, that state is outside the guaranteed delete/undo contract. The editor
must either reject deletion for such a target or require an explicit snapshot
callback before deletion; it must not claim complete restoration silently.

### Input and Validation

The editor input layer should expose `undo()`, `redo()`, and `clear_history()`
operations. The default editor bindings are:

- `DeleteKey`: Delete, which destroys the current selection.
- `UndoKeys`: `[vk_control, ord("Z")]`, which undoes the latest command.
- `RedoKeys`: `[vk_control, vk_shift, ord("Z")]`, which redoes the latest undone command.

These bindings must be configurable through the corresponding `BBMOD_Editor`
properties. The editor must not hard-code the keys in the renderer or gizmo.
Delete must be ignored while a gizmo drag is active and must produce one
command for multi-selection.

Focused regression coverage must include:

- Transform undo/redo for structs, instances, and mixed selections.
- Position, rotation, scale, light-range, cone-angle, and probe-size changes.
- Delete/undo for each supported struct registry.
- Delete/undo for instances using every existing save property type.
- Restoration of the additional native instance fields.
- Redo invalidation after a new edit.
- Dead-target cleanup, history limits, registry ordering, and resource cleanup.

### End-to-End Implementation Checklist

#### Phase 1: Establish the history contract

- [x] Add `BBMOD_EEditorCommand` members for `Transform`, `Delete`, and
  `Create`.
- [x] Define the command record shape, ownership rules, and maximum history size.
- [x] Add `UndoStack`, `RedoStack`, `HistoryLimit`, and `IsApplyingHistory` to
  `BBMOD_Editor`.
- [x] Add public editor methods `undo()`, `redo()`, and `clear_history()`.
- [x] Define snapshot disposal for buffers, property schemas, recreated
  instances, and any retained struct resources.

#### Phase 2: Add target state adapters

- [x] Implement `CaptureTargetState(_target)` for GameMaker instances and every
  supported BBMOD struct.
- [x] Implement `ApplyTargetState(_target, _state)` using existing transform and
  cache-invalidating setters.
- [x] Implement `TargetExists(_target)` for both live instances and registry
  backed structs.
- [x] Keep adapter dispatch compatible with mixed selections and the current
  reversible gizmo callback binding.
- [x] Define equality checks so unchanged edits do not create history entries.

#### Phase 3: Capture gizmo transforms

- [x] Capture the complete `Before` state when `Gizmo.begin_edit()` starts.
- [x] Capture the complete `After` state from `Gizmo.OnEditEnd()`.
- [x] Record one atomic command for a complete multi-target drag.
- [x] Cover translation, rotation, scale, light range, spot-light cone angles,
  reflection-probe size, and direction changes.
- [x] Clear the redo stack after a new user edit.
- [x] Prevent history recording while undo or redo is applying a command.
- [x] Preserve `NeedsUpdate` and other post-transform invalidation behavior.

#### Phase 4: Integrate instance save snapshots

- [x] Add a focused single-instance snapshot wrapper around
  `bbmod_instance_to_buffer()` rather than saving all instances of an object.
- [x] Capture the registered property schema from the object and its parents.
- [x] Store the serialized buffer together with its schema and object identity.
- [x] Extend the snapshot with `z`, depth, rotation, image scale, image state,
  visibility, and persistence.
- [x] Define restoration for parent-instance relationships if the editor begins
  supporting them.
- [x] Define behavior for unregistered instance state: reject deletion or require
  an explicit snapshot callback before allowing it.
- [x] Restore the replacement instance with `bbmod_instance_from_buffer()` and
  then apply the additional native fields.
- [x] Update selection, icon submissions, and any dependent references to the
  replacement instance ID.

#### Phase 5: Implement struct deletion and restoration

- [x] Implement deletion for lights and reflection probes without introducing a
  second ownership or registry system.
- [x] Implement particle-emitter deletion through its existing registry APIs.
- [x] Implement lens-flare deletion through its existing registry APIs.
- [x] Capture each struct's complete restorable state before removal.
- [x] Store each target's original registry index where ordering is observable.
- [x] Restore registry membership and ordering on undo.
- [x] Release owned resources only when a delete command is permanently removed
  from history, not while it can still be undone.
- [x] Record manually created structs and instances with `add_created()` so
  creation can be undone and redone through the editor history.

#### Phase 6: Implement delete commands

- [x] Capture snapshots for the complete current selection before destruction.
- [x] Create one atomic `Delete` command for multi-selection.
- [x] Use Delete as the default destroy action through `DeleteKey`.
- [x] Clear selection after deletion and restore it after undo.
- [x] Ensure deleted targets are not processed by icon, wireframe, or gizmo paths.
- [x] Handle deletion of already-dead targets without corrupting history.

#### Phase 7: Wire editor input

- [x] Add configurable `DeleteKey`, defaulting to Delete.
- [x] Add configurable `UndoKeys`, defaulting to `[vk_control, ord("Z")]`.
- [x] Add configurable `RedoKeys`, defaulting to `[vk_control, vk_shift, ord("Z")]`.
- [x] Detect modifier keys without triggering shortcuts during text-entry or
  active gizmo dragging contexts.
- [x] Ignore Delete while a gizmo drag is active.
- [x] Make Ctrl+Z and Ctrl+Shift+Z operate on the editor history only.

#### Phase 8: Refresh editor state after history operations

- [x] Rebuild mixed selection after undo and redo.
- [x] Recalculate gizmo position, rotation, and size.
- [x] Refresh icon projection, selection tint, and wireframes.
- [x] Revalidate registry membership and remove dead targets.
- [x] Reapply probe and light cache invalidation where restored state changes
  renderable data.

#### Phase 9: Add regression coverage

- [x] Test struct translation undo/redo.
- [x] Test struct rotation and scale undo/redo.
- [x] Test instance translation undo/redo.
- [x] Test instance rotation and scale undo/redo.
- [x] Test mixed struct and instance transforms in one command.
- [x] Test spot-light range undo/redo.
- [x] Test light direction, spot-light cone angles, and probe size.
- [x] Test delete/undo/redo for each supported struct registry.
- [x] Test instance delete/undo using every existing save property type.
- [x] Test restoration of every additional native instance field.
- [x] Test replacement instance IDs and restored icon selection.
- [x] Test redo invalidation after a new edit.
- [x] Test multi-selection, dead targets, history limits, registry ordering, and
  resource cleanup.
- [x] Test configurable key bindings and default Delete/Ctrl+Z/Ctrl+Shift+Z
  behavior.
- [x] Test manually created structs and instances with Create undo/redo.

#### Phase 10: Final validation and documentation

- [x] Run the focused editor regression suite.
- [x] Run GML diagnostics and formatter checks on all changed scripts.
- [x] Verify no `variable_struct_exists()` or secondary registry is introduced in
  editor hot paths.
- [x] Verify existing runtime ownership and resource-manager behavior is unchanged.
- [x] Update the changelog with the final public API and behavior.
- [x] Perform a manual GameMaker test of mixed transform, delete, undo, and redo.

## Full Editor Ownership Refactor Checklist

This checklist replaces the interim global-helper arrangement. The final
architecture keeps editor behavior on `BBMOD_Editor`; only the external
per-instance icon submission entry point may remain global because draw events
need to submit icons without owning an editor reference.

### Phase 1: Inventory and ownership map

- [x] Classify every `bbmod_editor_*` function as editor-owned, externally
  required, or obsolete.
- [x] Mark `bbmod_editor_submit_instance_icon()` as the only intentionally global
  submission API unless a later explicit context API replaces it.
- [x] Identify all renderer, object, test, and internal call sites for each helper.
- [x] Record the target `BBMOD_Editor` method name for every editor-owned helper.
- [x] Confirm no second editor registry or ownership system is introduced.

### Phase 2: Move target and transform behavior

- [x] Move position, rotation, scale, direction, and target-existence logic into
  `BBMOD_Editor` methods.
- [x] Move mixed instance/struct state capture, state comparison, and state
  application into editor methods.
- [x] Move registry index lookup and array insertion helpers into editor methods.
- [x] Move instance snapshot creation, restoration, and disposal into editor
  methods.
- [x] Update gizmo callbacks to use stable `method(BBMOD_Editor, ...)` bindings.
- [ ] Remove the obsolete global transform and snapshot helpers after all calls
  are migrated.

### Phase 3: Move history and deletion behavior

- [x] Keep `undo()`, `redo()`, `delete_selected()`, and `clear_history()` as
  editor-owned methods.
- [x] Move transform command recording and command equality logic into editor
  methods.
- [x] Move history command application and disposal into editor methods.
- [x] Move struct removal/restoration and instance deletion/restoration into
  editor methods.
- [ ] Remove duplicate global history and deletion implementations.
- [x] Verify command snapshots retain ownership of buffers and temporary data.

### Phase 4: Move selection and registry enumeration

- [x] Move editable registry enumeration into `BBMOD_Editor.get_editables()`.
- [x] Move selected-value storage and selection mutation into editor methods.
- [x] Move mixed-selection filtering into an editor method.
- [x] Update gizmo, history, deletion, and tests to use editor selection methods.
- [ ] Remove global selection helpers after migration.

### Phase 5: Move icon projection and picking

- [x] Move struct icon projection into an editor method.
- [x] Move submitted instance-icon projection into an editor method.
- [x] Move icon picking and priority/depth resolution into an editor method.
- [x] Move icon drawing into an editor method.
- [x] Keep only the global submission function, forwarding submitted descriptors
  to the current editor-owned transient queue through an explicit context.
- [x] Define and validate behavior when no editor is active.
- [x] Update `BBMOD_BaseRenderer` to call editor projection, picking, and drawing
  methods directly.
- [ ] Remove global projection, picking, and drawing helpers.

### Phase 6: Move wireframe behavior

- [x] Move single-value wireframe dispatch into an editor method.
- [x] Move selected-wireframe drawing into an editor method.
- [x] Move wireframe mode dispatch into an editor method.
- [x] Keep geometry primitives private to the editor implementation.
- [x] Update renderer overlay code to call editor wireframe methods directly.
- [ ] Remove global wireframe helpers after all call sites are migrated.

### Phase 7: Remove the obsolete gizmo binder

- [x] Confirm `BBMOD_Editor.bind()` is the sole gizmo callback installation path.
- [ ] Move any remaining callback restoration behavior into editor methods.
- [ ] Remove global `bbmod_editor_bind_gizmo()`.
- [ ] Remove global `bbmod_editor_unbind_gizmo()`.
- [ ] Verify original gizmo callbacks are restored when the editor is destroyed or
  explicitly unbound.

### Phase 8: Update external documentation and API boundaries

- [x] Update `EDITOR.md` to show editor method calls rather than private globals.
- [x] Document the intentionally global instance-icon submission function and
  its current-editor routing behavior.
- [x] Remove documentation that describes global helpers as editor ownership.
- [ ] Update the changelog with the final ownership/API result.
- [ ] Preserve public behavior and avoid introducing compatibility wrappers for
  private helpers.

### Phase 9: Regression and architecture tests

- [x] Test all editor methods through a `BBMOD_Editor` instance.
- [x] Test mixed struct/instance transforms and history.
- [x] Test delete/undo/redo for structs and instances.
- [x] Test icon submission, projection, picking, and drawing with an active editor.
- [ ] Test icon submission when no editor is active.
- [x] Test wireframe modes through editor methods.
- [x] Assert no obsolete `bbmod_editor_*` helper is referenced outside the
  intentionally global submission API.
- [x] Assert the renderer does not call private global editor helpers.
- [x] Test editor destruction, callback restoration, and history resource cleanup.

### Phase 10: Final migration validation

- [x] Search for all `bbmod_editor_*` definitions and classify the final results.
- [x] Search for all `bbmod_editor_*` call sites and verify ownership boundaries.
- [x] Run the GML formatter with UTF-8 mode on every changed script.
- [x] Run diagnostics on every changed script and documentation file.
- [x] Run `git diff --check` on the complete refactor.
- [x] Run the editor regression suite in GameMaker.
- [x] Manually verify mixed selection, icon picking, gizmo transforms, delete,
  undo, redo, and wireframe rendering.

## Wireframes

Wireframes are BBMOD-owned. Do not use `cm_*` ColMesh scripts or resources.

Add a private BBMOD editor-geometry module with only the primitives required by
these structs:

- Line.
- Sphere.
- Cone.
- AABB.
- Direction arrow.

The module uses a BBMOD debug vertex buffer, BBMOD debug vertex format, colored
vertices, and `pr_linelist` submission. Geometry is generated for the current
frame and is not stored as scene data.

Wireframe dispatch is explicit:

- Point light: range sphere.
- Spot light: inner and outer cones.
- Directional light: direction arrow.
- Finite reflection probe: influence AABB.

The current implementation is provided by `__bbmod_editor_geometry` and uses
the existing `global.__bbmodVBufferDebug` and `BBMOD_VFORMAT_DEBUG` resources.

## Implementation Order

1. Add `BBMOD_Editor` with one owned `BBMOD_Gizmo`.
2. Move the current `bbmod_editor` helper behavior into private editor methods.
3. Make `BBMOD_BaseRenderer` delegate editor update and overlay rendering.
4. Keep runtime registries and object ownership unchanged.
5. Add focused tests for icon selection, mixed selection, transforms, and wireframes.
6. Update this document and add the final-state changelog entry.

The `origin/bbmod3-editor` branch contains working gizmo math and transform
handling. Reuse or study that implementation as the starting point for the
gizmo integration, while keeping only the math and behavior needed by this
document's simpler registry-based editor architecture.

The same branch also contains working wireframe rendering that provides a good
visual reference for shape proportions, placement, and appearance. We do not
need to copy its wireframe implementation. BBMOD3 should implement its own
BBMOD-owned geometry while using the branch as a reference for the desired
result and behavior.

## Constraints

- Do not add `BBMOD_Scene` or `BBMOD_SceneNode`.
- Do not add `BBMOD_IEditable`.
- Do not add editor registration functions or a second authoritative object list.
- Do not use `variable_struct_exists()` in icon drawing, picking, gizmo, or wireframe paths.
- Do not use `cm_*` ColMesh code inside BBMOD.
- Do not alter runtime ownership or resource-manager behavior.
