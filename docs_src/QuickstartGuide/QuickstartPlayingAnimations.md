# Playing animations
To play loaded animations, you first need to create an AnimationPlayer structure
using script [bbmod_animation_player_create](./bbmod_animation_player_create.html).
This scripts takes as a parameter a model which it will be animating.

```gml
/// @desc Create
animation_player = bbmod_animation_player_create(mod_character);
```

If you have multiple instances which render the same model, they still each need
their own AnimationPlayer, but the model can be shared between them.

To tell an AnimationPlayer to start playing an animation, use the script
[bbmod_play](./bbmod_play.html). The animation update itself is performed in a script
[bbmod_animation_player_update](./bbmod_animation_player_update.html), so do not
forget to call that every frame for each AnimationPlayer structure!

```gml
/// @desc Create
anim_current = BBMOD_NONE;

/// @desc Step
var _anim_last = anim_current;

anim_current = (speed > 0) ? anim_walk : anim_idle;

if (anim_current != _anim_last)
{
    bbmod_play(anim_current, true);
}

bbmod_animation_player_update(animation_player, current_time * 0.001);
```

Also do not forget to destroy the AnimationPlayer when the instance is destroyed,
otherwise you will get memory leaks!

```gml
/// @desc Clean Up
bbmod_animation_player_destroy(animation_player);
```
