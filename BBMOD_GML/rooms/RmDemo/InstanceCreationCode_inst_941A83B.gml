cutscene = new CCutscene();

cutscene.AddStage(new CStage(
	"See these zombies?",
)).AddStage(new CStage(
	"There can be quite a lot of them - thanks to the new animation" 
	+ " optimization levels!",
));

var _stage = new CStage(
	"Lets spawn some more...",
);
_stage.OnEnter = function () {
	with (OZombieSpawner)
	{
		active = true;
	}
};
cutscene.AddStage(_stage);

_stage = new CStage(
	"Now get ready, because they are after you!",
);
_stage.OnLeave = function () {
	with (OZombie)
	{
		active = true;
	}
};
cutscene.AddStage(_stage);