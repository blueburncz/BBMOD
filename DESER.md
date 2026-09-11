# Binary Resource Serialization Plan

This document describes binary serialization for post-processors, terrains, and
particle systems. The formats are binary and must not use JSON.

This phase covers saving and loading resources for runtime use. It does not
cover editor UI, editor-only metadata, preview state, or live-reload tooling.

## Design Rules

- Serialize authored and configuration state, not transient GPU or runtime state.
- Rebuild surfaces, vertex buffers, DS grids, callback caches, and other runtime
  state after loading.
- Use the native GML constructor functions for struct round-tripping.
- Do not create an application-owned constructor registry.
- Preserve array ordering, especially post-process effect order and particle
  module order.
- Store project-resource dependencies as persistent references rather than raw
  runtime pointers or duplicated live structs.
- Make each resource struct inherit directly from `BBMOD_Resource`; do not add
  wrapper structs around resources that already own their serialized state.
- Give composite structs ownership of their own `to_buffer()` and
  `from_buffer()` payload methods. Containers should only serialize ordering,
  constructor identity, and container-level fields.
- Read binary fields into locals in stream order before passing them to a
  constructor. Do not embed multiple `buffer_read()` calls in constructor
  arguments because GML does not guarantee argument evaluation order.
- Use existing value APIs such as `BBMOD_Color.ToBuffer()` and
  `BBMOD_Color.FromBuffer()` instead of duplicating component serializers.
- Destructors must release owned resources and child containers, but need not
  reset fields after destruction because destroyed structs must not be reused.
- Fail loudly on unknown constructors, invalid payloads, unsupported versions,
  and missing required dependencies.

## Native Constructor Round-Trip

Every constructor-backed struct is serialized with its native GML constructor
name:

```gml
var _constructorName = instanceof(_value);
```

The name is written as a length-prefixed UTF-8 string. During deserialization,
the constructor is resolved and invoked dynamically:

```gml
// Feather ignore GM1021

var _constructor = asset_get_index(_constructorName);
if (_constructor == -1)
{
    throw new BBMOD_Exception(
        "Unknown constructor: " + string(_constructorName));
}

var _value = new _constructor();
```

The `// Feather ignore GM1021` comment must be at the top of the script that
contains the dynamic constructor call. Feather reports a false GM1021 warning
for this valid GML pattern.

`instanceof()` is valid for structs created with `new Constructor()`. Struct
literals return `"struct"` and cannot be reconstructed as their original
constructor. Such values must be rejected when a constructor-backed value is
required.

Constructor script asset names become part of the file format. Renaming a
constructor can therefore invalidate existing files; no custom registry is
introduced to hide that native GML behavior.

## Shared Binary Infrastructure

Build on `BBMOD_Resource`:

- `from_buffer(_buffer)` loads a resource.
- `to_buffer(_buffer)` writes a resource.
- `from_file()` and `to_file()` provide file access.
- `from_file_async()` and the resource manager provide asynchronous loading.

Add shared binary reader and writer helpers for:

- magic bytes
- format version
- resource type
- flags
- payload length
- unsigned and signed integers
- floating-point values
- booleans
- length-prefixed UTF-8 strings
- nullable values
- arrays
- vectors, colors, quaternions, and rectangles
- texture references
- project-resource references

Every resource begins with a validated header. Each resource format has an
independent version number.

## Project Resource References

Resources must refer to other project resources using canonical paths relative
to the project resource root. Absolute machine paths must never be written to
resource files.

A project-resource reference contains:

- resource path
- resource extension or kind when required for validation
- optional SHA1/content hash
- optional subresource name

References are resolved through `BBMOD_ResourceManager`. Dependencies must be
loaded before the owning resource is marked loaded. A missing or invalid
dependency is a load error, not a partially initialized resource.

External references are the default. Embedded data is used only when the
format explicitly supports it, such as embedded RGBA8 texture data or final
terrain height data.

Material serialization is outside the scope of this plan. These resources may
still refer to materials through the material representation already supported
by the project, but adding a binary material resource is future work.

## Texture References

Use one binary texture-reference representation for all four resource types.
Never serialize a raw `Pointer.Texture`.

Supported source forms:

1. Asset-backed sprite: asset name and subimage.
2. External resource: relative path, optional SHA1, and subimage.
3. Embedded texture: width, height, format, and RGBA8 byte data.

Ownership is reconstructed from the source:

- Asset-backed sprites are borrowed.
- Resource-manager sprites are borrowed.
- Embedded textures create owned sprites.
- A resource only owns sprites it created itself.

Do not infer source ownership from a runtime sprite's generated asset name.
Runtime-created sprites can appear as sprite assets. Persist explicit ownership
and source metadata, and use `asset_get_type()` only as an additional asset
validation check.

When optional metadata is represented by a struct, check it with
`variable_struct_exists()` before reading it. Null-coalescing does not protect
against reading an absent struct field in GML.

The current implementation supports RGBA8 capture and reconstruction. Other
formats must be rejected explicitly until implemented.

## Post-Processor Resource

File extension: `.bbpost`

The resource serializes:

- `Enabled`
- `DesignWidth`
- `DesignHeight`
- legacy supported post-processor properties
- `ColorGradingLUT` texture reference
- `LensDirt` texture reference
- `LensDirtStrength`
- `Starburst` texture reference
- `StarburstStrength`
- effect count
- each effect's native constructor name
- each effect's constructor-specific fields

Load sequence:

1. Validate the binary header.
2. Construct `BBMOD_PostProcessor`.
3. Read scalar properties and texture references.
4. Read each effect constructor name.
5. Resolve and construct each effect with native GML functions.
6. Deserialize its fields.
7. Add it with `PostProcessor.add_effect()`.
8. Rebuild any runtime effect state.

Read each effect payload sequentially before constructing or assigning its
fields. Each effect owns its own binary payload methods; the post-processor
only writes the effect constructor name and preserves effect order.

Do not serialize `Effects[i].PostProcessor`, surfaces, `Rect`, render-scale
caches, shader handles, or temporary GPU state. `add_effect()` restores the
post-processor back-reference.

Every post-process effect must provide a binary field contract. The effect
families currently include color grading, chromatic aberration, depth of field,
directional blur, exposure, film grain, FXAA, gamma correction, Kawase blur,
lens distortion, lens flares, light bloom, luma sharpen, monochrome, normal
distortion, radial blur, Reinhard tonemap, sun shafts, and vignette.

## Terrain Resource

File extension: `.bbterr`

The resource serializes:

- heightmap source or embedded final height data
- heightmap subimage
- position
- scale
- texture repeat
- chunk size and chunk radius
- lazy-build settings
- smoothing and build settings
- splatmap texture reference
- colormap texture reference
- five terrain-layer slots
- each `BBMOD_TerrainLayer` field and texture reference
- terrain material reference or material data
- collision-module configuration once its ownership boundary is defined

For runtime-edited terrains, serialize the final height grid rather than only
the original heightmap. This guarantees that a loaded terrain matches the
saved terrain. A future format may store source data plus an edit layer.

Each layer is serialized as a fresh constructor-backed struct. A
`BBMOD_TerrainLayer` can belong to only one terrain because
`BBMOD_Terrain.destroy()` destroys its defined layers.

Load sequence:

1. Validate the binary header.
2. Construct `BBMOD_Terrain`.
3. Restore height data and configuration.
4. Construct and restore each layer in its original slot.
5. Restore texture and material references.
6. Rebuild normals and smooth normals according to saved settings.
7. Rebuild chunks immediately or leave them for lazy building.
8. Recreate collision/runtime modules.
9. Mark the resource loaded.

Do not serialize DS grid IDs, vertex buffers, chunk bounds caches, normal and
tangent caches, lazy-build jobs, GPU surfaces, render queues, or profiling
state.

## Lens-Flare Resource

File extension: `.bbflare`

The resource serializes a reusable `BBMOD_LensFlare` composition:

- tint
- position and visibility range
- falloff and depth threshold
- direction and cone angles
- ordered `BBMOD_LensFlareElement` entries
- each element's sprite reference and subimage
- element offset, scale, distance scaling, color, angle, and fade settings
- starburst usage and ownership settings

Load sequence:

1. Validate the binary header.
2. Construct `BBMOD_LensFlare` from its scalar fields.
3. Construct each `BBMOD_LensFlareElement` using its native constructor name.
4. Restore each element's fields and texture reference.
5. Add elements in their original order.
6. Mark the resource loaded after all dependencies are resolved.

Sprite references may use project assets, external sprite files, or embedded
RGBA8 data. External and embedded sprites are owned by the loaded flare.

Do not serialize the global lens-flare list, post-processor back-references,
shader handles, screen coordinates, draw state, or other runtime rendering
state. A loaded flare owns sprites created from external files or embedded data;
asset-backed sprites remain borrowed.

## Particle-System Resource

File extension: `.bbpart`

The resource serializes the particle-system definition, not a running
simulation:

- particle-system configuration
- ordered module array
- emitter configuration
- particle material and texture references
- model or mesh reference
- batch size
- module-specific parameters
- optional deterministic random seed

The module order must be preserved exactly.

For every entry in `ParticleSystem.Modules`:

1. Write `instanceof(_module)`.
2. Write the module's binary fields.
3. Resolve the constructor with `asset_get_index()` during loading.
4. Construct it with `new _constructor()`.
5. Read its fields.
6. Append it to `Modules` in the original order.
7. Call `__rebuild_module_callbacks()`.

Do not serialize live particles, dynamic-batch vertex buffers, callback arrays,
particle-system back-references, GPU handles, collision scratch state, or
profiling state.

Particle module groups requiring binary field contracts include:

- Emission: `BBMOD_AABBEmissionModule`, `BBMOD_SphereEmissionModule`,
  `bbmod_emissionmodule`, and `BBMOD_EmissionOverTimeModule`.
- Value setters: the real, vector, quaternion, and color setter modules.
- Over-time modules: real, vector, quaternion, and color add/mix modules.
- Collision modules: collision event, collision kill, terrain collision, and
  on-collision add modules.
- Speed and health modules: all speed- and health-based real, vector,
  quaternion, and color mix modules.
- Other behavior: attractor, gravity, drag, random rotation, and direct mix
  modules.

Curves, ranges, easing modes, and randomization settings must use explicit
binary representations. Function references cannot be persisted as arbitrary
runtime values.

Particle systems should reference terrain, mesh, model, and material resources
by canonical project path instead of embedding duplicate resources. Sprite and
texture references use the shared texture-reference format above.

A later snapshot format may serialize a running simulation, including active
particles, ages, emitter counters, random state, and module runtime state. That
format must remain separate from the reusable `.bbpart` resource format.

## Resource Manager Integration

Register the extensions with `BBMOD_ResourceManager`:

- `.bbpost` -> post-processor resource
- `.bbterr` -> terrain resource
- `.bbpart` -> particle-system resource
- `.bbflare` -> lens-flare resource

Resources must use canonical paths, SHA1 validation, manager caching, and the
existing `BBMOD_Resource` ownership and lifetime rules.

Dependencies must load before the owning resource is marked loaded. Missing or
invalid dependencies must produce an error rather than a partially initialized
resource. This applies to model, mesh, sprite, terrain, and texture
dependencies.

## Testing

Add binary round-trip tests for each resource:

- serialize, load, and serialize again
- compare normalized configuration and constructor names
- preserve array and module/effect ordering
- cover every current effect and particle-module family
- cover empty resources
- cover asset, external, and embedded texture references
- cover terrain layers and final height data
- cover lens flares, element ordering, and element texture references
- cover terrain collision references
- verify callback caches are rebuilt
- verify dynamic batches and GPU/runtime resources are recreated
- verify owned resources are destroyed exactly once
- reject unknown constructors
- reject struct literals where constructors are required
- reject invalid magic, versions, lengths, and truncated buffers
- reject unsupported texture formats
- reject missing dependencies
- verify deterministic particle behavior with the same seed

## Implementation Order

1. Add shared binary readers and writers.
2. Add native constructor-name read/write helpers and the Feather suppression
   at the dynamic-construction site.
3. Add shared binary texture and resource-reference serialization.
4. Implement `.bbpost` resource loading and saving.
5. Add binary contracts to every post-process effect.
6. Implement `.bbterr` configuration, layers, and final height-data
   serialization.
7. Implement terrain cache and collision-state rebuilding.
8. Implement `.bbflare` loading and saving.
9. Implement `.bbpart` loading and saving.
10. Add binary contracts to every particle module.
11. Rebuild particle callback caches and dynamic batches after loading.
12. Register all four extensions with `BBMOD_ResourceManager`.
13. Add independent round-trip tests and cross-resource dependency tests.
14. Add malformed-file, versioning, missing-dependency, ownership, and
    destruction tests.
