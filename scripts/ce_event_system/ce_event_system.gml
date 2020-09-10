CE_PRAGMA_ONCE;

/// @macro {real} The number of the user event to be executed when a custom
/// event is triggered.
#macro CE_EV_BIND_CUSTOM 0

/// @var {any} The current event or `undefined`.
/// @private
global.__ce_event = undefined;

/// @var {any} Additonal data for the current event or `undefined`.
/// @private
global.__ce_event_data = undefined;

/// @var {any} The result of the event or `undefined`.
/// @private
global.__ce_event_result = undefined;

/// @func ce_event_return(_value)
/// @desc Returns a value from the triggered custom event.
/// @param {any} _value The value to return.
function ce_event_return(_value)
{
	gml_pragma("forceinline");
	global.__ce_event_result = _value;
}

/// @func ce_get_event()
/// @return {string/real} The id of the current event or `undefined`.
/// @note This script should be called only in the user event bound to
/// `CE_EV_BIND_CUSTOM`.
function ce_get_event()
{
	gml_pragma("forceinline");
	return global.__ce_event;
}

/// @func ce_get_event_data()
/// @return {any} Additional data of the current event.
/// @note This script should be called only in the user event bound to
/// `CE_EV_BIND_CUSTOM`.
function ce_get_event_data()
{
	gml_pragma("forceinline");
	return global.__ce_event_data;
}

/// @func ce_get_event_retval()
/// @return {any} The value returned from a custom event. This is by default
/// `undefined`.
function ce_get_event_retval()
{
	gml_pragma("forceinline");
	return global.__ce_event_result;
}

/// @func ce_trigger_event(_event[, _data[, _global]])
/// @desc Triggers the custom event.
/// @param {any} _event The id of the event.
/// @param {any} [_data] Additional event data.
/// @param {bool} [_global] True to trigger the event within all instances,
/// false to only within the calling instance. Defaults to false.
/// @return {any} The event result.
/// @see ce_event_return
function ce_trigger_event(_event)
{
	var _data = (argument_count > 1) ? argument[1] : undefined;
	var _global = (argument_count > 2) ? argument[2] : false;

	global.__ce_event = _event;
	global.__ce_event_data = _data;
	global.__ce_event_result = undefined;

	if (_global)
	{
		with (all)
		{
			event_user(CE_EV_BIND_CUSTOM);
		}
	}
	else
	{
		event_user(CE_EV_BIND_CUSTOM);
	}

	return global.__ce_event_result;
}

/// @func ce_trigger_event_global(_event[, _data])
/// @desc Triggers the custom event within all instances.
/// @param {string/real} _event The id of the event.
/// @param {any} [_data] Additional event data.
/// @return {any} The event result.
/// @see ce_event_return
function ce_trigger_event_global(_event)
{
	gml_pragma("forceinline");
	return ce_trigger_event(_event, (argument_count > 1) ? argument[1] : undefined, true);
}