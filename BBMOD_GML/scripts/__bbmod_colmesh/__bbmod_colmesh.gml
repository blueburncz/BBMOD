/// @module ColMesh

function __bbmod_mesh_to_colmesh_impl(_mesh, _colmesh, _transform, _version)
{
	gml_pragma("forceinline");

	var _singlesided = true;
	var _buffer = buffer_create_from_vertex_buffer(_mesh.VertexBuffer, buffer_fixed, 1);
	var _bufferSize = buffer_get_size(_buffer);
	var _vertexSize = _mesh.VertexFormat.get_byte_size();
	var _vertexStep = _vertexSize - 4 * 3;
	var _vertexCount = _bufferSize / _vertexSize;
	var _vertex = array_create(9, 0.0);

	buffer_copy_from_vertex_buffer(_mesh.VertexBuffer, 0, _vertexCount, _buffer, 0);
	buffer_seek(_buffer, buffer_seek_start, 0);

	repeat(_vertexCount / 3)
	{
		_vertex[@ 0] = buffer_read(_buffer, buffer_f32);
		_vertex[@ 1] = buffer_read(_buffer, buffer_f32);
		_vertex[@ 2] = buffer_read(_buffer, buffer_f32);
		buffer_seek(_buffer, buffer_seek_relative, _vertexStep);

		_vertex[@ 3] = buffer_read(_buffer, buffer_f32);
		_vertex[@ 4] = buffer_read(_buffer, buffer_f32);
		_vertex[@ 5] = buffer_read(_buffer, buffer_f32);
		buffer_seek(_buffer, buffer_seek_relative, _vertexStep);

		_vertex[@ 6] = buffer_read(_buffer, buffer_f32);
		_vertex[@ 7] = buffer_read(_buffer, buffer_f32);
		_vertex[@ 8] = buffer_read(_buffer, buffer_f32);
		buffer_seek(_buffer, buffer_seek_relative, _vertexStep);

		if (_transform != undefined)
		{
			array_copy(_vertex, 0, matrix_transform_vertex(_transform, _vertex[0], _vertex[1], _vertex[2]),
				0, 3);
			array_copy(_vertex, 3, matrix_transform_vertex(_transform, _vertex[3], _vertex[4], _vertex[5]),
				0, 3);
			array_copy(_vertex, 6, matrix_transform_vertex(_transform, _vertex[6], _vertex[7], _vertex[8]),
				0, 3);
		}

		switch (_version)
		{
			case 1:
				_colmesh.addTriangle(_vertex);
				break;

			case 2:
			{
				var _triangle = cm_triangle(
					_singlesided,
					_vertex[0], _vertex[1], _vertex[2],
					_vertex[3], _vertex[4], _vertex[5],
					_vertex[6], _vertex[7], _vertex[8]);

				cm_add(_colmesh, _triangle);
			}
			break;

			default:
				bbmod_assert(false, $"Unsupported ColMesh version {_version}!");
				break;
		}
	}

	buffer_delete(_buffer);
}

/// @func bbmod_mesh_to_colmesh(_mesh, _colmesh[, _transform])
///
/// @desc Adds a {@link BBMOD_Mesh} into ColMesh v1.
///
/// @param {Struct.BBMOD_Mesh} _mesh The mesh to add.
/// @param {Struct.colmesh} _colmesh The ColMesh to add the mesh to.
/// @param {Array<Real>} [_transform] A matrix to transform the mesh  with before
/// it is added to the ColMesh. Leave `undefined` if you do not wish to transform
/// the mesh.
///
/// @see https://marketplace.yoyogames.com/assets/8130/colmesh
function bbmod_mesh_to_colmesh(_mesh, _colmesh, _transform = undefined)
{
	__bbmod_add_mesh_to_colmesh_impl(_mesh, _colmesh, _transform, 1);
}

////////////////////////////////////////////////////////////////////////////////
//
// Model
//

function __bbmod_model_to_colmesh_impl(_model, _colmesh, _transform, _version)
{
	gml_pragma("forceinline");

	static _stack = ds_stack_create();

	var _meshes = _model.Meshes;
	_transform ??= bbmod_matrix_get_identity();

	ds_stack_push(_stack, _model.RootNode, _transform);

	while (!ds_stack_empty(_stack))
	{
		var _matrix = ds_stack_pop(_stack);
		var _node = ds_stack_pop(_stack);

		if (!_node.IsRenderable || !_node.Visible)
		{
			continue;
		}

		var _nodeMatrix = matrix_multiply(_node.Transform.ToMatrix(), _matrix);
		var _meshIndices = _node.Meshes;
		var _children = _node.Children;
		var i = 0;

		repeat(array_length(_meshIndices))
		{
			var _mesh = _meshes[_meshIndices[i++]];
			__bbmod_mesh_to_colmesh_impl(_mesh, _colmesh, _nodeMatrix, _version);
		}

		i = 0;
		repeat(array_length(_children))
		{
			ds_stack_push(_stack, _children[i++], _nodeMatrix);
		}
	}
}

/// @func bbmod_model_to_colmesh(_model, _colmesh[, _transform])
///
/// @desc Adds a {@link BBMOD_Model} into ColMesh v1.
///
/// @param {Struct.BBMOD_Model} _model The model to add.
/// @param {Struct.colmesh} _colmesh The ColMesh to add the model to.
/// @param {Array<Real>} [_transform] A matrix to transform the model with
/// before it is added to the ColMesh. Leave `undefined` if you do not wish to
/// transform the model.
///
/// @see https://marketplace.yoyogames.com/assets/8130/colmesh
function bbmod_model_to_colmesh(_model, _colmesh, _transform = undefined)
{
	__bbmod_model_to_colmesh_impl(_model, _colmesh, _transform, 1);
}
