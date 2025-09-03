ui.SetPosition(8, 8)
	.Slider("slider-walk-weight", layerWalk.Weight,
	{
		Label: "Walk Weight",
		OnChange: method(layerWalk, function (_value) { Weight = _value; }),
	})
	.Newline()
	.Slider("slider-walk-speed", layerWalk.PlaybackSpeed,
	{
		Label: "Walk Speed",
		OnChange: method(layerWalk, function (_value) { PlaybackSpeed = _value; }),
		Min: -2,
		Max: 2,
	})
	.Newline()
	.Slider("slider-shoot-weight", layerShoot.Weight,
	{
		Label: "Shoot Weight",
		OnChange: method(layerShoot, function (_value) { Weight = _value; }),
	})
	.Newline()
	.Slider("slider-jump-weight", layerJump.Weight,
	{
		Label: "Jump Weight",
		OnChange: method(layerJump, function (_value) { Weight = _value; }),
	})
	.Newline()
	.Slider("slider-torso-angle", torsoAngle,
	{
		Label: "Torso Angle",
		OnChange: method(self, function (_value)
		{
			torsoAngle = _value;
			layerTorso.set_node_rotation(1, new BBMOD_Quaternion().FromAxisAngle(BBMOD_VEC3_RIGHT,
				torsoAngle));
		}),
		Min: -60,
		Max: +60,
	});
