/// @func BBMOD_OBJImporter()
/// @extends BBMOD_Importer
/// @desc An `*.obj` model importer.
/// @example
/// ```gml
/// var _objImporter = new BBMOD_OBJImporter();
/// modHouse = _objImporter.import("Data/Assets/House.obj");
/// modTree = _objImporter.import("Data/Assets/Tree.obj");
/// modFence = _objImporter.import("Data/Assets/Fence.obj");
/// _objImporter.destroy();
/// ```
function BBMOD_OBJImporter()
	: BBMOD_Importer() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Super_Importer = {
		destroy: destroy,
	};

	/// @var {Bool} If `true`, then Y and Z axes are switched in imported
	/// models. Default value is `false.`
	ConvertYToZUp = false;

	/// @var {Bool} If `true`, then the winding order of vertices is inverted.
	/// Default value is `false`.
	InvertWinding = false;

	Vertices = ds_list_create();

	Normals = ds_list_create();

	TextureCoords = ds_list_create();

	static can_import = function (_path) {
		return (filename_ext(_path) == ".obj");
	};

	static _split_string = function (_string, _delimiter, _arrayOut) {
		var _pos = string_pos(_delimiter, _string);
		if (_pos == 0)
		{
			_arrayOut[@ 0] = _string;
			_arrayOut[@ 1] = "";
			return;
		}
		_arrayOut[@ 0] = string_copy(_string, 1, _pos - 1);
		_arrayOut[@ 1] = string_delete(_string, 1, _pos);
	};

	static import = function (_path) {
		ds_list_clear(Vertices);
		ds_list_clear(Normals);
		ds_list_clear(TextureCoords);

		var _file = file_text_open_read(_path);
		if (_file == -1)
		{
			throw new BBMOD_Exception("Could not open file \"" + _path + "\"!");
		}

		var _vformat = new BBMOD_VertexFormat(true, true, true, false, true);

		var _model = new BBMOD_Model();
		_model.IsLoaded = true;
		_model.VertexFormat = _vformat;
		_model.Meshes = [];
		_model.NodeCount = 1;

		var _root = new BBMOD_Node(_model);
		_root.Name = "Node0";
		_model.RootNode = _root;

		var _meshBuilder = undefined;
		var _split = array_create(2);
		var _face = array_create(3);
		var _vertexInd = array_create(3);

		var _node = _root;
		var _material = undefined;

		while (true)
		{
			var _line = file_text_read_string(_file);
			_split_string(_line, " ", _split);
			var _keyword = _split[0];
			_line = _split[1];

			// Build mesh
			// TODO: Deduplicate code
			if (_keyword != "f" && _meshBuilder != undefined)
			{
				_meshBuilder.make_tangents();
				var _mesh = _meshBuilder.build();
				_mesh.Model = _model;

				var _meshIndex = array_length(_model.Meshes);
				array_push(_model.Meshes, _mesh);
				array_push(_node.Meshes, _meshIndex);
				_node.set_renderable();

				if (_material == undefined)
				{
					_material = 0;
					_model.MaterialCount = 1;
					array_push(_model.Materials, BBMOD_MATERIAL_DEFAULT);
					array_push(_model.MaterialNames, "Material");
				}
				_mesh.MaterialIndex = _material;

				_meshBuilder.destroy();
				_meshBuilder = undefined;
			}

			switch (_keyword)
			{
			// Object
			case "o":
				_node = new BBMOD_Node(_model);
				_root.add_child(_node);
				_node.Index = array_length(_root.Children);
				_node.Name = "Node" + string(_node.Index);
				++_model.NodeCount;
				break;

			// Material
			case "usemtl":
				var _ind = array_length(_model.MaterialNames) - 1;
				for (/**/; _ind >= 0; --_ind)
				{
					if (_model.MaterialNames[_ind] == _line)
					{
						break;
					}
				}
				if (_ind == -1)
				{
					_ind = array_length(_model.MaterialNames);
					array_push(_model.MaterialNames, _line);
					array_push(_model.Materials, BBMOD_MATERIAL_DEFAULT);
					++_model.MaterialCount;
				}
				_material = _ind;
				break;

			// Vertex
			case "v":
				_split_string(_line, " ", _split);
				var _vx = real(_split[0]);

				_split_string(_split[1], " ", _split);
				var _vy = real(_split[0]);

				_split_string(_split[1], " ", _split);
				var _vz = real(_split[0]);

				if (ConvertYToZUp)
				{
					var _temp = _vz;
					_vz = _vy;
					_vy = _temp;
				}

				ds_list_add(Vertices, _vx, _vy, _vz);
				break;

			// Normal
			case "vn":
				_split_string(_line, " ", _split);
				var _nx = real(_split[0]);

				_split_string(_split[1], " ", _split);
				var _ny = real(_split[0]);

				_split_string(_split[1], " ", _split);
				var _nz = real(_split[0]);

				if (ConvertYToZUp)
				{
					var _temp = _nz;
					_nz = _ny;
					_ny = _temp;
				}

				ds_list_add(Normals, _nx, _ny, _nz);
				break;

			// Texture
			case "vt":
				_split_string(_line, " ", _split);
				var _tx = real(_split[0]);
				if (FlipUVHorizontally)
				{
					_tx = 1.0 - _tx;
				}

				_split_string(_split[1], " ", _split);
				var _ty = real(_split[0]);
				if (FlipUVVertically)
				{
					_ty = 1.0 - _ty;
				}

				ds_list_add(TextureCoords, _tx, _ty);
				break;

			// Face
			case "f":
				if (_meshBuilder == undefined)
				{
					_meshBuilder = new BBMOD_MeshBuilder();
				}

				_split_string(_line, " ", _split);
				_face[@ 0] = _split[0];
				_split_string(_split[1], " ", _split);
				_face[@ 1] = _split[0];
				_split_string(_split[1], " ", _split);
				_face[@ 2] = _split[0];

				for (var i = 0; i < 3; ++i)
				{
					_split_string(_face[i], "/", _split);
					var _v = (real(_split[0]) - 1) * 3;

					_split_string(_split[1], "/", _split);
					var _t = (_split[0] != "")
						? (real(_split[0]) - 1) * 2
						: -1;

					_split_string(_split[1], "/", _split);
					var _n = (real(_split[0]) - 1) * 3;

					var _vertex = new BBMOD_Vertex(_vformat);
					_vertex.Position.X = Vertices[| _v];
					_vertex.Position.Y = Vertices[| _v + 1];
					_vertex.Position.Z = Vertices[| _v + 2];

					_vertex.Normal.X = Normals[| _n];
					_vertex.Normal.Y = Normals[| _n + 1];
					_vertex.Normal.Z = Normals[| _n + 2];

					if (_t != -1)
					{
						_vertex.TextureCoord.X = TextureCoords[| _t];
						_vertex.TextureCoord.Y = TextureCoords[| _t + 1];
					}

					_vertexInd[@ i] = _meshBuilder.add_vertex(_vertex);
				}

				if (InvertWinding)
				{
					_meshBuilder.add_face(_vertexInd[2], _vertexInd[1], _vertexInd[0]);
				}
				else
				{
					_meshBuilder.add_face(_vertexInd[0], _vertexInd[1], _vertexInd[2]);
				}
				break;
			}

			file_text_readln(_file);

			if (file_text_eof(_file))
			{
				break;
			}
		}

		file_text_close(_file);

		// Build mesh
		// TODO: Deduplicate code
		if (_meshBuilder != undefined)
		{
			_meshBuilder.make_tangents();
			var _mesh = _meshBuilder.build();
			_mesh.Model = _model;

			var _meshIndex = array_length(_model.Meshes);
			array_push(_model.Meshes, _mesh);
			array_push(_node.Meshes, _meshIndex);
			_node.set_renderable();

			if (_material == undefined)
			{
				_material = 0;
				_model.MaterialCount = 1;
				array_push(_model.Materials, BBMOD_MATERIAL_DEFAULT);
				array_push(_model.MaterialNames, "Material");
			}
			_mesh.MaterialIndex = _material;

			_meshBuilder.destroy();
			_meshBuilder = undefined;
		}

		return _model;
	};

	static destroy = function () {
		method(self, Super_Importer.destroy)();
		ds_list_destroy(Vertices);
		ds_list_destroy(Normals);
		ds_list_destroy(TextureCoords);
		return undefined;
	};
}