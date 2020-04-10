# Rendering models
When you have all your models, materials and animations prepared, you can render
them on screen using the script [bbmod_render](./bbmod_render.html). This takes
as parameters a model to render, an array of materials - each corresponding to
the model's material slots, and the model's transformation (for animated models
only).

Model's material slots can be found in its `_log.txt` file, which is created
during the model conversion. For example my `Character_log.txt` file contained

```txt
Materials:
==========
0: head
1: body
```

so, I have to put my `mat_character_head` as the first and `mat_character_body`
as the second material into the material array.

Model's transformation can be obtained from an AnimationPlayer using the script
[bbmod_get_transform](./bbmod_get_transform.html).

It is also very important that every block of code that renders models starts and
ends with the script [bbmod_material_reset](./bbmod_material_reset.html)! Not
calling this script before and after you render models can result into unexpected
behavior.

```gml
/// @desc Draw
var _materials = [
	mat_character_head,
	mat_character_body
];

var _transform = bbmod_get_transform(animation_player);

bbmod_material_reset();
bbmod_render(mod_character, _materials, _transform);
bbmod_material_reset();
```
