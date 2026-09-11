if (true)
{
	var _surface = bbmod_surface_check(-1, 2, 2, surface_rgba8unorm, false);
	surface_set_target(_surface);
	draw_clear_alpha(make_color_rgb(32, 64, 128), 1.0);
	surface_reset_target();
	var _runtimeSprite = sprite_create_from_surface(
		_surface, 0, 0, 2, 2, false, false, 0, 0);
	surface_free(_surface);

	var _assetMaterial = new BBMOD_Material();
	_assetMaterial.BaseOpacity = sprite_get_texture(BBMOD_SprWhite, 0);
	_assetMaterial.BaseOpacitySprite = BBMOD_SprWhite;
	_assetMaterial.BaseOpacitySubimage = 0;
	_assetMaterial.BaseOpacityOwned = false;
	var _assetJson = {};
	_assetJson.RenderQueue = BBMOD_ERenderQueue.Opaque;
	_assetMaterial.to_json(_assetJson);
	var _assetClone = new BBMOD_Material().from_json(_assetJson);
	bbmod_assert(_assetClone.BaseOpacitySprite == BBMOD_SprWhite);
	bbmod_assert(!_assetClone.BaseOpacityOwned);

	var _pointerMaterial = new BBMOD_Material();
	_pointerMaterial.BaseOpacity = sprite_get_texture(_runtimeSprite, 0);
	var _pointerJson = {};
	_pointerJson.RenderQueue = BBMOD_ERenderQueue.Opaque;
	_pointerMaterial.to_json(_pointerJson);
	var _pointerClone = new BBMOD_Material().from_json(_pointerJson);
	bbmod_assert(_pointerClone.BaseOpacitySprite != undefined);
	bbmod_assert(_pointerClone.BaseOpacityOwned);
	bbmod_assert(_pointerClone.BaseOpacityFormat == surface_rgba8unorm);
	var _sourceSurface = bbmod_surface_check(-1, 2, 2, surface_rgba8unorm, false);
	var _cloneSurface = bbmod_surface_check(-1, 2, 2, surface_rgba8unorm, false);
	surface_set_target(_sourceSurface);
	draw_sprite(_runtimeSprite, 0, 0, 0);
	surface_reset_target();
	surface_set_target(_cloneSurface);
	draw_sprite(_pointerClone.BaseOpacitySprite, 0, 0, 0);
	surface_reset_target();
	for (var _pixelY = 0; _pixelY < 2; ++_pixelY)
	{
		for (var _pixelX = 0; _pixelX < 2; ++_pixelX)
		{
			bbmod_assert(
				surface_getpixel_ext(_sourceSurface, _pixelX, _pixelY)
				== surface_getpixel_ext(_cloneSurface, _pixelX, _pixelY));
		}
	}
	surface_free(_sourceSurface);
	surface_free(_cloneSurface);

	var _unsupportedFormatMaterial = new BBMOD_Material();
	_unsupportedFormatMaterial.BaseOpacity = sprite_get_texture(BBMOD_SprWhite, 0);
	_unsupportedFormatMaterial.BaseOpacityFormat = surface_r8unorm;
	var _unsupportedFormatFailed = false;
	try
	{
		_unsupportedFormatMaterial.to_json({});
	}
	catch (_error)
	{
		_unsupportedFormatFailed = true;
	}
	bbmod_assert(_unsupportedFormatFailed);
	_unsupportedFormatMaterial.destroy();

	var _worldBefore = matrix_get(matrix_world);
	var _viewBefore = matrix_get(matrix_view);
	var _projectionBefore = matrix_get(matrix_projection);
	var _stateMaterial = new BBMOD_Material();
	_stateMaterial.BaseOpacity = sprite_get_texture(_runtimeSprite, 0);
	_stateMaterial.to_json({});
	bbmod_assert(array_equals(matrix_get(matrix_world), _worldBefore));
	bbmod_assert(array_equals(matrix_get(matrix_view), _viewBefore));
	bbmod_assert(array_equals(matrix_get(matrix_projection), _projectionBefore));
	_stateMaterial.destroy();

	var _file = working_directory + "bbmod_texture_ref_test.png";
	sprite_save_strip(_runtimeSprite, _file);
	var _fileJson = {
		__Textures: { BaseOpacity: _file },
		RenderQueue: BBMOD_ERenderQueue.Opaque,
	};
	var _fileMaterial = new BBMOD_Material();
	_fileMaterial.from_json(_fileJson);
	var _fileOutput = {};
	_fileMaterial.to_json(_fileOutput);
	var _fileExpected = _file;
	var _fileActual = _fileOutput.__Textures.BaseOpacity;
	bbmod_assert(is_string(_fileActual));
	bbmod_assert(string_length(_fileActual) > 0);
	bbmod_assert(
		bbmod_path_get_absolute(_fileActual)
		== bbmod_path_get_absolute(_fileExpected));
	bbmod_assert(_fileMaterial.BaseOpacityOwned);
	var _materialFile = working_directory + "bbmod_texture_ref_test.bbmat";
	_fileMaterial.to_file(_materialFile);
	var _fileMaterialClone = new BBMOD_Material().from_file(_materialFile);
	bbmod_assert(_fileMaterialClone.BaseOpacitySprite != undefined);
	bbmod_assert(_fileMaterialClone.BaseOpacityOwned);
	file_delete(_materialFile);
	file_delete(_file);

	var _defaultMaterial = new BBMOD_DefaultMaterial();
	var _defaultNames = [
		"NormalSmoothness",
		"SpecularColor",
		"NormalRoughness",
		"MetallicAO",
		"Subsurface",
		"Emissive",
	];
	for (var i = 0; i < array_length(_defaultNames); ++i)
	{
		var _name = _defaultNames[i];
		_defaultMaterial[$ (_name + "Sprite")] = BBMOD_SprWhite;
		_defaultMaterial[$ (_name + "Owned")] = false;
		_defaultMaterial[$  _name] = sprite_get_texture(BBMOD_SprWhite, 0);
	}
	var _defaultJson = {};
	_defaultJson.RenderQueue = BBMOD_ERenderQueue.Opaque;
	_defaultMaterial.to_json(_defaultJson);
	var _defaultClone = new BBMOD_DefaultMaterial().from_json(_defaultJson);
	for (var j = 0; j < array_length(_defaultNames); ++j)
	{
		var _defaultName = _defaultNames[j];
		bbmod_assert(_defaultClone[$ (_defaultName + "Sprite")] == BBMOD_SprWhite);
		bbmod_assert(!_defaultClone[$ (_defaultName + "Owned")]);
	}

	var _cachedManager = new BBMOD_ResourceManager();
	var _cachedJson = {
		__MaterialName: "BBMOD_MATERIAL_DEFAULT",
		RenderQueue: BBMOD_ERenderQueue.Opaque,
		__Textures: { BaseOpacity: "sprite://SprColormap:1" },
	};
	var _cachedPathA = working_directory + "bbmod_texture_ref_cache_a.bbmat";
	var _cachedPathB = working_directory + "bbmod_texture_ref_cache_b.bbmat";
	var _cachedFile = file_text_open_write(_cachedPathA);
	file_text_write_string(_cachedFile, json_stringify(_cachedJson));
	file_text_close(_cachedFile);
	_cachedFile = file_text_open_write(_cachedPathB);
	file_text_write_string(_cachedFile, json_stringify(_cachedJson));
	file_text_close(_cachedFile);
	var _cachedMaterialA = _cachedManager.load_sync(_cachedPathA);
	var _cachedMaterialB = _cachedManager.load_sync(_cachedPathB);
	bbmod_assert(_cachedMaterialA.BaseOpacitySubimage == 1);
	bbmod_assert(_cachedMaterialB.BaseOpacitySubimage == 1);
	file_delete(_cachedPathA);
	file_delete(_cachedPathB);

	var _lightmapMaterial = new BBMOD_DefaultLightmapMaterial();
	_lightmapMaterial.Lightmap = sprite_get_texture(BBMOD_SprWhite, 0);
	_lightmapMaterial.LightmapSprite = BBMOD_SprWhite;
	var _lightmapJson = {};
	_lightmapMaterial.to_json(_lightmapJson);
	var _lightmapClone = new BBMOD_DefaultLightmapMaterial().from_json(_lightmapJson);
	bbmod_assert(_lightmapClone.LightmapSprite == BBMOD_SprWhite);
	bbmod_assert(!_lightmapClone.LightmapOwned);

	_assetMaterial.destroy();
	_assetClone.destroy();
	_pointerMaterial.destroy();
	_pointerClone.destroy();
	_fileMaterial.destroy();
	_fileMaterialClone.destroy();
	_defaultMaterial.destroy();
	_defaultClone.destroy();
	_lightmapMaterial.destroy();
	_lightmapClone.destroy();
	_cachedManager.destroy();
	sprite_delete(_runtimeSprite);
}
