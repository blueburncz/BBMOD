/// @module Core

/// @func BBMOD_IEventListener()
///
/// @interface
///
/// @example
/// ```gml
/// function MyEventListener() constructor
/// {
///     BBMOD_IEventListener();
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
	/// @var {Struct}
	/// @private
	__listeners = {};

	static _onEvent = function (_event, _listener=undefined)
	{
		gml_pragma("forceinline");
		if (is_method(_event))
		{
			_listener = _event;
			_event = __BBMOD_EV_ALL;
		}
		__listeners ??= {};
		if (!variable_struct_exists(__listeners, _event))
		{
			__listeners[$ _event] = [];
		}
		array_push(__listeners[$ _event], _listener);
		return self;
	};

	/// @func on_event([_event, ]_listener)
	///
	/// @desc Adds a listener for a specific event.
	///
	/// @param {String} [_event] The event name. If `undefined`, then the
	/// listener is executed on every event.
	/// @param {Function} _listener A function executed when the event occurs.
	/// Should take the event data as the first argument and the event name
	/// as the second argument.
	///
	/// @return {Struct.BBMOD_IEventListener} Returns `self`.
	///
	/// @example
	/// ```gml
	/// function Button() constructor
	/// {
	///     BBMOD_IEventListener();
	/// }
	///
	/// var _button = new Button();
	///
	/// /// @desc This will be always executed, no matter the event type.
	/// _button.on_event(function (_data, _eventName) {
	///     show_debug_message("Got event " + string(_eventName) + "!");
	/// });
	///
	/// /// @desc This will be executed only on event "click".
	/// _button.on_event("click", function () {
	///     show_debug_message("The button was clicked!");
	/// });
	/// ```
	///
	/// @see BBMOD_IEventListener.off_event
	on_event = _onEvent;

	static _offEvent = function (_event=undefined)
	{
		gml_pragma("forceinline");
		if (__listeners == undefined)
		{
			return self;
		}
		if (_event != undefined)
		{
			variable_struct_remove(__listeners, _event);
		}
		else
		{
			__listeners = {};
		}
		return self;
	};

	/// @func off_event([_event])
	///
	/// @desc Removes event listeners.
	///
	/// @param {String} [_event] The name of the event for which should be the
	/// listener removed. If `undefined`, then listeners for all events are
	/// removed.
	///
	/// @return {Struct.BBMOD_IEventListener} Returns `self`.
	///
	/// @see BBMOD_IEventListener.on_event
	off_event = _offEvent;

	static _triggerEvent = function (_event, _data)
	{
		gml_pragma("forceinline");
		if (__listeners == undefined)
		{
			return self;
		}

		var _events, i;

		if (variable_struct_exists(__listeners, _event))
		{
			_events = __listeners[$ _event];
			i = 0;
			repeat (array_length(_events))
			{
				_events[i++](_data, _event);
			}
		}

		if (variable_struct_exists(__listeners, __BBMOD_EV_ALL))
		{
			_events = __listeners[$ __BBMOD_EV_ALL];
			i = 0;
			repeat (array_length(_events))
			{
				_events[i++](_data, _event);
			}
		}

		return self;
	};

	/// @func trigger_event(_event, _data)
	///
	/// @desc Triggers an event in the event listener.
	///
	/// @param {String} _event The event name.
	/// @param {Any} _data The event data.
	///
	/// @return {Struct.BBMOD_IEventListener} Returns `self`.
	trigger_event = _triggerEvent;
}
