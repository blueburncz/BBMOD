cutscene = new CCutscene();

cutscene.AddStage(new CStage(
	"Don't worry, you don't have to read all that ;D"
)).AddStage(new CStage(
	"Those signs are there just to showcase static batching."
)).AddStage(new CStage(
	"Static batch is a way of rendering non-moving objects in a single draw call."
)).AddStage(new CStage(
	"..."
)).AddStage(new CStage(
	"Pretty handy!"
));