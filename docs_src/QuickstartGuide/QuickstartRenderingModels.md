# Rendering models
> Before you render anything on screen, make sure that you are calling function [bbmod_set_camera_position](./bbmod_set_camera_position.html) every frame. You can put this into a Step event or a Draw event for example, but it must be called before you render anything. This is required for proper functioning of the PBR shaders!

When you have all your models, materials and animations prepared, you can render them on screen using method [render](./BBMOD_Model.render.html). This takes an array of materials - each corresponding to the model's material slots, and the model's transformation (for animated models only).

Model's material slots can be found in its `_log.txt` file, which is created during the model conversion. For example my `Character_log.txt` file contained

```txt
Materials:
==========
0: head
1: body
```

so, I have to put my `mat_character_head` as the first and `mat_character_body`
as the second material into the material array.

Model's transformation can be obtained from an `BBMOD_AnimationPlayer` using its method
[get_transform](./BBMOD_AnimationPlayer.get_transform.html).

> It is also very important that every block of code that renders models starts and
ends with the script [bbmod_material_reset](./bbmod_material_reset.html)! Not
calling this script before and after you render models can result into unexpected
behavior.

```gml
/// @desc Create
camera = camera_create();
camera_set_proj_mat(camera, matrix_build_projection_perspective_fov(...));

/// @desc Step
camera_set_view_mat(camera, matrix_build_lookat(x, y, z, ...));
bbmod_set_camera_position(x, y, z);

/// @desc Draw
camera_apply(camera);
bbmod_material_reset();
mod_character.render(
	[mat_character_head, mat_character_body],
	animation_player.get_transform());
bbmod_material_reset();
```
