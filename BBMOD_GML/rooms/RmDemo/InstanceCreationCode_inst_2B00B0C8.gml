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
));