// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function cm_collider_activate_triggers(collider, object, mask = collider[CM.MASK])
{
	if (cm_check(object, collider, mask))
	{
		if (__cmi_is_container(object))
		{
			var collisions = collider[CM.COLLISIONS];
			var num = array_length(collisions);
			for (var i = 0; i < num; ++i)
			{
				//Perform the collision function of the trigger
				var colfunc = cm_custom_parameter_get(collisions[i]);
				if (is_callable(colfunc))
				{
					colfunc();
				}
			}
		}
		else
		{
			//Perform the collision function of the trigger
			var colfunc = cm_custom_parameter_get(object);
			if (is_callable(colfunc))
			{
				colfunc();
			}
		}
	}
}