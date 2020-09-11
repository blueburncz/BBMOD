# Setting up materials
After you have your models loaded, you will want to create materials that they
will use when they are rendered. Materials are defined using [BBMOD_Material](./BBMOD_Material.html) structs. Each material requires a shader that it will use.
BBMOD comes with three shaders:

  * `BBMOD_ShDefault` for regular static models,
  * `BBMOD_ShDefaultAnimated` for animated models with bones,
  * `BBMOD_ShDefaultBatched` for dynamically batched models (see [BBMOD_DynamicBatch](./BBMOD_DynamicBatch.html) for more info on dynamic batching).

You always have to choose a shader that is compatible with the model (i.e. you can't use `BBMOD_ShDefaultAnimated` for a model that doesn't have bones).

```gml
mat_character_body = new BBMOD_Material(BBMOD_ShDefaultAnimated);
mat_character_body.BaseOpacity = sprite_get_texture(SprBody, 0);

mat_character_head = new BBMOD_Material(BBMOD_ShDefaultAnimated);
mat_character_head.BaseOpacity = sprite_get_texture(SprHead, 0);
```

In this example we have only defined the materials' shader and base texture,
but the material struct has a full support for a metallic PBR workflow! See [BBMOD_Material](./BBMOD_Material.html) for more information on materials.

**Note:** If you don't want to use PBR, you can create your own variations of the shaders.