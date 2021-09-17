# Animation events
Using [BBMOD_AnimationPlayer.on_event](./BBMOD_AnimationPlayer.on_event.html)
you can add functions that will be executed when an event occurs during the
animation playback. The build-in animation events are:

* [BBMOD_EV_ANIMATION_END](./BBMOD_EV_ANIMATION_END.html) triggered when an animation reaches its end,
* [BBMOD_EV_ANIMATION_LOOP](./BBMOD_EV_ANIMATION_LOOP.html) triggered when an animation loops at its end and starts playing from the beginning
* [BBMOD_EV_ANIMATION_CHANGE](./BBMOD_EV_ANIMATION_CHANGE.html) triggered when an animation player starts playing a different animation.

You can also add custom animation events to a specific frame of an animation
using method [add_event](./BBMOD_Animation.add_event.html).

```gml
animAttack = new BBMOD_Animation("Data/Character_Attack.bbanim");
animRun = new BBMOD_Animation("Data/Character_Run.bbanim");
animRun.add_event(0, "Footstep")
    .add_event(16, "Footstep");
animationPlayer.on_event(BBMOD_EV_ANIMATION_END, method(self, function (_animation) {
    if (_animation == animAttack)
    {
        // Do damage to surrounding enemies...
    }
})).on_event("Footstep", method(self, function () {
    // Play footstep sound...
}));