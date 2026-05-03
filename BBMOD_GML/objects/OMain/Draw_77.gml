renderer.present();

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

