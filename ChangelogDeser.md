# ChangelogDeser

## Texture references and serialization

* Added new properties `*Sprite`, `*Subimage`, `*Owned`, and `*Format` to texture references throughout materials, lighting, post-processing, terrain, and rendering APIs. Sprite sources take precedence over raw texture pointers, and `*Subimage` selects the sprite frame used for rendering.
* Added new property `SpriteOwned` to `BBMOD_ReflectionProbe`, which controls whether the probe deletes its sprite when the sprite is replaced or the probe is destroyed.
* Added new property `SpriteOwned` to `BBMOD_LensFlareElement`, which controls whether the element deletes its sprite when the element is destroyed.
* The constructor of `BBMOD_ReflectionProbe` now accepts `_spriteOwned`, and `set_sprite()` now accepts `_owned` to control sprite ownership.
* The constructor of `BBMOD_LensFlareElement` now accepts `_spriteOwned` to control sprite ownership.
* Added new method `destroy()` to `BBMOD_Light`, which implements `BBMOD_IDestructible` for light instances.
* Added new method `destroy()` to `BBMOD_ReflectionProbe`, `BBMOD_LensFlare`, `BBMOD_LensFlareElement`, and `BBMOD_TerrainLayer`, which releases owned sprites and child resources.
* Destructors of materials, terrain, and image-based lights now release owned texture sprites, invoke inherited destructors where applicable, and cause `BBMOD_Terrain` to destroy each defined `BBMOD_TerrainLayer`. A layer can be assigned to only one terrain.
* Added new texture reference serialization and deserialization for asset-backed sprites, resource-manager paths, and runtime textures. Runtime textures are captured as raw RGBA8 data and reconstructed as owned sprites.
* Property `__Textures` of material serialization now preserves sprite subimages, including cached `sprite://` references, when texture references are expanded during deserialization.
* Added new texture reference properties to `BBMOD_Material`, `BBMOD_DefaultMaterial`, and `BBMOD_DefaultLightmapMaterial`, which are included in material serialization and deserialization.
* Added new sprite, subimage, ownership, and capture-format properties to `BBMOD_TerrainInfo`, `BBMOD_Terrain`, and `BBMOD_TerrainLayer` for terrain splatmap, colormap, and layer textures.
