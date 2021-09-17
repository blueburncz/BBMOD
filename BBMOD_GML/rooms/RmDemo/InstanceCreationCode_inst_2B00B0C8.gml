cutscene = new CCutscene();

cutscene.AddStage(new CStage(
	"You can now aim using the Right Mouse Button and shoot with the Left Mouse Button..."
)).AddStage(new CStage(
	"but you have probably found that out by this time :)"
)).AddStage(new CStage(
	"See how the character's arm points where you aim?"
)).AddStage(new CStage(
	"Bones of animated objects can be modified in code, which means that you can"
	+ " use techniques like inverse kinematics!"
)).AddStage(new CStage(
	"Oh and by the way..."
)).AddStage(new CStage(
	"Each shell that comes out of the gun is rendered using a dynamic batch."
)).AddStage(new CStage(
	"That means that multiple instances are rendered in a single draw call!"
)).AddStage(new CStage(
	"All these signs are also rendered using a batch - a static batch!"
)).AddStage(new CStage(
	"Static batches are also used to render multiple models at once, but those"
	+ " cannot be moved."
));