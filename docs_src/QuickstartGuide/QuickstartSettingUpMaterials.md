# Setting up materials
After you have your models loaded, you will want to create materials that they
will use when they are rendered. To create a new material, use the script
[bbmod_material_create](./bbmod_material_create.html):

```gml
mat_character_body = bbmod_material_create(
	BBMOD_ShDefaultAnimated, sprite_get_texture(SprBody, 0));

mat_character_head = bbmod_material_create(
    BBMOD_ShDefaultAnimated, sprite_get_texture(SprHead, 0));
```

In this example we have only defined the materials' shader and diffuse texture,
but the material structure offers unlimited possibilities! If you would like to
specify more advanced properties, like the render path, blend mode or culling
mode, see [BBMOD_EMaterial](./BBMOD_EMaterial.html).

**Note:** BBMOD comes with two simple shaders - `BBMOD_ShDefault` for non-animated
models and `BBMOD_ShDefaultAnimated` for animated models. They serve only as a
reference and you will likely need to create your own shaders to achieve desired
look of your game or to fit your rendering pipeline!
