# ChangelogDeser

## General serialization

* Added method `ToBuffer(_buffer)` to `BBMOD_Color`, which writes the color channels into a buffer.
* Added method `FromBuffer(_buffer)` to `BBMOD_Color`, which loads color channels from a buffer.

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

## Lens flares serialization

* Struct `BBMOD_LensFlare` now extends `BBMOD_Resource` and supports binary `from_buffer()`, `to_buffer()`, `from_file()`, and `to_file()` methods.
* Added properties `SpritePath` and `SpriteSha1` to `BBMOD_LensFlareElement` for external sprite-file references.
* Added methods `to_buffer(_buffer)` and `from_buffer(_buffer)` to `BBMOD_LensFlareElement` for serializing and deserializing element properties and sprite sources.
* Added binary `.bbflare` resources for saving and loading lens flare compositions, including scalar properties, ordered elements, native element constructors, and asset, external-file, and embedded RGBA8 sprite references.
* `.bbflare` resources are now supported by `BBMOD_ResourceManager` and restore owned sprites for external and embedded sources while asset-backed sprites remain borrowed.

## Post-processing serialization

* Struct `BBMOD_PostProcessor` now extends `BBMOD_Resource` and supports binary `from_buffer()`, `to_buffer()`, `from_file()`, and `to_file()` methods.
* Added methods `to_buffer(_buffer)` and `from_buffer(_buffer)` to post-process effects for serializing authored fields and shared `Enabled` state; runtime surfaces, shader handles, and effect caches are rebuilt or excluded.
* Added binary `.bbpost` resources for saving and loading post-processing configuration, legacy properties, texture references, and ordered effects.
* `BBMOD_ResourceManager` now supports `.bbpost` resources for loading post-processing effects.
