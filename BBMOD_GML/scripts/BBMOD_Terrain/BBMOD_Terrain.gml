/// @func BBMOD_Terrain([_heightmap])
/// @extends BBMOD_Class
/// @desc A heightmap based terrain with five material layers controlled through
/// a splatmap.
/// @param {Resource.GMSprite/Undefined} [_heightmap] The heightmap to make the
/// terrain from. If `undefined`, then you will need to build the terrain mesh
/// yourself later using the terrain's methods.
function BBMOD_Terrain(_heightmap=undefined)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	static Super_Class = {
		destroy: destroy,
	};

	/// @var {Struct.BBMOD_RenderQueue} Render queue for terrain layers.
	/// @readonly
	static RenderQueue = new BBMOD_RenderQueue("Terrain", -$FFFFFFFE);

	/// @var {Array.(Struct.BBMOD_Material/Undefined)} Array of five material
	/// layers. Use `undefined` instead of a material to disable certain layer.
	Layer = array_create(5, undefined);

	/// @var {Pointer.Texture} A texture that controls visibility of individual
	/// layers. The first layer is always visible (if the material is not
	/// `undefined`), the red channel of the splatmap controls visibility of the
	/// second layer, the green channel controls the third layer etc.
	Splatmap = pointer_null;

	/// @var {Struct.BBMOD_Vec3} The position of the terrain in the world.
	Position = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec2} The width and height of the terrain in world
	/// units.
	/// @readonly
	Size = new BBMOD_Vec2();

	/// @var {Struct.BBMOD_Vec3} The scale of the terrain.
	Scale = new BBMOD_Vec3(1.0, 1.0, 1.0);

	/// @var {Id.DsGrid} Height of individual vertices (on the z axis).
	/// @private
	Height = ds_grid_create(1, 1);

	/// @var {Id.DsGrid} Normal vector's X component of vertices.
	/// @private
	NormalX = ds_grid_create(1, 1);
	ds_grid_clear(NormalX, 0);

	/// @var {Id.DsGrid} Normal vector's Y component of vertices.
	/// @private
	NormalY = ds_grid_create(1, 1);
	ds_grid_clear(NormalY, 0);

	/// @var {Id.DsGrid} Normal vector's Z component of vertices.
	/// @private
	NormalZ = ds_grid_create(1, 1);
	ds_grid_clear(NormalZ, 1);

	/// @var {Id.DsGrid} Smooth normal vector's X component of vertices.
	/// @private
	NormalSmoothX = ds_grid_create(1, 1);
	ds_grid_clear(NormalSmoothX, 0);

	/// @var {Id.DsGrid} Smooth normal vector's Y component of vertices.
	/// @private
	NormalSmoothY = ds_grid_create(1, 1);
	ds_grid_clear(NormalSmoothY, 0);

	/// @var {Id.DsGrid} Smooth normal vector's Z component of vertices.
	/// @private
	NormalSmoothZ = ds_grid_create(1, 1);
	ds_grid_clear(NormalSmoothZ, 1);

	/// @var {Struct.BBMOD_VertexFormat} The vertex format used by the terrain
	/// mesh.
	/// @readonly
	VertexFormat = BBMOD_VFORMAT_DEFAULT;

	/// @var {Id.VertexBuffer/Undefined} The vertex buffer or `undefined` if
	/// the terrain was not built yet.
	/// @readonly
	/// @see BBMOD_Terrain.build_mesh
	VertexBuffer = undefined;

	/// @func in_bounds(_x, _y)
	/// @desc Checks whether the coordinate is within the terrain's bounds.
	/// @param {Real} _x The x coordinate to check.
	/// @param {Real} _y The y coordinate to check.
	/// @return {Bool} Returns `true` if the coordinate is within the terrain's
	/// bounds.
	static in_bounds = function (_x, _y) {
		gml_pragma("forceinline");
		return (_x >= Position.X && _x <= Position.X + (Size.X * Scale.X)
			&& _y >= Position.Y && _y <= Position.Y + (Size.Y * Scale.Y));
	};

	/// @func from_heightmap(_sprite)
	/// @desc Initializes terrain height from a sprite.
	/// @param {Resource.GMSprite} _sprite The heightmap sprite.
	/// @return {Struct.BBMOD_Terrain} Returns `self`.
	static from_heightmap = function (_sprite) {
		var _spriteWidth = sprite_get_width(_sprite);
		var _spriteHeight = sprite_get_height(_sprite);

		Size.X = _spriteWidth;
		Size.Y = _spriteHeight;

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
				Height[# _i++, _j] = buffer_read(_buffer, buffer_u8);
				buffer_seek(_buffer, buffer_seek_relative, 3);
			}
			++_j;
		}

		buffer_delete(_buffer);

		return self;
	};

	/// @func smooth_height()
	/// @desc Smoothens out the terrain's height.
	/// @return {Struct.BBMOD_Terrain} Returns `self`.
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

	/// @func get_height_index(_i, _j)
	/// @desc Retrieves terrain's height at given index.
	/// @param {Real} _i The X coordinate in the terrain's height grid.
	/// @param {Real} _j The Y coordinate in the terrain's height grid.
	/// @return {Real} The terrain's height at given index.
	/// @see BBMOD_Terrain.Height
	static get_height_index = function (_i, _j) {
		gml_pragma("forceinline");
		return Height[#
			clamp(_i, 0, ds_grid_width(Height) - 1),
			clamp(_j, 0, ds_grid_height(Height) - 1)
		];
	};

	/// @func get_height(_x, _y)
	/// @desc Retrieves terrain's height at given coordinate.
	/// @param {Real} _x The x position to get the height at.
	/// @param {Real} _y The y position to get the height at.
	/// @return {Real/Undefined} The terrain's height at given coordinate or
	/// `undefined` if the coordinate is outside of the terrain.
	static get_height = function (_x, _y) {
		gml_pragma("forceinline");
		var _xScaled = (_x - Position.X) / Scale.X;
		var _yScaled = (_y - Position.Y) / Scale.Y;
		if (_xScaled < 0.0 || _xScaled > Size.X
			|| _yScaled < 0.0 || _yScaled > Size.Y)
		{
			return undefined;
		}
		var _imax = ds_grid_width(Height) - 1;
		var _jmax = ds_grid_height(Height) - 1;
		var _i1 = floor(_xScaled);
		var _j1 = floor(_yScaled);
		var _h1 = Height[# clamp(_i1, 0, _imax), clamp(_j1, 0, _jmax)];
		var _h2 = Height[# clamp(_i1 + 1, 0, _imax), clamp(_j1, 0, _jmax)];
		var _h3 = Height[# clamp(_i1 + 1, 0, _imax), clamp(_j1 + 1, 0, _jmax)];
		var _h4 = Height[# clamp(_i1, 0, _imax), clamp(_j1 + 1, 0, _jmax)];
		var _offsetX = frac(_xScaled);
		var _offsetY = frac(_yScaled);
		// TODO: Optimize retrieving terrain height
		if (_offsetX <= _offsetY)
		{
			return Position.Z + (_h4 + (_h1-_h4)*(1.0-_offsetY) + (_h3-_h4)*(_offsetX)) * Scale.Z;
		}
		return Position.Z + (_h2 + (_h1-_h2)*(1.0-_offsetX) + (_h3-_h2)*(_offsetY)) * Scale.Z;
	};


	/// @func get_normal(_x, _y)
	/// @desc Retrieves terrain's normal at given coordinate.
	/// @param {Real} _x The x position to get the normal at.
	/// @param {Real} _y The y position to get the normal at.
	/// @return {Struct.BBMOD_Vec3/Undefined} The terrain's normal at given coordinate or
	/// `undefined` if the coordinate is outside of the terrain.
	static get_normal = function (_x, _y) {
		gml_pragma("forceinline");
		var _xScaled = (_x - Position.X) / Scale.X;
		var _yScaled = (_y - Position.Y) / Scale.Y;
		if (_xScaled < 0.0 || _xScaled > Size.X
			|| _yScaled < 0.0 || _yScaled > Size.Y)
		{
			return undefined;
		}
		var _imax = ds_grid_width(Height) - 1;
		var _jmax = ds_grid_height(Height) - 1;
		var _i1 = floor(_xScaled);
		var _j1 = floor(_yScaled);
		var _h1 = Height[# clamp(_i1, 0, _imax), clamp(_j1, 0, _jmax)];
		var _h2 = Height[# clamp(_i1 + 1, 0, _imax), clamp(_j1, 0, _jmax)];
		var _h3 = Height[# clamp(_i1 + 1, 0, _imax), clamp(_j1 + 1, 0, _jmax)];
		var _h4 = Height[# clamp(_i1, 0, _imax), clamp(_j1 + 1, 0, _jmax)];
		// TODO: Optimize retrieving terrain normal
		if (frac(_xScaled) <= frac(_yScaled))
		{
			return new BBMOD_Vec3(0.0, -Scale.Y, (_h1 - _h4) * Scale.Z)
				.Cross(new BBMOD_Vec3(Scale.X, 0.0, (_h3 - _h4) * Scale.Z))
				.Normalize();
		}
		return new BBMOD_Vec3(0.0, Scale.Y, (_h3 - _h2) * Scale.Z)
			.Cross(new BBMOD_Vec3(-Scale.X, 0.0, (_h1 - _h2) * Scale.Z))
			.Normalize();
	};

	/// @func build_normals()
	/// @desc Rebuilds normal vectors.
	/// @return {Struct.BBMOD_Terrain} Returns `self`.
	static build_normals = function () {
		var _i = 0;
		repeat (ds_grid_width(Height))
		{
			var _j = 0;
			repeat (ds_grid_height(Height))
			{
				var _nx = get_height_index(_i - 1, _j) - get_height_index(_i + 1, _j);
				var _ny = get_height_index(_i, _j - 1) - get_height_index(_i, _j + 1);
				var _nz = 2.0;
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

	/// @func build_smooth_normals()
	/// @desc Rebuilds smooth normals.
	/// @return {Struct.BBMOD_Terrain} Returns `self`.
	/// @note {@link BBMOD_Terrain.build_normals} should be called first!
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

	/// @func build_mesh()
	/// @desc Rebuilds the terrain's mesh.
	/// @return {Struct.BBMOD_Terrain} Returns `self`.
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
		repeat (_rows - 1)
		{
			var _j = 0;
			repeat (_cols - 1)
			{
				var _z1 = _height[# _i, _j];
				var _z2 = _height[# _i + 1, _j];
				var _z3 = _height[# _i + 1, _j + 1];
				var _z4 = _height[# _i, _j + 1];

				var _x1 = _i;
				var _y1 = _j;
				var _x2 = _i + 1;
				var _y2 = _j;
				var _x3 = _i + 1;
				var _y3 = _j + 1;
				var _x4 = _i;
				var _y4 = _j + 1;

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

	/// @func submit()
	/// @desc Immediately submits the terrain mesh for rendering.
	/// @return {Struct.BBMOD_Terrain} Returns `self`.
	static submit = function () {
		matrix_set(matrix_world, matrix_build(Position.X, Position.Y, Position.Z, 0, 0, 0, Scale.X, Scale.Y, Scale.Z));
		var i = 0;
		repeat (5)
		{
			var _mat = Layer[i];
			if (_mat != undefined && _mat.apply())
			{
				var _uSplatmap = BBMOD_SHADER_CURRENT.get_sampler_index("bbmod_Splatmap");
				var _uSplatmapIndex = BBMOD_SHADER_CURRENT.get_uniform("bbmod_SplatmapIndex");
				texture_set_stage(_uSplatmap, Splatmap);
				shader_set_uniform_i(_uSplatmapIndex, i - 1);
				vertex_submit(VertexBuffer, pr_trianglelist, _mat.BaseOpacity);
			}
			++i;
		}
		return self;
	};

	/// @func render()
	/// @desc Enqueues the terrain mesh for rendering.
	/// @return {Struct.BBMOD_Terrain} Returns `self`.
	static render = function () {
		var _matrix = matrix_build(Position.X, Position.Y, Position.Z, 0, 0, 0, Scale.X, Scale.Y, Scale.Z);
		var i = 0;
		repeat (5)
		{
			var _mat = Layer[i];
			if (_mat != undefined)
			{
				RenderQueue
					.apply_material(_mat, ~(1 << BBMOD_ERenderPass.Shadows))
					.begin_conditional_block()
					.set_gpu_zwriteenable(i == 0)
					.set_gpu_zfunc((i == 0) ? cmpfunc_lessequal : cmpfunc_equal)
					.set_sampler("bbmod_Splatmap", Splatmap)
					.set_uniform_i("bbmod_SplatmapIndex", i - 1)
					.set_world_matrix(_matrix)
					.submit_vertex_buffer(VertexBuffer, pr_trianglelist, _mat.BaseOpacity)
					.reset_material()
					.end_conditional_block();
			}
			++i;
		}
		return self;
	};

	static destroy = function () {
		method(self, Super_Class.destroy)();
		ds_grid_destroy(Height);
		ds_grid_destroy(NormalX);
		ds_grid_destroy(NormalY);
		ds_grid_destroy(NormalZ);
		ds_grid_destroy(NormalSmoothX);
		ds_grid_destroy(NormalSmoothY);
		ds_grid_destroy(NormalSmoothZ);
	};

	if (_heightmap != undefined)
	{
		from_heightmap(_heightmap);
		smooth_height();
		build_normals();
		build_smooth_normals();
		build_mesh();
	}
}