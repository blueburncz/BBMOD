cutscene = new CCutscene();

cutscene.AddStage(new CStage(
	"Don't worry, you don't have to read all that ;D"
)).AddStage(new CStage(
	"Those signs are there just to showcase static batching."
)).AddStage(new CStage(
	"Static batch is a way of rendering non-moving objects in a single draw call."
)).AddStage(new CStage(
	"You can press F1 to enable the debug overlay and see that there's much less"
	+ " draw calls than instances!"
));