if (id != instance_find(ORagdoll, 0)) exit;

var _char = self;
UI.SetPosition(8, 8);

for (var i = 0; i < array_length(Ragdoll); ++i)
{
	var _ragdollPart = Ragdoll[i];

	UI.Button(_ragdollPart.Expand ? "-" : "+",
		{
			OnClick: method(_ragdollPart, function ()
			{
				Expand = !Expand;
			}),
		})
		.Text(" " + _ragdollPart.Name)
		.Newline();

	if (!_ragdollPart.Expand)
	{
		continue;
	}

	UI.Input(_ragdollPart.Name + "-bone-name", (_ragdollPart.Bone != undefined) ? _ragdollPart.Bone.Name : "",
		{
			Label: "Bone",
			OnChange: method({ Char: _char, Part: _ragdollPart }, function (_name)
			{
				Part.Bone = Char.TryGetBone(_name);
			}),
		})
		.Newline();

	// Shape
	UI.Input(_ragdollPart.Name + "-shape-type", GetPhysicsShapeName(_ragdollPart.Type),
		{
			Label: "Physics shape",
			OnChange: method(_ragdollPart, function (_type)
			{
				Type = GetPhysicsShapeValue(_type);
			}),
		})
		.Newline();

	UI.Input(_ragdollPart.Name + "-offset-x", _ragdollPart.Offset.X,
		{
			Width: 200 / 3,
			OnChange: method(_ragdollPart.Offset, function (_x)
			{
				X = _x;
			}),
		})
		.Input(_ragdollPart.Name + "-offset-y", _ragdollPart.Offset.Y,
		{
			Width: 200 / 3,
			OnChange: method(_ragdollPart.Offset, function (_y)
			{
				Y = _y;
			}),
		})
		.Input(_ragdollPart.Name + "-offset-z", _ragdollPart.Offset.Z,
		{
			Label: "Offset",
			Width: 200 / 3,
			OnChange: method(_ragdollPart.Offset, function (_z)
			{
				Z = _z;
			}),
		})
		.Newline();

	UI.Input(_ragdollPart.Name + "-size-x", _ragdollPart.Size.X,
		{
			Width: 200 / 3,
			OnChange: method(_ragdollPart.Size, function (_x)
			{
				X = _x;
			}),
		})
		.Input(_ragdollPart.Name + "-size-y", _ragdollPart.Size.Y,
		{
			Width: 200 / 3,
			OnChange: method(_ragdollPart.Size, function (_y)
			{
				Y = _y;
			}),
		})
		.Input(_ragdollPart.Name + "-size-z", _ragdollPart.Size.Z,
		{
			Label: "Size",
			Width: 200 / 3,
			OnChange: method(_ragdollPart.Size, function (_z)
			{
				Z = _z;
			}),
		})
		.Newline();

	// Joint
	UI.Input(_ragdollPart.Name + "-connected-to-bone-name", (_ragdollPart.ConnectedToBone != undefined) ? _ragdollPart
			.ConnectedToBone.Name : "",
			{
				Label: "Connected to bone",
				OnChange: method({ Char: _char, Part: _ragdollPart }, function (_name)
				{
					if (Part.Bone == undefined || Part.Bone.Name != _name)
					{
						Part.ConnectedToBone = Char.TryGetBone(_name);
					}
				}),
			})
		.Newline();

	if (_ragdollPart.ConnectedToBone != undefined)
	{
		UI.Input(_ragdollPart.Name + "-lower-limit-x", _ragdollPart.LowerLimit.X,
			{
				Width: 200 / 3,
				OnChange: method(_ragdollPart.LowerLimit, function (_x)
				{
					X = _x;
				}),
			})
			.Input(_ragdollPart.Name + "-lower-limit-y", _ragdollPart.LowerLimit.Y,
			{
				Width: 200 / 3,
				OnChange: method(_ragdollPart.LowerLimit, function (_y)
				{
					Y = _y;
				}),
			})
			.Input(_ragdollPart.Name + "-lower-limit-z", _ragdollPart.LowerLimit.Z,
			{
				Label: "Lower limit",
				Width: 200 / 3,
				OnChange: method(_ragdollPart.LowerLimit, function (_z)
				{
					Z = _z;
				}),
			})
			.Newline();

		UI.Input(_ragdollPart.Name + "-upper-limit-x", _ragdollPart.UpperLimit.X,
			{
				Width: 200 / 3,
				OnChange: method(_ragdollPart.UpperLimit, function (_x)
				{
					X = _x;
				}),
			})
			.Input(_ragdollPart.Name + "-upper-limit-y", _ragdollPart.UpperLimit.Y,
			{
				Width: 200 / 3,
				OnChange: method(_ragdollPart.UpperLimit, function (_y)
				{
					Y = _y;
				}),
			})
			.Input(_ragdollPart.Name + "-upper-limit-z", _ragdollPart.UpperLimit.Z,
			{
				Label: "Upper limit",
				Width: 200 / 3,
				OnChange: method(_ragdollPart.UpperLimit, function (_z)
				{
					Z = _z;
				}),
			})
			.Newline();
	}
}

UI.Button("Create",
	{
		OnClick: method(_char, function ()
		{
			CreateRagdoll();
			OMain.physicsPause = true;
		}),
	})
	.Move(8)
	.Button("Play/Pause",
	{
		OnClick: function ()
		{
			OMain.physicsPause = !OMain.physicsPause;
		},
	})
	.Newline();

// Show instructions and current mode
UI.Newline();
if (ragdoll != undefined)
{
	var _mode = ragdoll.is_active() ? "RAGDOLL (Physics)" : "ANIMATION (Keyframes)";
	UI.Text("Current Mode: " + _mode).Newline();
	UI.Text("Press SPACE to toggle mode").Newline();
}
