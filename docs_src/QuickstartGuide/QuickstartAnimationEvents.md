# Animation events
BBMOD utilizes the [CE Event System](https://github.com/slagtand-org/ce-event-system)
library to trigger event [BBMOD_EV_ANIMATION_END](./BBMOD_EV_ANIMATION_END.html) at
the animation end. This can be used for example to reset the animation to "idle" after
an "attack" animation finishes playing:

```gml
/// @desc User Event 0
var _event = ce_get_event()

switch (_event)
{
case BBMOD_EV_ANIMATION_END:
    var _animation = ce_get_event_data();
    if (_animation == anim_attack)
    {
        anim_current = anim_idle;
    }
    break;

default:
    break;
}
```
