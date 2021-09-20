event_inherited();

speedWalk = 0.4;

dead = false;

directionBody = direction;

animationPlayer = new BBMOD_AnimationPlayer(OMain.modCharacter);

animationPlayer.on_event("Footstep", method(self, function () {
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