# Animation events
Using [BBMOD_AnimationPlayer.OnEvent](./BBMOD_AnimationPlayer.OnEvent.html) you can bind a function that will be executed when an even occurs during the animation playback. An example of such event is [BBMOD_EV_ANIMATION_END](./BBMOD_EV_ANIMATION_END.html), which is triggered at the animation end. This can be used for example to reset the animation to "idle" after an "attack" animation finishes playing:

```gml
animation_player.OnEvent = function (_event, _animation) {
    switch (_event)
    {
    case BBMOD_EV_ANIMATION_END:
        if (_animation == anim_attack)
        {
            anim_current = anim_idle;
        }
        break;

    default:
        break;
    }
};
```
