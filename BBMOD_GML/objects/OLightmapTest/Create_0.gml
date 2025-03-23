model = BBMOD_RESOURCE_MANAGER.load("Data/Lightmap/Lightmap.bbmod", undefined, function (_err, _model)
{
	bbmod_assert(_err == undefined, "Failed to load lightmapped model!");
	_model.Materials[0].set_base_opacity(BBMOD_C_SILVER);
	_model.freeze();
});
