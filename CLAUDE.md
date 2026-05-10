# BBMOD Development Guide

## Table of Contents

- [BBMOD_GML Coding Style and Naming Standards](#bbmod_gml-coding-style-and-naming-standards)
- [Scope](#scope)
- [Naming Conventions](#naming-conventions)
- [Documentation Style](#documentation-style)
- [GMLDoc Conventions (Required for New APIs)](#gmldoc-conventions-required-for-new-apis)
- [Formatting and Code Shape](#formatting-and-code-shape)
- [Section Divider Comments (Required)](#section-divider-comments-required)
- [Practical Rules for New Code](#practical-rules-for-new-code)
- [Production-Grade Implementation Quality](#production-grade-implementation-quality)
- [Runtime GML Reference (macOS)](#runtime-gml-reference-macos)
- [Notes on Existing Mixed Style](#notes-on-existing-mixed-style)
- [Alpha Branch and Changelog Policy](#alpha-branch-and-changelog-policy)
- [ChangelogDev.md Update Rules](#changelogdevmd-update-rules)
- [GameMaker Resource Registration (Exact Steps)](#gamemaker-resource-registration-exact-steps)
- [Files That Control Registration](#files-that-control-registration)
- [Important Repository-Specific Observation](#important-repository-specific-observation)
- [Preferred Workflow (Use GameMaker IDE)](#preferred-workflow-use-gamemaker-ide)
- [Manual Workflow (Deterministic)](#manual-workflow-deterministic)
- [Validation Checklist (Before Commit)](#validation-checklist-before-commit)
- [Common Failure Modes](#common-failure-modes)

## BBMOD_GML Coding Style and Naming Standards

### Scope

This file captures naming and style conventions observed in BBMOD_GML and should be treated as the default standard for new GML code and documentation.

### Naming Conventions

#### 1) Types and Constructors

- Struct and constructor names use `BBMOD_` + PascalCase.
- Examples: `BBMOD_Scene`, `BBMOD_Node`, `BBMOD_BaseRenderer`, `BBMOD_PointLight`.

#### 2) Global API Functions

- Public global functions use `bbmod_` + lower_snake_case.
- Examples: `bbmod_scene_get_current`, `bbmod_scene_set_current`, `bbmod_camera_get_zfar`, `bbmod_material_get`.

#### 3) Internal and Private Helpers

- Private globals and helpers use `__bbmod_` + lower_snake_case.
- Examples: `__bbmod_dll_is_supported`, `__bbmod_matrix_get_identity`.

#### 4) Struct Static Methods

- Preferred style in core runtime modules is lower_snake_case.
- Core evidence: `BBMOD_Scene` and `BBMOD_Node` static methods are lower_snake_case; `BBMOD_BaseRenderer` public methods are lower_snake_case and private internals use double-underscore lower_snake_case.
- Legacy modules may still expose PascalCase methods (notably collider and math-heavy areas). Keep compatibility there; do not introduce new mixed-style naming unless extending an existing mixed API.

#### 5) Enums and Enum Members

- Enum type names use `BBMOD_E` + PascalCase.
- Examples: `BBMOD_ECloudWeather`, `BBMOD_ERenderPass`.
- Enum members typically use PascalCase for named variants.

#### 6) Macros and Global Constants

- Macros and constants use uppercase snake case with a `BBMOD_` prefix.
- Internal macros use `__BBMOD_` uppercase snake case.
- Examples: `BBMOD_RELEASE_MAJOR`, `BBMOD_VERSION_MINOR`, `BBMOD_EV_ANIMATION_END`, `__BBMOD_BONE_SPACE_WORLD`.

#### 7) Variables and Parameters

- Function parameters use underscore prefix: `_deltaTime`, `_index`, `_scene`.
- Local temporary variables usually use underscore prefix: `_probe`, `_childCount`, `_matrix`.
- Short loop counters are commonly `i` without underscore.

#### 8) Fields and Properties on Struct Instances

- Public data fields use PascalCase.
- Examples: `AmbientLightColorUp`, `ReflectionProbes`, `FogIntensity`, `UseAppSurface`.
- Booleans typically use semantic prefixes such as `Is`, `Has`, `Enable`, `Use`.

### Documentation Style

- Use GMLDoc comments with triple slash: `///`.
- Common tags: `@module`, `@func`, `@var`, `@param`, `@return`, `@see`, `@private`, `@readonly`, `@desc`, `@note`.
- Keep docs close to the symbol they describe.

### GMLDoc Conventions (Required for New APIs)

These rules are based on observed usage in `BBMOD_GML/scripts` and should be followed for every new public API and struct member.

#### 1) Comment Prefix and Spacing

- Every doc line must start with `///` followed by a single space.
- Use `///` (empty doc line) to separate logical sections in a doc block.
- Never use `//////`, `///@tag` (missing space), or mixed plain comments inside a doc block.
- Inside constructors and static methods, keep doc indentation aligned with code indentation (tabs in this project).

#### 2) Line Length and Wrapping

Observed distribution across project `///` lines:

- `<= 80`: vast majority.
- `<= 100`: almost all lines.
- `> 100`: rare, mostly long `@func` signatures.

Required limits for new docs:

- Soft limit: 100 characters per `///` line.
- Hard limit: 120 characters for prose lines.
- Exception: `@func` signatures with many optional parameters may exceed 120 when needed.
- Wrap long prose across multiple `///` lines at phrase boundaries; do not split tokens or types.

#### 3) File-Level Block Order

At top of script files, use this order when applicable:

1. `@module`
1. Optional macro, interface, or enum docs (`@macro`, `@interface`, `@enum`, `@member`)
1. Constructor and global function docs (`@func` blocks)

#### 4) Standard `@func` Block Order

For constructors, global functions, and methods, use this canonical order:

1. `@func <signature>`
1. Blank doc line (`///`)
1. Optional relationship tags: `@implements` (0 or more), `@extends` (0 or 1)
1. Blank doc line (`///`) when relationship tags are present
1. `@desc`
1. Blank doc line (`///`)
1. `@param` lines in argument order
1. Optional `@return`
1. Optional `@throws`
1. Optional `@note` (0 or more)
1. Optional `@example`
1. Optional `@see` (0 or more), usually at block end

For deprecated or obsolete APIs:

- Use `@deprecated` or `@obsolete` immediately after `@desc` (or immediately after `@func` for very short wrappers), and include migration target via `{@link ...}`.

#### 5) `@var` Block Rules

For struct fields and properties:

- Start with `@var {Type} Description...`.
- If needed, follow with qualifier tags on separate lines such as `@private` and `@readonly`.
- Preferred order: `@var` description first, then qualifiers.
- Include defaults in prose using `Defaults to ...` or `Default value is ...`.

#### 6) Linking Rules (`{@link ...}`)

- Prefer `{@link Symbol}` for symbol references in prose.
- Use fully qualified member names when useful, for example `{@link BBMOD_BaseRenderer.render}`.
- Keep link targets as symbol identifiers, not URLs.
- For new docs, do not introduce markdown file links like `[text](./SomePage.html)`; treat those as legacy style.

#### 7) Examples

- Use `@example` followed by a fenced code block with a language marker, for example `gml`.
- Event walkthrough lines inside examples may use `/// @desc ...` markers, but only inside fenced code.
- Keep examples minimal and executable in context (create, step, and draw snippets are preferred).

#### 8) Allowed Tag Set for New APIs

Prefer this normalized set:

- `@module`, `@func`, `@desc`, `@param`, `@return`, `@throws`, `@var`, `@private`, `@readonly`, `@note`, `@see`, `@example`, `@extends`, `@implements`, `@enum`, `@member`, `@interface`, `@macro`, `@deprecated`, `@obsolete`.

Do not introduce variant spellings such as:

- `@returns` (use `@return`).
- `@funct` (use `@func`).

#### 9) Naming Inside Docs

- Keep documented function names consistent with API naming conventions.
- Public globals: `bbmod_*`.
- Internal helpers: `__bbmod_*`.
- Types and constructors: `BBMOD_*`.
- Parameter names in docs must match code parameter identifiers exactly (`_deltaTime`, `_index`, etc.).

### Formatting and Code Shape

- Braces are on their own line for functions and blocks.
- Indentation uses tabs in GML sources.
- Trivial wrappers often start with `gml_pragma("forceinline")`.
- Fluent methods commonly return `self`; destructors return `undefined`.
- Run `format-gml.py` to enforce project formatting consistency across GML files.
- If formatting still changes files after one pass, run `format-gml.py` again until it produces no further changes.

### Section Divider Comments (Required)

Use slash-divider comments for code sections with these strict rules:

1. Divider length must target 80 columns.
1. Tab width for column counting is 4 spaces.
1. Only the following two styles are valid for new code.

Big section style:

```gml
////////////////////////////////////////////////////////////////////////////////
//
// Big section
//
```

Small section style:

```gml
////////////////////////////////////////////////////////////////////////////////
// Small section
```

Additional constraints:

- Do not use shorter slash lines (for example 40-character separators) in new code.
- Do not use dashed separators (for example `// --------`) for section headers.
- Do not invent alternate multi-line section layouts; use only the two patterns above.

### Practical Rules for New Code

1. New public global functions: `bbmod_*` lower_snake_case.
1. New private globals and helpers: `__bbmod_*` lower_snake_case.
1. New struct methods: lower_snake_case (unless extending a legacy PascalCase API in-place).
1. New types: `BBMOD_*` PascalCase; enums: `BBMOD_E*`.
1. Parameters and short-lived locals: underscore-prefixed.
1. Keep docs in GMLDoc format and preserve return semantics (`self` for fluent, `undefined` for destroy).

### Production-Grade Implementation Quality

These rules apply to production code changes in this repository.

#### Runtime GML Reference

- The full GML reference is available at `/Users/Shared/GameMakerStudio2-Beta/Cache/runtimes/runtime-2024.1400.5.1027/GmlSpec.xml` (macOS) or `C:\ProgramData/GameMakerStudio2-Beta/Cache/runtimes\runtime-2024.1400.5.1027` (Windows)

#### Core Quality Bar

- Do not produce pseudocode.
- Do not produce partial implementations.
- Do not leave TODO, FIXME, placeholder comments, or stubbed branches in committed code.
- Do not label delivered code as "simplified", "example-only", or "temporary".
- Assume code is shipping and must be production-ready.

If requirements are ambiguous, make a reasonable explicit assumption in the PR or summary and proceed.

#### Implementation Completeness

- Every edited function and path must be fully implemented for the requested behavior.
- No empty branches unless they are intentionally unreachable and guarded with an assertion.
- Avoid half-migrations: when replacing behavior, remove superseded paths unless compatibility is explicitly required.

#### Architecture and Maintainability

- Keep ownership and lifetime, data flow, and subsystem boundaries explicit.
- Avoid hidden global state unless explicitly justified by engine and runtime constraints.
- Avoid unnecessary abstractions and one-line wrapper helpers that reduce clarity.
- Prefer explicit readable code over clever compact code.

#### Performance and Runtime Behavior

- Treat render and update paths as performance-critical by default.
- Minimize hot-path allocations and avoid unnecessary per-frame churn.
- Prefer cache-friendly contiguous data access for per-instance and per-vertex loops.
- Separate hot-path logic from cold-path setup and validation where practical.
- Do not use `variable_struct_exists` in render/update hot paths.
- Do not add runtime type-validation guards in hot paths; rely on API contracts and let invalid usage fail naturally.

#### Safety, Validation, and Debuggability

- Add assertions for invalid internal states where failure should be loud.
- Add lightweight validation for external inputs where misuse is plausible.
- Include debug hooks and diagnostics when changing behavior that is hard to reason about at runtime.

#### Delivery Discipline (Required)

Before finalizing a non-trivial change:

1. Perform a strict self-review for correctness, regressions, edge cases, and performance.
1. Fix all identified issues in the same change when feasible.
1. Re-check diagnostics and tests relevant to edited files.

Do not leave known issues intentionally unfixed without explicitly documenting why.

### Notes on Existing Mixed Style

BBMOD_GML currently contains both lower_snake_case and PascalCase method names across different modules. This is historical layering, not a signal to use mixed style for new APIs. Prefer lower_snake_case for method and function surfaces unless compatibility requires otherwise.

## Alpha Branch and Changelog Policy

- `BBMOD_Scene` is currently an alpha-branch API and is not part of stable BBMOD yet.
- While working in `3.99.0-alpha2` (unreleased), `BBMOD_Scene` can be changed as needed to match the intended component-based architecture.
- Changelog policy for unreleased `3.99.0-alpha2`: if a behavior or API was already listed and is changed again before release, keep only the latest final description, remove superseded notes for the same change, and treat `3.99.0-alpha2` as a current-state changelog rather than a timeline of intermediate edits.

### ChangelogDev.md Update Rules

When updating `ChangelogDev.md`, follow these rules:

1. Update only the current unreleased version section unless explicitly asked to edit older releases.
1. Keep entries in final-state form. If a behavior changed again before release, rewrite the existing bullet instead of adding a second historical bullet.
1. Remove superseded bullets for the same feature or API so the section reflects the latest truth only.
1. Keep one bullet per externally meaningful change (API surface, behavior, fix, deprecation, migration).
1. Prefer concrete impact wording (what changed and where) over implementation chronology (how many refactors happened).
1. For deprecations and obsoletions, include the migration target in the same bullet.
1. Avoid duplicate bullets that describe the same change with different phrasing; consolidate them.
1. Keep style consistent with existing file conventions: use `*` list bullets, use code formatting for symbols and functions, and keep entries concise but specific enough for users.
1. For unreleased work, prioritize accuracy of current behavior over preserving intermediate development history.

## GameMaker Resource Registration (Exact Steps)

This section documents the exact, repeatable process for adding new files and resources to `BBMOD_GML` so they are recognized by the GameMaker project.

### Files That Control Registration

- `BBMOD_GML/BBMOD.yyp`: authoritative resource registry (`resources` array) and folder tree metadata used by IDE (`Folders` array with `folderPath` like `folders/...yy`).
- `BBMOD_GML/BBMOD.resource_order`: display and execution ordering metadata (`FolderOrderSettings`, `ResourceOrderSettings`).
- Resource `.yy` file (per resource): must exist at path referenced in `BBMOD.yyp/resources` and must contain correct `resourceType`, `name`, and `parent.path`.

### Important Repository-Specific Observation

- In this repo state, physical `BBMOD_GML/folders/*.yy` files are not present on disk, but `BBMOD.yyp` and `BBMOD.resource_order` still reference those `folders/...yy` paths.
- Treat `folderPath` and `parent.path` values as metadata strings that must match existing conventions in `BBMOD.yyp` and `BBMOD.resource_order`, even if the target folder `.yy` file is not present locally.

### Preferred Workflow (Use GameMaker IDE)

1. Create the resource in GameMaker IDE under the correct virtual folder.
1. Save project once.
1. Verify diffs include all required pieces: new resource directory and resource `.yy` (and `.gml` for scripts, shader source files for shaders, etc.), one new entry in `BBMOD.yyp/resources`, correct `parent.path` in the new resource `.yy`, and ordering updates in `BBMOD.resource_order`.
1. If IDE missed ordering or parent placement, apply the manual fix process below.

### Manual Workflow (Deterministic)

#### A) Create the resource files

1. Create a directory under the correct root by type: scripts in `BBMOD_GML/scripts/<ResourceName>/`, objects in `BBMOD_GML/objects/<ResourceName>/`, and shaders in `BBMOD_GML/shaders/<ResourceName>/`.
1. Add a resource `.yy` file with required keys.
1. Add companion files: script as `<ResourceName>.gml`, object event `.gml` files as needed, and shader files as `.vsh` and `.fsh`.

Minimal `.yy` patterns observed in this project:

- Script (`GMScript`): `$GMScript`, `%Name`, `name`, `parent { name, path }`, `resourceType:"GMScript"`, `resourceVersion:"2.0"`, `isDnD`, `isCompatibility`.
- Object (`GMObject`): `$GMObject`, `%Name`, `name`, `parent { name, path }`, `eventList`, `resourceType:"GMObject"`, `resourceVersion:"2.0"`, object flags.
- Shader (`GMShader`): `$GMShader`, `%Name`, `name`, `parent { name, path }`, `resourceType:"GMShader"`, `resourceVersion:"2.0"`, `type`.

#### B) Register in `BBMOD.yyp`

1. Add one object to `resources` using format `{"id":{"name":"<ResourceName>","path":"<relative/path/to/resource.yy>",},},`.
1. Keep path style exactly like existing entries: use forward slashes, make it relative to `BBMOD_GML/`, and include `.yy`.
1. Ensure `id.name` matches `%Name` and `name` in the resource `.yy`.

#### C) Place into folder metadata

1. In resource `.yy`, set `parent.path` to the target virtual folder path used by this project (for example `folders/BBMOD/1_Core/Scene/Lights.yy`).
1. If the folder path does not exist in `BBMOD.yyp/Folders`, add a new `GMFolder` item there first.
1. Also add that folder path to `BBMOD.resource_order/FolderOrderSettings` with a suitable `order` value.

#### D) Add ordering entry

1. Add one entry to `BBMOD.resource_order/ResourceOrderSettings` using format `{"name":"<ResourceName>","order":<int>,"path":"<relative/path/to/resource.yy>",},`.
1. Use an `order` value consistent with neighboring resources in the same logical group.

### Validation Checklist (Before Commit)

1. Resource files exist in the expected directory.
1. `BBMOD.yyp/resources` contains exactly one entry for the new resource path.
1. Resource `.yy` has correct `resourceType`, `name`, `%Name`, and `parent.path`.
1. `BBMOD.resource_order/ResourceOrderSettings` contains the new path.
1. If a new virtual folder was introduced, confirm `BBMOD.yyp/Folders` includes it, `BBMOD.resource_order/FolderOrderSettings` includes it, and resource `.yy/parent.path` points to it.
1. Open project in GameMaker IDE and confirm resource appears in the correct tree location, no auto-rewrite removes your entries, and project loads and compiles.

### Common Failure Modes

- Added `.yy` file but forgot `BBMOD.yyp/resources`: resource is invisible and unloaded.
- `id.name` mismatch with resource `%Name` and `name`: inconsistent metadata and potential IDE rewrite.
- Missing `ResourceOrderSettings` entry: unstable ordering and diff churn.
- Wrong `parent.path`: resource appears in wrong group or gets moved on IDE save.
- Added a new folder in `parent.path` without corresponding `Folders` and `FolderOrderSettings` entries.
