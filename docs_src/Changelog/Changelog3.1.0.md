# Changelog 3.1.0

## GML API:
**Core module:**
* Added new struct `BBMOD_Class` which is a base struct for BBMOD structs that require more OOP functionality.
* Moved methods `on_event`, `off_event` and `trigger_event` of `BBMOD_AnimationPlayer` into a new interface `BBMOD_IEventListener`.
* Struct `BBMOD_AnimationPlayer` now implements interface `BBMOD_EventListener`.
* Listeners passed to method `BBMOD_EventListener.on_event` can now take the event name as the second argument.
* The event name argument of method `BBMOD_EventListener.on_event` is now optional. If it is not specified, then the listener is executed on every event.

**State machine module:**
* Added a new module - State machine.
* Added new structs `BBMOD_StateMachine` and `BBMOD_State`, which implement a state machine.
* Added new structs `BBMOD_AnimationStateMachine` and `BBMOD_AnimationState`, which implement a state machine that controls animation playback.
