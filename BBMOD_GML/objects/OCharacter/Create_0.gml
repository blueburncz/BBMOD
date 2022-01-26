event_inherited();

modCharacter = global.resourceManager.load(
	"Data/Assets/Character/Character.bbmod",
	undefined,
	method(self, function (_err, _model) {
		if (!_err)
		{
			_model.freeze();
		}
	}));

// Maximum hitpoints.
hpMax = 100;

// Current number of hitpoints. Character dies if reaches 0.
hp = hpMax;

// A function that processes incoming damage. By default it simply subtracts
// the damage from the character's `hp` and sets `hurt` to 1.
ReceiveDamage = function (_damage) {
	hp -= _damage;
	hurt = 1.0;
};

// Controls the screen flash effect for the player and model flash for zombies.
hurt = 0.0;

// The character's speed when they are walking.
speedWalk = 0.225;

// The direction of the character's body. This is used to slowly turn it towards
// the look direction.
directionBody = direction;

// A matrix used when rendering the character's body.
matrixBody = matrix_build_identity();

////////////////////////////////////////////////////////////////////////////////
// Animation player
animationPlayer = new BBMOD_AnimationPlayer(modCharacter);

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