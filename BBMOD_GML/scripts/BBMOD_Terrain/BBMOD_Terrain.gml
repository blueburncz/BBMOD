/// @module Terrain

/// @macro {Real}
/// @private
#macro __BBMOD_SAVE_TERRAIN_VERSION 0

/// @func BBMOD_TerrainInfo()
///
/// @desc Configuration struct for initializing a {@link BBMOD_Terrain}.
/// Every public property of `BBMOD_Terrain` has a corresponding field here
/// that defines its default value. Pass an instance to the
/// {@link BBMOD_Terrain} constructor to override defaults at construction
/// time.
function BBMOD_TerrainInfo() constructor
{
	/// @var {Asset.GMSprite} The heightmap sprite to initialize the terrain
	/// from. Use `undefined` to skip heightmap initialization. Defaults to
	/// `undefined`.
	Heightmap = undefined;

	/// @var {Real} The subimage of the heightmap sprite to use. Defaults to
	/// `0`.
	Subimage = 0;

	/// @var {Pointer.Texture} A texture that controls terrain layer visibility
	/// through its RGBA channels. Defaults to `pointer_null`.
	Splatmap = pointer_null;

	/// @var {SurfaceFormatType} Serialization capture format. Only
	/// `surface_rgba8unorm` (default) is currently supported.
	SplatmapFormat = surface_rgba8unorm;

	/// @var {Asset.GMSprite} Sprite source for
	/// {@link BBMOD_TerrainInfo.Splatmap}, or `undefined`.
	/// Takes precedence over the texture when defined.
	SplatmapSprite = undefined;

	/// @var {Real} Subimage of
	/// {@link BBMOD_TerrainInfo.SplatmapSprite} to use.
	SplatmapSubimage = 0;

	/// @var {Bool} Whether this configuration owns
	/// {@link BBMOD_TerrainInfo.SplatmapSprite}.
	SplatmapOwned = false;

	/// @var {Pointer.Texture} A texture to multiply terrain colors with.
	/// Defaults to `pointer_null`.
	Colormap = pointer_null;

	/// @var {SurfaceFormatType} Serialization capture format. Only
	/// `surface_rgba8unorm` (default) is currently supported.
	ColormapFormat = surface_rgba8unorm;

	/// @var {Asset.GMSprite} Sprite source for
	/// {@link BBMOD_TerrainInfo.Colormap}, or `undefined`.
	/// Takes precedence over the texture when defined.
	ColormapSprite = undefined;

	/// @var {Real} Subimage of
	/// {@link BBMOD_TerrainInfo.ColormapSprite} to use.
	ColormapSubimage = 0;

	/// @var {Bool} Whether this configuration owns
	/// {@link BBMOD_TerrainInfo.ColormapSprite}.
	ColormapOwned = false;

	/// @var {Struct.BBMOD_TerrainMaterial} The material used when rendering
	/// the terrain. Defaults to {@link BBMOD_MATERIAL_TERRAIN}.
	Material = BBMOD_MATERIAL_TERRAIN;

	/// @var {Array<Struct.BBMOD_TerrainLayer>} Array of five terrain layers.
	/// Use `undefined` entries to disable individual layers. Defaults to an
	/// array of five `undefined` entries. Each layer can be assigned to only one
	/// terrain.
	Layer = array_create(5, undefined);

	/// @var {Struct.BBMOD_Vec2} Controls material texture repeat over the
	/// terrain mesh. Defaults to `(1, 1)`.
	TextureRepeat = new BBMOD_Vec2(1.0);

	/// @var {Real} The width and height of a single terrain chunk in
	/// heightmap pixels. Defaults to `128`.
	ChunkSize = 128;

	/// @var {Real} The radius in chunks around the camera within which terrain
	/// chunks are visible. Use `infinity` to make all chunks visible. Defaults
	/// to `infinity`.
	ChunkRadius = infinity;

	/// @var {Bool} When `true`, terrain chunks are built lazily on submit; when
	/// `false`, normals, smooth normals, and all chunks are built immediately.
	/// Defaults to `false`.
	EnableLazyBuild = false;

	/// @var {Real} Time budget in milliseconds per frame for lazy chunk
	/// building. Use `infinity` for unlimited budget. Defaults to `infinity`.
	LazyBuildBudget = infinity;

	/// @var {Real} Minimum number of frames between lazy chunk build passes.
	/// Defaults to `1` (every frame).
	LazyBuildInterval = 1;

	/// @var {Bool} When `true`, the reflection-capture pass bypasses lazy-build
	/// interval and budget to guarantee chunk availability around reflection
	/// probes. Defaults to `true`.
	LazyBuildForceReflectionCapture = true;

	/// @var {Bool} When `true`, enables micro-profiling of terrain chunk build
	/// stages. Timings are available via
	/// {@link BBMOD_Terrain.get_build_profiler}. Defaults to `false`.
	EnableBuildProfiler = false;

	/// @var {Struct.BBMOD_Vec3} The position of the terrain in the world.
	/// Defaults to `(0, 0, 0)`.
	Position = new BBMOD_Vec3();

	/// @var {Struct.BBMOD_Vec3} The scale of the terrain. Defaults to
	/// `(1, 1, 1)`.
	Scale = new BBMOD_Vec3(1.0);

	/// @var {Real} The number of smoothing passes to apply to the heightmap
	/// after loading. Pass `0` to skip smoothing. Defaults to `1`.
	SmoothHeight = 1;

	/// @var {Bool} When `true`, smooth normals and tangents are computed
	/// during construction. Has no effect when `EnableLazyBuild` is `true`.
	/// Defaults to `true`.
	BuildSmoothNormals = true;

	/// @var {Bool} When `true`, all chunk meshes are built during construction.
	/// Has no effect when `EnableLazyBuild` is `true`. Defaults to `true`.
	BuildMesh = true;
}

/// @func BBMOD_Terrain([_info])
///
/// @implements {BBMOD_IDestructible}
///
/// @desc A heightmap-based terrain with five material layers controlled through
/// a splatmap.
///
/// @param {Struct.BBMOD_TerrainInfo} [_info] Properties to initialize the
/// terrain with.
function BBMOD_Terrain(_info = new BBMOD_TerrainInfo()) constructor
{
	////////////////////////////////////////////////////////////////////////////
	// Legacy arguments

	var _heightmap = undefined;

	if (!is_struct(_info))
	{
		_heightmap = _info;
		_info = new BBMOD_TerrainInfo();
	}
	else
	{
		_heightmap = _info.Heightmap;
	}

	var _subimage = (argument_count > 1) ? argument[1] : _info.Subimage;
	var _chunkSize = (argument_count > 2) ? argument[2] : _info.ChunkSize;

	////////////////////////////////////////////////////////////////////////////

	/// @var {Struct.BBMOD_RenderQueue} Render queue for terrain layers.
	/// @readonly
	/// @deprecated Use bbmod_render_queue_get(BBMOD_ERenderQueue.Terrain) instead.
	static RenderQueue = bbmod_render_queue_get(BBMOD_ERenderQueue.Terrain);

	/// @var {Struct.BBMOD_TerrainMaterial} The material used when rendering
	/// the terrain. Default is {@link BBMOD_MATERIAL_TERRAIN}.
	Material = _info.Material;

	/// @var {Array<Struct.BBMOD_TerrainLayer>} Array of five terrain layers.
	/// Use `undefined` to disable certain layers. Each layer can be assigned to
	/// only one terrain because the terrain destroys its layers on destruction.
	Layer = array_create(5, undefined);
	array_copy(Layer, 0, _info.Layer, 0, 5);

	/// @var {Pointer.Texture} A texture that controls visibility of individual
	/// layers. The first layer is always visible (if the material is not
	/// `undefined`), the red channel of the splatmap controls visibility of the
	/// second layer, the green channel controls the third layer etc.
	Splatmap = _info.Splatmap;

	/// @var {Asset.GMSprite} Sprite source for
	/// {@link BBMOD_Terrain.Splatmap}, or `undefined`.
	/// Takes precedence over the texture when defined.
	SplatmapSprite = _info.SplatmapSprite;

	/// @var {Real} Subimage of
	/// {@link BBMOD_Terrain.SplatmapSprite} to use.
	SplatmapSubimage = _info.SplatmapSubimage;

	/// @var {Bool} Whether this terrain owns
	/// {@link BBMOD_Terrain.SplatmapSprite}.
	SplatmapOwned = _info.SplatmapOwned;

	/// @var {SurfaceFormatType} Serialization capture format. Only
	/// `surface_rgba8unorm` (default) is currently supported.
	SplatmapFormat = _info.SplatmapFormat;

	/// @var {Pointer.Texture} A texture to multiply the terrain colors with.
	Colormap = _info.Colormap;

	/// @var {Asset.GMSprite} Sprite source for
	/// {@link BBMOD_Terrain.Colormap}, or `undefined`.
	/// Takes precedence over the texture when defined.
	ColormapSprite = _info.ColormapSprite;

	/// @var {Real} Subimage of
	/// {@link BBMOD_Terrain.ColormapSprite} to use.
	ColormapSubimage = _info.ColormapSubimage;

	/// @var {Bool} Whether this terrain owns
	/// {@link BBMOD_Terrain.ColormapSprite}.
	ColormapOwned = _info.ColormapOwned;

	/// @var {SurfaceFormatType} Serialization capture format. Only
	/// `surface_rgba8unorm` (default) is currently supported.
	ColormapFormat = _info.ColormapFormat;

	/// @var {Id.DsGrid}
	/// @private
	__splatmapGrid = ds_grid_create(1, 1);
	ds_grid_clear(__splatmapGrid, 0);

	/// @var {Struct.BBMOD_Vec2} Controls material texture repeat over the
	/// terrain mesh.
	TextureRepeat = new BBMOD_Vec2(_info.TextureRepeat.X, _info.TextureRepeat.Y);

	/// @var {Struct.BBMOD_Vec3} The position of the terrain in the world.
	Position = new BBMOD_Vec3(_info.Position.X, _info.Position.Y, _info.Position.Z);

	/// @var {Struct.BBMOD_Vec2} The width and height of the terrain in world
	/// units.
	/// @readonly
	Size = new BBMOD_Vec2();

	/// @var {Struct.BBMOD_Vec3} The scale of the terrain.
	Scale = new BBMOD_Vec3(_info.Scale.X, _info.Scale.Y, _info.Scale.Z);

	/// @var {Id.DsGrid} __height of individual vertices (on the z axis).
	/// @private
	__height = ds_grid_create(1, 1);

	/// @var {Id.DsGrid} Normal vector's X component of vertices.
	/// @private
	__normalX = ds_grid_create(1, 1);
	ds_grid_clear(__normalX, 0);

	/// @var {Id.DsGrid} Normal vector's Y component of vertices.
	/// @private
	__normalY = ds_grid_create(1, 1);
	ds_grid_clear(__normalY, 0);

	/// @var {Id.DsGrid} Normal vector's Z component of vertices.
	/// @private
	__normalZ = ds_grid_create(1, 1);
	ds_grid_clear(__normalZ, 1);

	/// @var {Id.DsGrid} Smooth normal vector's X component of vertices.
	/// @private
	__normalSmoothX = ds_grid_create(1, 1);
	ds_grid_clear(__normalSmoothX, 0);

	/// @var {Id.DsGrid} Smooth normal vector's Y component of vertices.
	/// @private
	__normalSmoothY = ds_grid_create(1, 1);
	ds_grid_clear(__normalSmoothY, 0);

	/// @var {Id.DsGrid} Smooth normal vector's Z component of vertices.
	/// @private
	__normalSmoothZ = ds_grid_create(1, 1);
	ds_grid_clear(__normalSmoothZ, 1);

	/// @var {Id.DsGrid} Smooth tangent vector's X component of vertices.
	/// @private
	__tangentSmoothX = ds_grid_create(1, 1);
	ds_grid_clear(__tangentSmoothX, -1);

	/// @var {Id.DsGrid} Smooth tangent vector's Y component of vertices.
	/// @private
	__tangentSmoothY = ds_grid_create(1, 1);
	ds_grid_clear(__tangentSmoothY, 0);

	/// @var {Id.DsGrid} Smooth tangent vector's Z component of vertices.
	/// @private
	__tangentSmoothZ = ds_grid_create(1, 1);
	ds_grid_clear(__tangentSmoothZ, 0);

	/// @var {Id.DsGrid} Smooth tangent bitangent-sign component of vertices.
	/// @private
	__tangentSmoothW = ds_grid_create(1, 1);
	ds_grid_clear(__tangentSmoothW, -1);

	/// @var {Struct.BBMOD_VertexFormat} The vertex format used by the terrain
	/// mesh.
	/// @readonly
	VertexFormat = BBMOD_VFORMAT_DEFAULT;

	/// @var {Id.VertexBuffer} The vertex buffer or `undefined` if the terrain
	/// was not built yet.
	/// @readonly
	/// @obsolete This property was replaced with {@link BBMOD_Terrain.Chunks}.
	VertexBuffer = undefined;

	/// @var {Real} The width and height of a single terrain chunk.
	ChunkSize = _chunkSize;

	/// @var {Id.DsGrid<Id.VertexBuffer>} Grid of vertex buffers, each representing
	/// an individual terrain chunk.
	Chunks = ds_grid_create(1, 1);

	ds_grid_clear(Chunks, undefined);

	/// @var {Id.DsGrid<Array<Real>>} Grid storing bounding sphere data for each chunk.
	/// Each entry is an array [centerX, centerY, centerZ, radius] in local space.
	/// @private
	__chunkBoundingSpheres = ds_grid_create(1, 1);

	ds_grid_clear(__chunkBoundingSpheres, undefined);

	/// @var {Id.DsGrid<Bool>} Tracks whether raw normals were built for each chunk.
	/// @private
	__chunkNormalsBuilt = ds_grid_create(1, 1);

	ds_grid_clear(__chunkNormalsBuilt, false);

	/// @var {Id.DsGrid<Bool>} Tracks whether smooth normals were built for each chunk.
	/// @private
	__chunkSmoothNormalsBuilt = ds_grid_create(1, 1);

	ds_grid_clear(__chunkSmoothNormalsBuilt, false);

	/// @var {Real} The radius (in chunk size) within which terrain chunks are visible
	/// around the camera. Zero means only the chunk that the camera is on is visible.
	/// Use `infinity` to make all chunks visible. Default value is `infinity`.
	/// @see bbmod_camera_set_position
	ChunkRadius = _info.ChunkRadius;

	/// @var {Bool} Enables lazy chunk building during terrain submission.
	/// Default value is `false`.
	EnableLazyBuild = _info.EnableLazyBuild;

	/// @var {Real} Time budget in milliseconds for lazy chunk building per frame.
	/// Use `infinity` for unlimited budget. Default value is `infinity`.
	LazyBuildBudget = _info.LazyBuildBudget;

	/// @var {Real} Lazy chunk build interval in frames. Chunk building can happen
	/// only every Nth frame. Default value is `1` (every frame).
	LazyBuildInterval = _info.LazyBuildInterval;

	/// @var {Bool} If `true`, reflection-capture pass bypasses lazy-build
	/// interval and budget to guarantee chunk availability around probes.
	/// Default value is `true`.
	LazyBuildForceReflectionCapture = _info.LazyBuildForceReflectionCapture;

	/// @var {Real}
	/// @private
	__lazyBuildFrameStamp = -1;

	/// @var {Real}
	/// @private
	__lazyBuildFrameIndex = -1;

	/// @var {Real}
	/// @private
	__lazyBuildElapsedUs = 0.0;

	/// @var {Bool}
	/// @private
	__lazyBuildBudgetReached = false;

	/// @var {Struct}
	/// @private
	__lazyBuildChunkJob = undefined;

	/// @var {Bool} Enables micro-profiling of terrain chunk build stages.
	/// Timings are measured using `get_timer()` and are reported in microseconds.
	EnableBuildProfiler = _info.EnableBuildProfiler;

	/// @var {Real}
	/// @private
	__buildProfilerChunkCount = 0;

	/// @var {Real}
	/// @private
	__buildProfilerTotalUs = 0.0;

	/// @var {Real}
	/// @private
	__buildProfilerSmoothNormalsUs = 0.0;

	/// @var {Real}
	/// @private
	__buildProfilerWriteVertexDataUs = 0.0;

	/// @var {Real}
	/// @private
	__buildProfilerFreezeUs = 0.0;

	/// @var {Real}
	/// @private
	__buildProfilerBoundsUs = 0.0;

	/// @var {Real}
	/// @private
	__buildProfilerLastChunkUs = 0.0;

	/// @var {Real}
	/// @private
	__buildProfilerMaxChunkUs = 0.0;

	/// @var {Real}
	/// @private
	__buildProfilerLastChunkI = -1;

	/// @var {Real}
	/// @private
	__buildProfilerLastChunkJ = -1;

	/// @var {Real}
	/// @private
	__buildProfilerLastVertexCount = 0;

	/// @func in_bounds(_x, _y)
	///
	/// @desc Checks whether the coordinate is within the terrain's bounds.
	///
	/// @param {Real} _x The x coordinate to check.
	/// @param {Real} _y The y coordinate to check.
	///
	/// @return {Bool} Returns `true` if the coordinate is within the terrain's
	/// bounds.
	static in_bounds = function (_x, _y)
	{
		gml_pragma("forceinline");
		return (_x >= Position.X && _x <= Position.X + (Size.X * Scale.X)
			&& _y >= Position.Y && _y <= Position.Y + (Size.Y * Scale.Y));
	};

	/// @func get_random_position()
	///
	/// @desc Retrieves a random position on the terrain.
	///
	/// @return {Struct.BBMOD_Vec3} A random position on the terrain.
	static get_random_position = function ()
	{
		gml_pragma("forceinline");
		var _x = Position.X + (random(Size.X) * Scale.X);
		var _y = Position.Y + (random(Size.Y) * Scale.Y);
		var _z = get_height(_x, _y);
		return new BBMOD_Vec3(_x, _y, _z);
	};

	/// @func reset_build_profiler()
	///
	/// @desc Resets all accumulated terrain chunk build profiler counters.
	///
	/// @return {Struct.BBMOD_Terrain} Returns `self`.
	static reset_build_profiler = function ()
	{
		__buildProfilerChunkCount = 0;
		__buildProfilerTotalUs = 0.0;
		__buildProfilerSmoothNormalsUs = 0.0;
		__buildProfilerWriteVertexDataUs = 0.0;
		__buildProfilerFreezeUs = 0.0;
		__buildProfilerBoundsUs = 0.0;
		__buildProfilerLastChunkUs = 0.0;
		__buildProfilerMaxChunkUs = 0.0;
		__buildProfilerLastChunkI = -1;
		__buildProfilerLastChunkJ = -1;
		__buildProfilerLastVertexCount = 0;
		return self;
	};

	/// @func get_build_profiler()
	///
	/// @desc Retrieves accumulated terrain chunk build profiler data.
	///
	/// @return {Struct} A struct with stage totals and averages in microseconds.
	static get_build_profiler = function ()
	{
		var _count = __buildProfilerChunkCount;
		var _countSafe = max(_count, 1);

		var _topStageName = "none";
		var _topStageUs = 0.0;

		if (_count > 0)
		{
			_topStageName = "smooth_normals";
			_topStageUs = __buildProfilerSmoothNormalsUs;

			if (__buildProfilerWriteVertexDataUs > _topStageUs)
			{
				_topStageName = "write_vertex_data";
				_topStageUs = __buildProfilerWriteVertexDataUs;
			}

			if (__buildProfilerFreezeUs > _topStageUs)
			{
				_topStageName = "freeze";
				_topStageUs = __buildProfilerFreezeUs;
			}

			if (__buildProfilerBoundsUs > _topStageUs)
			{
				_topStageName = "bounds";
				_topStageUs = __buildProfilerBoundsUs;
			}
		}

		return {
			Enabled: EnableBuildProfiler,
			ChunkCount: _count,
			LastChunkI: __buildProfilerLastChunkI,
			LastChunkJ: __buildProfilerLastChunkJ,
			LastVertexCount: __buildProfilerLastVertexCount,
			LastChunkUs: __buildProfilerLastChunkUs,
			MaxChunkUs: __buildProfilerMaxChunkUs,
			TotalChunkUs: __buildProfilerTotalUs,
			AvgChunkUs: __buildProfilerTotalUs / _countSafe,
			TopStageName: _topStageName,
			TopStageTotalUs: _topStageUs,
			TopStageAvgUs: _topStageUs / _countSafe,
			StageTotalUs:
			{
				SmoothNormals: __buildProfilerSmoothNormalsUs,
				WriteVertexData: __buildProfilerWriteVertexDataUs,
				Freeze: __buildProfilerFreezeUs,
				Bounds: __buildProfilerBoundsUs,
			},
			StageAvgUs:
			{
				SmoothNormals: __buildProfilerSmoothNormalsUs / _countSafe,
				WriteVertexData: __buildProfilerWriteVertexDataUs / _countSafe,
				Freeze: __buildProfilerFreezeUs / _countSafe,
				Bounds: __buildProfilerBoundsUs / _countSafe,
			},
		};
	};

	/// @func __invalidate_chunk_cache()
	///
	/// @desc Invalidates all chunk-dependent cached data.
	///
	/// @return {Struct.BBMOD_Terrain} Returns `self`.
	///
	/// @private
	static __invalidate_chunk_cache = function ()
	{
		var _chunksX = ds_grid_width(Chunks);
		var _chunksY = ds_grid_height(Chunks);

		for (var i = _chunksX - 1; i >= 0; --i)
		{
			for (var j = _chunksY - 1; j >= 0; --j)
			{
				var _chunk = Chunks[# i, j];
				if (_chunk != undefined)
				{
					vertex_delete_buffer(_chunk);
				}
			}
		}

		__lazy_build_cancel_job();

		ds_grid_clear(Chunks, undefined);
		ds_grid_clear(__chunkBoundingSpheres, undefined);
		ds_grid_clear(__chunkNormalsBuilt, false);
		ds_grid_clear(__chunkSmoothNormalsBuilt, false);
		__lazyBuildElapsedUs = 0.0;
		__lazyBuildBudgetReached = false;

		return self;
	};

	/// @func __is_chunk_visible(_chunkI, _chunkJ, _maxScale)
	///
	/// @desc Checks whether a chunk should be considered visible for
	/// submission/building.
	///
	/// @param {Real} _chunkI The X index of the chunk.
	/// @param {Real} _chunkJ The Y index of the chunk.
	/// @param {Real} _maxScale Maximum scale component of terrain transform.
	///
	/// @return {Bool} Returns `true` if the chunk is visible.
	///
	/// @private
	static __is_chunk_visible = function (_chunkI, _chunkJ, _maxScale)
	{
		if (!global.__bbmodFrustumCulling)
		{
			return true;
		}

		var _boundingSphere = __chunkBoundingSpheres[# _chunkI, _chunkJ];
		if (_boundingSphere == undefined)
		{
			return true;
		}

		var _worldX = Position.X + _boundingSphere[0] * Scale.X;
		var _worldY = Position.Y + _boundingSphere[1] * Scale.Y;
		var _worldZ = Position.Z + _boundingSphere[2] * Scale.Z;
		var _worldRadius = _boundingSphere[3] * _maxScale;

		return sphere_is_visible(_worldX, _worldY, _worldZ, _worldRadius);
	};

	/// @func __lazy_build_cancel_job()
	///
	/// @desc Cancels and disposes current incremental lazy-build job.
	///
	/// @return {Struct.BBMOD_Terrain} Returns `self`.
	///
	/// @private
	static __lazy_build_cancel_job = function ()
	{
		var _job = __lazyBuildChunkJob;
		if (_job != undefined)
		{
			if (_job.RawBuffer != -1)
			{
				buffer_delete(_job.RawBuffer);
				_job.RawBuffer = -1;
			}

			__lazyBuildChunkJob = undefined;
		}

		return self;
	};

	/// @func __lazy_build_start_job(_chunkI, _chunkJ)
	///
	/// @desc Creates an incremental lazy-build job for a missing chunk.
	///
	/// @param {Real} _chunkI The X index of the chunk.
	/// @param {Real} _chunkJ The Y index of the chunk.
	///
	/// @return {Bool} Returns `true` if a new job was created.
	///
	/// @private
	static __lazy_build_start_job = function (_chunkI, _chunkJ)
	{
		if (__lazyBuildChunkJob != undefined)
		{
			return false;
		}

		var _chunksX = ds_grid_width(Chunks);
		var _chunksY = ds_grid_height(Chunks);
		_chunkI = clamp(_chunkI, 0, _chunksX - 1);
		_chunkJ = clamp(_chunkJ, 0, _chunksY - 1);

		if (Chunks[# _chunkI, _chunkJ] != undefined)
		{
			return false;
		}

		var _height = __height;
		var _terrainWidth = ds_grid_width(_height);
		var _terrainHeight = ds_grid_height(_height);
		var _chunkIStart = _chunkI * ChunkSize;
		var _chunkJStart = _chunkJ * ChunkSize;
		var _chunkMinX = _chunkIStart;
		var _chunkMaxX = min((_chunkI + 1) * ChunkSize, _terrainWidth - 1);
		var _chunkMinY = _chunkJStart;
		var _chunkMaxY = min((_chunkJ + 1) * ChunkSize, _terrainHeight - 1);
		var _fromX = max(_chunkMinX - 1, 0);
		var _toX = min(_chunkMaxX + 1, _terrainWidth - 1);
		var _fromY = max(_chunkMinY - 1, 0);
		var _toY = min(_chunkMaxY + 1, _terrainHeight - 1);
		var _rows = min(_terrainWidth - 1 - _chunkIStart, ChunkSize);
		var _cols = min(_terrainHeight - 1 - _chunkJStart, ChunkSize);
		var _hasQuads = (_rows > 0 && _cols > 0);
		var _vertexCount = _hasQuads
			? (2 * _rows * (_cols + 1) + (_rows - 1) * 2)
			: 0;
		var _normalsBuilt = __chunkNormalsBuilt[# _chunkI, _chunkJ];
		var _smoothNormalsBuilt = __chunkSmoothNormalsBuilt[# _chunkI, _chunkJ];
		var _initialStage = 0;
		if (_normalsBuilt && _smoothNormalsBuilt)
		{
			_initialStage = 2;
		}
		else if (_normalsBuilt)
		{
			_initialStage = 1;
		}
		var _rawBuffer = -1;
		var _rawBufferSize = 0;

		if (_vertexCount > 0)
		{
			var _vertexStride = VertexFormat.get_byte_size();
			_rawBufferSize = _vertexCount * _vertexStride;
			_rawBuffer = buffer_create(_rawBufferSize, buffer_fixed, 1);
			buffer_seek(_rawBuffer, buffer_seek_start, 0);
		}

		var _invTerrainWidth = 1.0 / _terrainWidth;
		var _invTerrainHeight = 1.0 / _terrainHeight;

		__lazyBuildChunkJob = {
			ChunkI: _chunkI,
			ChunkJ: _chunkJ,
			ChunkIStart: _chunkIStart,
			ChunkJStart: _chunkJStart,
			ChunkJEnd: _chunkJStart + _cols,
			NormalsFromX: _fromX,
			NormalsToX: _toX,
			NormalsFromY: _fromY,
			NormalsToY: _toY,
			ChunkMinX: _chunkMinX,
			ChunkMaxX: _chunkMaxX,
			ChunkMinY: _chunkMinY,
			ChunkMaxY: _chunkMaxY,
			InvTerrainWidth: _invTerrainWidth,
			InvTerrainHeight: _invTerrainHeight,
			VStart: _chunkJStart * _invTerrainHeight,
			VEnd: (_chunkJStart + _cols) * _invTerrainHeight,
			Rows: _rows,
			Cols: _cols,
			VertexCount: _vertexCount,
			VertexWriteCount: 0,
			RawBuffer: _rawBuffer,
			RawBufferSize: _rawBufferSize,
			Stage: _initialStage,
			NormalsRowX: _fromX,
			SmoothRowX: _chunkMinX,
			MeshRow: 0,
			ProfileSmoothNormalsUs: 0.0,
			ProfileWriteVertexDataUs: 0.0,
			ProfileFreezeUs: 0.0,
			ProfileBoundsUs: 0.0,
		};

		return true;
	};

	/// @func __lazy_build_advance_active_job([_budgetUs])
	///
	/// @desc Advances the current incremental lazy-build job within the given
	/// time budget.
	///
	/// @param {Real} [_budgetUs] Time budget in microseconds.
	/// Defaults to `infinity`.
	///
	/// @return {Real} Returns consumed CPU time in microseconds.
	///
	/// @private
	static __lazy_build_advance_active_job = function (_budgetUs = infinity)
	{
		var _job = __lazyBuildChunkJob;
		if (_job == undefined)
		{
			return 0.0;
		}

		var _stepStartUs = get_timer();
		var _hasDeadline = (_budgetUs != infinity);
		var _deadlineUs = _hasDeadline ? (_stepStartUs + max(_budgetUs, 0.0)) : infinity;
		var _height = __height;
		var _epsilon = math_get_epsilon();

		while (true)
		{
			if (_job.Stage == 0)
			{
				while (_job.NormalsRowX <= _job.NormalsToX)
				{
					if (_hasDeadline && get_timer() >= _deadlineUs)
					{
						return max(get_timer() - _stepStartUs, 0.0);
					}

					var _rowStartUs = get_timer();
					var _iChunk = _job.NormalsRowX;

					for (var _jChunk = _job.NormalsFromY; _jChunk <= _job.NormalsToY; ++_jChunk)
					{
						var _nx = get_height_index(_iChunk - 1, _jChunk) - get_height_index(_iChunk + 1, _jChunk);
						var _ny = get_height_index(_iChunk, _jChunk - 1) - get_height_index(_iChunk, _jChunk + 1);
						var _nz = 2.0;
						var _r = sqrt(_nx * _nx + _ny * _ny + _nz * _nz);
						_nx /= _r;
						_ny /= _r;
						_nz /= _r;
						__normalX[# _iChunk, _jChunk] = _nx;
						__normalY[# _iChunk, _jChunk] = _ny;
						__normalZ[# _iChunk, _jChunk] = _nz;
					}

					_job.ProfileSmoothNormalsUs += max(get_timer() - _rowStartUs, 0.0);
					++_job.NormalsRowX;
				}

				__chunkNormalsBuilt[# _job.ChunkI, _job.ChunkJ] = true;
				__chunkSmoothNormalsBuilt[# _job.ChunkI, _job.ChunkJ] = false;
				_job.Stage = 1;
				continue;
			}

			if (_job.Stage == 1)
			{
				while (_job.SmoothRowX <= _job.ChunkMaxX)
				{
					if (_hasDeadline && get_timer() >= _deadlineUs)
					{
						return max(get_timer() - _stepStartUs, 0.0);
					}

					var _rowStartUs = get_timer();
					var _xChunk = _job.SmoothRowX;

					for (var _yChunk = _job.ChunkMinY; _yChunk <= _job.ChunkMaxY; ++_yChunk)
					{
						var _nx = ds_grid_get_mean(__normalX, _xChunk - 1, _yChunk - 1, _xChunk + 1, _yChunk + 1);
						var _ny = ds_grid_get_mean(__normalY, _xChunk - 1, _yChunk - 1, _xChunk + 1, _yChunk + 1);
						var _nz = ds_grid_get_mean(__normalZ, _xChunk - 1, _yChunk - 1, _xChunk + 1, _yChunk + 1);
						var _r = sqrt(_nx * _nx + _ny * _ny + _nz * _nz);
						_nx /= _r;
						_ny /= _r;
						_nz /= _r;

						var _bY = _nz;
						var _bZ = -_ny;
						var _bLengthSqr = _bY * _bY + _bZ * _bZ;
						if (_bLengthSqr > _epsilon)
						{
							var _invBLength = 1.0 / sqrt(_bLengthSqr);
							_bY *= _invBLength;
							_bZ *= _invBLength;
						}

						var _tX = _ny * _bZ - _nz * _bY;
						var _tY = -_nx * _bZ;
						var _tZ = _nx * _bY;
						var _tLengthSqr = _tX * _tX + _tY * _tY + _tZ * _tZ;
						if (_tLengthSqr > _epsilon)
						{
							var _invTLength = 1.0 / sqrt(_tLengthSqr);
							_tX *= _invTLength;
							_tY *= _invTLength;
							_tZ *= _invTLength;
						}

						var _s = ((_nx * _tX + _ny * _tY + _nz * _tZ) < 0.0) ? 1.0 : -1.0;

						__normalSmoothX[# _xChunk, _yChunk] = _nx;
						__normalSmoothY[# _xChunk, _yChunk] = _ny;
						__normalSmoothZ[# _xChunk, _yChunk] = _nz;
						__tangentSmoothX[# _xChunk, _yChunk] = _tX;
						__tangentSmoothY[# _xChunk, _yChunk] = _tY;
						__tangentSmoothZ[# _xChunk, _yChunk] = _tZ;
						__tangentSmoothW[# _xChunk, _yChunk] = _s;
					}

					_job.ProfileSmoothNormalsUs += max(get_timer() - _rowStartUs, 0.0);
					++_job.SmoothRowX;
				}

				__chunkSmoothNormalsBuilt[# _job.ChunkI, _job.ChunkJ] = true;
				_job.Stage = 2;
				continue;
			}

			if (_job.Stage == 2)
			{
				if (_job.VertexCount <= 0)
				{
					_job.Stage = 3;
					continue;
				}

				while (_job.MeshRow < _job.Rows)
				{
					if (_hasDeadline && get_timer() >= _deadlineUs)
					{
						return max(get_timer() - _stepStartUs, 0.0);
					}

					var _rowStartUs = get_timer();
					var _x0 = _job.ChunkIStart + _job.MeshRow;
					var _x1 = _x0 + 1;
					var _u0 = _x0 * _job.InvTerrainWidth;
					var _u1 = _x1 * _job.InvTerrainWidth;
					var _j = _job.ChunkJStart;

					repeat(_job.Cols + 1)
					{
						var _v = _j * _job.InvTerrainHeight;

						var _z = _height[# _x0, _j];
						var _nX = __normalSmoothX[# _x0, _j];
						var _nY = __normalSmoothY[# _x0, _j];
						var _nZ = __normalSmoothZ[# _x0, _j];
						var _tX = __tangentSmoothX[# _x0, _j];
						var _tY = __tangentSmoothY[# _x0, _j];
						var _tZ = __tangentSmoothZ[# _x0, _j];
						var _s = __tangentSmoothW[# _x0, _j];

						buffer_write(_job.RawBuffer, buffer_f32, _x0);
						buffer_write(_job.RawBuffer, buffer_f32, _j);
						buffer_write(_job.RawBuffer, buffer_f32, _z);
						buffer_write(_job.RawBuffer, buffer_f32, _nX);
						buffer_write(_job.RawBuffer, buffer_f32, _nY);
						buffer_write(_job.RawBuffer, buffer_f32, _nZ);
						buffer_write(_job.RawBuffer, buffer_f32, _u0);
						buffer_write(_job.RawBuffer, buffer_f32, _v);
						buffer_write(_job.RawBuffer, buffer_f32, _tX);
						buffer_write(_job.RawBuffer, buffer_f32, _tY);
						buffer_write(_job.RawBuffer, buffer_f32, _tZ);
						buffer_write(_job.RawBuffer, buffer_f32, _s);
						++_job.VertexWriteCount;

						_z = _height[# _x1, _j];
						_nX = __normalSmoothX[# _x1, _j];
						_nY = __normalSmoothY[# _x1, _j];
						_nZ = __normalSmoothZ[# _x1, _j];
						_tX = __tangentSmoothX[# _x1, _j];
						_tY = __tangentSmoothY[# _x1, _j];
						_tZ = __tangentSmoothZ[# _x1, _j];
						_s = __tangentSmoothW[# _x1, _j];

						buffer_write(_job.RawBuffer, buffer_f32, _x1);
						buffer_write(_job.RawBuffer, buffer_f32, _j);
						buffer_write(_job.RawBuffer, buffer_f32, _z);
						buffer_write(_job.RawBuffer, buffer_f32, _nX);
						buffer_write(_job.RawBuffer, buffer_f32, _nY);
						buffer_write(_job.RawBuffer, buffer_f32, _nZ);
						buffer_write(_job.RawBuffer, buffer_f32, _u1);
						buffer_write(_job.RawBuffer, buffer_f32, _v);
						buffer_write(_job.RawBuffer, buffer_f32, _tX);
						buffer_write(_job.RawBuffer, buffer_f32, _tY);
						buffer_write(_job.RawBuffer, buffer_f32, _tZ);
						buffer_write(_job.RawBuffer, buffer_f32, _s);
						++_job.VertexWriteCount;

						++_j;
					}

					if (_job.MeshRow < _job.Rows - 1)
					{
						var _z = _height[# _x1, _job.ChunkJEnd];
						var _nX = __normalSmoothX[# _x1, _job.ChunkJEnd];
						var _nY = __normalSmoothY[# _x1, _job.ChunkJEnd];
						var _nZ = __normalSmoothZ[# _x1, _job.ChunkJEnd];
						var _tX = __tangentSmoothX[# _x1, _job.ChunkJEnd];
						var _tY = __tangentSmoothY[# _x1, _job.ChunkJEnd];
						var _tZ = __tangentSmoothZ[# _x1, _job.ChunkJEnd];
						var _s = __tangentSmoothW[# _x1, _job.ChunkJEnd];

						buffer_write(_job.RawBuffer, buffer_f32, _x1);
						buffer_write(_job.RawBuffer, buffer_f32, _job.ChunkJEnd);
						buffer_write(_job.RawBuffer, buffer_f32, _z);
						buffer_write(_job.RawBuffer, buffer_f32, _nX);
						buffer_write(_job.RawBuffer, buffer_f32, _nY);
						buffer_write(_job.RawBuffer, buffer_f32, _nZ);
						buffer_write(_job.RawBuffer, buffer_f32, _u1);
						buffer_write(_job.RawBuffer, buffer_f32, _job.VEnd);
						buffer_write(_job.RawBuffer, buffer_f32, _tX);
						buffer_write(_job.RawBuffer, buffer_f32, _tY);
						buffer_write(_job.RawBuffer, buffer_f32, _tZ);
						buffer_write(_job.RawBuffer, buffer_f32, _s);
						++_job.VertexWriteCount;

						_z = _height[# _x1, _job.ChunkJStart];
						_nX = __normalSmoothX[# _x1, _job.ChunkJStart];
						_nY = __normalSmoothY[# _x1, _job.ChunkJStart];
						_nZ = __normalSmoothZ[# _x1, _job.ChunkJStart];
						_tX = __tangentSmoothX[# _x1, _job.ChunkJStart];
						_tY = __tangentSmoothY[# _x1, _job.ChunkJStart];
						_tZ = __tangentSmoothZ[# _x1, _job.ChunkJStart];
						_s = __tangentSmoothW[# _x1, _job.ChunkJStart];

						buffer_write(_job.RawBuffer, buffer_f32, _x1);
						buffer_write(_job.RawBuffer, buffer_f32, _job.ChunkJStart);
						buffer_write(_job.RawBuffer, buffer_f32, _z);
						buffer_write(_job.RawBuffer, buffer_f32, _nX);
						buffer_write(_job.RawBuffer, buffer_f32, _nY);
						buffer_write(_job.RawBuffer, buffer_f32, _nZ);
						buffer_write(_job.RawBuffer, buffer_f32, _u1);
						buffer_write(_job.RawBuffer, buffer_f32, _job.VStart);
						buffer_write(_job.RawBuffer, buffer_f32, _tX);
						buffer_write(_job.RawBuffer, buffer_f32, _tY);
						buffer_write(_job.RawBuffer, buffer_f32, _tZ);
						buffer_write(_job.RawBuffer, buffer_f32, _s);
						++_job.VertexWriteCount;
					}

					_job.ProfileWriteVertexDataUs += max(get_timer() - _rowStartUs, 0.0);
					++_job.MeshRow;
				}

				_job.Stage = 3;
				continue;
			}

			if (_job.Stage == 3)
			{
				if (_hasDeadline && get_timer() >= _deadlineUs)
				{
					return max(get_timer() - _stepStartUs, 0.0);
				}

				var _freezeStartUs = get_timer();
				var _vbuffer;

				if (_job.VertexCount > 0)
				{
					_vbuffer = vertex_create_buffer_from_buffer_ext(
						_job.RawBuffer, VertexFormat.Raw, 0, _job.VertexCount);
				}
				else
				{
					_vbuffer = vertex_create_buffer();
					vertex_begin(_vbuffer, VertexFormat.Raw);
					vertex_end(_vbuffer);
				}

				vertex_freeze(_vbuffer);
				Chunks[# _job.ChunkI, _job.ChunkJ] = _vbuffer;
				_job.ProfileFreezeUs += max(get_timer() - _freezeStartUs, 0.0);

				var _boundsStartUs = get_timer();
				var _heightMin = ds_grid_get_min(_height,
					_job.ChunkMinX, _job.ChunkMinY, _job.ChunkMaxX, _job.ChunkMaxY);
				var _heightMax = ds_grid_get_max(_height,
					_job.ChunkMinX, _job.ChunkMinY, _job.ChunkMaxX, _job.ChunkMaxY);
				var _centerX = (_job.ChunkMinX + _job.ChunkMaxX) * 0.5;
				var _centerY = (_job.ChunkMinY + _job.ChunkMaxY) * 0.5;
				var _centerZ = (_heightMin + _heightMax) * 0.5;
				var _halfSizeX = (_job.ChunkMaxX - _job.ChunkMinX) * 0.5;
				var _halfSizeY = (_job.ChunkMaxY - _job.ChunkMinY) * 0.5;
				var _halfSizeZ = (_heightMax - _heightMin) * 0.5;
				var _radius = sqrt(_halfSizeX * _halfSizeX
					+ _halfSizeY * _halfSizeY
					+ _halfSizeZ * _halfSizeZ);

				__chunkBoundingSpheres[# _job.ChunkI, _job.ChunkJ] = [_centerX, _centerY, _centerZ, _radius];
				_job.ProfileBoundsUs += max(get_timer() - _boundsStartUs, 0.0);

				if (EnableBuildProfiler)
				{
					var _chunkTotalUs = _job.ProfileSmoothNormalsUs
						+ _job.ProfileWriteVertexDataUs
						+ _job.ProfileFreezeUs
						+ _job.ProfileBoundsUs;

					++__buildProfilerChunkCount;
					__buildProfilerTotalUs += _chunkTotalUs;
					__buildProfilerSmoothNormalsUs += _job.ProfileSmoothNormalsUs;
					__buildProfilerWriteVertexDataUs += _job.ProfileWriteVertexDataUs;
					__buildProfilerFreezeUs += _job.ProfileFreezeUs;
					__buildProfilerBoundsUs += _job.ProfileBoundsUs;
					__buildProfilerLastChunkUs = _chunkTotalUs;
					__buildProfilerLastChunkI = _job.ChunkI;
					__buildProfilerLastChunkJ = _job.ChunkJ;
					__buildProfilerLastVertexCount = _job.VertexCount;

					if (_chunkTotalUs > __buildProfilerMaxChunkUs)
					{
						__buildProfilerMaxChunkUs = _chunkTotalUs;
					}
				}

				if (_job.RawBuffer != -1)
				{
					buffer_delete(_job.RawBuffer);
					_job.RawBuffer = -1;
				}

				__lazyBuildChunkJob = undefined;
				return max(get_timer() - _stepStartUs, 0.0);
			}

			__lazy_build_cancel_job();
			return max(get_timer() - _stepStartUs, 0.0);
		}
	};

	/// @func from_heightmap(_sprite[, _subimage])
	///
	/// @desc Initializes terrain height from a sprite.
	///
	/// @param {Asset.GMSprite} _sprite The heightmap sprite.
	/// @param {Real} [_subimage] The subimage to use for the heightmap.
	/// Defaults to 0.
	///
	/// @return {Struct.BBMOD_Terrain} Returns `self`.
	static from_heightmap = function (_sprite, _subimage = 0)
	{
		var _spriteWidth = sprite_get_width(_sprite);
		var _spriteHeight = sprite_get_height(_sprite);

		Size.X = _spriteWidth;
		Size.Y = _spriteHeight;

		ds_grid_resize(__height, _spriteWidth, _spriteHeight);
		ds_grid_clear(__height, 0);

		ds_grid_resize(__normalX, _spriteWidth, _spriteHeight);
		ds_grid_clear(__normalX, 0);

		ds_grid_resize(__normalY, _spriteWidth, _spriteHeight);
		ds_grid_clear(__normalY, 0);

		ds_grid_resize(__normalZ, _spriteWidth, _spriteHeight);
		ds_grid_clear(__normalZ, 1);

		ds_grid_resize(__normalSmoothX, _spriteWidth, _spriteHeight);
		ds_grid_clear(__normalSmoothX, 0);

		ds_grid_resize(__normalSmoothY, _spriteWidth, _spriteHeight);
		ds_grid_clear(__normalSmoothY, 0);

		ds_grid_resize(__normalSmoothZ, _spriteWidth, _spriteHeight);
		ds_grid_clear(__normalSmoothZ, 1);

		ds_grid_resize(__tangentSmoothX, _spriteWidth, _spriteHeight);
		ds_grid_clear(__tangentSmoothX, -1);

		ds_grid_resize(__tangentSmoothY, _spriteWidth, _spriteHeight);
		ds_grid_clear(__tangentSmoothY, 0);

		ds_grid_resize(__tangentSmoothZ, _spriteWidth, _spriteHeight);
		ds_grid_clear(__tangentSmoothZ, 0);

		ds_grid_resize(__tangentSmoothW, _spriteWidth, _spriteHeight);
		ds_grid_clear(__tangentSmoothW, -1);

		gpu_push_state();
		gpu_set_state(bbmod_gpu_get_default_state());

		var _surface = bbmod_surface_check(-1, _spriteWidth, _spriteHeight, surface_rgba8unorm, false);
		surface_set_target(_surface);
		draw_sprite(_sprite, _subimage, 0, 0);
		surface_reset_target();

		gpu_pop_state();

		var _buffer = buffer_create(_spriteWidth * _spriteHeight * 4, buffer_fast, 1);
		buffer_get_surface(_buffer, _surface, 0);
		surface_free(_surface);
		// Offset to the second byte, just in case the format was ARGB for example.
		buffer_seek(_buffer, buffer_seek_start, 1);

		var _j = 0;
		repeat(_spriteHeight)
		{
			var _i = 0;
			repeat(_spriteWidth)
				{
					__height[# _i++, _j] = buffer_read(_buffer, buffer_u8);
					buffer_seek(_buffer, buffer_seek_relative, 3);
				}
				++_j;
		}

		buffer_delete(_buffer);

		__invalidate_chunk_cache();

		var _chunksX = max(ceil(_spriteWidth / ChunkSize), 1);
		var _chunksY = max(ceil(_spriteHeight / ChunkSize), 1);

		ds_grid_resize(Chunks, _chunksX, _chunksY);
		ds_grid_clear(Chunks, undefined);

		ds_grid_resize(__chunkBoundingSpheres, _chunksX, _chunksY);
		ds_grid_clear(__chunkBoundingSpheres, undefined);

		ds_grid_resize(__chunkNormalsBuilt, _chunksX, _chunksY);
		ds_grid_clear(__chunkNormalsBuilt, false);

		ds_grid_resize(__chunkSmoothNormalsBuilt, _chunksX, _chunksY);
		ds_grid_clear(__chunkSmoothNormalsBuilt, false);

		return self;
	};

	/// @func smooth_height([_range])
	///
	/// @desc Smoothens out the terrain's height.
	///
	/// @param {Real} [_range] The range of the smoothing kernel. The wider the
	/// range, the smoother the terrain becomes. Defaults to 1.
	///
	/// @return {Struct.BBMOD_Terrain} Returns `self`.
	static smooth_height = function (_range = 1)
	{
		if (_range <= 0)
		{
			return self;
		}

		var _width = ds_grid_width(__height);
		var _height = ds_grid_height(__height);
		var _heightSmooth = ds_grid_create(_width, _height);

		for (var x1 = 0; x1 < _width; ++x1)
		{
			for (var y1 = 0; y1 < _height; ++y1)
			{
				_heightSmooth[# x1, y1] = ds_grid_get_mean(
					__height, x1 - _range, y1 - _range, x1 + _range, y1 + _range);
			}
		}

		ds_grid_copy(__height, _heightSmooth);
		ds_grid_destroy(_heightSmooth);
		__invalidate_chunk_cache();

		return self;
	};

	/// @func get_height_index(_i, _j)
	///
	/// @desc Retrieves terrain's height at given index.
	///
	/// @param {Real} _i The X coordinate in the terrain's height grid.
	/// @param {Real} _j The Y coordinate in the terrain's height grid.
	///
	/// @return {Real} The terrain's height at given index.
	static get_height_index = function (_i, _j)
	{
		gml_pragma("forceinline");
		return __height[# clamp(_i, 0, ds_grid_width(__height) - 1),
			clamp(_j, 0, ds_grid_height(__height) - 1)
		];
	};

	/// @func get_height(_x, _y)
	///
	/// @desc Retrieves terrain's height at given coordinate.
	///
	/// @param {Real} _x The x position to get the height at.
	/// @param {Real} _y The y position to get the height at.
	///
	/// @return {Real} The terrain's height at given coordinate or `undefined`
	/// if the coordinate is outside of the terrain.
	static get_height = function (_x, _y)
	{
		gml_pragma("forceinline");
		var _xScaled = (_x - Position.X) / Scale.X;
		var _yScaled = (_y - Position.Y) / Scale.Y;
		if (_xScaled < 0.0 || _xScaled > Size.X
			|| _yScaled < 0.0 || _yScaled > Size.Y)
		{
			return undefined;
		}
		var _imax = ds_grid_width(__height) - 1;
		var _jmax = ds_grid_height(__height) - 1;
		var _i1 = floor(_xScaled);
		var _j1 = floor(_yScaled);
		var _h1 = __height[# clamp(_i1, 0, _imax), clamp(_j1, 0, _jmax)];
		var _h2 = __height[# clamp(_i1 + 1, 0, _imax), clamp(_j1, 0, _jmax)];
		var _h3 = __height[# clamp(_i1 + 1, 0, _imax), clamp(_j1 + 1, 0, _jmax)];
		var _h4 = __height[# clamp(_i1, 0, _imax), clamp(_j1 + 1, 0, _jmax)];
		var _offsetX = frac(_xScaled);
		var _offsetY = frac(_yScaled);
		var _height;
		if (_offsetX <= _offsetY)
		{
			_height = _h4 + (_h1 - _h4) * (1.0 - _offsetY) + (_h3 - _h4) * _offsetX;
		}
		else
		{
			_height = _h2 + (_h1 - _h2) * (1.0 - _offsetX) + (_h3 - _h2) * _offsetY;
		}
		return Position.Z + _height * Scale.Z;
	};

	/// @func get_normal(_x, _y)
	///
	/// @desc Retrieves terrain's normal at given coordinate.
	///
	/// @param {Real} _x The x position to get the normal at.
	/// @param {Real} _y The y position to get the normal at.
	///
	/// @return {Struct.BBMOD_Vec3} The terrain's normal at given coordinate or
	/// `undefined` if the coordinate is outside of the terrain.
	static get_normal = function (_x, _y)
	{
		gml_pragma("forceinline");
		var _xScaled = (_x - Position.X) / Scale.X;
		var _yScaled = (_y - Position.Y) / Scale.Y;
		if (_xScaled < 0.0 || _xScaled > Size.X
			|| _yScaled < 0.0 || _yScaled > Size.Y)
		{
			return undefined;
		}

		var _chunkI = clamp(floor(_xScaled / ChunkSize), 0, ds_grid_width(Chunks) - 1);
		var _chunkJ = clamp(floor(_yScaled / ChunkSize), 0, ds_grid_height(Chunks) - 1);
		build_normals(_chunkI, _chunkJ);

		var _imax = ds_grid_width(__height) - 1;
		var _jmax = ds_grid_height(__height) - 1;
		var _i1 = floor(_xScaled);
		var _j1 = floor(_yScaled);
		var _h1 = __height[# clamp(_i1, 0, _imax), clamp(_j1, 0, _jmax)];
		var _h2 = __height[# clamp(_i1 + 1, 0, _imax), clamp(_j1, 0, _jmax)];
		var _h3 = __height[# clamp(_i1 + 1, 0, _imax), clamp(_j1 + 1, 0, _jmax)];
		var _h4 = __height[# clamp(_i1, 0, _imax), clamp(_j1 + 1, 0, _jmax)];
		var _offsetX = frac(_xScaled);
		var _offsetY = frac(_yScaled);
		var _scaleX = Scale.X;
		var _scaleY = Scale.Y;
		var _scaleZ = Scale.Z;
		var _normalX;
		var _normalY;
		var _normalZ = _scaleX * _scaleY;

		if (_offsetX <= _offsetY)
		{
			var _dz14 = (_h1 - _h4) * _scaleZ;
			var _dz34 = (_h3 - _h4) * _scaleZ;
			_normalX = -_scaleY * _dz34;
			_normalY = _scaleX * _dz14;
		}
		else
		{
			var _dz32 = (_h3 - _h2) * _scaleZ;
			var _dz12 = (_h1 - _h2) * _scaleZ;
			_normalX = _scaleY * _dz12;
			_normalY = -_scaleX * _dz32;
		}

		var _normalLengthSqr = _normalX * _normalX + _normalY * _normalY + _normalZ * _normalZ;
		if (_normalLengthSqr > math_get_epsilon())
		{
			var _invNormalLength = 1.0 / sqrt(_normalLengthSqr);
			_normalX *= _invNormalLength;
			_normalY *= _invNormalLength;
			_normalZ *= _invNormalLength;
		}

		return new BBMOD_Vec3(_normalX, _normalY, _normalZ);
	};

	/// @func get_smooth_normal(_x, _y)
	///
	/// @desc Retrieves terrain's smooth normal at given coordinate.
	///
	/// @param {Real} _x The x position to get the smooth normal at.
	/// @param {Real} _y The y position to get the smooth normal at.
	///
	/// @return {Struct.BBMOD_Vec3} The terrain's smooth normal at given
	/// coordinate or `undefined` if the coordinate is outside of the terrain.
	static get_smooth_normal = function (_x, _y)
	{
		gml_pragma("forceinline");
		var _xScaled = (_x - Position.X) / Scale.X;
		var _yScaled = (_y - Position.Y) / Scale.Y;
		if (_xScaled < 0.0 || _xScaled > Size.X
			|| _yScaled < 0.0 || _yScaled > Size.Y)
		{
			return undefined;
		}

		var _chunksX = ds_grid_width(Chunks);
		var _chunksY = ds_grid_height(Chunks);
		var _chunkI1 = clamp(floor(_xScaled / ChunkSize), 0, _chunksX - 1);
		var _chunkJ1 = clamp(floor(_yScaled / ChunkSize), 0, _chunksY - 1);

		var _imax = ds_grid_width(__height) - 1;
		var _jmax = ds_grid_height(__height) - 1;
		var _i1 = clamp(floor(_xScaled), 0, _imax);
		var _j1 = clamp(floor(_yScaled), 0, _jmax);
		var _i2 = clamp(_i1 + 1, 0, _imax);
		var _j2 = clamp(_j1 + 1, 0, _jmax);

		var _chunkI2 = clamp(floor(_i2 / ChunkSize), 0, _chunksX - 1);
		var _chunkJ2 = clamp(floor(_j2 / ChunkSize), 0, _chunksY - 1);

		build_smooth_normals(_chunkI1, _chunkJ1);
		if (_chunkI2 != _chunkI1)
		{
			build_smooth_normals(_chunkI2, _chunkJ1);
		}
		if (_chunkJ2 != _chunkJ1)
		{
			build_smooth_normals(_chunkI1, _chunkJ2);
		}
		if (_chunkI2 != _chunkI1 && _chunkJ2 != _chunkJ1)
		{
			build_smooth_normals(_chunkI2, _chunkJ2);
		}

		var _n1X = __normalSmoothX[# _i1, _j1];
		var _n1Y = __normalSmoothY[# _i1, _j1];
		var _n1Z = __normalSmoothZ[# _i1, _j1];
		var _n2X = __normalSmoothX[# _i2, _j1];
		var _n2Y = __normalSmoothY[# _i2, _j1];
		var _n2Z = __normalSmoothZ[# _i2, _j1];
		var _n3X = __normalSmoothX[# _i2, _j2];
		var _n3Y = __normalSmoothY[# _i2, _j2];
		var _n3Z = __normalSmoothZ[# _i2, _j2];
		var _n4X = __normalSmoothX[# _i1, _j2];
		var _n4Y = __normalSmoothY[# _i1, _j2];
		var _n4Z = __normalSmoothZ[# _i1, _j2];

		var _offsetX = frac(_xScaled);
		var _offsetY = frac(_yScaled);
		var _normalX;
		var _normalY;
		var _normalZ;

		if (_offsetX <= _offsetY)
		{
			_normalX = _n4X + (_n1X - _n4X) * (1.0 - _offsetY) + (_n3X - _n4X) * _offsetX;
			_normalY = _n4Y + (_n1Y - _n4Y) * (1.0 - _offsetY) + (_n3Y - _n4Y) * _offsetX;
			_normalZ = _n4Z + (_n1Z - _n4Z) * (1.0 - _offsetY) + (_n3Z - _n4Z) * _offsetX;
		}
		else
		{
			_normalX = _n2X + (_n1X - _n2X) * (1.0 - _offsetX) + (_n3X - _n2X) * _offsetY;
			_normalY = _n2Y + (_n1Y - _n2Y) * (1.0 - _offsetX) + (_n3Y - _n2Y) * _offsetY;
			_normalZ = _n2Z + (_n1Z - _n2Z) * (1.0 - _offsetX) + (_n3Z - _n2Z) * _offsetY;
		}

		_normalX /= Scale.X;
		_normalY /= Scale.Y;
		_normalZ /= Scale.Z;

		var _normalLengthSqr = _normalX * _normalX + _normalY * _normalY + _normalZ * _normalZ;
		if (_normalLengthSqr > math_get_epsilon())
		{
			var _invNormalLength = 1.0 / sqrt(_normalLengthSqr);
			_normalX *= _invNormalLength;
			_normalY *= _invNormalLength;
			_normalZ *= _invNormalLength;
		}

		return new BBMOD_Vec3(_normalX, _normalY, _normalZ);
	};

	/// @func get_layer(_x, _y[, _threshold])
	///
	/// @desc Retrieves the topmost splatmap layer at given coordinate.
	///
	/// @param {Real} _x The x coordinate to retrieve the layer at.
	/// @param {Real} _y The y coordinate to retrieve the layer at.
	/// @param {Real} [_threshold] The minimum required opacity. Defaults to 0.5.
	///
	/// @return {Real} The topmost splatmap layer at given coordinate. Returns
	/// `undefined` if the coordinate is outside of the terrain or if no layer
	/// was found!
	///
	/// @note Method {@link BBMOD_Terrain.build_layer_index} needs to be called
	/// first!
	static get_layer = function (_x, _y, _threshold = 0.5)
	{
		gml_pragma("forceinline");
		var _xScaled = (_x - Position.X) / Scale.X;
		var _yScaled = (_y - Position.Y) / Scale.Y;
		if (_xScaled < 0.0 || _xScaled > Size.X
			|| _yScaled < 0.0 || _yScaled > Size.Y)
		{
			return undefined;
		}
		var _i = floor((_xScaled / Size.X) * ds_grid_width(__splatmapGrid));
		var _j = floor((_yScaled / Size.Y) * ds_grid_height(__splatmapGrid));
		var _rgba = __splatmapGrid[# _i, _j];

		for (var _layerIndex = 4; _layerIndex >= 1; --_layerIndex)
		{
			if (Layer[_layerIndex] != undefined)
			{
				var _shift = (4 - _layerIndex) * 8;
				var _opacity = ((_rgba >> _shift) & $FF) / 255.0;
				if (_opacity >= _threshold)
				{
					return _layerIndex;
				}
			}
		}

		return ((Layer[0] != undefined) ? 0 : undefined);
	};

	/// @func build_normals([_chunkI, _chunkJ])
	///
	/// @desc Rebuilds normal vectors for the whole terrain or for a specific
	/// chunk.
	///
	/// @param {Real} [_chunkI] The X index of the chunk to rebuild.
	/// @param {Real} [_chunkJ] The Y index of the chunk to rebuild.
	///
	/// @return {Struct.BBMOD_Terrain} Returns `self`.
	static build_normals = function (_chunkI = undefined, _chunkJ = undefined)
	{
		if (_chunkI == undefined || _chunkJ == undefined)
		{
			var _i = 0;
			repeat(ds_grid_width(__height))
			{
				var _j = 0;
				repeat(ds_grid_height(__height))
					{
						var _nx = get_height_index(_i - 1, _j) - get_height_index(_i + 1, _j);
						var _ny = get_height_index(_i, _j - 1) - get_height_index(_i, _j + 1);
						var _nz = 2.0;
						var _r = sqrt(_nx * _nx + _ny * _ny + _nz * _nz);
						_nx /= _r;
						_ny /= _r;
						_nz /= _r;
						__normalX[# _i, _j] = _nx;
						__normalY[# _i, _j] = _ny;
						__normalZ[# _i, _j] = _nz;
						++_j;
					}
					++_i;
			}

			ds_grid_clear(__chunkNormalsBuilt, true);
			ds_grid_clear(__chunkSmoothNormalsBuilt, false);

			return self;
		}

		var _chunksX = ds_grid_width(Chunks);
		var _chunksY = ds_grid_height(Chunks);
		_chunkI = clamp(_chunkI, 0, _chunksX - 1);
		_chunkJ = clamp(_chunkJ, 0, _chunksY - 1);

		if (__chunkNormalsBuilt[# _chunkI, _chunkJ])
		{
			return self;
		}

		var _terrainWidth = ds_grid_width(__height);
		var _terrainHeight = ds_grid_height(__height);
		var _chunkMinX = _chunkI * ChunkSize;
		var _chunkMaxX = min((_chunkI + 1) * ChunkSize, _terrainWidth - 1);
		var _chunkMinY = _chunkJ * ChunkSize;
		var _chunkMaxY = min((_chunkJ + 1) * ChunkSize, _terrainHeight - 1);
		var _fromX = max(_chunkMinX - 1, 0);
		var _toX = min(_chunkMaxX + 1, _terrainWidth - 1);
		var _fromY = max(_chunkMinY - 1, 0);
		var _toY = min(_chunkMaxY + 1, _terrainHeight - 1);

		for (var _iChunk = _fromX; _iChunk <= _toX; ++_iChunk)
		{
			for (var _jChunk = _fromY; _jChunk <= _toY; ++_jChunk)
			{
				var _nx = get_height_index(_iChunk - 1, _jChunk) - get_height_index(_iChunk + 1, _jChunk);
				var _ny = get_height_index(_iChunk, _jChunk - 1) - get_height_index(_iChunk, _jChunk + 1);
				var _nz = 2.0;
				var _r = sqrt(_nx * _nx + _ny * _ny + _nz * _nz);
				_nx /= _r;
				_ny /= _r;
				_nz /= _r;
				__normalX[# _iChunk, _jChunk] = _nx;
				__normalY[# _iChunk, _jChunk] = _ny;
				__normalZ[# _iChunk, _jChunk] = _nz;
			}
		}

		__chunkNormalsBuilt[# _chunkI, _chunkJ] = true;
		__chunkSmoothNormalsBuilt[# _chunkI, _chunkJ] = false;

		return self;
	};

	/// @func build_smooth_normals([_chunkI, _chunkJ])
	///
	/// @desc Rebuilds smooth normals for the whole terrain or for a specific
	/// chunk.
	///
	/// @param {Real} [_chunkI] The X index of the chunk to rebuild.
	/// @param {Real} [_chunkJ] The Y index of the chunk to rebuild.
	///
	/// @return {Struct.BBMOD_Terrain} Returns `self`.
	///
	/// @note {@link BBMOD_Terrain.build_normals} should be called first.
	static build_smooth_normals = function (_chunkI = undefined, _chunkJ = undefined)
	{
		var _epsilon = math_get_epsilon();

		if (_chunkI == undefined || _chunkJ == undefined)
		{
			build_normals();

			var _width = ds_grid_width(__height);
			var _height = ds_grid_height(__height);
			for (var x1 = 0; x1 < _width; ++x1)
			{
				for (var y1 = 0; y1 < _height; ++y1)
				{
					var _nx = ds_grid_get_mean(__normalX, x1 - 1, y1 - 1, x1 + 1, y1 + 1);
					var _ny = ds_grid_get_mean(__normalY, x1 - 1, y1 - 1, x1 + 1, y1 + 1);
					var _nz = ds_grid_get_mean(__normalZ, x1 - 1, y1 - 1, x1 + 1, y1 + 1);
					var _r = sqrt(_nx * _nx + _ny * _ny + _nz * _nz);
					_nx /= _r;
					_ny /= _r;
					_nz /= _r;

					var _bY = _nz;
					var _bZ = -_ny;
					var _bLengthSqr = _bY * _bY + _bZ * _bZ;
					if (_bLengthSqr > _epsilon)
					{
						var _invBLength = 1.0 / sqrt(_bLengthSqr);
						_bY *= _invBLength;
						_bZ *= _invBLength;
					}

					var _tX = _ny * _bZ - _nz * _bY;
					var _tY = -_nx * _bZ;
					var _tZ = _nx * _bY;
					var _tLengthSqr = _tX * _tX + _tY * _tY + _tZ * _tZ;
					if (_tLengthSqr > _epsilon)
					{
						var _invTLength = 1.0 / sqrt(_tLengthSqr);
						_tX *= _invTLength;
						_tY *= _invTLength;
						_tZ *= _invTLength;
					}

					var _s = ((_nx * _tX + _ny * _tY + _nz * _tZ) < 0.0) ? 1.0 : -1.0;

					__normalSmoothX[# x1, y1] = _nx;
					__normalSmoothY[# x1, y1] = _ny;
					__normalSmoothZ[# x1, y1] = _nz;
					__tangentSmoothX[# x1, y1] = _tX;
					__tangentSmoothY[# x1, y1] = _tY;
					__tangentSmoothZ[# x1, y1] = _tZ;
					__tangentSmoothW[# x1, y1] = _s;
				}
			}

			ds_grid_clear(__chunkSmoothNormalsBuilt, true);

			return self;
		}

		var _chunksX = ds_grid_width(Chunks);
		var _chunksY = ds_grid_height(Chunks);
		_chunkI = clamp(_chunkI, 0, _chunksX - 1);
		_chunkJ = clamp(_chunkJ, 0, _chunksY - 1);

		if (__chunkSmoothNormalsBuilt[# _chunkI, _chunkJ])
		{
			return self;
		}

		build_normals(_chunkI, _chunkJ);

		var _terrainWidth = ds_grid_width(__height);
		var _terrainHeight = ds_grid_height(__height);
		var _chunkMinX = _chunkI * ChunkSize;
		var _chunkMaxX = min((_chunkI + 1) * ChunkSize, _terrainWidth - 1);
		var _chunkMinY = _chunkJ * ChunkSize;
		var _chunkMaxY = min((_chunkJ + 1) * ChunkSize, _terrainHeight - 1);

		for (var _xChunk = _chunkMinX; _xChunk <= _chunkMaxX; ++_xChunk)
		{
			for (var _yChunk = _chunkMinY; _yChunk <= _chunkMaxY; ++_yChunk)
			{
				var _nx = ds_grid_get_mean(__normalX, _xChunk - 1, _yChunk - 1, _xChunk + 1, _yChunk + 1);
				var _ny = ds_grid_get_mean(__normalY, _xChunk - 1, _yChunk - 1, _xChunk + 1, _yChunk + 1);
				var _nz = ds_grid_get_mean(__normalZ, _xChunk - 1, _yChunk - 1, _xChunk + 1, _yChunk + 1);
				var _r = sqrt(_nx * _nx + _ny * _ny + _nz * _nz);
				_nx /= _r;
				_ny /= _r;
				_nz /= _r;

				var _bY = _nz;
				var _bZ = -_ny;
				var _bLengthSqr = _bY * _bY + _bZ * _bZ;
				if (_bLengthSqr > _epsilon)
				{
					var _invBLength = 1.0 / sqrt(_bLengthSqr);
					_bY *= _invBLength;
					_bZ *= _invBLength;
				}

				var _tX = _ny * _bZ - _nz * _bY;
				var _tY = -_nx * _bZ;
				var _tZ = _nx * _bY;
				var _tLengthSqr = _tX * _tX + _tY * _tY + _tZ * _tZ;
				if (_tLengthSqr > _epsilon)
				{
					var _invTLength = 1.0 / sqrt(_tLengthSqr);
					_tX *= _invTLength;
					_tY *= _invTLength;
					_tZ *= _invTLength;
				}

				var _s = ((_nx * _tX + _ny * _tY + _nz * _tZ) < 0.0) ? 1.0 : -1.0;

				__normalSmoothX[# _xChunk, _yChunk] = _nx;
				__normalSmoothY[# _xChunk, _yChunk] = _ny;
				__normalSmoothZ[# _xChunk, _yChunk] = _nz;
				__tangentSmoothX[# _xChunk, _yChunk] = _tX;
				__tangentSmoothY[# _xChunk, _yChunk] = _tY;
				__tangentSmoothZ[# _xChunk, _yChunk] = _tZ;
				__tangentSmoothW[# _xChunk, _yChunk] = _s;
			}
		}

		__chunkSmoothNormalsBuilt[# _chunkI, _chunkJ] = true;

		return self;
	};

	/// @func build_layer_index()
	///
	/// @desc Builds an index of layers using the current splatmap.
	///
	/// @return {Struct.BBMOD_Terrain} Returns `self`.
	static build_layer_index = function ()
	{
		var _width = 1.0 / texture_get_texel_width(Splatmap);
		var _height = 1.0 / texture_get_texel_height(Splatmap);
		var _buffer = array_create(4);
		var _surface = bbmod_surface_check(-1, _width, _height, surface_rgba8unorm, false);

		gpu_push_state();
		gpu_set_state(bbmod_gpu_get_default_state());
		gpu_set_blendenable(false);

		for (var i = 0; i < 4; ++i)
		{
			shader_set(BBMOD_ShExtractSplatmapLayer);
			texture_set_stage(shader_get_sampler_index(BBMOD_ShExtractSplatmapLayer, BBMOD_U_SPLATMAP), Splatmap);
			shader_set_uniform_i(shader_get_uniform(BBMOD_ShExtractSplatmapLayer, BBMOD_U_SPLATMAP_INDEX), i);

			surface_set_target(_surface);
			draw_clear_alpha(0, 0);
			// We just need something that has UVs 0..1
			draw_sprite_stretched(BBMOD_SprWhite, 0, 0, 0, _width, _height);
			surface_reset_target();

			shader_reset();

			_buffer[@ i] = buffer_create(_width * _height * 4, buffer_fast, 1);
			buffer_get_surface(_buffer[i], _surface, 0);
			// Offset to the second byte, just in case the format was ARGB for example.
			buffer_seek(_buffer[i], buffer_seek_start, 1);
		}

		gpu_pop_state();
		surface_free(_surface);

		ds_grid_resize(__splatmapGrid, _width, _height);
		ds_grid_clear(__splatmapGrid, 0);

		var _j = 0;
		repeat(_height)
		{
			var _i = 0;
			repeat(_width)
				{
					__splatmapGrid[# _i, _j] = (0
						| (buffer_read(_buffer[0], buffer_u8) << 24)
						| (buffer_read(_buffer[1], buffer_u8) << 16)
						| (buffer_read(_buffer[2], buffer_u8) << 8)
						| buffer_read(_buffer[3], buffer_u8));
					buffer_seek(_buffer[0], buffer_seek_relative, 3);
					buffer_seek(_buffer[1], buffer_seek_relative, 3);
					buffer_seek(_buffer[2], buffer_seek_relative, 3);
					buffer_seek(_buffer[3], buffer_seek_relative, 3);
					++_i;
				}
				++_j;
		}

		buffer_delete(_buffer[0]);
		buffer_delete(_buffer[1]);
		buffer_delete(_buffer[2]);
		buffer_delete(_buffer[3]);

		return self;
	};

	/// @func build_chunk(_chunkI, _chunkJ)
	///
	/// @desc Force-rebuilds a chunk mesh even if it's not dirty and clears
	/// its dirty state.
	///
	/// @param {Real} _chunkI The X index of the chunk.
	/// @param {Real} _chunkJ The Y index of the chunk.
	///
	/// @return {Struct.BBMOD_Terrain} Returns `self`.
	static build_chunk = function (_chunkI, _chunkJ)
	{
		var _chunksX = ds_grid_width(Chunks);
		var _chunksY = ds_grid_height(Chunks);
		_chunkI = clamp(_chunkI, 0, _chunksX - 1);
		_chunkJ = clamp(_chunkJ, 0, _chunksY - 1);

		if (__lazyBuildChunkJob != undefined)
		{
			__lazy_build_cancel_job();
		}

		var _profileEnabled = EnableBuildProfiler;
		var _profileChunkStartUs = 0.0;
		var _profileStageStartUs = 0.0;
		var _profileSmoothNormalsUs = 0.0;
		var _profileWriteVertexDataUs = 0.0;
		var _profileFreezeUs = 0.0;
		var _profileBoundsUs = 0.0;

		if (_profileEnabled)
		{
			_profileChunkStartUs = get_timer();
			_profileStageStartUs = _profileChunkStartUs;
		}

		build_smooth_normals(_chunkI, _chunkJ);

		if (_profileEnabled)
		{
			var _stageNowUs = get_timer();
			_profileSmoothNormalsUs = _stageNowUs - _profileStageStartUs;
			_profileStageStartUs = _stageNowUs;
		}

		var _chunk = Chunks[# _chunkI, _chunkJ];
		if (_chunk != undefined)
		{
			vertex_delete_buffer(_chunk);
		}

		var _height = __height;
		var _terrainWidth = ds_grid_width(_height);
		var _terrainHeight = ds_grid_height(_height);
		var _rows = min(_terrainWidth - 1 - _chunkI * ChunkSize, ChunkSize);
		var _cols = min(_terrainHeight - 1 - _chunkJ * ChunkSize, ChunkSize);

		var _hasQuads = (_rows > 0 && _cols > 0);
		var _vertexCount = _hasQuads
			? (2 * _rows * (_cols + 1) + (_rows - 1) * 2)
			: 0;
		var _vbuffer;

		if (_vertexCount > 0)
		{
			_vbuffer = vertex_create_buffer();
			vertex_begin(_vbuffer, VertexFormat.Raw);

			var _chunkIStart = _chunkI * ChunkSize;
			var _chunkJStart = _chunkJ * ChunkSize;
			var _chunkJEnd = _chunkJStart + _cols;
			var _invTerrainWidth = 1.0 / _terrainWidth;
			var _invTerrainHeight = 1.0 / _terrainHeight;
			var _vStart = _chunkJStart * _invTerrainHeight;
			var _vEnd = _chunkJEnd * _invTerrainHeight;

			var _row = 0;
			repeat(_rows)
			{
				var _x0 = _chunkIStart + _row;
				var _x1 = _x0 + 1;
				var _u0 = _x0 * _invTerrainWidth;
				var _u1 = _x1 * _invTerrainWidth;

				var _j = _chunkJStart;
				repeat(_cols + 1)
				{
					var _v = _j * _invTerrainHeight;

					var _z = _height[# _x0, _j];
					var _nX = __normalSmoothX[# _x0, _j];
					var _nY = __normalSmoothY[# _x0, _j];
					var _nZ = __normalSmoothZ[# _x0, _j];
					var _tX = __tangentSmoothX[# _x0, _j];
					var _tY = __tangentSmoothY[# _x0, _j];
					var _tZ = __tangentSmoothZ[# _x0, _j];
					var _s = __tangentSmoothW[# _x0, _j];

					vertex_position_3d(_vbuffer, _x0, _j, _z);
					vertex_normal(_vbuffer, _nX, _nY, _nZ);
					vertex_texcoord(_vbuffer, _u0, _v);
					vertex_float4(_vbuffer, _tX, _tY, _tZ, _s);

					_z = _height[# _x1, _j];
					_nX = __normalSmoothX[# _x1, _j];
					_nY = __normalSmoothY[# _x1, _j];
					_nZ = __normalSmoothZ[# _x1, _j];
					_tX = __tangentSmoothX[# _x1, _j];
					_tY = __tangentSmoothY[# _x1, _j];
					_tZ = __tangentSmoothZ[# _x1, _j];
					_s = __tangentSmoothW[# _x1, _j];

					vertex_position_3d(_vbuffer, _x1, _j, _z);
					vertex_normal(_vbuffer, _nX, _nY, _nZ);
					vertex_texcoord(_vbuffer, _u1, _v);
					vertex_float4(_vbuffer, _tX, _tY, _tZ, _s);

					++_j;
				}

				if (_row < _rows - 1)
				{
					var _z = _height[# _x1, _chunkJEnd];
					var _nX = __normalSmoothX[# _x1, _chunkJEnd];
					var _nY = __normalSmoothY[# _x1, _chunkJEnd];
					var _nZ = __normalSmoothZ[# _x1, _chunkJEnd];
					var _tX = __tangentSmoothX[# _x1, _chunkJEnd];
					var _tY = __tangentSmoothY[# _x1, _chunkJEnd];
					var _tZ = __tangentSmoothZ[# _x1, _chunkJEnd];
					var _s = __tangentSmoothW[# _x1, _chunkJEnd];

					vertex_position_3d(_vbuffer, _x1, _chunkJEnd, _z);
					vertex_normal(_vbuffer, _nX, _nY, _nZ);
					vertex_texcoord(_vbuffer, _u1, _vEnd);
					vertex_float4(_vbuffer, _tX, _tY, _tZ, _s);

					_z = _height[# _x1, _chunkJStart];
					_nX = __normalSmoothX[# _x1, _chunkJStart];
					_nY = __normalSmoothY[# _x1, _chunkJStart];
					_nZ = __normalSmoothZ[# _x1, _chunkJStart];
					_tX = __tangentSmoothX[# _x1, _chunkJStart];
					_tY = __tangentSmoothY[# _x1, _chunkJStart];
					_tZ = __tangentSmoothZ[# _x1, _chunkJStart];
					_s = __tangentSmoothW[# _x1, _chunkJStart];

					vertex_position_3d(_vbuffer, _x1, _chunkJStart, _z);
					vertex_normal(_vbuffer, _nX, _nY, _nZ);
					vertex_texcoord(_vbuffer, _u1, _vStart);
					vertex_float4(_vbuffer, _tX, _tY, _tZ, _s);
				}

				++_row;
			}

			vertex_end(_vbuffer);

			if (_profileEnabled)
			{
				var _stageNowUs = get_timer();
				_profileWriteVertexDataUs = _stageNowUs - _profileStageStartUs;
				_profileStageStartUs = _stageNowUs;
			}
		}
		else
		{
			_vbuffer = vertex_create_buffer();
			vertex_begin(_vbuffer, VertexFormat.Raw);
			vertex_end(_vbuffer);

			if (_profileEnabled)
			{
				var _stageNowUs = get_timer();
				_profileWriteVertexDataUs = _stageNowUs - _profileStageStartUs;
				_profileStageStartUs = _stageNowUs;
			}
		}

		vertex_freeze(_vbuffer);
		Chunks[# _chunkI, _chunkJ] = _vbuffer;

		if (_profileEnabled)
		{
			var _stageNowUs = get_timer();
			_profileFreezeUs = _stageNowUs - _profileStageStartUs;
			_profileStageStartUs = _stageNowUs;
		}

		// Compute and store bounding sphere for this chunk
		var _chunkMinX = _chunkI * ChunkSize;
		var _chunkMaxX = min((_chunkI + 1) * ChunkSize, _terrainWidth - 1);
		var _chunkMinY = _chunkJ * ChunkSize;
		var _chunkMaxY = min((_chunkJ + 1) * ChunkSize, _terrainHeight - 1);

		// Get min/max height for this chunk
		var _heightMin = ds_grid_get_min(_height, _chunkMinX, _chunkMinY, _chunkMaxX, _chunkMaxY);
		var _heightMax = ds_grid_get_max(_height, _chunkMinX, _chunkMinY, _chunkMaxX, _chunkMaxY);

		// Compute bounding sphere center in local space
		var _centerX = (_chunkMinX + _chunkMaxX) * 0.5;
		var _centerY = (_chunkMinY + _chunkMaxY) * 0.5;
		var _centerZ = (_heightMin + _heightMax) * 0.5;

		// Compute bounding sphere radius in local space
		var _halfSizeX = (_chunkMaxX - _chunkMinX) * 0.5;
		var _halfSizeY = (_chunkMaxY - _chunkMinY) * 0.5;
		var _halfSizeZ = (_heightMax - _heightMin) * 0.5;
		var _radius = sqrt(_halfSizeX * _halfSizeX + _halfSizeY * _halfSizeY + _halfSizeZ * _halfSizeZ);

		// Store bounding sphere data
		__chunkBoundingSpheres[# _chunkI, _chunkJ] = [_centerX, _centerY, _centerZ, _radius];

		if (_profileEnabled)
		{
			var _stageNowUs = get_timer();
			_profileBoundsUs = _stageNowUs - _profileStageStartUs;
			var _chunkTotalUs = _stageNowUs - _profileChunkStartUs;

			++__buildProfilerChunkCount;
			__buildProfilerTotalUs += _chunkTotalUs;
			__buildProfilerSmoothNormalsUs += _profileSmoothNormalsUs;
			__buildProfilerWriteVertexDataUs += _profileWriteVertexDataUs;
			__buildProfilerFreezeUs += _profileFreezeUs;
			__buildProfilerBoundsUs += _profileBoundsUs;
			__buildProfilerLastChunkUs = _chunkTotalUs;
			__buildProfilerLastChunkI = _chunkI;
			__buildProfilerLastChunkJ = _chunkJ;
			__buildProfilerLastVertexCount = _vertexCount;

			if (_chunkTotalUs > __buildProfilerMaxChunkUs)
			{
				__buildProfilerMaxChunkUs = _chunkTotalUs;
			}
		}

		return self;
	};

	/// @func build_mesh()
	///
	/// @desc Rebuilds all dirty chunks of the terrain mesh.
	///
	/// @return {Struct.BBMOD_Terrain} Returns `self`.
	static build_mesh = function ()
	{
		var _chunksX = ds_grid_width(Chunks);
		var _chunksY = ds_grid_height(Chunks);

		var i = 0;
		repeat(_chunksX)
		{
			var j = 0;
			repeat(_chunksY)
				{
					build_chunk(i, j);
					++j;
				}
				++i;
		}

		return self;
	};

	/// @func submit()
	///
	/// @desc Immediately submits the terrain mesh for rendering.
	///
	/// @return {Struct.BBMOD_Terrain} Returns `self`.
	static submit = function ()
	{
		if (!Material.apply(VertexFormat))
		{
			return self;
		}

		var _shader = Material.get_shader(BBMOD_ERenderPass.GBuffer)
			?? Material.get_shader(BBMOD_ERenderPass.Forward);
		if (_shader == undefined)
		{
			return self;
		}

		var _layersPerDrawCall = _shader.LayersPerDrawCall;
		var _layers = [];
		var _layerIndices = [];
		for (var i = 0; i < min(_shader.MaxLayers, 5); ++i)
		{
			var _layer = Layer[i];
			if (_layer != undefined)
			{
				array_push(_layers, _layer);
				array_push(_layerIndices, i);
			}
		}

		var _layerCount = array_length(_layers);
		if (_layerCount == 0)
		{
			return self;
		}

		var _matrix = matrix_build(Position.X, Position.Y, Position.Z, 0, 0, 0, Scale.X, Scale.Y, Scale.Z);
		var _normalMatrix = bbmod_matrix_build_normalmatrix(_matrix);
		matrix_set(matrix_world, _matrix);

		var _chunksX = ds_grid_width(Chunks);
		var _chunksY = ds_grid_height(Chunks);
		var _terrainWidth = ds_grid_width(__height);
		var _terrainHeight = ds_grid_height(__height);
		var _camPos = bbmod_camera_get_position();
		var _renderPass = bbmod_render_pass_get();
		var _isReflectionCapturePass = (_renderPass == BBMOD_ERenderPass.ReflectionCapture);
		var _maxScale = max(Scale.X, Scale.Y, Scale.Z);

		var _chunkFromX, _chunkFromY, _chunkToX, _chunkToY;

		if (ChunkRadius == infinity)
		{
			_chunkFromX = 0;
			_chunkFromY = 0;
			_chunkToX = _chunksX;
			_chunkToY = _chunksY;
		}
		else
		{
			var _camI = clamp(((_camPos.X - Position.X) / Scale.X) / ChunkSize, 0, _chunksX);
			var _camJ = clamp(((_camPos.Y - Position.Y) / Scale.Y) / ChunkSize, 0, _chunksY);
			_chunkFromX = clamp(floor(_camI - ChunkRadius), 0, _chunksX);
			_chunkFromY = clamp(floor(_camJ - ChunkRadius), 0, _chunksY);
			_chunkToX = clamp(ceil(_camI + ChunkRadius), 0, _chunksX);
			_chunkToY = clamp(ceil(_camJ + ChunkRadius), 0, _chunksY);
		}

		var _frameStamp = current_time;
		if (_frameStamp != __lazyBuildFrameStamp)
		{
			__lazyBuildFrameStamp = _frameStamp;
			++__lazyBuildFrameIndex;
			__lazyBuildElapsedUs = 0.0;
			__lazyBuildBudgetReached = false;
		}

		var _canBuildChunks = true;
		var _buildBudgetUs = infinity;
		if (EnableLazyBuild)
		{
			var _lazyBuildInterval = max(floor(LazyBuildInterval), 1);
			_canBuildChunks = ((__lazyBuildFrameIndex mod _lazyBuildInterval) == 0)
				&& !__lazyBuildBudgetReached;
			_buildBudgetUs = (LazyBuildBudget == infinity) ? infinity : max(LazyBuildBudget, 0.0) * 1000.0;

			if (_isReflectionCapturePass && LazyBuildForceReflectionCapture)
			{
				_canBuildChunks = true;
				_buildBudgetUs = infinity;
				__lazyBuildBudgetReached = false;
			}
		}
		else
		{
			__lazyBuildBudgetReached = false;
			__lazy_build_cancel_job();
		}

		if (_canBuildChunks)
		{
			var _activeJob = __lazyBuildChunkJob;
			var _activeChunkI = (_activeJob != undefined) ? _activeJob.ChunkI : -1;
			var _activeChunkJ = (_activeJob != undefined) ? _activeJob.ChunkJ : -1;

			var _missingChunks = ds_priority_create();

			var _iChunk = _chunkFromX;
			repeat(_chunkToX - _chunkFromX)
			{
				var _jChunk = _chunkFromY;
				repeat(_chunkToY - _chunkFromY)
					{
						if (Chunks[# _iChunk, _jChunk] == undefined
							&& __is_chunk_visible(_iChunk, _jChunk, _maxScale)
							&& !(_iChunk == _activeChunkI && _jChunk == _activeChunkJ))
						{
							var _chunkMinX = _iChunk * ChunkSize;
							var _chunkMaxX = min((_iChunk + 1) * ChunkSize, _terrainWidth - 1);
							var _chunkMinY = _jChunk * ChunkSize;
							var _chunkMaxY = min((_jChunk + 1) * ChunkSize, _terrainHeight - 1);
							var _chunkCenterX = Position.X + ((_chunkMinX + _chunkMaxX) * 0.5) * Scale.X;
							var _chunkCenterY = Position.Y + ((_chunkMinY + _chunkMaxY) * 0.5) * Scale.Y;
							var _dx = _chunkCenterX - _camPos.X;
							var _dy = _chunkCenterY - _camPos.Y;
							var _priority = _dx * _dx + _dy * _dy;
							ds_priority_add(_missingChunks, _iChunk * _chunksY + _jChunk, _priority);
						}
						++_jChunk;
					}
					++_iChunk;
			}

			while (true)
			{
				if (__lazyBuildChunkJob == undefined)
				{
					if (ds_priority_size(_missingChunks) <= 0)
					{
						break;
					}

					var _packedChunk = ds_priority_delete_min(_missingChunks);
					var _buildI = floor(_packedChunk / _chunksY);
					var _buildJ = floor(_packedChunk - _buildI * _chunksY);

					if (EnableLazyBuild)
					{
						if (!__lazy_build_start_job(_buildI, _buildJ))
						{
							continue;
						}
					}
					else
					{
						build_chunk(_buildI, _buildJ);
						continue;
					}
				}

				var _remainingBudgetUs = (_buildBudgetUs == infinity)
					? infinity
					: max(_buildBudgetUs - __lazyBuildElapsedUs, 0.0);

				if (_remainingBudgetUs <= 0.0 && _buildBudgetUs != infinity)
				{
					__lazyBuildBudgetReached = true;
					break;
				}

				var _spentUs = __lazy_build_advance_active_job(_remainingBudgetUs);

				if (_buildBudgetUs != infinity)
				{
					__lazyBuildElapsedUs += max(_spentUs, 0.0);
					if (__lazyBuildElapsedUs >= _buildBudgetUs)
					{
						__lazyBuildBudgetReached = true;
						break;
					}
				}

				if (__lazyBuildChunkJob != undefined)
				{
					break;
				}
			}

			ds_priority_destroy(_missingChunks);
		}

		var _shaderRaw = shader_current();
		var _uSplatmap = shader_get_sampler_index(_shaderRaw, BBMOD_U_SPLATMAP);
		var _uSplatmapIndex = array_create(_layersPerDrawCall, -1);
		var _uColormap = shader_get_sampler_index(_shaderRaw, BBMOD_U_COLORMAP);
		var _uTextureScale = shader_get_uniform(_shaderRaw, BBMOD_U_TEXTURE_SCALE);
		var _uNormalMatrix = shader_get_uniform(_shaderRaw, BBMOD_U_NORMAL_MATRIX);
		var _uTerrainBaseOpacity = array_create(_layersPerDrawCall, -1);
		var _uTerrainNormalW = array_create(_layersPerDrawCall, -1);
		var _uTerrainIsRoughness = array_create(_layersPerDrawCall, -1);

		for (var i = 0; i < _layersPerDrawCall; ++i)
		{
			var _iStr = string(i);
			_uSplatmapIndex[@ i] = shader_get_uniform(_shaderRaw, BBMOD_U_SPLATMAP_INDEX + _iStr);
			_uTerrainBaseOpacity[@ i] = shader_get_sampler_index(_shaderRaw, BBMOD_U_TERRAIN_BASE_OPACITY + _iStr);
			_uTerrainNormalW[@ i] = shader_get_sampler_index(_shaderRaw, BBMOD_U_TERRAIN_NORMAL_W + _iStr);
			_uTerrainIsRoughness[@ i] = shader_get_uniform(_shaderRaw, BBMOD_U_TERRAIN_IS_ROUGHNESS + _iStr);
		}

		texture_set_stage(_uSplatmap, Splatmap);
		texture_set_stage(_uColormap, Colormap);
		shader_set_uniform_f(_uTextureScale, TextureRepeat.X, TextureRepeat.Y);
		shader_set_uniform_matrix_array(_uNormalMatrix, _normalMatrix);

		gpu_push_state();

		var _baseOpacityFirst = -1;
		var _normalWDefault = sprite_get_texture(BBMOD_SprDefaultNormalW, 0);

		// For non-visual passes (Depth, Shadows, InstanceId, etc.), only render
		// once since all layers produce identical data
		var _isVisualPass = (_renderPass == BBMOD_ERenderPass.Forward
			|| _renderPass == BBMOD_ERenderPass.ReflectionCapture
			|| _renderPass == BBMOD_ERenderPass.GBuffer);

		for (var _call = 0; _call < _layerCount; _call += _layersPerDrawCall)
		{
			if (_call == 0)
			{
				//gpu_set_blendenable(false);
				//gpu_set_colorwriteenable(true, true, true, true);
			}
			else
			{
				//gpu_set_blendenable(true);
				//gpu_set_colorwriteenable(true, true, true, false);

				if (!_isVisualPass)
				{
					break;
				}
			}

			// For non-visual passes, we only need the first layer's base
			// opacity. No need to set up all layer textures/uniforms since they
			// don't affect depth/shadows/etc.
			if (_isVisualPass)
			{
				for (var i = 0; i < _layersPerDrawCall; ++i)
				{
					var _layerCallIndex = _call + i;
					if (_layerCallIndex < _layerCount)
					{
						var _layer = _layers[_layerCallIndex];
						var _layerNormalRoughness = _layer[$ "NormalRoughness"];
						var _baseOpacity = bbmod_texture_ref_resolve(
							_layer.BaseOpacity,
							_layer.BaseOpacitySprite,
							_layer.BaseOpacitySubimage);

						if (i == 0)
						{
							_baseOpacityFirst = _baseOpacity;
						}
						else
						{
							texture_set_stage(_uTerrainBaseOpacity[i], _baseOpacity);
						}

						shader_set_uniform_i(_uSplatmapIndex[i], _layerIndices[_call + i] - 1);
						texture_set_stage(_uTerrainNormalW[i], _layerNormalRoughness ?? (_layer[$ "NormalSmoothness"]
							?? _normalWDefault));
						shader_set_uniform_f(_uTerrainIsRoughness[i], (_layerNormalRoughness != undefined) ? 1.0
							: 0.0);
					}
					else
					{
						shader_set_uniform_i(_uSplatmapIndex[i], -1);
					}
				}
			}
			else
			{
				// For non-visual passes, just get the base opacity from the
				// first layer
				if (_layerCount > 0)
				{
					_baseOpacityFirst = bbmod_texture_ref_resolve(
						_layers[0].BaseOpacity,
						_layers[0].BaseOpacitySprite,
						_layers[0].BaseOpacitySubimage);
				}
			}

			// Submit all chunks once per draw call (not per layer)
			var _i = _chunkFromX;
			repeat(_chunkToX - _chunkFromX)
			{
				var _j = _chunkFromY;
				repeat(_chunkToY - _chunkFromY)
					{
						var _chunk = Chunks[# _i, _j];
						var _isVisible = __is_chunk_visible(_i, _j, _maxScale);

						if (_isVisible)
						{
							if (_chunk != undefined)
							{
								__bbmod_render_statistics_count(
									__BBMOD_ERenderStatisticsCounter.TerrainDrawCallsDrawn);
								vertex_submit(_chunk, pr_trianglestrip, _baseOpacityFirst);
							}
						}
						else
						{
							__bbmod_render_statistics_count(
								__BBMOD_ERenderStatisticsCounter.TerrainDrawCallsFrustumCulled);
						}
						++_j;
					}
					++_i;
			}
		}

		gpu_pop_state();

		return self;
	};

	/// @func render()
	///
	/// @desc Enqueues the terrain mesh for rendering.
	///
	/// @return {Struct.BBMOD_Terrain} Returns `self`.
	static render = function ()
	{
		RenderQueue.DrawTerrain(self);
		return self;
	};

	static destroy = function ()
	{
		__lazy_build_cancel_job();
		for (var i = array_length(Layer) - 1; i >= 0; --i)
		{
			var _layer = Layer[i];
			if (_layer != undefined)
			{
				_layer.destroy();
				Layer[i] = undefined;
			}
		}
		bbmod_texture_ref_destroy(self, "Splatmap");
		bbmod_texture_ref_destroy(self, "Colormap");

		ds_grid_destroy(__splatmapGrid);
		ds_grid_destroy(__height);
		ds_grid_destroy(__normalX);
		ds_grid_destroy(__normalY);
		ds_grid_destroy(__normalZ);
		ds_grid_destroy(__normalSmoothX);
		ds_grid_destroy(__normalSmoothY);
		ds_grid_destroy(__normalSmoothZ);
		ds_grid_destroy(__tangentSmoothX);
		ds_grid_destroy(__tangentSmoothY);
		ds_grid_destroy(__tangentSmoothZ);
		ds_grid_destroy(__tangentSmoothW);
		ds_grid_destroy(__chunkNormalsBuilt);
		ds_grid_destroy(__chunkSmoothNormalsBuilt);

		for (var i = ds_grid_width(Chunks) - 1; i >= 0; --i)
		{
			for (var j = ds_grid_height(Chunks) - 1; j >= 0; --j)
			{
				var _chunk = Chunks[# i, j];
				if (_chunk != undefined)
				{
					vertex_delete_buffer(_chunk);
				}
			}
		}

		ds_grid_destroy(Chunks);
		ds_grid_destroy(__chunkBoundingSpheres);

		return undefined;
	};

	if (_heightmap != undefined)
	{
		from_heightmap(_heightmap, _subimage);
		smooth_height(_info.SmoothHeight);
		if (!EnableLazyBuild)
		{
			build_normals();
			if (_info.BuildSmoothNormals)
			{
				build_smooth_normals();
			}
			if (_info.BuildMesh)
			{
				build_mesh();
			}
		}
	}
}
