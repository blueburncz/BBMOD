event_inherited();

// The character's speed when they're walking.
speedWalk = 0.4;

// The direction of the character's body. This is used to slowly turn it towards
// the look direction.
directionBody = direction;

// A matrix used when rendering the character's body.
matrixBody = matrix_build_identity();

// If true then the character is dead.
dead = false;

////////////////////////////////////////////////////////////////////////////////
// Animation player
animationPlayer = new BBMOD_AnimationPlayer(OMain.modCharacter);

animationPlayer.on_event("Footstep", method(self, function () {
	// Play a random footstep sound at the character's position when a "Footstep"
	// event is triggered.
	var _sound = choose(
		SndFootstep0,
		SndFootstep1,
		SndFootstep2,
		SndFootstep3,
		SndFootstep4,
		SndFootstep5,
		SndFootstep6,
		SndFootstep7,
		SndFootstep8,
		SndFootstep9,
	);
	audio_play_sound_at(_sound, x, y, z, 1, 200, 1, false, 1);
}));

animationStateMachine = new BBMOD_AnimationStateMachine(animationPlayer);