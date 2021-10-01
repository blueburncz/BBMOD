# Changelog 3.1.0

## GML API:
**Core module:**
* Listeners passed to method `BBMOD_AnimationPlayer.on_event` can now take the event name as the second argument.
* The event name argument of method `BBMOD_AnimationPlayer.on_event` is now optional. If it is not specified, then the listener is executed on every event.

**State machine module:**
* Added a new module - State machine.
* Added new structs `BBMOD_StateMachine` and `BBMOD_State` which implement a state machine.
* Added new structs `BBMOD_AnimationStateMachine` and `BBMOD_AnimationState` which implement a state machine that controls animation playback.
