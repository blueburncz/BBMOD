# Materials
BBMOD has a powerful material system. Setting up a completely custom material
is an advanced topic, outside of the scope of this quickstart guide. For the
starters, you can create a clone material
[BBMOD_MATERIAL_DEFAULT](./BBMOD_MATERIAL_DEFAULT.html) and change its base
texture:

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
