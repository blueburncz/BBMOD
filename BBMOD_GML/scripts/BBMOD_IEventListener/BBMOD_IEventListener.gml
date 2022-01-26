/// @func BBMOD_IEventListener()
///
/// @interface
///
/// @example
/// ```gml
/// function MyEventListener() : BBMOD_Class() constructor
/// {
///     implement(BBMOD_IEventListener);
///
///     on_event("test", function () {
///         show_debug_message("It is working!");
///     });
/// }
///
/// new MyEventListener().trigger_event("test"); // Prints "It is working!"
/// ```
function BBMOD_IEventListener()
{
	/// @var {ds_map<string, func[]>/undefined} Map of event listeners.
	/// @private
	Listeners = undefined;

	static _onEvent = function (_event, _listener) {
		gml_pragma("forceinline");
		if (is_method(_event))
		{
			_listener = _event;
			_event = __BBMOD_EV_ALL;
		}
		if (Listeners == undefined)
		{
			Listeners = ds_map_create();
		}
		if (!ds_map_exists(Listeners, _event))
		{
			Listeners[? _event] = [];
		}
		array_push(Listeners[? _event], _listener);
		return self;
	};

	/// @func on_event([_event, ]_listener)
	/// @desc Adds a listener for a specific event.
	/// @param {string} [_event] The event name. If not specified, then the
	/// listener is executed on every event.
	/// @param {func} _listener A function executed when the event occurs.
	/// Should take the event data as the first argument and the event name
	/// as the second argument.
	/// @return {BBMOD_EventListener} Returns `self`.
	/// @see BBMOD_IEventListener.off_event
	on_event = _onEvent;

	static _offEvent = function (_event) {
		gml_pragma("forceinline");
		if (Listeners == undefined)
		{
			return self;
		}
		if (_event != undefined)
		{
			ds_map_delete(Listeners, _event);
		}
		else
		{
			ds_map_destroy(Listeners);
		}
		return self;
	};

	/// @func off_event([_event])
	/// @desc Removes event listeners.
	/// @param {string} [_event] The name of the event for which should be the
	/// listener removed. If not specified, then listeners for all events are
	/// removed.
	/// @return {BBMOD_IEventListener} Returns `self`.
	/// @see BBMOD_IEventListener.on_event
	off_event = _offEvent;

	static _triggerEvent = function (_event, _data) {
		gml_pragma("forceinline");
		if (Listeners == undefined)
		{
			return self;
		}

		var _events, i;

		if (ds_map_exists(Listeners, _event))
		{
			_events = Listeners[? _event];
			i = 0;
			repeat (array_length(_events))
			{
				_events[i++](_data, _event);
			}
		}

		if (ds_map_exists(Listeners, __BBMOD_EV_ALL))
		{
			_events = Listeners[? __BBMOD_EV_ALL];
			i = 0;
			repeat (array_length(_events))
			{
				_events[i++](_data, _event);
			}
		}

		return self;
	};

	/// @func trigger_event(_event, _data)
	/// @desc Triggers an event in the event listener.
	/// @param {string} _event The event name.
	/// @param {any} _data The event data.
	/// @return {BBMOD_IEventListener} Returns `self`.
	trigger_event = _triggerEvent;

	array_push(__DestroyActions, function () {
		if (Listeners != undefined)
		{
			ds_map_destroy(Listeners);
		}
	});
}