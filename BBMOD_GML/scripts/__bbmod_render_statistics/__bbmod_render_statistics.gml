/// @module Core

/// @enum Internal counter identifiers used by render-statistics helpers.
/// @private
enum __BBMOD_ERenderStatisticsCounter
{
	MeshDrawCallsDrawn = 0,
		MeshDrawCallsFrustumCulled,
		MeshDrawCallsDistanceCulled,
		AnimatedMeshDrawCallsDrawn,
		AnimatedMeshDrawCallsFrustumCulled,
		AnimatedMeshDrawCallsDistanceCulled,
		BatchedMeshDrawCallsDrawn,
		BatchedMeshDrawCallsFrustumCulled,
		BatchedMeshDrawCallsDistanceCulled,
		TerrainDrawCallsDrawn,
		TerrainDrawCallsFrustumCulled,
		SpriteDrawCallsDrawn,
		ShadowmapUpdatesDrawn,
		ShadowmapUpdatesSkippedFrustum,
		ShadowmapUpdatesSkippedSchedule,
		PunctualLightsUsed,
		PunctualLightsSkippedDisabled,
		PunctualLightsSkippedFrustum,
		PunctualLightsSkippedDistance,
};

/// @func BBMOD_RenderStatistics()
///
/// @desc Render statistics grouped by render pass.
function BBMOD_RenderStatistics() constructor
{
	static __counter_create = function ()
	{
		return array_create(BBMOD_ERenderPass.SIZE, 0);
	};

	/// @var {Array<Real>} Number of drawn static-mesh draw calls per pass.
	MeshDrawCallsDrawn = __counter_create();

	/// @var {Array<Real>} Number of frustum-culled static-mesh draw calls per
	/// pass.
	MeshDrawCallsFrustumCulled = __counter_create();

	/// @var {Array<Real>} Number of distance-culled static-mesh draw calls per
	/// pass.
	MeshDrawCallsDistanceCulled = __counter_create();

	/// @var {Array<Real>} Number of drawn animated-mesh draw calls per pass.
	AnimatedMeshDrawCallsDrawn = __counter_create();

	/// @var {Array<Real>} Number of frustum-culled animated-mesh draw calls per
	/// pass.
	AnimatedMeshDrawCallsFrustumCulled = __counter_create();

	/// @var {Array<Real>} Number of distance-culled animated-mesh draw calls per
	/// pass.
	AnimatedMeshDrawCallsDistanceCulled = __counter_create();

	/// @var {Array<Real>} Number of drawn batched-mesh instances per pass.
	BatchedMeshDrawCallsDrawn = __counter_create();

	/// @var {Array<Real>} Number of frustum-culled batched-mesh instances per
	/// pass.
	BatchedMeshDrawCallsFrustumCulled = __counter_create();

	/// @var {Array<Real>} Number of distance-culled batched-mesh instances per
	/// pass.
	BatchedMeshDrawCallsDistanceCulled = __counter_create();

	/// @var {Array<Real>} Number of drawn terrain chunk draw calls per pass.
	TerrainDrawCallsDrawn = __counter_create();

	/// @var {Array<Real>} Number of frustum-culled terrain chunk draw calls per
	/// pass.
	TerrainDrawCallsFrustumCulled = __counter_create();

	/// @var {Array<Real>} Number of drawn sprite draw calls per pass.
	SpriteDrawCallsDrawn = __counter_create();

	/// @var {Array<Real>} Number of drawn shadowmap updates per pass.
	ShadowmapUpdatesDrawn = __counter_create();

	/// @var {Array<Real>} Number of frustum-skipped shadowmap updates per pass.
	ShadowmapUpdatesSkippedFrustum = __counter_create();

	/// @var {Array<Real>} Number of schedule-skipped shadowmap updates per pass.
	ShadowmapUpdatesSkippedSchedule = __counter_create();

	/// @var {Array<Real>} Number of used punctual lights per pass.
	PunctualLightsUsed = __counter_create();

	/// @var {Array<Real>} Number of disabled punctual lights skipped per pass.
	PunctualLightsSkippedDisabled = __counter_create();

	/// @var {Array<Real>} Number of frustum-culled punctual lights skipped per
	/// pass.
	PunctualLightsSkippedFrustum = __counter_create();

	/// @var {Array<Real>} Number of distance-faded punctual lights skipped per
	/// pass.
	PunctualLightsSkippedDistance = __counter_create();

	/// @func reset()
	///
	/// @desc Resets all counters to zero.
	///
	/// @return {Struct.BBMOD_RenderStatistics} Returns `self`.
	static reset = function ()
	{
		var _counters = [
			MeshDrawCallsDrawn,
			MeshDrawCallsFrustumCulled,
			MeshDrawCallsDistanceCulled,
			AnimatedMeshDrawCallsDrawn,
			AnimatedMeshDrawCallsFrustumCulled,
			AnimatedMeshDrawCallsDistanceCulled,
			BatchedMeshDrawCallsDrawn,
			BatchedMeshDrawCallsFrustumCulled,
			BatchedMeshDrawCallsDistanceCulled,
			TerrainDrawCallsDrawn,
			TerrainDrawCallsFrustumCulled,
			SpriteDrawCallsDrawn,
			ShadowmapUpdatesDrawn,
			ShadowmapUpdatesSkippedFrustum,
			ShadowmapUpdatesSkippedSchedule,
			PunctualLightsUsed,
			PunctualLightsSkippedDisabled,
			PunctualLightsSkippedFrustum,
			PunctualLightsSkippedDistance
		];

		var i = 0;
		repeat(array_length(_counters))
		{
			var _counter = _counters[i];
			++i;
			var j = 0;
			repeat(array_length(_counter))
			{
				_counter[@ j] = 0;
				++j;
			}
		}

		return self;
	};

	/// @func copy_from(_stats)
	///
	/// @desc Copies all counters from another render-statistics struct.
	///
	/// @param {Struct.BBMOD_RenderStatistics} _stats Source statistics.
	///
	/// @return {Struct.BBMOD_RenderStatistics} Returns `self`.
	static copy_from = function (_stats)
	{
		array_copy(MeshDrawCallsDrawn, 0, _stats.MeshDrawCallsDrawn, 0, BBMOD_ERenderPass.SIZE);
		array_copy(MeshDrawCallsFrustumCulled, 0, _stats.MeshDrawCallsFrustumCulled, 0,
			BBMOD_ERenderPass.SIZE);
		array_copy(MeshDrawCallsDistanceCulled, 0, _stats.MeshDrawCallsDistanceCulled, 0,
			BBMOD_ERenderPass.SIZE);
		array_copy(AnimatedMeshDrawCallsDrawn, 0, _stats.AnimatedMeshDrawCallsDrawn, 0,
			BBMOD_ERenderPass.SIZE);
		array_copy(AnimatedMeshDrawCallsFrustumCulled, 0, _stats.AnimatedMeshDrawCallsFrustumCulled, 0,
			BBMOD_ERenderPass.SIZE);
		array_copy(AnimatedMeshDrawCallsDistanceCulled, 0, _stats.AnimatedMeshDrawCallsDistanceCulled, 0,
			BBMOD_ERenderPass.SIZE);
		array_copy(BatchedMeshDrawCallsDrawn, 0, _stats.BatchedMeshDrawCallsDrawn, 0,
			BBMOD_ERenderPass.SIZE);
		array_copy(BatchedMeshDrawCallsFrustumCulled, 0, _stats.BatchedMeshDrawCallsFrustumCulled, 0,
			BBMOD_ERenderPass.SIZE);
		array_copy(BatchedMeshDrawCallsDistanceCulled, 0, _stats.BatchedMeshDrawCallsDistanceCulled, 0,
			BBMOD_ERenderPass.SIZE);
		array_copy(TerrainDrawCallsDrawn, 0, _stats.TerrainDrawCallsDrawn, 0,
			BBMOD_ERenderPass.SIZE);
		array_copy(TerrainDrawCallsFrustumCulled, 0, _stats.TerrainDrawCallsFrustumCulled, 0,
			BBMOD_ERenderPass.SIZE);
		array_copy(SpriteDrawCallsDrawn, 0, _stats.SpriteDrawCallsDrawn, 0, BBMOD_ERenderPass.SIZE);
		array_copy(ShadowmapUpdatesDrawn, 0, _stats.ShadowmapUpdatesDrawn, 0,
			BBMOD_ERenderPass.SIZE);
		array_copy(ShadowmapUpdatesSkippedFrustum, 0, _stats.ShadowmapUpdatesSkippedFrustum, 0,
			BBMOD_ERenderPass.SIZE);
		array_copy(ShadowmapUpdatesSkippedSchedule, 0, _stats.ShadowmapUpdatesSkippedSchedule, 0,
			BBMOD_ERenderPass.SIZE);
		array_copy(PunctualLightsUsed, 0, _stats.PunctualLightsUsed, 0, BBMOD_ERenderPass.SIZE);
		array_copy(PunctualLightsSkippedDisabled, 0, _stats.PunctualLightsSkippedDisabled, 0,
			BBMOD_ERenderPass.SIZE);
		array_copy(PunctualLightsSkippedFrustum, 0, _stats.PunctualLightsSkippedFrustum, 0,
			BBMOD_ERenderPass.SIZE);
		array_copy(PunctualLightsSkippedDistance, 0, _stats.PunctualLightsSkippedDistance, 0,
			BBMOD_ERenderPass.SIZE);

		return self;
	};

	/// @func clone()
	///
	/// @desc Creates a deep copy of this render-statistics snapshot.
	///
	/// @return {Struct.BBMOD_RenderStatistics} Cloned snapshot.
	static clone = function ()
	{
		return new BBMOD_RenderStatistics().copy_from(self);
	};
}

/// @var {Bool} Tracks whether render-statistics capture is active.
/// @private
global.__bbmodRenderStatisticsActive = false;

/// @var {Struct.BBMOD_RenderStatistics} Global render statistics tracker.
/// @private
global.__bbmodRenderStatistics = new BBMOD_RenderStatistics();

/// @var {Struct.BBMOD_RenderStatistics} Last completed render-statistics snapshot.
/// @private
global.__bbmodRenderStatisticsSnapshot = new BBMOD_RenderStatistics();

/// @var {Pointer.View|Undefined} Render-statistics debug view handle.
/// @private
global.__bbmodRenderStatisticsDebugView = undefined;

/// @var {Struct} Render-statistics summed counters across all passes.
/// @private
global.__bbmodRenderStatisticsTotals = {
	MeshDrawCallsDrawn: 0,
	MeshDrawCallsFrustumCulled: 0,
	MeshDrawCallsDistanceCulled: 0,
	AnimatedMeshDrawCallsDrawn: 0,
	AnimatedMeshDrawCallsFrustumCulled: 0,
	AnimatedMeshDrawCallsDistanceCulled: 0,
	BatchedMeshDrawCallsDrawn: 0,
	BatchedMeshDrawCallsFrustumCulled: 0,
	BatchedMeshDrawCallsDistanceCulled: 0,
	TerrainDrawCallsDrawn: 0,
	TerrainDrawCallsFrustumCulled: 0,
	SpriteDrawCallsDrawn: 0,
	ShadowmapUpdatesDrawn: 0,
	ShadowmapUpdatesSkippedFrustum: 0,
	ShadowmapUpdatesSkippedSchedule: 0,
	PunctualLightsUsed: 0,
	PunctualLightsSkippedDisabled: 0,
	PunctualLightsSkippedFrustum: 0,
	PunctualLightsSkippedDistance: 0,
};

/// @func __bbmod_render_statistics_count(_counter[, _amount[, _pass]])
///
/// @desc Internal helper that increments the selected render-statistics counter.
///
/// @param {Real} _counter One of `__BBMOD_ERenderStatisticsCounter`.
/// @param {Real} [_amount] Increment amount. Defaults to `1`.
/// @param {Real} [_pass] Render pass to count into. Defaults to current pass.
///
/// @private
function __bbmod_render_statistics_count(_counter, _amount = 1, _pass = undefined)
{
	gml_pragma("forceinline");

	if (!global.__bbmodRenderStatisticsActive)
	{
		return;
	}

	_pass ??= bbmod_render_pass_get();
	_pass = clamp(_pass, 0, BBMOD_ERenderPass.SIZE - 1);

	var _stats = global.__bbmodRenderStatistics;

	switch (_counter)
	{
		case __BBMOD_ERenderStatisticsCounter.MeshDrawCallsDrawn:
			_stats.MeshDrawCallsDrawn[@ _pass] += _amount;
			break;

		case __BBMOD_ERenderStatisticsCounter.MeshDrawCallsFrustumCulled:
			_stats.MeshDrawCallsFrustumCulled[@ _pass] += _amount;
			break;

		case __BBMOD_ERenderStatisticsCounter.MeshDrawCallsDistanceCulled:
			_stats.MeshDrawCallsDistanceCulled[@ _pass] += _amount;
			break;

		case __BBMOD_ERenderStatisticsCounter.AnimatedMeshDrawCallsDrawn:
			_stats.AnimatedMeshDrawCallsDrawn[@ _pass] += _amount;
			break;

		case __BBMOD_ERenderStatisticsCounter.AnimatedMeshDrawCallsFrustumCulled:
			_stats.AnimatedMeshDrawCallsFrustumCulled[@ _pass] += _amount;
			break;

		case __BBMOD_ERenderStatisticsCounter.AnimatedMeshDrawCallsDistanceCulled:
			_stats.AnimatedMeshDrawCallsDistanceCulled[@ _pass] += _amount;
			break;

		case __BBMOD_ERenderStatisticsCounter.BatchedMeshDrawCallsDrawn:
			_stats.BatchedMeshDrawCallsDrawn[@ _pass] += _amount;
			break;

		case __BBMOD_ERenderStatisticsCounter.BatchedMeshDrawCallsFrustumCulled:
			_stats.BatchedMeshDrawCallsFrustumCulled[@ _pass] += _amount;
			break;

		case __BBMOD_ERenderStatisticsCounter.BatchedMeshDrawCallsDistanceCulled:
			_stats.BatchedMeshDrawCallsDistanceCulled[@ _pass] += _amount;
			break;

		case __BBMOD_ERenderStatisticsCounter.TerrainDrawCallsDrawn:
			_stats.TerrainDrawCallsDrawn[@ _pass] += _amount;
			break;

		case __BBMOD_ERenderStatisticsCounter.TerrainDrawCallsFrustumCulled:
			_stats.TerrainDrawCallsFrustumCulled[@ _pass] += _amount;
			break;

		case __BBMOD_ERenderStatisticsCounter.SpriteDrawCallsDrawn:
			_stats.SpriteDrawCallsDrawn[@ _pass] += _amount;
			break;

		case __BBMOD_ERenderStatisticsCounter.ShadowmapUpdatesDrawn:
			_stats.ShadowmapUpdatesDrawn[@ _pass] += _amount;
			break;

		case __BBMOD_ERenderStatisticsCounter.ShadowmapUpdatesSkippedFrustum:
			_stats.ShadowmapUpdatesSkippedFrustum[@ _pass] += _amount;
			break;

		case __BBMOD_ERenderStatisticsCounter.ShadowmapUpdatesSkippedSchedule:
			_stats.ShadowmapUpdatesSkippedSchedule[@ _pass] += _amount;
			break;

		case __BBMOD_ERenderStatisticsCounter.PunctualLightsUsed:
			_stats.PunctualLightsUsed[@ _pass] += _amount;
			break;

		case __BBMOD_ERenderStatisticsCounter.PunctualLightsSkippedDisabled:
			_stats.PunctualLightsSkippedDisabled[@ _pass] += _amount;
			break;

		case __BBMOD_ERenderStatisticsCounter.PunctualLightsSkippedFrustum:
			_stats.PunctualLightsSkippedFrustum[@ _pass] += _amount;
			break;

		case __BBMOD_ERenderStatisticsCounter.PunctualLightsSkippedDistance:
			_stats.PunctualLightsSkippedDistance[@ _pass] += _amount;
			break;
	}
}

/// @func __bbmod_render_statistics_sum_passes(_counterValues)
///
/// @desc Sums a pass-indexed counter array.
///
/// @param {Array<Real>} _counterValues Counter values per pass.
///
/// @return {Real} Total summed value.
///
/// @private
function __bbmod_render_statistics_sum_passes(_counterValues)
{
	var _sum = 0;
	var i = 0;
	repeat(BBMOD_ERenderPass.SIZE)
	{
		_sum += _counterValues[i++];
	}

	return _sum;
}

/// @func __bbmod_render_statistics_debug_reset_totals()
///
/// @desc Clears all summed debug totals.
///
/// @private
function __bbmod_render_statistics_debug_reset_totals()
{
	var _totals = global.__bbmodRenderStatisticsTotals;

	_totals.MeshDrawCallsDrawn = 0;
	_totals.MeshDrawCallsFrustumCulled = 0;
	_totals.MeshDrawCallsDistanceCulled = 0;
	_totals.AnimatedMeshDrawCallsDrawn = 0;
	_totals.AnimatedMeshDrawCallsFrustumCulled = 0;
	_totals.AnimatedMeshDrawCallsDistanceCulled = 0;
	_totals.BatchedMeshDrawCallsDrawn = 0;
	_totals.BatchedMeshDrawCallsFrustumCulled = 0;
	_totals.BatchedMeshDrawCallsDistanceCulled = 0;
	_totals.TerrainDrawCallsDrawn = 0;
	_totals.TerrainDrawCallsFrustumCulled = 0;
	_totals.SpriteDrawCallsDrawn = 0;
	_totals.ShadowmapUpdatesDrawn = 0;
	_totals.ShadowmapUpdatesSkippedFrustum = 0;
	_totals.ShadowmapUpdatesSkippedSchedule = 0;
	_totals.PunctualLightsUsed = 0;
	_totals.PunctualLightsSkippedDisabled = 0;
	_totals.PunctualLightsSkippedFrustum = 0;
	_totals.PunctualLightsSkippedDistance = 0;
}

/// @func __bbmod_render_statistics_debug_update_totals(_stats)
///
/// @desc Recomputes summed totals from a render-statistics snapshot.
///
/// @param {Struct.BBMOD_RenderStatistics} _stats Snapshot to aggregate.
///
/// @private
function __bbmod_render_statistics_debug_update_totals(_stats)
{
	var _totals = global.__bbmodRenderStatisticsTotals;

	_totals.MeshDrawCallsDrawn = __bbmod_render_statistics_sum_passes(_stats.MeshDrawCallsDrawn);
	_totals.MeshDrawCallsFrustumCulled = __bbmod_render_statistics_sum_passes(_stats.MeshDrawCallsFrustumCulled);
	_totals.MeshDrawCallsDistanceCulled = __bbmod_render_statistics_sum_passes(_stats
		.MeshDrawCallsDistanceCulled);
	_totals.AnimatedMeshDrawCallsDrawn = __bbmod_render_statistics_sum_passes(_stats.AnimatedMeshDrawCallsDrawn);
	_totals.AnimatedMeshDrawCallsFrustumCulled = __bbmod_render_statistics_sum_passes(_stats
		.AnimatedMeshDrawCallsFrustumCulled);
	_totals.AnimatedMeshDrawCallsDistanceCulled = __bbmod_render_statistics_sum_passes(_stats
		.AnimatedMeshDrawCallsDistanceCulled);
	_totals.BatchedMeshDrawCallsDrawn = __bbmod_render_statistics_sum_passes(_stats.BatchedMeshDrawCallsDrawn);
	_totals.BatchedMeshDrawCallsFrustumCulled = __bbmod_render_statistics_sum_passes(_stats
		.BatchedMeshDrawCallsFrustumCulled);
	_totals.BatchedMeshDrawCallsDistanceCulled = __bbmod_render_statistics_sum_passes(_stats
		.BatchedMeshDrawCallsDistanceCulled);
	_totals.TerrainDrawCallsDrawn = __bbmod_render_statistics_sum_passes(_stats.TerrainDrawCallsDrawn);
	_totals.TerrainDrawCallsFrustumCulled = __bbmod_render_statistics_sum_passes(_stats.TerrainDrawCallsFrustumCulled);
	_totals.SpriteDrawCallsDrawn = __bbmod_render_statistics_sum_passes(_stats.SpriteDrawCallsDrawn);
	_totals.ShadowmapUpdatesDrawn = __bbmod_render_statistics_sum_passes(_stats.ShadowmapUpdatesDrawn);
	_totals.ShadowmapUpdatesSkippedFrustum = __bbmod_render_statistics_sum_passes(_stats
		.ShadowmapUpdatesSkippedFrustum);
	_totals.ShadowmapUpdatesSkippedSchedule = __bbmod_render_statistics_sum_passes(_stats
		.ShadowmapUpdatesSkippedSchedule);
	_totals.PunctualLightsUsed = __bbmod_render_statistics_sum_passes(_stats.PunctualLightsUsed);
	_totals.PunctualLightsSkippedDisabled = __bbmod_render_statistics_sum_passes(_stats.PunctualLightsSkippedDisabled);
	_totals.PunctualLightsSkippedFrustum = __bbmod_render_statistics_sum_passes(_stats.PunctualLightsSkippedFrustum);
	_totals.PunctualLightsSkippedDistance = __bbmod_render_statistics_sum_passes(_stats.PunctualLightsSkippedDistance);
}

/// @func __bbmod_render_statistics_debug_add_watch(_section, _source, _fieldName, _label[, _pass])
///
/// @desc Adds a watched counter field to a debug section.
///
/// @param {Pointer.Section} _section Target debug section.
/// @param {Struct} _source Struct that owns the watched field.
/// @param {String} _fieldName Counter field name in `BBMOD_RenderStatistics`.
/// @param {String} _label Label shown in the debug view.
/// @param {Real} [_pass] Optional render-pass index for array counters.
///
/// @private
function __bbmod_render_statistics_debug_add_watch(_section, _source, _fieldName, _label, _pass = undefined)
{
	dbg_set_section(_section);

	if (_pass == undefined)
	{
		dbg_watch(ref_create(_source, _fieldName), _label);
		return;
	}

	dbg_watch(ref_create(_source, _fieldName, _pass), _label);
}

/// @func __bbmod_render_statistics_debug_create_view()
///
/// @desc Creates and wires the render-statistics debug view and its controls.
///
/// @private
function __bbmod_render_statistics_debug_create_view()
{
	var _counterSpecs = [
		["MeshDrawCallsDrawn", "Mesh Drawn"],
		["MeshDrawCallsFrustumCulled", "Mesh Culled"],
		["MeshDrawCallsDistanceCulled", "Mesh Dist Culled"],
		["AnimatedMeshDrawCallsDrawn", "Anim Drawn"],
		["AnimatedMeshDrawCallsFrustumCulled", "Anim Culled"],
		["AnimatedMeshDrawCallsDistanceCulled", "Anim Dist Culled"],
		["BatchedMeshDrawCallsDrawn", "Batch Drawn"],
		["BatchedMeshDrawCallsFrustumCulled", "Batch Culled"],
		["BatchedMeshDrawCallsDistanceCulled", "Batch Dist Culled"],
		["TerrainDrawCallsDrawn", "Terrain Drawn"],
		["TerrainDrawCallsFrustumCulled", "Terrain Culled"],
		["SpriteDrawCallsDrawn", "Sprite Drawn"],
		["ShadowmapUpdatesDrawn", "Shadow Drawn"],
		["ShadowmapUpdatesSkippedFrustum", "Shadow Skip Frustum"],
		["ShadowmapUpdatesSkippedSchedule", "Shadow Skip Schedule"],
		["PunctualLightsUsed", "Lights Used"],
		["PunctualLightsSkippedDisabled", "Lights Skip Disabled"],
		["PunctualLightsSkippedFrustum", "Lights Skip Frustum"],
		["PunctualLightsSkippedDistance", "Lights Skip Distance"]
	];

	global.__bbmodRenderStatisticsDebugView = dbg_view(
		"BBMOD Render Statistics",
		true,
		16,
		16,
		520,
		760
	);

	dbg_set_view(global.__bbmodRenderStatisticsDebugView);

	var _totalsSection = dbg_section("TOTAL", true);

	var i = 0;
	repeat(array_length(_counterSpecs))
	{
		var _totalsSpec = _counterSpecs[i];
		__bbmod_render_statistics_debug_add_watch(_totalsSection, global.__bbmodRenderStatisticsTotals,
			_totalsSpec[0], _totalsSpec[1]);
		++i;
	}

	dbg_text_separator("Per-pass details", 0);

	var _pass = 0;
	repeat(BBMOD_ERenderPass.SIZE)
	{
		var _passName = bbmod_render_pass_to_string(_pass);
		if (_passName == "")
		{
			_passName = "Pass " + string(_pass);
		}

		var _section = dbg_section(_passName, false);

		i = 0;
		repeat(array_length(_counterSpecs))
			{
				var _spec = _counterSpecs[i];
				__bbmod_render_statistics_debug_add_watch(_section, global.__bbmodRenderStatisticsSnapshot,
					_spec[0], _spec[1], _pass);
				++i;
			}

			++_pass;
	}
}

/// @func __bbmod_render_statistics_debug_ensure_view()
///
/// @desc Ensures the render-statistics debug view exists.
///
/// @private
function __bbmod_render_statistics_debug_ensure_view()
{
	if (global.__bbmodRenderStatisticsDebugView != undefined
		&& dbg_view_exists(global.__bbmodRenderStatisticsDebugView))
	{
		return;
	}

	__bbmod_render_statistics_debug_create_view();
}

/// @func bbmod_render_statistics_get()
///
/// @desc Retrieves the global render statistics tracker for manual data
/// processing.
///
/// @return {Struct.BBMOD_RenderStatistics} Render statistics tracker.
function bbmod_render_statistics_get()
{
	gml_pragma("forceinline");
	return global.__bbmodRenderStatistics;
}

/// @func bbmod_render_statistics_start()
///
/// @desc Starts a new render-statistics capture window.
///
/// @return {Struct.BBMOD_RenderStatistics} Render statistics tracker.
function bbmod_render_statistics_start()
{
	gml_pragma("forceinline");
	global.__bbmodRenderStatistics.reset();
	__bbmod_render_statistics_debug_reset_totals();
	global.__bbmodRenderStatisticsActive = true;
	return global.__bbmodRenderStatistics;
}

/// @func bbmod_render_statistics_end()
///
/// @desc Ends the active render-statistics capture window and returns a
/// stable snapshot of collected counters.
///
/// @note Also updates the built-in debug-overlay render-statistics view.
///
/// @return {Struct.BBMOD_RenderStatistics} Completed snapshot.
function bbmod_render_statistics_end()
{
	gml_pragma("forceinline");
	global.__bbmodRenderStatisticsActive = false;
	global.__bbmodRenderStatisticsSnapshot.copy_from(global.__bbmodRenderStatistics);
	__bbmod_render_statistics_debug_update_totals(global.__bbmodRenderStatisticsSnapshot);
	__bbmod_render_statistics_debug_ensure_view();
	return global.__bbmodRenderStatisticsSnapshot;
}
