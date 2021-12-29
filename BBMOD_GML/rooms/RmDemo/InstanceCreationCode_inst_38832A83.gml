cutscene = new CCutscene();

var _stage = new CStage(
	"Hello, welcome to the BBMOD 3.1.6 demo! You can use the E key to interact"
	+ " with objects, like this sign."
);
cutscene.AddStage(_stage);

_stage = new CStage(
	"Use keys WSAD and the mouse to run and look around."
);
cutscene.AddStage(_stage);

_stage = new CStage(
	"You can also jump and slow walk using the Space and Shift keys respectively."
);
cutscene.AddStage(_stage);

_stage = new CStage(
	"Go to the next sign to find out more!"
);
cutscene.AddStage(_stage);

cutscene.Start();