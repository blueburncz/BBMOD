function BBMOD_Terrain() constructor
{
	Layer = array_create(5, undefined);

	Splatmap = pointer_null;

	Position = new BBMOD_Vec3();

	Size = new BBMOD_Vec2();

	Height = ds_grid_create(1, 1);

	NormalX = ds_grid_create(1, 1);
	ds_grid_clear(NormalX, 0);

	NormalY = ds_grid_create(1, 1);
	ds_grid_clear(NormalY, 0);

	NormalZ = ds_grid_create(1, 1);
	ds_grid_clear(NormalZ, 1);

	NormalSmoothX = ds_grid_create(1, 1);
	ds_grid_clear(NormalSmoothX, 0);

	NormalSmoothY = ds_grid_create(1, 1);
	ds_grid_clear(NormalSmoothY, 0);

	NormalSmoothZ = ds_grid_create(1, 1);
	ds_grid_clear(NormalSmoothZ, 1);

	VertexFormat = BBMOD_VFORMAT_DEFAULT;

	VertexBuffer = undefined;

	static from_heightmap = function (_sprite, _zmin, _zmax) {
		var _spriteWidth = sprite_get_width(_sprite);
		var _spriteHeight = sprite_get_height(_sprite);

		ds_grid_resize(Height, _spriteWidth, _spriteHeight);
		ds_grid_clear(Height, 0);

		ds_grid_resize(NormalX, _spriteWidth, _spriteHeight);
		ds_grid_clear(NormalX, 0);

		ds_grid_resize(NormalY, _spriteWidth, _spriteHeight);
		ds_grid_clear(NormalY, 0);

		ds_grid_resize(NormalZ, _spriteWidth, _spriteHeight);
		ds_grid_clear(NormalZ, 1);

		ds_grid_resize(NormalSmoothX, _spriteWidth, _spriteHeight);
		ds_grid_clear(NormalSmoothX, 0);

		ds_grid_resize(NormalSmoothY, _spriteWidth, _spriteHeight);
		ds_grid_clear(NormalSmoothY, 0);

		ds_grid_resize(NormalSmoothZ, _spriteWidth, _spriteHeight);
		ds_grid_clear(NormalSmoothZ, 1);

		var _surface = surface_create(_spriteWidth, _spriteHeight);
		surface_set_target(_surface);
		draw_sprite(_sprite, 0, 0, 0);
		surface_reset_target();

		var _buffer = buffer_create(_spriteWidth * _spriteHeight * 4, buffer_fast, 1);
		buffer_get_surface(_buffer, _surface, 0);
		surface_free(_surface);
		buffer_seek(_buffer, buffer_seek_start, 0);

		var _j = 0;
		repeat (_spriteHeight)
		{
			var _i = 0;
			repeat (_spriteWidth)
			{
				Height[# _i++, _j] = lerp(_zmin, _zmax, buffer_read(_buffer, buffer_u8) / 255.0);
				buffer_seek(_buffer, buffer_seek_relative, 3);
			}
			++_j;
		}

		buffer_delete(_buffer);

		smooth_height();

		return self;
	};

	static smooth_height = function () {
		var _width = ds_grid_width(Height);
		var _height = ds_grid_height(Height);
		var _heightSmooth = ds_grid_create(_width, _height);

		for (var x1 = 0; x1 < _width; ++x1)
		{
			for (var y1 = 0; y1 < _height; ++y1)
			{
				_heightSmooth[# x1, y1] = ds_grid_get_mean(Height, x1 - 1, y1 - 1, x1 + 1, y1 + 1);
			}
		}

		ds_grid_copy(Height, _heightSmooth);
		ds_grid_destroy(_heightSmooth);

		return self;
	};

	static get_height = function (_i, _j) {
		gml_pragma("forceinline");
		return Height[#
			clamp(_i, 0, ds_grid_width(Height) - 1),
			clamp(_j, 0, ds_grid_height(Height) - 1)
		];
	};

	static get_height_xy = function (_x, _y) {
		gml_pragma("forceinline");
		var _imax = ds_grid_width(Height) - 1;
		var _jmax = ds_grid_height(Height) - 1;
		var _x4 = _x / 4;
		var _y4 = _y / 4;
		var _i1 = floor(_x4);
		var _j1 = floor(_y4);
		var _h1 = Height[# clamp(_i1, 0, _imax), clamp(_j1, 0, _jmax)];
		var _h2 = Height[# clamp(_i1 + 1, 0, _imax), clamp(_j1, 0, _jmax)];
		var _h3 = Height[# clamp(_i1, 0, _imax), clamp(_j1 + 1, 0, _jmax)];
		var _h4 = Height[# clamp(_i1 + 1, 0, _imax), clamp(_j1 + 1, 0, _jmax)];
		return lerp(
			lerp(_h1, _h2, frac(_x4)),
			lerp(_h3, _h4, frac(_x4)),
			frac(_y4));
	};

	static build_normals = function (_scale) {
		var _i = 0;
		repeat (ds_grid_width(Height))
		{
			var _j = 0;
			repeat (ds_grid_height(Height))
			{
				var _nx = get_height(_i - 1, _j) - get_height(_i + 1, _j);
				var _ny = get_height(_i, _j - 1) - get_height(_i, _j + 1);
				var _nz = _scale * 2;
				var _r = sqrt((_nx * _nx) + (_ny * _ny) + (_nz * _nz));
				_nx /= _r;
				_ny /= _r;
				_nz /= _r;
				NormalX[# _i, _j] = _nx;
				NormalY[# _i, _j] = _ny;
				NormalZ[# _i, _j] = _nz;
				++_j;
			}
			++_i;
		}
		return self;
	};

	static build_smooth_normals = function () {
		var _width = ds_grid_width(Height);
		var _height = ds_grid_height(Height);
		for (var x1 = 0; x1 < _width; ++x1)
		{
			for (var y1 = 0; y1 < _height; ++y1)
			{
				var _nx = ds_grid_get_mean(NormalX, x1 - 1, y1 - 1, x1 + 1, y1 + 1);
				var _ny = ds_grid_get_mean(NormalY, x1 - 1, y1 - 1, x1 + 1, y1 + 1);
				var _nz = ds_grid_get_mean(NormalZ, x1 - 1, y1 - 1, x1 + 1, y1 + 1);
				var _r = sqrt((_nx * _nx) + (_ny * _ny) + (_nz * _nz));
				_nx /= _r;
				_ny /= _r;
				_nz /= _r;
				NormalSmoothX[# x1, y1] = _nx;
				NormalSmoothY[# x1, y1] = _ny;
				NormalSmoothZ[# x1, y1] = _nz;
			}
		}
		return self;
	};

	static build_mesh = function () {
		if (VertexBuffer != undefined)
		{
			vertex_delete_buffer(VertexBuffer);
		}
		var _height = Height;
		var _rows = ds_grid_width(_height);
		var _cols = ds_grid_height(_height);
		var _vbuffer = vertex_create_buffer();
		vertex_begin(_vbuffer, VertexFormat.Raw);
		var _i = 0;
		var _scale = 4.0;
		build_normals(_scale);
		build_smooth_normals();
		repeat (_rows - 1)
		{
			var _j = 0;
			repeat (_cols - 1)
			{
				var _z1 = _height[# _i, _j];
				var _z2 = _height[# _i + 1, _j];
				var _z3 = _height[# _i + 1, _j + 1];
				var _z4 = _height[# _i, _j + 1];

				var _x1 = _i * _scale;
				var _y1 = _j * _scale;
				var _x2 = (_i + 1) * _scale;
				var _y2 = _j * _scale;
				var _x3 = (_i + 1) * _scale;
				var _y3 = (_j + 1) * _scale;
				var _x4 = _i * _scale;
				var _y4 = (_j + 1) * _scale;

				var _u1 = _i / _rows;
				var _v1 = _j / _cols;
				var _u2 = (_i + 1) / _rows;
				var _v2 = _j / _cols;
				var _u3 = (_i + 1) / _rows;
				var _v3 = (_j + 1) / _cols;
				var _u4 = _i / _rows;
				var _v4 = (_j + 1) / _cols;

				var _n1X = NormalSmoothX[# _i, _j];
				var _n1Y = NormalSmoothY[# _i, _j];
				var _n1Z = NormalSmoothZ[# _i, _j];

				var _n2X = NormalSmoothX[# _i + 1, _j];
				var _n2Y = NormalSmoothY[# _i + 1, _j];
				var _n2Z = NormalSmoothZ[# _i + 1, _j];

				var _n3X = NormalSmoothX[# _i + 1, _j + 1];
				var _n3Y = NormalSmoothY[# _i + 1, _j + 1];
				var _n3Z = NormalSmoothZ[# _i + 1, _j + 1];

				var _n4X = NormalSmoothX[# _i, _j + 1];
				var _n4Y = NormalSmoothY[# _i, _j + 1];
				var _n4Z = NormalSmoothZ[# _i, _j + 1];

				var _t1X = - _n1X * _n1Y;
				var _t1Y = _n1X * _n1X - (-_n1Z) * _n1Z;
				var _t1Z = (-_n1Z) * _n1Y;

				var _t2X = - _n2X * _n2Y;
				var _t2Y = _n2X * _n2X - (-_n2Z) * _n2Z;
				var _t2Z = (-_n2Z) * _n2Y;

				var _t3X = - _n3X * _n3Y;
				var _t3Y = _n3X * _n3X - (-_n3Z) * _n3Z;
				var _t3Z = (-_n3Z) * _n3Y;

				var _t4X = - _n4X * _n4Y;
				var _t4Y = _n4X * _n4X - (-_n4Z) * _n4Z;
				var _t4Z = (-_n4Z) * _n4Y;

				vertex_position_3d(_vbuffer, _x1, _y1, _z1);
				vertex_normal(_vbuffer, _n1X, _n1Y, _n1Z);
				vertex_texcoord(_vbuffer, _u1, _v1);
				vertex_float4(_vbuffer, _t1X, _t1Y, _t1Z, 1);

				vertex_position_3d(_vbuffer, _x3, _y3, _z3);
				vertex_normal(_vbuffer, _n3X, _n3Y, _n3Z);
				vertex_texcoord(_vbuffer, _u3, _v3);
				vertex_float4(_vbuffer, _t3X, _t3Y, _t3Z, 1);

				vertex_position_3d(_vbuffer, _x4, _y4, _z4);
				vertex_normal(_vbuffer, _n4X, _n4Y, _n4Z);
				vertex_texcoord(_vbuffer, _u4, _v4);
				vertex_float4(_vbuffer, _t4X, _t4Y, _t4Z, 1);

				vertex_position_3d(_vbuffer, _x1, _y1, _z1);
				vertex_normal(_vbuffer, _n1X, _n1Y, _n1Z);
				vertex_texcoord(_vbuffer, _u1, _v1);
				vertex_float4(_vbuffer, _t1X, _t1Y, _t1Z, 1);

				vertex_position_3d(_vbuffer, _x2, _y2, _z2);
				vertex_normal(_vbuffer, _n2X, _n2Y, _n2Z);
				vertex_texcoord(_vbuffer, _u2, _v2);
				vertex_float4(_vbuffer, _t2X, _t2Y, _t2Z, 1);

				vertex_position_3d(_vbuffer, _x3, _y3, _z3);
				vertex_normal(_vbuffer, _n3X, _n3Y, _n3Z);
				vertex_texcoord(_vbuffer, _u3, _v3);
				vertex_float4(_vbuffer, _t3X, _t3Y, _t3Z, 1);

				++_j;
			}
			++_i;
		}
		vertex_end(_vbuffer);
		vertex_freeze(_vbuffer);
		VertexBuffer = _vbuffer;
		return self;
	};

	static submit = function () {
		matrix_set(matrix_world, matrix_build_identity());
		for (var i = 0; i < 5; ++i)
		{
			var _mat = Layer[i];
			if (_mat != undefined && _mat.apply())
			{
				var _shader = BBMOD_SHADER_CURRENT.Raw;
				var _uSplatmap = shader_get_sampler_index(_shader, "bbmod_Splatmap");
				var _uSplatmapIndex = shader_get_uniform(_shader, "bbmod_SplatmapIndex");
				shader_set(_shader);
				texture_set_stage(_uSplatmap, Splatmap);
				shader_set_uniform_i(_uSplatmapIndex, i - 1);
				vertex_submit(VertexBuffer, pr_trianglelist, _mat.BaseOpacity);
			}
		}
		return self;
	};

	static render = function () {
		var _matrix = matrix_build_identity();
		for (var i = 0; i < 5; ++i)
		{
			var _mat = Layer[i];
			if (_mat != undefined)
			{
				var _renderCommand = new BBMOD_RenderCommand();
				_renderCommand.VertexBuffer = VertexBuffer;
				_renderCommand.Texture = _mat.BaseOpacity;
				_renderCommand.Matrix = _matrix;
				ds_list_add(_mat.RenderCommands, _renderCommand);
			}
		}
		return self;
	};

	static destroy = function () {
		ds_grid_destroy(Height);
	};
}