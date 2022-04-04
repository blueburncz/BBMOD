# Materials
BBMOD has a powerful material system. Setting up a completely custom material
is an advanced topic, outside of the scope of this quickstart guide. For the
starters, you can create a clone of one of these materials:

  1. [BBMOD_MATERIAL_DEFAULT](./BBMOD_MATERIAL_DEFAULT.html) for static models,
  2. [BBMOD_MATERIAL_DEFAULT_ANIMATED](./BBMOD_MATERIAL_DEFAULT_ANIMATED.html) for animated models with bones,

and change its base texture:

```gml
matSwordHilt = BBMOD_MATERIAL_DEFAULT.clone();
matSwordHilt.BaseOpacity = sprite_get_texture(SprSwordHilt, 0);

matSwordBlade = BBMOD_MATERIAL_DEFAULT.clone();
matSwordBlade.BaseOpacity = sprite_get_texture(SprSwordBlade, 0);
```

You can use method [set_material](./BBMOD_Model.set_material.html) to assign
materials to models:

```gml
modSword.set_material("Hilt", matSwordHilt)
    .set_material("Blade", matSwordBlade);
```

Make sure to always use a shader that is compatible with your model (i.e. you
cannot use `BBMOD_MATERIAL_DEFAULT_ANIMATED` for a model that does not have
bones). For more info on materials, see the documentation of
[BBMOD_BaseMaterial](./BBMOD_BaseMaterial.html).

**Note:** If you are interested in using PBR materials, see the
[PBR module](./PBRModule.html) section for more info on PBR materials in BBMOD.
