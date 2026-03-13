UI.SetPosition(8, 8);

////////////////////////////////////////////////////////////////////////////////
// Weather presets
UI.Text("CLOUDS").Newline();

UI.Button("Clear",
	{ OnClick: method(clouds, function() { set_weather(BBMOD_ECloudWeather.Clear);        }), })
	.Move(4)
	.Button("Partly Cloudy",
	{ OnClick: method(clouds, function() { set_weather(BBMOD_ECloudWeather.PartlyCloudy); }), })
	.Move(4)
	.Button("Cloudy",
	{ OnClick: method(clouds, function() { set_weather(BBMOD_ECloudWeather.Cloudy);       }), })
	.Move(4)
	.Button("Overcast",
	{ OnClick: method(clouds, function() { set_weather(BBMOD_ECloudWeather.Overcast);     }), })
	.Move(4)
	.Button("Stormy",
	{ OnClick: method(clouds, function() { set_weather(BBMOD_ECloudWeather.Stormy);       }), })
	.Newline();

////////////////////////////////////////////////////////////////////////////////
// Layer geometry
UI.Input("cloud-altitude", clouds.Altitude,
	{
		Label:    "Altitude",
		OnChange: method(clouds, function(_v) { Altitude = _v; }),
	})
	.Move(4)
	.Input("cloud-layer-sep", clouds.LayerSep,
	{
		Label:    "Layer Sep.",
		OnChange: method(clouds, function(_v) { LayerSep = _v; }),
	})
	.Newline();

UI.Text("Layers:").Newline();
UI.Button("1",
	{ OnClick: method(clouds, function() { LayerCount = 1; }), })
	.Move(4)
	.Button("2",
	{ OnClick: method(clouds, function() { LayerCount = 2; }), })
	.Move(4)
	.Button("3",
	{ OnClick: method(clouds, function() { LayerCount = 3; }), })
	.Newline();

////////////////////////////////////////////////////////////////////////////////
// Layer 0
UI.Text("Layer 0").Newline();
UI.Input("cloud-size-0", clouds.CloudSize,
	{
		Label:    "Size (wu)",
		OnChange: method(clouds, function(_v) { CloudSize = _v; }),
	})
	.Newline();
UI.Slider("cloud-coverage-0", clouds.Coverage,
	{
		Label:    "Coverage",
		Min:      0.0,
		Max:      1.0,
		OnChange: method(clouds, function(_v) { Coverage = _v; }),
	})
	.Newline();
UI.Slider("cloud-density-0", clouds.Density,
	{
		Label:    "Density",
		Min:      0.0,
		Max:      1.0,
		OnChange: method(clouds, function(_v) { Density = _v; }),
	})
	.Newline();

////////////////////////////////////////////////////////////////////////////////
// Layer 1
UI.Text("Layer 1").Newline();
UI.Input("cloud-size-1", clouds.CloudSize1,
	{
		Label:    "Size (wu)",
		OnChange: method(clouds, function(_v) { CloudSize1 = _v; }),
	})
	.Newline();
UI.Slider("cloud-coverage-1", clouds.Coverage1,
	{
		Label:    "Coverage",
		Min:      0.0,
		Max:      1.0,
		OnChange: method(clouds, function(_v) { Coverage1 = _v; }),
	})
	.Newline();
UI.Slider("cloud-density-1", clouds.Density1,
	{
		Label:    "Density",
		Min:      0.0,
		Max:      1.0,
		OnChange: method(clouds, function(_v) { Density1 = _v; }),
	})
	.Newline();

////////////////////////////////////////////////////////////////////////////////
// Layer 2
UI.Text("Layer 2").Newline();
UI.Input("cloud-size-2", clouds.CloudSize2,
	{
		Label:    "Size (wu)",
		OnChange: method(clouds, function(_v) { CloudSize2 = _v; }),
	})
	.Newline();
UI.Slider("cloud-coverage-2", clouds.Coverage2,
	{
		Label:    "Coverage",
		Min:      0.0,
		Max:      1.0,
		OnChange: method(clouds, function(_v) { Coverage2 = _v; }),
	})
	.Newline();
UI.Slider("cloud-density-2", clouds.Density2,
	{
		Label:    "Density",
		Min:      0.0,
		Max:      1.0,
		OnChange: method(clouds, function(_v) { Density2 = _v; }),
	})
	.Newline();

////////////////////////////////////////////////////////////////////////////////
// Atmosphere / horizon
UI.Slider("cloud-horizon-fade", clouds.HorizonFade,
	{
		Label:    "Horizon Fade",
		Min:      0.0,
		Max:      0.0001,
		OnChange: method(clouds, function(_v) { HorizonFade = _v; }),
	})
	.Newline();

////////////////////////////////////////////////////////////////////////////////
// Wind / offset
UI.Slider("cloud-wind", clouds.WindSpeed,
	{
		Label:    "Wind Speed",
		Min:      0.0,
		Max:      50.0,
		OnChange: method(clouds, function(_v) { WindSpeed = _v; }),
	})
	.Newline();

UI.Slider("cloud-offset-x", clouds.Offset.X,
	{
		Label:    "Offset X",
		Min:      -20000.0,
		Max:      20000.0,
		OnChange: method(clouds, function(_v) { Offset.X = _v; }),
	})
	.Newline();
UI.Slider("cloud-offset-y", clouds.Offset.Y,
	{
		Label:    "Offset Y",
		Min:      -20000.0,
		Max:      20000.0,
		OnChange: method(clouds, function(_v) { Offset.Y = _v; }),
	})
	.Newline();

////////////////////////////////////////////////////////////////////////////////
// Time of day
UI.Newline();
UI.Text("TIME OF DAY").Newline();

var _hour = ((astroHourAccum mod 24) + 24) mod 24;
var _h    = floor(_hour);
var _m    = floor((_hour - _h) * 60);
UI.Text(string_format(_h, 2, 0) + ":" + string_format(_m, 2, 0)
	+ "   " + string(astroDay) + "/" + string(astroMonth) + "/" + string(astroYear))
	.Newline();

UI.Slider("tod-hour", _hour,
	{
		Label:    "Hour",
		Min:      0.0,
		Max:      24.0,
		OnChange: method(id, function(_newHour)
		{
			var _dayOffset = floor(astroHourAccum / 24.0) * 24.0;
			astroHourAccum = _dayOffset + _newHour;
			astroJumped = true;
		}),
	})
	.Newline();
