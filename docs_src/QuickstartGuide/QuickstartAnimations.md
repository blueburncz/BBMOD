# Animations
To play animations, you first need to load your animated character like usually:

```gml
/// @desc Create event
modCharacter = new BBMOD_Model("Data/Character.bbmod");
```

and assign it materials that support animations:

```gml
matCharacter = BBMOD_MATERIAL_DEFAULT.clone();
matCharacter.BaseOpacity = sprite_get_texture(SprCharacter, 0);
modCharacter.set_material("Material", matCharacter);
```

Then you need to create a [BBMOD_AnimationPlayer](./BBMOD_AnimationPlayer.html)
for the model:

```gml
animationPlayer = new BBMOD_AnimationPlayer(modCharacter);
```

To load the actual animation data, use struct
[BBMOD_Animation](./BBMOD_Animation.html):

```gml
animIdle = new BBMOD_Animation("Data/Character_Idle.bbanim");
animWalk = new BBMOD_Animation("Data/Character_Walk.bbanim");
```


`BBMOD_AnimationPlayer` has a method [play](./BBMOD_AnimationPlayer.play.html)
which starts playing an animation from the beginning. When dealing with changing
animations, it is a lot easier to use the method
[change](./BBMOD_AnimationPlayer.change.html), which keeps track of which
animation it was playing and every time you pass it a different animation it
automatically transitions into it. The animation update itself is performed in
method [update](./BBMOD_AnimationPlayer.update.html), so do not forget to call
that every frame for each animation player!

```gml
/// @desc Step event
var _animation = (speed > 0) ? animWalk : animIdle;
animationPlayer.change(_animation, true);
animationPlayer.update(delta_time);
```

To render the animated model, use method [submit](./BBMOD_AnimationPlayer.submit.html)
of the animation player:

```gml
/// @desc Draw event
bbmod_material_reset();
matrix_set(matrix_world, matrix_build(x, y, z, 0, 0, direction, 1, 1, 1));
animationPlayer.submit();
matrix_set(matrix_world, matrix_build_identity());
bbmod_material_reset();
```

Also do not forget to destroy the animation player before it gets out of scope,
otherwise you will get memory leaks!

```gml
/// @desc Clean Up event
animationPlayer.destroy();
```
