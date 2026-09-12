renderer.present();

if (renderer.Editor.Enabled)
{
	var _spawnHelp = "Editor spawns: 1 PointLight | 2 SpotLight | 3 ReflectionProbe | 4 Lightmap instance";
	_spawnHelp += "\nPlace cursor over rendered geometry; depth buffer required";
	var _spawnColor = draw_get_color();
	var _spawnAlpha = draw_get_alpha();
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_color(c_black);
	draw_set_alpha(0.75);
	draw_text(19, 19, _spawnHelp);
	draw_set_color(c_white);
	draw_set_alpha(1.0);
	draw_text(18, 18, _spawnHelp);
	draw_set_color(_spawnColor);
	draw_set_alpha(_spawnAlpha);
}

if (particleModuleShowcaseEnabled)
{
	var _emitters = particleModuleShowcaseEmitters;
	var _names = particleModuleShowcaseNames;
	var _count = min(array_length(_emitters), array_length(_names));

	if (_count > 0)
	{
		var _screenWidth = bbmod_window_get_width();
		var _screenHeight = bbmod_window_get_height();
		var _labelWorldPos = new BBMOD_Vec3(0.0);
		var _screenCenterX = _screenWidth * 0.5;
		var _screenCenterY = _screenHeight * 0.5;
		var _screenRadius = max(point_distance(0.0, 0.0, _screenCenterX, _screenCenterY), 1.0);
		var _focusInner = 0.18;
		var _focusOuter = 0.95;
		var _distanceNear = 20.0;
		var _distanceFar = 260.0;
		var _distanceRangeInv = 1.0 / max(_distanceFar - _distanceNear, 0.001);
		var _cameraPosition = camera.Position;

		var _colorPrev = draw_get_color();
		var _alphaPrev = draw_get_alpha();
		var _halignPrev = draw_get_halign();
		var _valignPrev = draw_get_valign();

		draw_set_halign(fa_center);
		draw_set_valign(fa_bottom);
		draw_set_alpha(1.0);

		var i = 0;
		repeat(_count)
		{
			var _emitter = _emitters[i];
			var _position = _emitter.Position;
			_labelWorldPos.X = _position.X;
			_labelWorldPos.Y = _position.Y;
			_labelWorldPos.Z = _position.Z + 2.5;

			var _screenPos = camera.world_to_screen(_labelWorldPos, _screenWidth, _screenHeight);
			if (_screenPos != undefined)
			{
				var _labelX = _screenPos.X;
				var _labelY = _screenPos.Y - 8.0;
				var _name = _names[i];
				var _distanceToCamera = point_distance_3d(
					_cameraPosition.X, _cameraPosition.Y, _cameraPosition.Z,
					_labelWorldPos.X, _labelWorldPos.Y, _labelWorldPos.Z);
				var _distanceAlpha = 1.0 - clamp((_distanceToCamera - _distanceNear) * _distanceRangeInv, 0.0, 1.0);
				var _focusNorm = point_distance(_labelX, _labelY, _screenCenterX, _screenCenterY) / _screenRadius;
				var _focusAlpha = 1.0 - clamp((_focusNorm - _focusInner) / (_focusOuter - _focusInner), 0.0, 1.0);
				_focusAlpha *= _focusAlpha;
				var _labelAlpha = _distanceAlpha * _focusAlpha;

				if (_labelAlpha <= 0.02)
				{
					++i;
					continue;
				}

				draw_set_color(c_black);
				draw_set_alpha(_labelAlpha * 0.75);
				draw_text(_labelX + 1.0, _labelY + 1.0, _name);
				draw_set_color(c_white);
				draw_set_alpha(_labelAlpha);
				draw_text(_labelX, _labelY, _name);
			}

			++i;
		}

		draw_set_color(_colorPrev);
		draw_set_alpha(_alphaPrev);
		draw_set_halign(_halignPrev);
		draw_set_valign(_valignPrev);
	}
}

if (terrain != undefined)
{
	var _prof = terrain.get_build_profiler();
	var _avg = _prof.StageAvgUs;

	var _lastMs = _prof.LastChunkUs * 0.001;
	var _avgMs = _prof.AvgChunkUs * 0.001;
	var _maxMs = _prof.MaxChunkUs * 0.001;

	var _text = "Terrain Build Profiler [" + (_prof.Enabled ? "ON" : "OFF") + "]";
	_text += "  (F4 toggle, F5 reset)\n";
	_text += "Chunks: " + string(_prof.ChunkCount) + " | Last verts: " + string(_prof.LastVertexCount) + "\n";
	_text += "Chunk ms: last " + string_format(_lastMs, 1, 3)
		+ " | avg " + string_format(_avgMs, 1, 3)
		+ " | max " + string_format(_maxMs, 1, 3) + "\n";
	_text += "Top stage: " + string(_prof.TopStageName)
		+ " (avg " + string_format(_prof.TopStageAvgUs, 1, 1) + " us)\n";
	_text += "Avg us: SN " + string_format(_avg.SmoothNormals, 1, 1)
		+ " | Write " + string_format(_avg.WriteVertexData, 1, 1)
		+ " | Freeze " + string_format(_avg.Freeze, 1, 1)
		+ " | Bounds " + string_format(_avg.Bounds, 1, 1);

	var _colorPrev = draw_get_color();
	var _alphaPrev = draw_get_alpha();
	var _halignPrev = draw_get_halign();
	var _valignPrev = draw_get_valign();

	var _x = 18;
	var _y = 100;

	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_set_alpha(0.75);
	draw_set_color(c_black);
	draw_text(_x + 1, _y + 1, _text);
	draw_set_alpha(1.0);
	draw_set_color(c_white);
	draw_text(_x, _y, _text);

	draw_set_color(_colorPrev);
	draw_set_alpha(_alphaPrev);
	draw_set_halign(_halignPrev);
	draw_set_valign(_valignPrev);
}
