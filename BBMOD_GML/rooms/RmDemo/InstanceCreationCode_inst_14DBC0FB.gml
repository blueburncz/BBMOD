cutscene = new CCutscene();

cutscene.AddStage(new CStage(
	"You may have noticed that each footstep makes a sound exactly when the foot"
	+ " meets the ground."
)).AddStage(new CStage(
	"This is thanks to custom animation events triggered at specific frames!"
)).AddStage(new CStage(
	"We are using them here for the walking and running animations, as well as for"
	+ " picking up items."
)).AddStage(new CStage(
	"See that gun over there?"
)).AddStage(new CStage(
	"Go pick it up using the E key!"
)).AddStage(new CStage(
	"In the middle of the pick-up animation there is another custom event triggered."
)).AddStage(new CStage(
	"This time it is used to put the gun into the players hands."
));