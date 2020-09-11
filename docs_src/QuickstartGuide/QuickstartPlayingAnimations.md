# Playing animations
To play loaded animations, you first need to create a [BBMOD_AnimationPlayer](./BBMOD_AnimationPlayer.html).
This takes a model which it will be animating as the first argument.

```gml
/// @desc Create
animation_player = new BBMOD_AnimationPlayer(mod_character);
```

If you have multiple instances which render the same model, they still each need
their own `BBMOD_AnimationPlayer`, but the model can be shared between them.

To tell a `BBMOD_AnimationPlayer` to start playing an animation, use its method
[play](./BBMOD_AnimationPlayer.play.html). The animation update itself is performed in method
[update](./BBMOD_AnimationPlayer.update.html), so do not
forget to call that every frame for each `BBMOD_AnimationPlayer`!

```gml
/// @desc Create
anim_current = undefined;

/// @desc Step
var _anim_last = anim_current;

anim_current = (speed > 0) ? anim_walk : anim_idle;

if (anim_current != _anim_last)
{
    animation_player.play(anim_current, true);
}

animation_player.update();
```

Also do not forget to destroy the `BBMOD_AnimationPlayer` when the instance is destroyed,
otherwise you will get memory leaks!

```gml
/// @desc Clean Up
animation_player.destroy();
delete animation_player;
```
