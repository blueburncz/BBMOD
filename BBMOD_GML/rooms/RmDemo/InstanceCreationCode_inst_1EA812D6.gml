cutscene = new CCutscene();

cutscene.AddStage(new CStage(
	"Found it!"
));

var _stage = new CStage(
	"Here's more zombies as your reward :P"
);
_stage.OnExit = function () {
	repeat (10)
	{
		var _zombie = instance_create_depth(
			random(room_width), random(room_height), 0, OZombie);
		_zombie.active = true;
	}
};

cutscene.AddStage(_stage);