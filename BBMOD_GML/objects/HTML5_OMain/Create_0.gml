model = new BBMOD_Model().from_file_async("Data/BBMOD/Models/Sphere.bbmod", undefined, function (_err, _model) {
	show_debug_message(["Err", _err, "Model", _model]);
});