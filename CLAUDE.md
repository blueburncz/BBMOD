# BBMOD - Claude Guidelines

## Project Goal

BBMOD's mission is to make creating 3D games in GameMaker easy and accessible.
Primary focus areas:

- **Rendering** — implemented in GML and GLSL ES 2.0
- **Navigation** — Recast/Detour via C++ extension
- **Physics** — Bullet via C++ extension

When C++ extensions are unavailable (e.g. WASM targets do not support them in
GameMaker), provide simple, practical, performant **GML-only fallbacks**:

- **Physics fallback:** not a physics simulation — instead leverage GM's
  built-in 2D instance collision system and add height (Z-axis) detection on
  top of it. Simple, practical, fast.
- **Navigation fallback:** A* on a user-placed node graph (AI path nodes).
  **Implementation note:** `ds_priority_queue` is extremely slow in GM — do
  NOT use it. Use `ds_grid` as the open set and sort by a cost column instead.

## Coding Conventions

- **ASCII only:** all source code (GML and GLSL) must use pure ASCII characters — no Unicode, no fancy quotes, no non-ASCII symbols anywhere in code.
- **GameMaker project:** every new `.yy` file must be registered in the `.yyp` project file — new assets are silently ignored by GM otherwise.
- **Documentation:** JSDoc style using `///` comments (GameMaker convention); max line length 80 characters. See full rules below.

### JSDoc Rules

Every file begins with `/// @module ModuleName` then a blank line.

**Function / constructor block** — tag order with blank `///` lines between groups:

```gml
/// @func FunctionName([_optionalParam])
///
/// @extends ParentClass
/// @implements {InterfaceName}
/// @interface
///
/// @desc Short description. Wraps at 80 chars, continuation lines have
/// no extra indent — just `///` at the same level.
///
/// @example
/// Optional prose before the code fence:
/// ```gml
/// var _x = new FunctionName();
/// ```
///
/// @param {Type} _paramName Description.
/// @param {Type} [_optionalParam] Description. Defaults to `value`.
///
/// @return {Type} Description.
///
/// @throws {BBMOD_Exception} When and why.
///
/// @note Additional notes go here.
///
/// @see OtherFunction
/// @see ClassName.Property
///
/// @deprecated Please use {@link NewFunction} instead.
```

- Include only the tags that apply; omit the rest (and their surrounding blank lines).
- Multiple `@param` lines: no blank `///` between them.
- Multiple `@see` lines: no blank `///` between them.
- **Enum parameters:** GML enums are `Real` at runtime. Use `{Real}` as the
  type and reference the enum via `{@link}` in the description:

  ```gml
  /// @param {Real} _type The weather preset. Use values from
  /// {@link BBMOD_ECloudWeather}.
  ```

  Never use `{Constant.EnumName}` or `{Enum.EnumName}` — these are not valid.

**Macro block** — type and description on a single `@macro` line:

```gml
/// @macro {Type} Description text.
/// @private
/// @note Optional extra note.
#macro BBMOD_MY_MACRO value

/// @macro {Type}
/// @private
#macro __BBMOD_PRIVATE_MACRO value
```

**Enum block** — `@enum` directly above the `enum` keyword; each member gets
`/// @member` directly above the member name (no blank line between):

```gml
/// @enum Description of the enum.
/// @see RelatedThing
enum BBMOD_EMyEnum
{
    /// @member Description of this member.
    MemberA,
    /// @member Description. Supports {@link links}, @see, @example, @obsolete.
    /// @see BBMOD_EMyEnum.MemberA
    MemberB,
};
```

**Property block** — all tags on consecutive lines, no blank lines between them:

```gml
/// @var {Type} Description. Inline {@link Reference} allowed.
/// @readonly
/// @private
/// @note Extra note.
/// @see Something
PropertyName = value;
```

**Inline `{@link}` format:**

- `{@link FunctionName}` — standalone function
- `{@link ClassName.Property}` — member of a class
- No spaces inside `{@link ...}`

**Type notation inside `{}`:**

| Type                       | Syntax                              |
|----------------------------|-------------------------------------|
| Primitive                  | `{Real}`, `{Bool}`, `{String}`      |
| Struct / class             | `{Struct.BBMOD_ClassName}`          |
| Interface (in @implements) | `{InterfaceName}`                   |
| Array                      | `{Array<Type>}`                     |
| Nullable / union           | `{Type, Undefined}`                 |
| Pointer                    | `{Pointer.Texture}`                 |
| GM built-in ID             | `{Id.Instance}`, `{camera}`         |
| DS map                     | `{Id.DsMap<KeyType, ValueType>}`    |

- **Indentation:** tabs, displayed as 4 characters wide.
- **Formatter:** `format-gml.py` (uses `jsbeautifier` + `.jsbeautifyrc`).
  Run before committing. Key enforced settings:
  - Tabs, indent size 4
  - Brace style: expand (Allman), preserve-inline for compact struct literals
  - Line wrap at 120 characters (GML code; JSDoc is still 80)
  - LF line endings, newline at end of file
  - No spaces inside parentheses
  - Max 2 consecutive blank lines
  - Files under `__cmi_` / `cm_` are excluded (third-party code)
  - **Shader files (`.vsh`/`.fsh`) are not handled** — apply the same
    formatting rules manually when writing or editing GLSL code.
- **No alignment spacing:** use exactly one space between tokens. Never pad
  with extra spaces to align assignments, declarations, or anything else
  vertically. This applies to both GML and GLSL. Examples:

  ```gml
  // Correct:
  Something = 1;
  SomethingElse = 2;
  uniform vec3 bbmod_CamPos;
  uniform float bbmod_ZFar;

  // Wrong:
  Something      = 1;
  SomethingElse  = 2;
  uniform vec3  bbmod_CamPos;
  uniform float bbmod_ZFar;
  ```

- **Braces:** always on their own line (Allman style); always required — even
  for single-statement bodies:

  ```gml
  if (something)
  {
      return;
  }
  ```

- **Section comments:** exactly two styles, both with a `/` line up to 80 chars. **Never use any other style** (no `// ====`, no `// ----`, no variations):

## Naming Conventions

These are strict — always follow them when adding new code.

### GML

| Thing                        | Convention                    | Example                          |
|------------------------------|-------------------------------|----------------------------------|
| Constructor / class          | `BBMOD_PascalCase`            | `BBMOD_PointLight`               |
| Interface                    | `BBMOD_IPascalCase`           | `BBMOD_IDestructible`            |
| Public static method         | `snake_case`                  | `update_matrices`, `destroy`     |
| Public constructor property  | `PascalCase`                  | `Direction`, `MouseLook`         |
| Private constructor property | `__camelCase`                 | `__mouseLockAt`                  |
| Public standalone function   | `bbmod_snake_case`            | `bbmod_fog_set_color`            |
| Private/internal function    | `__bbmod_snake_case`          | `__bbmod_logging`                |
| Public macro                 | `BBMOD_UPPER_SNAKE`           | `BBMOD_RGBM_VALUE_MAX`           |
| Private macro                | `__BBMOD_UPPER_SNAKE`         | `__BBMOD_RGBM_RANGE`             |
| Enum                         | `BBMOD_EPascalCase`           | `BBMOD_EPhysicsShapeType`        |
| Global variable              | `global.__bbmodCamelCase`     | `global.__bbmodCameraCurrent`    |
| Function parameter           | `_camelCase`                  | `_color`, `_position`            |
| Local variable               | `_camelCase`                  | `_view`, `_quatZ`                |
| GM object                    | `OPascalCase`                 | `OCharacter`, `OMainPhysics`     |

### GLSL Shaders

| Thing                  | Convention                        | Example                           |
|------------------------|-----------------------------------|-----------------------------------|
| Shader asset           | `BBMOD_ShPascalCase[_RenderPath]` | `BBMOD_ShStatic_Forward`          |
| Post-process shader    | `BBMOD_ShPascalCase`              | `BBMOD_ShChromaticAberration`     |
| Uniform                | `bbmod_camelCase`                 | `bbmod_CamPos`, `bbmod_ZFar`      |
| GLSL utility function  | `BBMOD_PascalCase`                | `BBMOD_GammaToLinear`             |
| `#define` constant     | `BBMOD_UPPER_SNAKE`               | `BBMOD_MAX_PUNCTUAL_LIGHTS`       |
| Varying                | `v_` + type hint + `camelCase`    | `v_vVertex`, `v_mTBN`             |
| Vertex attribute       | `in_PascalCase` (GM standard)     | `in_Position`, `in_TangentW`      |
| Local variable         | `camelCase` (no `_` prefix)       | `position`, `fogStrength`         |

**Varying type hints:** `v` = vec/scalar, `m` = matrix.

**`x` prefix is legacy — replace with `BBMOD_`:**
All GLSL utility functions previously named `xFunctionName` must be renamed to
`BBMOD_FunctionName`. Examples:

| Old name          | New name               |
|-------------------|------------------------|
| `xGammaToLinear`  | `BBMOD_GammaToLinear`  |
| `xLinearToGamma`  | `BBMOD_LinearToGamma`  |
| `xEncodeDepth`    | `BBMOD_EncodeDepth`    |
| `xDecodeDepth`    | `BBMOD_DecodeDepth`    |
| `xEncodeRGBM`     | `BBMOD_EncodeRGBM`     |
| `xDecodeRGBM`     | `BBMOD_DecodeRGBM`     |
| `xBestFitNormal`  | `BBMOD_BestFitNormal`  |
| `xLuminance`      | `BBMOD_Luminance`      |

**Platform detection** (GameMaker built-in macros):
`_YY_GLSL_`, `_YY_HLSL11_`, `_YY_PSSL_` — use for platform-specific code paths
(e.g. dynamic array indexing workaround for GLSL ES 2.0).

```gml
////////////////////////////////////////////////////////////////////////////////
//
// Big section
//

////////////////////////////////////////////////////////////////////////////////
// Small section
```

## Debug UI

Use `CGUI` (`BBMOD_GML/scripts/CGUI/CGUI.gml`) for any in-engine debug UI
during development (sliders, buttons, labels, etc.). Do not roll custom debug
drawing when `CGUI` covers the need.

## API Design Philosophy

The user-facing API should be **easy and artist-focused, but still powerful**. Sensible defaults, minimal boilerplate, no unnecessary exposure of internal complexity — but with enough depth for advanced users to take control when needed.

Includes built-in support for common **gameplay-oriented rendering features** — e.g. solid color hit flash, fog of war — so developers don't have to build these from scratch.

BBMOD uses a **fluent API** — setters and chainable methods return `self`, enabling method chaining. Always follow this pattern for new methods.

BBMOD provides **built-in visual/performance quality settings** (e.g. Low / Medium / High / Ultra presets) so users don't have to build their own. Effects like SSR are gated behind these settings (e.g. SSR only on "Ultra").

## Platform / Shader Constraints

These are hard constraints that affect every shader and rendering decision:

- **Shader language:** GLSL ES 2.0 (GameMaker-flavored) — no compute shaders, no instancing extensions, limited built-ins
- **Texture samplers:** 8 max total, including `gm_BaseTexture` — budget carefully
- **MRT:** Not always available; when present, 4 render targets max
- **HW depth buffer:** Accessible
- **Floating point textures:** Not guaranteed to be available
- **Vertex texture fetch:** Not guaranteed to be available
- **Cubemap / 3D textures:** Not natively available — simulated with custom 2D
  layouts. Cubemap faces are packed into a single 2D texture as 8 equal-width
  columns (6 used, 2 padding):

  ```text
  +---------------------------+
  |+X|-X|+Y|-Y|+Z|-Z|    |    |
  +---------------------------+
  ```

  Cubemaps are also commonly converted to octahedral projection for IBL,
  reflection probes, and SH light probe capture.
- **Geometry instancing:** Unavailable — faked via `BBMOD_DynamicBatch`:
  - Multiple copies of a model are baked into a single vertex buffer with an extra per-vertex instance ID attribute
  - Instance data (transforms, etc.) passed via uniforms
  - Instance count is hard-limited by the number of available uniforms — keep this in mind when designing instanced shaders

Design all shaders and render pipelines with these limits in mind. Prefer fallback-friendly approaches.

### Shader Build System

Shaders are migrating from **Xpanda** to **`pre-build.py`**
(`BBMOD_GML/extensions/BBMOD/pre-build.py`). All new shaders must use this
system.

**How it works:**

1. At build time the script unpacks `shader_includes.zip` into `BBMOD_GML/`,
   producing `BBMOD_GML/shader_includes/*.glsl`.
   **After adding/modifying/removing any `.glsl` file in `shader_includes/`,
   run `update-shader-includes.py` (repo root) to repack the zip.**
2. It walks every `.vsh` / `.fsh` in `BBMOD_GML/shaders/` and expands
   `// @include` directives in-place.
3. Already-expanded blocks are delimited by `// @endinclude` (written
   automatically) so they can be re-expanded on the next build.

**Shader include syntax:**

```glsl
// @include IncludeName
// @endinclude
```

- `IncludeName` matches `shader_includes/IncludeName.glsl` (no extension).
- Each include is injected only once per shader (de-duplicated).
- Includes can nest — include files may themselves contain `// @include`.
- Indentation of the `// @include` line is preserved and applied to the
  injected code.

**Preprocessor directives** (usable in both shaders and include files):

```glsl
// @define MY_FLAG
// @ifdef MY_FLAG
...code...
// @else
...code...
// @endif
// @ifndef MY_FLAG
...
// @endif
```

**Include file conventions** (`shader_includes/Name.glsl`):

- Own `// @include` dependencies go at the very top.
- Then the GLSL utility functions follow (named `BBMOD_FunctionName`).
- Keep each file focused on one utility or small group of related utilities.

**Also runs model conversion:** converts model files in `assets/` to `.bbmod`
format in `datafiles/assets/` using `BBMOD.exe`, with args from
`bbmod.conf.json` and change-detection caching via `bbmod.cache.json`.

## Changelog

**ALL user-facing changes MUST be documented in `Changelog.md`.** This is
mandatory — never skip it when modifying existing behavior, adding features,
or fixing bugs that users could notice.

Current version in progress: **3.99.0-alpha2**.

Format — add entries under the appropriate section heading, matching the
existing style:

```markdown
## Changelog 3.99.0-alpha2

### Breaking Changes

* **Short Label:** Description of what changed and how to migrate.

### Rendering

* **Feature Name:** Description.
* Fixed `SomeThing` doing wrong thing in some scenario.

### Bug Fixes

* Fixed ...
```

Sections used in the current changelog: `Breaking Changes`, `Rendering`,
`Raycasting`, `Optimizations`, `Math Library`, `Particles`. Add new sections
as needed.

## Renderer Architecture

A single universal renderer supporting two paths:

- **Forward rendering** — always available, used as fallback; supports 1 directional light + up to 8 point/spot lights per draw call
- Optimized render queue with automatic material sorting by hash to minimize state changes
- Forward and deferred paths must be **visually as close as possible** — the forward path is not a degraded fallback, just missing deferred-only features (decals, parallax-corrected probes, SSR, etc.)
- `BBMOD_DefaultRenderer` and `BBMOD_DeferredRenderer` will be merged into a single `BBMOD_UniversalRenderer`
- Use `/// @module Rendering` for all new rendering code

### Render Pass Order

**Forward (`BBMOD_DefaultRenderer`):**

1. `ReflectionCapture` — render scene into reflection probe cubemaps
2. `Id` — render instance IDs (edit mode only)
3. `Shadows` — render shadow maps
4. `DepthOnly` — opaque scene depth (optional; used for SSAO)
5. SSAO (post-process on depth)
6. `Background` — sky, skybox
7. `Forward` — opaque lit geometry
8. `Alpha` — alpha-blended geometry
9. Gizmo overlay (edit mode)

**Deferred (`BBMOD_DeferredRenderer`):**

1. `ReflectionCapture` — render scene into reflection probe cubemaps
2. `Id` — render instance IDs (edit mode only)
3. `Shadows` — render shadow maps
4. `GBuffer` — opaque geometry into G-buffer (RT0/RT1/RT2 + L-buffer)
5. `DepthOnly` — additional depth for alpha/transparent objects
6. SSAO (post-process on G-buffer depth)
7. Lighting pass — fullscreen ambient/directional + punctual light volumes
8. `Background` — sky rendered into final surface
9. `Forward` — forward-rendered objects (e.g. alpha-tested)
10. `Alpha` — alpha-blended geometry
11. `Translucent` — objects needing blurred screen as input
12. `Distortion` — screen-space distortion effects
13. Gizmo overlay (edit mode)

### Memory Management

- Structs implementing `BBMOD_IDestructible` must be explicitly destroyed;
  assign the return value: `thing = thing.destroy()`.
- `BBMOD_ResourceManager` handles lifetime of loaded assets — prefer it for
  models, materials, and textures. The default instance is `BBMOD_RESOURCE_MANAGER`.
- GM surfaces and vertex buffers must be managed manually — destroy them in
  Clean Up events or `destroy()` methods.
- There is no garbage collection for GPU resources — always pair create with destroy.

### G-Buffer Layout

Current layout (3 render targets + L-buffer for emissive):

| RT   | R          | G          | B          | A          |
|------|------------|------------|------------|------------|
| RT0  | Albedo.r   | Albedo.g   | Albedo.b   | AO         |
| RT1  | Normal.x   | Normal.y   | Normal.z   | Roughness  |
| RT2  | Depth[0]   | Depth[1]   | Depth[2]   | Metallic   |
| L-buf| Emissive.r | Emissive.g | Emissive.b | —          |

**Planned:** replace RGB-encoded depth (RT2.rgb) with the HW depth buffer.
This frees up RT2.rgb for other data, effectively giving us an extra channel.
Material type ID float will be packed into one of the freed channels.

### BRDF

- **Diffuse:** Lambert
- **Fresnel:** Schlick approximation (everywhere — critical for modern look)
- **Specular (current):** Full Cook-Torrance GGX — `D_GGX * G_SchlickGGX * F_Schlick / (4 * NdotL * NdotV)`
- **Specular (target):** Simplified GGX — replace the expensive NDF with the
  cheaper `xSpecularD_Approx` (UE mobile `exp2` approximation, already present
  in the shader but not yet wired up); also evaluate simplifying or removing
  the geometric attenuation term `G`

### Coordinate System

- **Z-up** world space (matches Bullet physics and Blender export `-zup=true`)
- Both FOV and aspect ratio are **negated** in the projection matrix by default
  (`FovFlip = -1`, `AspectFlip = -1`) to compensate for GameMaker's Y-down
  screen space. Do not remove these flips.

### IBL Storage

A single texture containing 8 prefiltered octahedral maps stacked vertically:

- **Map 0:** diffuse irradiance
- **Maps 1–7:** specular at increasing roughness levels

Use `bbmod_IBLTexel` uniform (texel size of one octahedron) to sample correctly.

- **Deferred rendering** — used only when MRT and floating-point textures are available on the hardware

### Light Culling

Lights must be culled aggressively for performance:

| Technique          | Forward | Deferred |
|--------------------|---------|----------|
| Frustum culling    | yes     | yes      |
| Distance culling   | yes     | yes      |
| Screen-size culling| yes     | yes      |
| Stencil masking    | no      | yes      |
| Scissor / clip rect| no      | yes      |

### G-Buffer Material Flags

Lightmapped and other special materials must be identifiable in the G-buffer during the deferred lighting pass. A channel (or part of one) must be reserved for a **material type ID stored as a float** (e.g. 0.0 = standard PBR, 0.5 = lightmapped, etc.).

**Important:** GLSL ES 2.0 has no bitwise operations — flags cannot be bit-packed. Use discrete float values compared with thresholds instead.

### Deferred Decals

Decals applied by writing into the G-buffer, deferred renderer only.

## Rendering Direction: Mobile PBR

BBMOD's rendering goal is "mobile PBR" - physically based but with cheap approximations, not full accuracy.

### Supported PBR Workflows

- Metallic-roughness
- Specular-color / smoothness

### Lighting Features

- Meaningful (physically scaled) light intensities
- Energy conservation
- Fresnel (Schlick approximation) - prioritize this, it's key to the modern look
- Toksvig mapping — adjusts specular roughness based on normal map mip variance to prevent specular aliasing on distant surfaces
- Optional emissive
- Optional subsurface scattering (Frostbite cheap approximation)

## General Rendering Techniques

- Distance-based dithering to fade out far objects (no hard pop-in)
- Shadow maps for directional (single cascade), point, and spot lights
  - Hard and soft filtering options
  - No `gl_FragDepth` available in GLSL ES 2.0 — point and spot shadow maps use a dedicated shader that encodes radial depth (distance from light) into RGBA channels
  - Point light shadow maps use octahedral projection (existing cube-to-octahedron conversion functions available)
  - Forward renderer: shadow maps from multiple lights are atlased into a single texture to support multiple shadow casters
- Frustum culling
- Terrain rendering with splat map blending: 1 base layer (black/no splatmap) + up to 4 layers driven by RGBA splatmap channels; optional colormap texture to tint the blended result
- Terrain editing (sculpt, paint) — not yet supported, but desirable
- CPU-driven soft particles
- Refraction / heat distortion effects (rain, explosions, etc.)
- Configurable fog, tinted by atmosphere/sky color
- Cloud shadows — simple but convincing
- Toon outlines via back-face shell extrusion (reverse culling; supports global scale and normal offset modes)
- Solid color overlay effect (e.g. flash red when a character is hit)
- TreeIt tree rendering with wind sway animation
- Swaying grass rendering
- Global wind direction and strength setting, shared across trees, grass, clouds, ocean waves, and particles
- Vertex skinning via dual quaternions (no bone scaling support)
- Road rendering: spline-to-mesh generation, conformed to terrain surface
- Fog of war (optional / nice to have)
- Planar reflections (optional / nice to have)
- Selection outlines for the editor gizmo (highlight selected objects)
- Gizmo currently supports selecting instances by clicking on their model; extend to also support selecting structs (lights, probes, etc.) by clicking on a 2D billboard icon displayed above them in edit mode
- **Blockout material shader** for distance visualization (e.g. 1m, 5m, 10m rings based on camera distance):
  - Regular models: gray with procedurally varying roughness to avoid a flat look
  - Terrain: same distance markings but base color driven by splatmap
- Baked lightmaps (created in Blender, RGBM encoded) for static geometry
- L1 Spherical Harmonics light probes for dynamic object lighting from baked surroundings:
  - Capture: render the surrounding scene (lightmapped geometry, sky, emissives)
    into a cubemap from the probe's position — same infrastructure as reflection
    probe capture; can share the same pass
  - Offline: integrate the cubemap into L1 SH coefficients (4 per RGB channel =
    12 floats per probe); save to a binary file for fast runtime loading
  - Runtime: build a spatial grid/hash for O(1) nearest-probe lookup; pass 12
    floats as a uniform array per dynamic object; evaluate in vertex shader
  - Gives correct directionality at near-zero cost; extends the existing
    hemisphere ambient system

## Light Types

| Type             | Notes                                                                            |
|------------------|----------------------------------------------------------------------------------|
| Ambient          | Upper and lower hemisphere colors; affects both diffuse and specular             |
| Directional      | Sun/moon; single cascade shadow map                                              |
| Point            | Physically attenuated                                                            |
| Spot             | Physically attenuated                                                            |
| IBL              | Image-based lighting via prefiltered octahedral maps at varying roughness levels |
| Reflection probe | In-game capture; same prefiltered octahedral format as IBL                       |

> **Reflection probe capture:** specular reflections (SSR, cubemap lookups) must be disabled during capture — they are view/angle dependent and would look wrong when baked.

In the deferred renderer, reflection probes are **parallax-corrected** and treated analogously to point lights: rendered with a bounding volume, subject to all culling techniques (frustum, screen-size, distance, stencil, scissor), and faded out by distance for smooth blending between probes.

**Deferred reflection fallback chain** (each step fills in where the previous had no coverage):

1. Glossy SSR (if enabled in user settings)
2. Parallax-corrected reflection probes
3. Global IBL (if defined)

## Light Intensities

Analytical lights use real-world units scaled to fit float16 textures (max ~65504).

**Conversion formula:**

```text
engine_intensity = lux / 1000
```

### Directional Lights (illuminance in lux)

| Condition             | Real (lux)  | Engine units |
|-----------------------|-------------|--------------|
| Sun, clear noon       | 100,000     | 100          |
| Sun, hazy day         | 50,000      | 50           |
| Overcast day          | 10,000      | 10           |
| Sunrise / sunset      | 1,000       | 1            |
| Deep twilight         | 10          | 0.01         |
| Full moon             | 0.27        | 0.00027      |

### Point / Spot Lights (luminous flux in lumens)

Point and spot light intensity is stored as luminous flux (lm), using the same `/1000` scale.
Actual illuminance at distance `r` is computed in the shader:

```glsl
illuminance = (engine_intensity * 1000) / (4 * PI * r^2)  // lux, for reference
// or equivalently, keep everything in engine space:
illuminance_engine = engine_intensity / (4 * PI * r^2)
```

| Source                    | Real (lm)   | Engine units |
|---------------------------|-------------|--------------|
| Candle                    | 12          | 0.012        |
| 40W incandescent bulb     | 450         | 0.45         |
| 60W incandescent bulb     | 800         | 0.8          |
| 100W incandescent bulb    | 1,600       | 1.6          |
| Street lamp               | 10,000      | 10           |
| Car headlight (high beam) | 50,000      | 50           |

## Sky Rendering

### Daytime

- Optimized Rayleigh-Mie atmospheric scattering
- Sun disk

### Nighttime

- Artist-driven gradient
- Procedural stars
- Procedural moon with phase support

## Cloud Rendering

Not volumetric — flat/layered but visually convincing. Cheap and optimized.

- 2D noise texture as input
- 1-3 independently moving layers
- Per-layer coverage and density controls — can be driven by an artist-painted texture
- Lighting reacts to sky, sun, and moon

## Ocean / Water Rendering

Cheap and optimized. All effects should avoid heavy per-pixel cost.

| Feature             | Notes                                                                                   |
|---------------------|-----------------------------------------------------------------------------------------|
| Gerstner waves      | Vertex displacement                                                                     |
| Fresnel             | Schlick approximation, consistent with the rest of PBR                                  |
| Reflections         | SSR on "Ultra"; cubemap-only on lower settings                                          |
| Refraction          |                                                                                         |
| Caustics            |                                                                                         |
| Contact foam        |                                                                                         |
| Underwater color    | Depth-based tint                                                                        |
| Ripple simulation   | Real-time (e.g. player walking in water); height map simulated and converted to normals |

## Post-Processing

A heavily optimized post-processing chain. All effects should be cheap unless noted otherwise.

**Post-process volumes:** scene volumes that override post-process settings when the camera is inside them (e.g. darker vignette indoors, desaturated look in a poison zone).

| Effect                  | Notes                                                                 |
|-------------------------|-----------------------------------------------------------------------|
| Chromatic aberration    |                                                                       |
| Color grading           | 3D LUT encoded into a 2D texture                                      |
| Depth of field (bokeh)  | Near and far field blur; cheap approximation                          |
| Exposure                |                                                                       |
| Film grain              |                                                                       |
| FXAA                    | The only AA solution provided                                         |
| Gamma correction        |                                                                       |
| Tonemapping             | Filmic/ACES cheap approximation                                       |
| Lens distortion         |                                                                       |
| Lens flares             |                                                                       |
| Light bloom             | Cheap approximation                                                   |
| Luma sharpen            |                                                                       |
| Monochrome              |                                                                       |
| Normal distortion       | E.g. water drops on screen                                            |
| Directional blur        |                                                                       |
| Radial blur             |                                                                       |
| Sunshafts               |                                                                       |
| Vignette                |                                                                       |
| SSAO                    | Two modes: depth-only, and depth + normals                            |
| SSR                     | Variable roughness; PC "Ultra" settings only                          |

## Extensions

- Bullet physics engine
- Recast/Detour navigation mesh and pathfinding

## Physics

Bullet physics engine integrated as a GameMaker extension. Target feature set covers everything a modern game engine needs:

- Rigid body dynamics
- Collision shapes: box, sphere, capsule, cylinder, cone, convex hull, triangle mesh, compound
- Collision detection with callbacks/events
- Constraints / joints: hinge, slider, ball-socket, 6DOF, cone twist
- Kinematic character controller (jumping, crouching, pushing objects, slope/step handling)
- Vehicle physics (Bullet raycast vehicle)
- Ragdolls (compound rigid bodies + constraints)
- Ghost objects for triggers and sensors
- Ray casts and shape casts
- Soft bodies (cloth, ropes)

## Units

1 unit = 1 meter. This is required for compatibility with the Bullet physics engine.

### Guiding Principles

- Prefer cheap approximations over full correctness (e.g. no full GGX NDF)
- Must be viable on mobile hardware
- The above features are already partially implemented - build on them, don't replace them
