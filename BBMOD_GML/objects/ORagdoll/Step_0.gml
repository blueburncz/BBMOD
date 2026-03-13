if (id == instance_find(ORagdoll, 0))
{
	UI.Update();
}

// Update animation player (only when not in ragdoll)
if (ragdoll == undefined || !ragdoll.is_active())
{
	animationPlayer.update(delta_time);
}

// Toggle ragdoll with SPACE key
if (keyboard_check_pressed(vk_space) && ragdoll != undefined)
{
	if (ragdoll.is_active())
	{
		// Switch from ragdoll to animation mode
		ragdoll.set_active(false);
	}
	else
	{
		// Switch from animation to ragdoll mode
		// Sync ragdoll to match current animation pose at current world position
		var _worldMat = new BBMOD_Matrix().TranslateSelf(x, y, z);
		ragdoll.sync_to_animation(animationPlayer, _worldMat);
		ragdoll.set_active(true);
	}
}
