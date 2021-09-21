cutscene = new CCutscene();

cutscene.AddStage(new CStage(
	"Using a dynamic batch, you can render multiple instances of moving objects"
	+ " in a single draw call."
)).AddStage(new CStage(
	"Like these gun shells!"
)).AddStage(new CStage(
	"You can press F1 to enable the debug overlay and see that there's much less"
	+ " draw calls than instances!"
));