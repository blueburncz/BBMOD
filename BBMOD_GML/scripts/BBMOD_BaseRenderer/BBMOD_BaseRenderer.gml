/// @module Core

/// @var {Struct.BBMOD_Renderer} The last used renderer. Can be `undefined`.
/// @private
global.__bbmodRendererCurrent = undefined;

/// @func BBMOD_BaseRenderer()
///
/// @implements {BBMOD_IDestructible}
///
/// @desc Base struct for renderers. Renderers execute
/// [render commands](./BBMOD_ERenderCommand.html) created with method
/// [render](./BBMOD_Model.render.html).
function BBMOD_BaseRenderer() constructor
{
	/// @var {Real} The X position of the renderer on the screen. Default value
	/// is 0.
	X = 0;

	/// @var {Real} The Y position of the renderer on the screen. Default value
	/// is 0.
	Y = 0;

	/// @var {Real} The width of the renderer on the screen. If `undefined` then
	/// the window width is used. Default value is `undefined`.
	Width = undefined;

	/// @var {Real} The height of the renderer on the screen. If `undefined`
	/// then the window height is used. Default value is `undefined`.
	Height = undefined;

	/// @var {Bool} If `true` then rendering of instance IDs into an off-screen
	/// surface is enabled. This must be enabled if you would like to use method
	/// {@link BBMOD_BaseRenderer.get_instance_id} for mouse-picking instances.
	/// Default value is `false`.
	RenderInstanceIDs = false;

	/// @var {Id.Surface} Surface for rendering highlight of selected instances.
	/// @private
	__surInstanceHighlight = -1;

	/// @var {Struct.BBMOD_Color} Outline color of instances selected by gizmo.
	/// Default value is {@link BBMOD_C_ORANGE}.
	/// @see BBMOD_BaseRenderer.Gizmo
	InstanceHighlightColor = BBMOD_C_ORANGE;

	/// @var {Bool} If `true` then edit mode is enabled. Default value is `false`.
	EditMode = false;

	/// @var {Bool} If `true` then mousepicking of gizmo and instances is enabled.
	/// Default value is `true`.
	/// @note This can be useful for example to disable mousepicking when the
	/// mouse cursor is over UI.
	EnableMousepick = true;

	/// @var {Constant.MouseButton} The mouse button used to select instances when
	/// edit mode is enabled. Default value is `mb_left`.
	/// @see BBMOD_BaseRenderer.EditMode
	ButtonSelect = mb_left;

	/// @var {Constant.VirtualKey} The keyboard key used to add/remove instances
	/// from multiple selection when edit mode is enabled. Default value is
	/// `vk_shift`.
	/// @see BBMOD_BaseRenderer.EditMode
	KeyMultiSelect = vk_shift;

	/// @var {Struct.BBMOD_Gizmo} A gizmo for transforming instances when
	/// {@link BBMOD_BaseRenderer.EditMode} is enabled. This is by default
	/// `undefined`.
	/// @see BBMOD_Gizmo
	Gizmo = undefined;

	/// @var {Bool} If `true` (default) then edit-mode icons for selectable
	/// structs are shown.
	ShowEditorIcons = true;

	/// @var {Real} Size of edit-mode icons in pixels. Default value is 24.
	EditorIconSize = 24.0;

	/// @var {Bool} If `true` (default) then wireframe debug geometry for
	/// selected editable lights and reflection probes is shown in edit mode.
	ShowEditorWireframe = true;

	/// @var {Struct.BBMOD_Color} Color of edit-mode wireframe debug geometry.
	EditorWireframeColor = BBMOD_C_ORANGE;

	/// @var {Id.Surface} A surface containing the gizmo. Used to enable
	/// z-testing against itself, but ingoring the scene geometry.
	/// @private
	__surGizmo = -1;

	/// @var {Id.Surface} Surface for mouse-picking the gizmo.
	/// @private
	__surSelect = -1;

	/// @var {Struct} Editor icon target under the mouse or `undefined`.
	/// @private
	__editorHoveredTarget = undefined;

	/// @var {Array<Struct>} Projected editor icon targets.
	/// @private
	__editorIconTarget = [];

	/// @var {Array<Real>} Projected editor icon screen X coordinates.
	/// @private
	__editorIconX = [];

	/// @var {Array<Real>} Projected editor icon screen Y coordinates.
	/// @private
	__editorIconY = [];

	/// @var {Array<Real>} Projected editor icon left bounds.
	/// @private
	__editorIconLeft = [];

	/// @var {Array<Real>} Projected editor icon top bounds.
	/// @private
	__editorIconTop = [];

	/// @var {Array<Real>} Projected editor icon right bounds.
	/// @private
	__editorIconRight = [];

	/// @var {Array<Real>} Projected editor icon bottom bounds.
	/// @private
	__editorIconBottom = [];

	/// @var {Array<Real>} Projected editor icon draw scales.
	/// @private
	__editorIconScale = [];

	/// @var {Array<Real>} Projected editor icon alpha values.
	/// @private
	__editorIconAlpha = [];

	/// @var {Array<Real>} Projected editor icon depths.
	/// @private
	__editorIconDepth = [];

	/// @var {Array<Real>} Projected editor icon priorities.
	/// @private
	__editorIconPriority = [];

	/// @var {Array<Real>} Projected editor icon sprites.
	/// @private
	__editorIconSprite = [];

	/// @var {Array<Real>} Projected editor icon frames.
	/// @private
	__editorIconFrame = [];

	/// @var {Array<Real>} Projected editor icon flags.
	/// @private
	__editorIconFlags = [];

	/// @var {Real} Allocated size of editor icon projection arrays.
	/// @private
	__editorIconCapacity = 0;

	/// @var {Real} Number of projected editor icons in current frame.
	/// @private
	__editorIconCount = 0;

	/// @var {Array<Struct.BBMOD_IRenderable>} An array of renderable objects
	/// and structs. These are automatically rendered in
	/// {@link BBMOD_BaseRenderer.render}.
	/// @readonly
	/// @see BBMOD_BaseRenderer.add
	/// @see BBMOD_BaseRenderer.remove
	/// @see BBMOD_IRenderable
	Renderables = [];

	/// @var {Bool} Set to `true` to enable the `application_surface`.
	/// Use method {@link BBMOD_BaseRenderer.present} to draw the
	/// `application_surface` to the screen. Defaults to `false`.
	UseAppSurface = false;

	/// @var {Real} Resolution multiplier for the `application_surface`.
	/// {@link BBMOD_BaseRenderer.UseAppSurface} must be enabled for this to
	/// have any effect. Defaults to 1. Use lower values to improve framerate.
	/// @note Not supported on platforms GX.games and HTML5!
	/// @see bbmod_is_browser
	RenderScale = 1.0;

	/// @var {Bool} Enables rendering into a shadowmap in the shadows render pass.
	/// Defauls to `false`.
	/// @see BBMOD_DirectionalLight.ShadowmapArea
	/// @see BBMOD_Light.ShadowmapResolution
	EnableShadows = false;

	/// @var {Id.DsList}
	/// @private
	__shadowmapLights = ds_list_create();

	/// @var {Id.DsList}
	/// @private
	__shadowmapHealth = ds_list_create();

	/// @var {Id.DsMap}
	/// @private
	__shadowmapSurfaces = ds_map_create();

	/// @var {Id.DsMap}
	/// @private
	__shadowmapCubes = ds_map_create();

	/// @var {Real} When rendering shadows, offsets vertex position by its normal
	/// scaled by this value. Defaults to 1. Increasing the value can remove some
	/// artifacts but using too high value could make the objects appear flying
	/// above the ground.
	ShadowmapNormalOffset = 1;

	/// @var {Struct.BBMOD_PostProcessor} Handles post-processing effects if
	/// isn't `undefined` and {@link BBMOD_BaseRenderer.UseAppSurface} is enabled.
	/// Default value is `undefined`.
	/// @see BBMOD_PostProcessor
	PostProcessor = undefined;

	/// @var {Id.Surface}
	/// @private
	__surFinal = -1;

	/// @var {Struct.BBMOD_Cubemap} For reflection probe capture.
	/// @private
	static __cubemap = new BBMOD_Cubemap(128);

	if (bbmod_hdr_is_supported())
	{
		__cubemap.Format = surface_rgba16float;
	}
	/// @var {Id.Surface} For reflection probe capture.
	/// @private
	__surProbe1 = -1;

	/// @var {Id.Surface} For reflection probe capture.
	/// @private
	__surProbe2 = -1;

	/// @var {Bool} Enables screen-space ambient occlusion. This requires
	/// the depth buffer. Defaults to `false`. Enabling this requires the
	/// [SSAO submodule](./SSAOSubmodule.html)!
	/// @see BBMOD_DefaultRenderer.EnableGBuffer
	EnableSSAO = false;

	/// @var {Id.Surface} The SSAO surface.
	/// @private
	__surSSAO = -1;

	/// @var {Id.Surface} Surface used for blurring SSAO.
	/// @private
	__surWork = -1;

	/// @var {Real} Resolution multiplier for SSAO surface. Defaults to 1.
	SSAOScale = 1.0;

	/// @var {Real} Screen-space radius of SSAO. Default value is 16.
	SSAORadius = 16.0;

	/// @var {Real} Strength of the SSAO effect. Should be greater than 0.
	/// Default value is 1.
	SSAOPower = 1.0;

	/// @var {Real} SSAO angle bias in radians. Default value is 0.03.
	SSAOAngleBias = 0.03;

	/// @var {Real} Maximum depth difference of SSAO samples. Samples farther
	/// away from the origin than this will not contribute to the effect.
	/// Default value is 10.
	SSAODepthRange = 10.0;

	/// @var {Real} Defaults to 0.01. Increase to fix self-occlusion.
	SSAOSelfOcclusionBias = 0.01;

	/// @var {Real} Maximum depth difference over which can be SSAO samples
	/// blurred. Defaults to 2.
	SSAOBlurDepthRange = 2.0;

	/// @var {Id.Camera}
	/// @private
	__camera2D = camera_create();

	/// @var {Array<Struct.BBMOD_PunctualLight>} Renderer-local punctual lights
	/// filtered to enabled and currently visible entries.
	/// @private
	__punctualLightsVisible = [];

	/// @func __sort_visible_punctual_lights_by_distance_fn(_a, _b)
	///
	/// @desc Comparator used by {@link array_sort} to order punctual lights
	/// from closest to farthest camera distance.
	///
	/// @note This method is expected to be called using
	/// `method(_context, __sort_visible_punctual_lights_by_distance_fn)` where
	/// `_context` provides `Camera`, `FallbackX`, `FallbackY`, and `FallbackZ`.
	///
	/// @param {Struct.BBMOD_PunctualLight} _a First light.
	/// @param {Struct.BBMOD_PunctualLight} _b Second light.
	///
	/// @return {Real} `-1`, `0`, or `1` according to sort order.
	///
	/// @private
	static __sort_visible_punctual_lights_by_distance_fn = function (_a, _b)
	{
		var _distanceA;
		var _distanceB;

		if (Camera != undefined)
		{
			_distanceA = Camera.get_distance(_a.Position);
			_distanceB = Camera.get_distance(_b.Position);
		}
		else
		{
			var _dxA = _a.Position.X - FallbackX;
			var _dyA = _a.Position.Y - FallbackY;
			var _dzA = _a.Position.Z - FallbackZ;
			_distanceA = _dxA * _dxA + _dyA * _dyA + _dzA * _dzA;

			var _dxB = _b.Position.X - FallbackX;
			var _dyB = _b.Position.Y - FallbackY;
			var _dzB = _b.Position.Z - FallbackZ;
			_distanceB = _dxB * _dxB + _dyB * _dyB + _dzB * _dzB;
		}

		if (_distanceA < _distanceB)
		{
			return -1;
		}

		if (_distanceA > _distanceB)
		{
			return 1;
		}

		return 0;
	};

	/// @func __sort_visible_punctual_lights_by_distance()
	///
	/// @desc Sorts {@link BBMOD_BaseRenderer.__punctualLightsVisible} from
	/// closest to farthest using {@link array_sort}.
	///
	/// @private
	static __sort_visible_punctual_lights_by_distance = function ()
	{
		var _count = array_length(__punctualLightsVisible);
		if (_count < 2)
		{
			return;
		}

		var _fallbackCameraPos = bbmod_camera_get_position();
		var _sortContext = {
			Camera: bbmod_scene_get_current().CameraCurrent ?? global.__bbmodCameraCurrent,
			FallbackX: _fallbackCameraPos.X,
			FallbackY: _fallbackCameraPos.Y,
			FallbackZ: _fallbackCameraPos.Z,
		};

		array_sort(__punctualLightsVisible,
			method(_sortContext, __sort_visible_punctual_lights_by_distance_fn));
	};

	/// @func __get_punctual_light_distance_fade(_light, _distanceSq)
	///
	/// @desc Computes a punctual light's distance fade factor using camera
	/// distance-squared input.
	///
	/// @param {Struct.BBMOD_PunctualLight} _light A punctual light.
	/// @param {Real} _distanceSq Camera-to-light distance squared.
	///
	/// @return {Real} A fade factor in range 0..1.
	///
	/// @private
	static __get_punctual_light_distance_fade = function (_light, _distanceSq)
	{
		var _fadeStart = max(_light.DistanceFadeStart, 0.0);
		var _fadeEnd = max(_light.DistanceFadeEnd, 0.0);

		if (_fadeEnd != infinity && _fadeEnd > _fadeStart)
		{
			var _fadeEndSq = _fadeEnd * _fadeEnd;
			if (_distanceSq >= _fadeEndSq)
			{
				return 0.0;
			}

			var _fadeStartSq = _fadeStart * _fadeStart;
			if (_distanceSq <= _fadeStartSq)
			{
				return 1.0;
			}

			var _distance = sqrt(_distanceSq);
			return 1.0 - ((_distance - _fadeStart) / (_fadeEnd - _fadeStart));
		}

		if (_fadeEnd < infinity)
		{
			return (_distanceSq < (_fadeEnd * _fadeEnd)) ? 1.0 : 0.0;
		}

		return 1.0;
	};

	/// @func __build_visible_punctual_lights()
	///
	/// @desc Builds renderer-local array of enabled punctual lights that are
	/// visible in the current camera frustum and sorts them by camera distance
	/// from closest to farthest.
	///
	/// @return {Array<Struct.BBMOD_PunctualLight>} Visible punctual lights.
	///
	/// @private
	static __build_visible_punctual_lights = function ()
	{
		array_resize(__punctualLightsVisible, 0);

		var _lights = bbmod_scene_get_current().LightsPunctual;
		var _cameraPos = bbmod_camera_get_position();
		var _cameraPosX = _cameraPos.X;
		var _cameraPosY = _cameraPos.Y;
		var _cameraPosZ = _cameraPos.Z;

		var i = 0;
		repeat(array_length(_lights))
		{
			var _light = _lights[i++];

			if (!_light.Enabled)
			{
				__bbmod_render_statistics_count(
					__BBMOD_ERenderStatisticsCounter.PunctualLightsSkippedDisabled);
				continue;
			}

			if (!sphere_is_visible(_light.Position.X, _light.Position.Y, _light.Position.Z, _light.Range))
			{
				__bbmod_render_statistics_count(
					__BBMOD_ERenderStatisticsCounter.PunctualLightsSkippedFrustum);
				continue;
			}

			var _dx = _light.Position.X - _cameraPosX;
			var _dy = _light.Position.Y - _cameraPosY;
			var _dz = _light.Position.Z - _cameraPosZ;
			var _distanceSq = _dx * _dx + _dy * _dy + _dz * _dz;
			var _fade = __get_punctual_light_distance_fade(_light, _distanceSq);
			if (_fade <= 0.0)
			{
				__bbmod_render_statistics_count(
					__BBMOD_ERenderStatisticsCounter.PunctualLightsSkippedDistance);
				continue;
			}

			_light.__distanceFadeFactor = _fade;
			__bbmod_render_statistics_count(__BBMOD_ERenderStatisticsCounter.PunctualLightsUsed);

			array_push(__punctualLightsVisible, _light);
		}

		__sort_visible_punctual_lights_by_distance();

		return __punctualLightsVisible;
	};

	/// @func get_width()
	///
	/// @desc Retrieves the width of the renderer on the screen.
	///
	/// @return {Real} The width of the renderer on the screen.
	static get_width = function ()
	{
		gml_pragma("forceinline");
		return ((Width != undefined) ? max(Width, 1) : bbmod_window_get_width());
	};

	/// @func get_height()
	///
	/// @desc Retrieves the height of the renderer on the screen.
	///
	/// @return {Real} The height of the renderer on the screen.
	static get_height = function ()
	{
		gml_pragma("forceinline");
		return ((Height != undefined) ? max(Height, 1) : bbmod_window_get_height());
	};

	/// @func get_render_width()
	///
	/// @desc Retrieves the width of the renderer with
	///
	/// {@link BBMOD_BaseRenderer.RenderScale} applied.
	///
	/// @return {Real} The width of the renderer after `RenderScale` is applied.
	static get_render_width = function ()
	{
		gml_pragma("forceinline");
		if (bbmod_is_browser())
		{
			return get_width();
		}
		return max(get_width() * RenderScale, 1);
	};

	/// @func get_render_height()
	///
	/// @desc Retrieves the height of the renderer with
	/// {@link BBMOD_BaseRenderer.RenderScale} applied.
	///
	/// @return {Real} The height of the renderer after `RenderScale` is applied.
	static get_render_height = function ()
	{
		gml_pragma("forceinline");
		if (bbmod_is_browser())
		{
			return get_height();
		}
		return max(get_height() * RenderScale, 1);
	};

	/// @func set_position(_x, _y)
	///
	/// @desc Changes the renderer's position on the screen.
	///
	/// @param {Real} _x The new X position on the screen.
	/// @param {Real} _y The new Y position on the screen.
	///
	/// @return {Struct.BBMOD_BaseRenderer} Returns `self`.
	static set_position = function (_x, _y)
	{
		gml_pragma("forceinline");
		X = _x;
		Y = _y;
		return self;
	};

	/// @func set_size(_width, _height)
	///
	/// @desc Changes the renderer's size on the screen.
	///
	/// @param {Real} _width The new width on the screen.
	/// @param {Real} _height The new height on the screen.
	///
	/// @return {Struct.BBMOD_BaseRenderer} Returns `self`.
	static set_size = function (_width, _height)
	{
		gml_pragma("forceinline");
		Width = _width;
		Height = _height;
		return self;
	};

	/// @func set_rectangle(_x, _y, _width, _height)
	///
	/// @desc Changes the renderer's position and size on the screen.
	///
	/// @param {Real} _x The new X position on the screen.
	/// @param {Real} _y The new Y position on the screen.
	/// @param {Real} _width The new width on the screen.
	/// @param {Real} _height The new height on the screen.
	///
	/// @return {Struct.BBMOD_BaseRenderer} Returns `self`.
	static set_rectangle = function (_x, _y, _width, _height)
	{
		gml_pragma("forceinline");
		set_position(_x, _y);
		set_size(_width, _height);
		return self;
	};

	/// @func select_gizmo(_screenX, _screenY)
	///
	/// @desc Tries to select a gizmo at given screen coordinates and
	/// automatically changes its {@link BBMOD_Gizmo.EditAxis} and
	/// {@link BBMOD_Gizmo.EditType} based on which part of the gizmo
	/// was selected.
	///
	/// @param {Real} _screenX The X position on the screen.
	/// @param {Real} _screenY The Y position on the screen.
	///
	/// @return {Bool} Returns `true` if the gizmo was selected.
	///
	/// @note {@link BBMOD_BaseRenderer.Gizmo} must be defined.
	///
	/// @private
	static select_gizmo = function (_screenX, _screenY)
	{
		var _renderScale = bbmod_is_browser() ? 1.0 : RenderScale;

		_screenX = clamp(_screenX - X, 0, get_width()) * _renderScale;
		_screenY = clamp(_screenY - Y, 0, get_height()) * _renderScale;

		Gizmo.EditAxis = BBMOD_EEditAxis.None;

		var _pixel = surface_getpixel_ext(__surSelect, _screenX, _screenY);
		if (_pixel & $FF000000 == 0)
		{
			return false;
		}

		var _blue = (_pixel >> 16) & 255;
		var _green = (_pixel >> 8) & 255;
		var _red = _pixel & 255;
		var _value = max(_red, _green, _blue);

		Gizmo.EditAxis = 0
			| (BBMOD_EEditAxis.X * (_red > 0))
			| (BBMOD_EEditAxis.Y * (_green > 0))
			| (BBMOD_EEditAxis.Z * (_blue > 0));

		Gizmo.EditType = ((_value == 255) ? BBMOD_EEditType.Position
			: ((_value == 128) ? BBMOD_EEditType.Rotation
				: BBMOD_EEditType.Scale));

		return true;
	};

	/// @private
	static __editor_icon_ensure_capacity = function (_capacity)
	{
		if (__editorIconCapacity >= _capacity)
		{
			return;
		}

		__editorIconCapacity = max(_capacity, max(__editorIconCapacity * 2, 16));
		array_resize(__editorIconTarget, __editorIconCapacity);
		array_resize(__editorIconX, __editorIconCapacity);
		array_resize(__editorIconY, __editorIconCapacity);
		array_resize(__editorIconLeft, __editorIconCapacity);
		array_resize(__editorIconTop, __editorIconCapacity);
		array_resize(__editorIconRight, __editorIconCapacity);
		array_resize(__editorIconBottom, __editorIconCapacity);
		array_resize(__editorIconScale, __editorIconCapacity);
		array_resize(__editorIconAlpha, __editorIconCapacity);
		array_resize(__editorIconDepth, __editorIconCapacity);
		array_resize(__editorIconPriority, __editorIconCapacity);
		array_resize(__editorIconSprite, __editorIconCapacity);
		array_resize(__editorIconFrame, __editorIconCapacity);
		array_resize(__editorIconFlags, __editorIconCapacity);
	};

	/// @private
	static __editor_icon_project_target = function (
		_target,
		_viewProjection,
		_width,
		_height,
		_projFlipped,
		_cameraPosition
	)
	{
		var _flags = _target.EditorFlags;
		var _position = new BBMOD_Vec3().TransformSelf(_target.get_world_matrix());
		var _offset = _target.EditorOffset;
		var _x = _position.X + _offset.X;
		var _y = _position.Y + _offset.Y;
		var _z = _position.Z + _offset.Z;
		var _fadeStart = _target.EditorIconFadeStart;
		var _fadeEnd = _target.EditorIconFadeEnd;
		var _alpha = 1.0;

		if (_fadeEnd > _fadeStart)
		{
			var _dx = _x - _cameraPosition.X;
			var _dy = _y - _cameraPosition.Y;
			var _dz = _z - _cameraPosition.Z;
			var _distance = sqrt(_dx * _dx + _dy * _dy + _dz * _dz);

			if (_distance >= _fadeEnd)
			{
				return;
			}

			if (_distance > _fadeStart)
			{
				_alpha = 1.0 - ((_distance - _fadeStart) / (_fadeEnd - _fadeStart));
			}
		}

		var _clipX = _viewProjection[0] * _x + _viewProjection[4] * _y + _viewProjection[8] * _z + _viewProjection[
			12];
		var _clipY = _viewProjection[1] * _x + _viewProjection[5] * _y + _viewProjection[9] * _z + _viewProjection[
			13];
		var _clipZ = _viewProjection[2] * _x + _viewProjection[6] * _y + _viewProjection[10] * _z + _viewProjection[
			14];
		var _clipW = _viewProjection[3] * _x + _viewProjection[7] * _y + _viewProjection[11] * _z + _viewProjection[
			15];

		if (_clipZ < 0.0 || _clipW == 0.0)
		{
			return;
		}

		var _screenX = (((_clipX / _clipW) * 0.5) + 0.5) * _width;
		var _screenY = (((_clipY / _clipW) * 0.5) + 0.5) * _height;
		if (_projFlipped)
		{
			_screenY = _height - _screenY;
		}

		var _sprite = _target.EditorIconSprite;
		var _spriteWidth = max(sprite_get_width(_sprite), 1.0);
		var _spriteHeight = max(sprite_get_height(_sprite), 1.0);
		var _scale = EditorIconSize / max(_spriteWidth, _spriteHeight);
		var _left = _screenX - sprite_get_xoffset(_sprite) * _scale;
		var _top = _screenY - sprite_get_yoffset(_sprite) * _scale;
		var _right = _left + _spriteWidth * _scale;
		var _bottom = _top + _spriteHeight * _scale;

		if (_right < 0.0
			|| _left > _width
			|| _bottom < 0.0
			|| _top > _height)
		{
			return;
		}

		var _index = __editorIconCount++;
		__editor_icon_ensure_capacity(__editorIconCount);
		__editorIconTarget[@ _index] = _target;
		__editorIconX[@ _index] = _screenX;
		__editorIconY[@ _index] = _screenY;
		__editorIconLeft[@ _index] = _left;
		__editorIconTop[@ _index] = _top;
		__editorIconRight[@ _index] = _right;
		__editorIconBottom[@ _index] = _bottom;
		__editorIconScale[@ _index] = _scale;
		__editorIconAlpha[@ _index] = _alpha;
		__editorIconDepth[@ _index] = _clipZ / _clipW;
		__editorIconPriority[@ _index] = _target.EditorPickPriority;
		__editorIconSprite[@ _index] = _sprite;
		__editorIconFrame[@ _index] = _target.EditorIconIndex;
		__editorIconFlags[@ _index] = _flags;
	};

	/// @private
	static __editor_project_icons = function (_width, _height)
	{
		__editorIconCount = 0;
		__editorHoveredTarget = undefined;

		var _camera = bbmod_scene_get_current().CameraCurrent ?? global.__bbmodCameraCurrent;

		if (!ShowEditorIcons || _camera == undefined)
		{
			return;
		}

		var _viewProjection = _camera.ViewProjectionMatrix;
		var _projFlipped = _camera.__projFlipped;
		var _cameraPosition = _camera.Position;

		var _scene = bbmod_scene_get_current();
		var _punctualLights = _scene.LightsPunctual;
		var i = 0;
		repeat(array_length(_punctualLights))
		{
			var _light = _punctualLights[i++];
			if (_light.Enabled)
			{
				__editor_icon_project_target(
					_light, _viewProjection, _width, _height, _projFlipped, _cameraPosition);
			}
		}

		var _directionalLight = _scene.LightDirectional;
		if (_directionalLight != undefined && _directionalLight.Enabled)
		{
			__editor_icon_project_target(
				_directionalLight, _viewProjection, _width, _height, _projFlipped, _cameraPosition);
		}

		var _reflectionProbes = _scene.ReflectionProbes;
		i = 0;
		repeat(array_length(_reflectionProbes))
		{
			var _probe = _reflectionProbes[i++];
			if (_probe.Enabled)
			{
				__editor_icon_project_target(
					_probe, _viewProjection, _width, _height, _projFlipped, _cameraPosition);
			}
		}

		var _emitters = _scene.ParticleEmitters;
		i = 0;
		repeat(array_length(_emitters))
		{
			__editor_icon_project_target(
				_emitters[i++], _viewProjection, _width, _height, _projFlipped, _cameraPosition);
		}

		var _terrains = _scene.Terrains;
		i = 0;
		repeat(array_length(_terrains))
		{
			__editor_icon_project_target(
				_terrains[i++], _viewProjection, _width, _height, _projFlipped, _cameraPosition);
		}

		var _lensFlares = _scene.LensFlares;
		i = 0;
		repeat(array_length(_lensFlares))
		{
			__editor_icon_project_target(
				_lensFlares[i++], _viewProjection, _width, _height, _projFlipped, _cameraPosition);
		}
	};

	/// @private
	static __editor_pick_icon = function (_screenX, _screenY)
	{
		var _renderScale = bbmod_is_browser() ? 1.0 : RenderScale;
		var _x = clamp(_screenX - X, 0, get_width()) * _renderScale;
		var _y = clamp(_screenY - Y, 0, get_height()) * _renderScale;
		var _bestIndex = -1;
		var _bestDepth = infinity;
		var _bestPriority = -infinity;

		var i = 0;
		repeat(__editorIconCount)
		{
			if (_x >= __editorIconLeft[i]
				&& _x <= __editorIconRight[i]
				&& _y >= __editorIconTop[i]
				&& _y <= __editorIconBottom[i])
			{
				var _priority = __editorIconPriority[i];
				var _depth = __editorIconDepth[i];
				if (_priority > _bestPriority
					|| (_priority == _bestPriority && _depth < _bestDepth)
					|| (_priority == _bestPriority && _depth == _bestDepth && i > _bestIndex))
				{
					_bestIndex = i;
					_bestDepth = _depth;
					_bestPriority = _priority;
				}
			}
			++i;
		}

		if (_bestIndex == -1)
		{
			return undefined;
		}

		return __editorIconTarget[_bestIndex];
	};

	/// @func get_instance_id(_screenX, _screenY)
	///
	/// @desc Retrieves an ID of an instance at given position on the screen.
	///
	/// @param {Real} _screenX The X position on the screen.
	/// @param {Real} _screenY The Y position on the screen.
	///
	/// @return {Id.Instance} The ID of the instance or 0 if no instance was
	/// found at the given position.
	///
	/// @note {@link BBMOD_BaseRenderer.RenderInstanceIDs} must be enabled.
	static get_instance_id = function (_screenX, _screenY)
	{
		gml_pragma("forceinline");
		if (!surface_exists(__surSelect))
		{
			return 0;
		}
		var _renderScale = bbmod_is_browser() ? 1.0 : RenderScale;
		_screenX = clamp(_screenX - X, 0, get_width()) * _renderScale;
		_screenY = clamp(_screenY - Y, 0, get_height()) * _renderScale;
		return surface_getpixel_ext(__surSelect, _screenX, _screenY);
	};

	/// @func add(_renderable)
	///
	/// @desc Adds a renderable object or struct to the renderer.
	///
	/// @param {Struct.BBMOD_IRenderable} _renderable The renderable object or
	/// struct to add.
	///
	/// @return {Struct.BBMOD_BaseRenderer} Returns `self`.
	///
	/// @see BBMOD_BaseRenderer.remove
	/// @see BBMOD_IRenderable
	static add = function (_renderable)
	{
		gml_pragma("forceinline");
		array_push(Renderables, _renderable);
		return self;
	};

	/// @func remove(_renderable)
	///
	/// @desc Removes a renderable object or a struct from the renderer.
	///
	/// @param {Struct.BBMOD_IRenderable} _renderable The renderable object or
	/// struct to remove.
	///
	/// @return {Struct.BBMOD_BaseRenderer} Returns `self`.
	///
	/// @see BBMOD_BaseRenderer.add
	/// @see BBMOD_IRenderable
	static remove = function (_renderable)
	{
		gml_pragma("forceinline");
		for (var i = array_length(Renderables) - 1; i >= 0; --i)
		{
			if (Renderables[i] == _renderable)
			{
				array_delete(Renderables, i, 1);
			}
		}
		return self;
	};

	/// @func __has_renderable(_renderable)
	///
	/// @desc Checks whether a renderable is registered directly with this renderer.
	///
	/// @param {Struct.BBMOD_IRenderable} _renderable The renderable to check.
	///
	/// @return {Bool} Returns `true` if the renderable is registered.
	///
	/// @private
	static __has_renderable = function (_renderable)
	{
		var i = 0;
		repeat(array_length(Renderables))
		{
			if (Renderables[i++] == _renderable)
			{
				return true;
			}
		}
		return false;
	};

	/// @func __render_scene_nodes()
	///
	/// @desc Enqueues renderable scene nodes from the current scene.
	///
	/// @return {Struct.BBMOD_BaseRenderer} Returns `self`.
	///
	/// @private
	static __render_scene_nodes = function ()
	{
		var _scene = bbmod_scene_get_current();
		var _editMode = EditMode;

		var _models = _scene.Models;
		var i = 0;
		repeat(array_length(_models))
		{
			var _model = _models[i++];
			if (!__has_renderable(_model))
			{
				if (_editMode)
				{
					var _pickId = global.__bbmodSceneNodePickIdNext++;
					ds_map_add(global.__bbmodSceneNodePickMap, _pickId, _model);
					_model.__bbmodPickId = _pickId;
					global.__bbmodInstanceID = _pickId;
				}

				_model.render(undefined, undefined, undefined, _model.get_world_matrix());

				if (_editMode)
				{
					global.__bbmodInstanceID = 0;
				}
			}
		}

		var _emitters = _scene.ParticleEmitters;
		i = 0;
		repeat(array_length(_emitters))
		{
			_emitters[i++].render();
		}

		var _terrains = _scene.Terrains;
		i = 0;
		repeat(array_length(_terrains))
		{
			var _terrain = _terrains[i++];
			if (_editMode)
			{
				var _pickId = global.__bbmodSceneNodePickIdNext++;
				ds_map_add(global.__bbmodSceneNodePickMap, _pickId, _terrain);
				_terrain.__bbmodPickId = _pickId;
				global.__bbmodInstanceID = _pickId;

				if (is_instanceof(_terrain, BBMOD_Terrain))
				{
					var _mat = _terrain.Material;
					if (_mat != undefined && !_mat.has_shader(BBMOD_ERenderPass.Id))
					{
						_mat.set_shader(BBMOD_ERenderPass.Id, BBMOD_SHADER_INSTANCE_ID);
					}
				}
			}

			_terrain.render();

			if (_editMode)
			{
				global.__bbmodInstanceID = 0;
			}
		}

		return self;
	};

	/// @func update(_deltaTime)
	///
	/// @desc Updates the renderer. This should be called in the Step event.
	///
	/// @param {Real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	///
	/// @return {Struct.BBMOD_BaseRenderer} Returns `self`.
	static update = function (_deltaTime)
	{
		global.__bbmodRendererCurrent = self;

		if (UseAppSurface)
		{
			application_surface_enable(true);
			application_surface_draw_enable(false);

			if (!bbmod_is_browser())
			{
				var _surfaceWidth = get_render_width();
				var _surfaceHeight = get_render_height();
				bbmod_surface_check(application_surface, _surfaceWidth, _surfaceHeight, surface_rgba8unorm, true);
			}
		}

		if (Gizmo && EditMode)
		{
			Gizmo.update(_deltaTime);
		}

		return self;
	};

	/// @func __incr_shadowmap_health(_light)
	///
	/// @desc Increments health of a light's shadowmap.
	///
	/// @param {Struct.BBMOD_Light} _light The light.
	///
	/// @private
	static __incr_shadowmap_health = function (_light)
	{
		var _lightIndex = ds_list_find_index(__shadowmapLights, _light);
		if (_lightIndex == -1)
		{
			_lightIndex = ds_list_size(__shadowmapLights);
			ds_list_add(__shadowmapLights, _light);
			ds_list_add(__shadowmapHealth, 1);
		}
		++__shadowmapHealth[|  _lightIndex];
	};

	/// @func __gc_collect_shadowmaps()
	///
	/// @desc Decrements health of all shadowmaps and frees them from memory
	/// when it reaches or drops below 0.
	///
	/// @private
	static __gc_collect_shadowmaps = function ()
	{
		for (var i = ds_list_size(__shadowmapLights) - 1; i >= 0; --i)
		{
			var _light = __shadowmapLights[|  i];
			if (--__shadowmapHealth[|  i] <= 0)
			{
				ds_list_delete(__shadowmapLights, i);
				ds_list_delete(__shadowmapHealth, i);

				if (ds_map_exists(__shadowmapSurfaces, _light))
				{
					var _surface = __shadowmapSurfaces[?  _light];
					if (surface_exists(_surface))
					{
						surface_free(_surface);
					}
					ds_map_delete(__shadowmapSurfaces, _light);
				}

				if (ds_map_exists(__shadowmapCubes, _light))
				{
					__shadowmapCubes[?  _light].destroy();
					ds_map_delete(__shadowmapCubes, _light);
				}
			}
		}
	};

	/// @func __render_shadowmap_impl(_light)
	///
	/// @desc Re-captures light's shadowmap if required and always increments
	/// shadowmap health.
	///
	/// @param {Struct.BBMOD_Light} _light The light to capture shadowmap for.
	///
	/// @private
	static __render_shadowmap_impl = function (_light)
	{
		__incr_shadowmap_health(_light);

		if ((!_light.Static || _light.NeedsUpdate)
			&& _light.__frameskipCurrent == 0)
		{
			__bbmod_render_statistics_count(
				__BBMOD_ERenderStatisticsCounter.ShadowmapUpdatesDrawn,
				1,
				BBMOD_ERenderPass.Shadows);

			var _shadowCaster = _light;
			var _shadowmapMatrix;
			var _shadowmapZFar = _light.__getZFar();
			var _surShadowmap = -1;

			bbmod_render_pass_set(BBMOD_ERenderPass.Shadows);

			if (is_instanceof(_light, BBMOD_PointLight))
			{
				var _cubemap;
				if (ds_map_exists(__shadowmapCubes, _light))
				{
					_cubemap = __shadowmapCubes[?  _light];
				}
				else
				{
					_cubemap = new BBMOD_Cubemap(_light.ShadowmapResolution);
					__shadowmapCubes[?  _light] = _cubemap;
				}

				_light.Position.Copy(_cubemap.Position);
				bbmod_shader_set_global_f(BBMOD_U_ZFAR, _shadowmapZFar);
				bbmod_shader_set_global_f("u_fOutputDistance", 1.0);

				while (_cubemap.set_target())
				{
					draw_clear(c_red);
					bbmod_render_queues_submit();
					_cubemap.reset_target();
				}
				bbmod_material_reset();

				bbmod_shader_set_global_f("u_fOutputDistance", 0.0);

				_cubemap.to_single_surface();
				_cubemap.to_octahedron();
				__shadowmapSurfaces[?  _light] = _cubemap.SurfaceOctahedron;
			}
			else
			{
				var _surShadowmapOld = -1;
				if (ds_map_exists(__shadowmapSurfaces, _light))
				{
					_surShadowmapOld = __shadowmapSurfaces[?  _light];
				}

				_surShadowmap = bbmod_surface_check(
					_surShadowmapOld, _light.ShadowmapResolution, _light.ShadowmapResolution,
					surface_rgba8unorm, true);

				if (_surShadowmap != _surShadowmapOld)
				{
					__shadowmapSurfaces[?  _light] = _surShadowmap;
				}

				surface_set_target(_surShadowmap);
				draw_clear(c_red);
				matrix_set(matrix_view, _light.__getViewMatrix());
				matrix_set(matrix_projection, _light.__getProjMatrix());
				bbmod_shader_set_global_f(BBMOD_U_ZFAR, _shadowmapZFar);
				bbmod_render_queues_submit();
				bbmod_material_reset();
				surface_reset_target();
			}

			_light.NeedsUpdate = false;
		}
		else
		{
			__bbmod_render_statistics_count(
				__BBMOD_ERenderStatisticsCounter.ShadowmapUpdatesSkippedSchedule,
				1,
				BBMOD_ERenderPass.Shadows);
		}

		if (_light.Frameskip == infinity)
		{
			_light.__frameskipCurrent = -1;
		}
		else if (++_light.__frameskipCurrent > _light.Frameskip)
		{
			_light.__frameskipCurrent = 0;
		}
	};

	/// @func __render_shadowmaps()
	///
	/// @desc Renders a shadowmap.
	///
	/// @note This modifies render pass and view and projection matrices and
	/// for optimization reasons it does not reset them back! Make sure to do
	/// that yourself in the calling function if needed.
	///
	/// @private
	static __render_shadowmaps = function ()
	{
		var _shadowCaster = undefined;
		var _shadowCasterIndex = -1;

		if (EnableShadows)
		{
			var _light = bbmod_light_directional_get();
			if (_light != undefined
				&& _light.CastShadows)
			{
				// Directional light
				_shadowCaster = _light;
			}
			else
			{
				// Punctual lights
				var _cameraPos = bbmod_camera_get_position();
				var _cameraPosX = _cameraPos.X;
				var _cameraPosY = _cameraPos.Y;
				var _cameraPosZ = _cameraPos.Z;
				var i = 0;
				var _punctualLights = bbmod_scene_get_current().LightsPunctual;
				repeat(array_length(_punctualLights))
				{
					_light = _punctualLights[i];
					if (_light.CastShadows)
					{
						if (sphere_is_visible(_light.Position.X, _light.Position.Y, _light.Position.Z, _light
								.Range))
						{
							var _dx = _light.Position.X - _cameraPosX;
							var _dy = _light.Position.Y - _cameraPosY;
							var _dz = _light.Position.Z - _cameraPosZ;
							var _distanceSq = _dx * _dx + _dy * _dy + _dz * _dz;
							if (__get_punctual_light_distance_fade(_light, _distanceSq) > 0.0)
							{
								_shadowCaster = _light;
								_shadowCasterIndex = i;
								break;
							}
						}
						else
						{
							__bbmod_render_statistics_count(
								__BBMOD_ERenderStatisticsCounter.ShadowmapUpdatesSkippedFrustum,
								1,
								BBMOD_ERenderPass.Shadows);
						}
					}
					++i;
				}
			}
		}

		if (_shadowCaster == undefined)
		{
			bbmod_shader_unset_global(BBMOD_U_SHADOWMAP);
			bbmod_shader_set_global_f(BBMOD_U_SHADOWMAP_ENABLE_VS, 0.0);
			bbmod_shader_set_global_f(BBMOD_U_SHADOWMAP_ENABLE_PS, 0.0);
			__gc_collect_shadowmaps();
			return;
		}

		__render_shadowmap_impl(_shadowCaster);

		var _shadowmapTexture = surface_get_texture(__shadowmapSurfaces[?  _shadowCaster]);
		bbmod_shader_set_global_f(BBMOD_U_SHADOWMAP_ENABLE_VS, 1.0);
		bbmod_shader_set_global_f(BBMOD_U_SHADOWMAP_ENABLE_PS, 1.0);
		bbmod_shader_set_global_sampler(BBMOD_U_SHADOWMAP, _shadowmapTexture);
		bbmod_shader_set_global_sampler_mip_enable(BBMOD_U_SHADOWMAP, true);
		bbmod_shader_set_global_sampler_filter(BBMOD_U_SHADOWMAP, true);
		bbmod_shader_set_global_sampler_repeat(BBMOD_U_SHADOWMAP, false);
		bbmod_shader_set_global_f2(BBMOD_U_SHADOWMAP_TEXEL,
			texture_get_texel_width(_shadowmapTexture),
			texture_get_texel_height(_shadowmapTexture));
		bbmod_shader_set_global_f(BBMOD_U_SHADOWMAP_AREA, _shadowCaster.__getZFar());
		bbmod_shader_set_global_f(BBMOD_U_SHADOWMAP_NORMAL_OFFSET_VS, ShadowmapNormalOffset);
		bbmod_shader_set_global_f(BBMOD_U_SHADOWMAP_NORMAL_OFFSET_PS, ShadowmapNormalOffset);
		bbmod_shader_set_global_matrix_array(BBMOD_U_SHADOWMAP_MATRIX, _shadowCaster.__getShadowmapMatrix());
		bbmod_shader_set_global_f(BBMOD_U_SHADOW_CASTER_INDEX, _shadowCasterIndex);
		__gc_collect_shadowmaps();
	};

	/// @func __render_reflection_probes()
	///
	/// @desc
	///
	/// @note This modifies render pass and view and projection matrices and
	/// for optimization reasons it does not reset them back! Make sure to do
	/// that yourself in the calling function if needed.
	///
	/// @private
	static __render_reflection_probes = function ()
	{
		var _view = matrix_get(matrix_view);
		var _projection = matrix_get(matrix_projection);
		var _exposure = bbmod_camera_get_exposure();

		global.__bbmodReflectionProbeTexture = (-1 /*pointer_null*/ );
		bbmod_camera_set_exposure(1.0);

		var _cubemap = __cubemap;
		var _reflectionProbes = bbmod_scene_get_current().ReflectionProbes;

		var i = 0;
		repeat(array_length(_reflectionProbes))
		{
			with(_reflectionProbes[i++])
			{
				if (!Enabled || !NeedsUpdate)
				{
					continue;
				}

				// Copy reflection probe settings to cubemap
				Position.Copy(_cubemap.Position);
				_cubemap.Resolution = Resolution;

				// Render shadows
				with(other)
				{
					var _enableShadows = EnableShadows;
					EnableShadows &= other.EnableShadows; // Temporarily modify renderer's EnableShadows
					__render_shadowmaps();
					EnableShadows = _enableShadows;
				}

				// Fill cubemap
				bbmod_render_pass_set(BBMOD_ERenderPass.ReflectionCapture);

				bbmod_shader_set_global_f(BBMOD_U_HDR, bbmod_hdr_is_supported() ? 1.0 : 0.0);

				while (_cubemap.set_target())
				{
					draw_clear(c_black);
					bbmod_render_queues_submit();
					_cubemap.reset_target();
				}
				bbmod_material_reset();

				bbmod_shader_unset_global(BBMOD_U_HDR);

				// Prefilter and apply
				_cubemap.to_single_surface();
				_cubemap.to_octahedron();
				var _sprite = _cubemap.prefilter_ibl();
				set_sprite(_sprite);

				NeedsUpdate = false;
			}
		}

		var _imageBasedLight = bbmod_scene_get_current().ImageBasedLight;
		var _to = (_imageBasedLight != undefined)
			? _imageBasedLight.Texture
			: sprite_get_texture(BBMOD_SprBlack, 0);

		var _reflectionProbe = bbmod_reflection_probe_find(bbmod_camera_get_position());
		if (_reflectionProbe != undefined)
		{
			_to = sprite_get_texture(_reflectionProbe.Sprite, 0);
		}

		var _world = matrix_get(matrix_world);
		matrix_set(matrix_world, matrix_build_identity());

		gpu_push_state();
		gpu_set_state(bbmod_gpu_get_default_state());
		gpu_set_blendenable(false);
		gpu_set_tex_filter(false);

		var _height = 128;
		var _width = _height * 8;

		var _surOld = __surProbe1;
		__surProbe1 = bbmod_surface_check(__surProbe1, _width, _height, surface_rgba8unorm, false);
		__surProbe2 = bbmod_surface_check(__surProbe2, _width, _height, surface_rgba8unorm, false);

		if (__surProbe1 != _surOld)
		{
			surface_set_target(__surProbe1);
			draw_clear_alpha(c_black, 0);

			var _camera = camera_create();
			camera_set_view_size(_camera, _width, _height);
			camera_apply(_camera);

			shader_set(BBMOD_ShMixRGBM);
			texture_set_stage(shader_get_sampler_index(BBMOD_ShMixRGBM, "u_texTo"), _to);
			shader_set_uniform_f(shader_get_uniform(BBMOD_ShMixRGBM, "u_fFactor"), 1.0);
			draw_surface(__surProbe2, 0, 0);
			shader_reset();

			surface_reset_target();
			camera_destroy(_camera);
		}

		{
			surface_set_target(__surProbe2);
			draw_clear_alpha(c_black, 0);
			var _camera = camera_create();
			camera_set_view_size(_camera, _width, _height);
			camera_apply(_camera);
			draw_surface(__surProbe1, 0, 0);
			surface_reset_target();
			camera_destroy(_camera);
		}

		{
			surface_set_target(__surProbe1);
			draw_clear_alpha(c_black, 0);

			var _camera = camera_create();
			camera_set_view_size(_camera, _width, _height);
			camera_apply(_camera);

			shader_set(BBMOD_ShMixRGBM);
			texture_set_stage(shader_get_sampler_index(BBMOD_ShMixRGBM, "u_texTo"), _to);
			shader_set_uniform_f(shader_get_uniform(BBMOD_ShMixRGBM, "u_fFactor"), 0.1);
			draw_surface(__surProbe2, 0, 0);
			shader_reset();

			surface_reset_target();
			camera_destroy(_camera);
		}

		gpu_pop_state();

		matrix_set(matrix_world, _world);
		matrix_set(matrix_view, _view);
		matrix_set(matrix_projection, _projection);

		global.__bbmodReflectionProbeTexture = surface_get_texture(__surProbe1);
		bbmod_camera_set_exposure(_exposure);
	};

	/// @func __render_gizmo_and_instance_ids(_hdr)
	///
	/// @desc Renders gizmo and instance IDs into dedicated surfaces.
	///
	/// @param {Bool} _hdr Whether HDR rendering is enabled.
	///
	/// @private
	static __render_gizmo_and_instance_ids = function (_hdr)
	{
		var _view = matrix_get(matrix_view);
		var _projection = matrix_get(matrix_projection);
		var _renderWidth = get_render_width();
		var _renderHeight = get_render_height();

		var _editMode = (EditMode && Gizmo);
		var _mouseX = window_mouse_get_x();
		var _mouseY = window_mouse_get_y();
		var _mouseOver = (_mouseX >= X && _mouseX < X + get_width()
			&& _mouseY >= Y && _mouseY < Y + get_height());
		var _continueMousePick = EnableMousepick;
		var _gizmoSize;

		if (_editMode)
		{
			_gizmoSize = Gizmo.Size;

			if (_projection[11] != 0.0)
			{
				Gizmo.Size = _gizmoSize
					* Gizmo.Position.Sub(bbmod_camera_get_position()).Length() / 100.0;
			}
		}

		////////////////////////////////////////////////////////////////////////
		// Gizmo select
		if (_editMode
			&& _continueMousePick
			&& _mouseOver
			&& mouse_check_button_pressed(Gizmo.ButtonDrag))
		{
			bbmod_render_pass_set(BBMOD_ERenderPass.Forward);

			__surSelect = bbmod_surface_check(__surSelect, _renderWidth, _renderHeight, surface_rgba8unorm, true);
			surface_set_target(__surSelect);
			draw_clear_alpha(0, 0.0);
			matrix_set(matrix_view, _view);
			matrix_set(matrix_projection, _projection);
			Gizmo.submit(Gizmo.MaterialsSelect);
			bbmod_material_reset();
			surface_reset_target();

			if (select_gizmo(_mouseX, _mouseY))
			{
				Gizmo.IsEditing = true;
				_continueMousePick = false;
			}
		}

		////////////////////////////////////////////////////////////////////////
		// Instance IDs
		if (_editMode)
		{
			__editor_project_icons(_renderWidth, _renderHeight);
		}

		if (_editMode
			&& ShowEditorIcons
			&& _continueMousePick
			&& _mouseOver
			&& mouse_check_button_pressed(ButtonSelect))
		{
			var _target = __editor_pick_icon(_mouseX, _mouseY);
			if (_target != undefined)
			{
				if (!keyboard_check(KeyMultiSelect))
				{
					Gizmo.clear_selection();
				}
				Gizmo.toggle_select_node(_target).update_position();
				Gizmo.Size = _gizmoSize
					* Gizmo.Position.Sub(bbmod_camera_get_position()).Length() / 100.0;
				_continueMousePick = false;
			}
		}

		var _mousePickInstance = (_editMode && _continueMousePick
			&& _mouseOver && mouse_check_button_pressed(ButtonSelect));

		if (_mousePickInstance || RenderInstanceIDs)
		{
			__surSelect = bbmod_surface_check(__surSelect, _renderWidth, _renderHeight, surface_rgba8unorm, true);

			surface_set_target(__surSelect);
			draw_clear_alpha(0, 0.0);
			matrix_set(matrix_view, _view);
			matrix_set(matrix_projection, _projection);

			bbmod_render_pass_set(BBMOD_ERenderPass.Id);

			bbmod_render_queues_submit();
			bbmod_material_reset();

			surface_reset_target();

			// Select instance
			if (_mousePickInstance)
			{
				if (!keyboard_check(KeyMultiSelect))
				{
					Gizmo.clear_selection();
				}

				var _id = get_instance_id(_mouseX, _mouseY);
				if (_id != 0)
				{
					if (ds_map_exists(global.__bbmodSceneNodePickMap, _id))
					{
						var _target = global.__bbmodSceneNodePickMap[?  _id];
						Gizmo.toggle_select_node(_target).update_position();
					}
					else
					{
						Gizmo.toggle_select(_id).update_position();
					}

					Gizmo.Size = _gizmoSize
						* Gizmo.Position.Sub(bbmod_camera_get_position()).Length() / 100.0;
				}
			}
		}

		ds_map_clear(global.__bbmodSceneNodePickMap);

		if (_editMode && (!ds_list_empty(Gizmo.Selected)
				|| !ds_list_empty(Gizmo.SelectedNodes)))
		{
			////////////////////////////////////////////////////////////////////
			// Instance highlight
			if (!ds_list_empty(Gizmo.Selected) || !ds_list_empty(Gizmo.SelectedNodes))
			{
				__surInstanceHighlight = bbmod_surface_check(
					__surInstanceHighlight, _renderWidth, _renderHeight, surface_rgba8unorm, true);

				surface_set_target(__surInstanceHighlight);
				draw_clear_alpha(0, 0.0);

				matrix_set(matrix_view, _view);
				matrix_set(matrix_projection, _projection);

				bbmod_render_pass_set(BBMOD_ERenderPass.Id);

				// Build combined filter: legacy instance IDs + scene node pick IDs
				var _selectedAll = Gizmo.Selected;
				var _sizeNodes = ds_list_size(Gizmo.SelectedNodes);
				if (_sizeNodes > 0)
				{
					_selectedAll = ds_list_create();
					var _sizeInstances = ds_list_size(Gizmo.Selected);
					var k = 0;
					repeat(_sizeInstances)
					{
						ds_list_add(_selectedAll, Gizmo.Selected[|  k]);
						++k;
					}
					k = 0;
					repeat(_sizeNodes)
					{
						var _node = Gizmo.SelectedNodes[|  k];
						if (variable_struct_exists(_node, "__bbmodPickId"))
						{
							ds_list_add(_selectedAll, _node.__bbmodPickId);
						}
						++k;
					}
				}

				bbmod_render_queues_submit(_selectedAll);

				if (_selectedAll != Gizmo.Selected)
				{
					ds_list_destroy(_selectedAll);
				}

				bbmod_material_reset();

				surface_reset_target();
			}

			////////////////////////////////////////////////////////////////////
			// Gizmo
			bbmod_render_pass_set(BBMOD_ERenderPass.Forward);

			__surGizmo = bbmod_surface_check(__surGizmo, _renderWidth, _renderHeight,
				_hdr ? surface_rgba16float : surface_rgba8unorm, true);

			surface_set_target(__surGizmo);
			draw_clear_alpha(0, 0.0);
			matrix_set(matrix_view, _view);
			matrix_set(matrix_projection, _projection);

			var _hdrPrev = bbmod_shader_get_global(BBMOD_U_HDR);
			bbmod_shader_set_global_f(BBMOD_U_HDR, _hdr ? 1.0 : 0.0);

			Gizmo.submit();

			if (_hdrPrev != undefined)
			{
				bbmod_shader_set_global_f(BBMOD_U_HDR, _hdrPrev);
			}
			else
			{
				bbmod_shader_unset_global(BBMOD_U_HDR);
			}

			bbmod_material_reset();
			surface_reset_target();
		}

		if (_editMode)
		{
			Gizmo.Size = _gizmoSize;
		}
	};

	/// @private
	static __draw_editor_debug_geometry = function ()
	{
		if (!EditMode || !Gizmo || !ShowEditorWireframe
			|| ds_list_empty(Gizmo.SelectedNodes))
		{
			return;
		}

		var _color = EditorWireframeColor.ToConstant();
		var _alpha = EditorWireframeColor.Alpha;

		gpu_push_state();
		gpu_set_state(bbmod_gpu_get_default_state());
		gpu_set_blendenable(true);
		gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_one, bm_inv_src_alpha);
		gpu_set_colorwriteenable(true, true, true, true);
		gpu_set_zwriteenable(false);
		gpu_set_ztestenable(false);

		var _world = matrix_get(matrix_world);
		matrix_set(matrix_world, bbmod_matrix_get_identity());

		var _size = ds_list_size(Gizmo.SelectedNodes);
		var i = 0;
		repeat(_size)
		{
			var _target = Gizmo.SelectedNodes[|  i++];

			switch (_target.SceneNodeKind)
			{
				case BBMOD_ESceneNodeType.PointLight:
					__bbmod_editor_debug_draw_sphere(
						_target.Position,
						_target.Range,
						_color,
						_alpha);
					break;

				case BBMOD_ESceneNodeType.SpotLight:
					__bbmod_editor_debug_draw_cone(
						_target.Position,
						_target.Direction,
						_target.Range,
						_target.AngleInner,
						_color,
						_alpha);
					__bbmod_editor_debug_draw_cone(
						_target.Position,
						_target.Direction,
						_target.Range,
						_target.AngleOuter,
						_color,
						_alpha);
					break;

				case BBMOD_ESceneNodeType.DirectionalLight:
					var _position = _target.Position;
					var _direction = _target.Direction.Normalize();
					var _wireframeLength = _target.EditorWireframeLength;
					var _directionOffset = _direction.Scale(_wireframeLength * 0.5);
					var _directionStart = _position.Sub(_directionOffset);
					var _directionEnd = _position.Add(_directionOffset);
					__bbmod_editor_debug_draw_line(
						_directionStart.X,
						_directionStart.Y,
						_directionStart.Z,
						_directionEnd.X,
						_directionEnd.Y,
						_directionEnd.Z,
						_color,
						_alpha);
					__bbmod_editor_debug_draw_cone(
						_directionEnd,
						_direction.Scale(-1.0),
						_wireframeLength * 0.2,
						20.0,
						_color,
						_alpha);
					break;

				case BBMOD_ESceneNodeType.ReflectionProbe:
					if (!_target.Infinite)
					{
						__bbmod_editor_debug_draw_aabb(
							_target.Position,
							_target.Size,
							_color,
							_alpha);
					}
					break;
			}
		}

		matrix_set(matrix_world, _world);
		gpu_pop_state();
	};

	/// @private
	static __overlay_gizmo_and_instance_highlight = function ()
	{
		if (!EditMode || !Gizmo
			|| (ds_list_empty(Gizmo.Selected)
				&& ds_list_empty(Gizmo.SelectedNodes)
				&& __editorIconCount <= 0))
		{
			return;
		}

		gpu_push_state();
		gpu_set_blendenable(true);
		gpu_set_zwriteenable(false);
		gpu_set_ztestenable(false);

		var _world = matrix_get(matrix_world);
		var _view = matrix_get(matrix_view);
		var _projection = matrix_get(matrix_projection);
		var _width = get_render_width();
		var _height = get_render_height();
		var _texelWidth = 1.0 / _width;
		var _texelHeight = 1.0 / _height;

		matrix_set(matrix_world, bbmod_matrix_get_identity());
		camera_set_view_size(__camera2D, _width, _height);
		camera_apply(__camera2D);

		////////////////////////////////////////////////////////////////
		// Highlighted instances
		if ((!ds_list_empty(Gizmo.Selected)
				|| !ds_list_empty(Gizmo.SelectedNodes))
			&& surface_exists(__surInstanceHighlight))
		{
			var _shader = BBMOD_ShInstanceHighlight;
			shader_set(_shader);
			bbmod_shader_set_globals(_shader);
			shader_set_uniform_f(shader_get_uniform(_shader, "u_vTexel"),
				_texelWidth, _texelHeight);
			shader_set_uniform_f(shader_get_uniform(_shader, "u_vColor"),
				InstanceHighlightColor.Red / 255.0,
				InstanceHighlightColor.Green / 255.0,
				InstanceHighlightColor.Blue / 255.0,
				InstanceHighlightColor.Alpha);
			draw_surface_stretched(__surInstanceHighlight, 0, 0, _width, _height);
			shader_reset();
		}

		////////////////////////////////////////////////////////////////
		// Gizmo
		if ((!ds_list_empty(Gizmo.Selected) || !ds_list_empty(Gizmo.SelectedNodes))
			&& surface_exists(__surGizmo))
		{
			draw_surface_stretched(__surGizmo, 0, 0, _width, _height);
		}

		////////////////////////////////////////////////////////////////
		// Editor icons
		if (ShowEditorIcons && __editorIconCount > 0)
		{
			var i = 0;
			repeat(__editorIconCount)
			{
				var _target = __editorIconTarget[i];
				var _sprite = __editorIconSprite[i];
				var _frame = __editorIconFrame[i];
				var _scale = __editorIconScale[i];
				var _alpha = __editorIconAlpha[i] * 0.75;
				if (Gizmo.is_node_selected(_target))
				{
					_scale *= 1.25;
					_alpha = __editorIconAlpha[i];
				}
				draw_sprite_ext(
					_sprite,
					_frame,
					__editorIconX[i],
					__editorIconY[i],
					_scale,
					_scale,
					0.0,
					c_white,
					_alpha);
				++i;
			}
		}

		matrix_set(matrix_world, _world);
		matrix_set(matrix_view, _view);
		matrix_set(matrix_projection, _projection);

		gpu_pop_state();
	};

	/// @private
	static __render_ssao = function (_surDepth, _projection)
	{
		if (EnableSSAO)
		{
			var _width = get_render_width() * SSAOScale;
			var _height = get_render_height() * SSAOScale;

			__surSSAO = bbmod_surface_check(__surSSAO, _width, _height, surface_rgba8unorm, false);
			__surWork = bbmod_surface_check(__surWork, _width, _height, surface_rgba8unorm, false);

			bbmod_ssao_draw(SSAORadius * SSAOScale, SSAOPower, SSAOAngleBias,
				SSAODepthRange, __surSSAO, __surWork, _surDepth, _projection,
				bbmod_camera_get_zfar(), SSAOSelfOcclusionBias, SSAOBlurDepthRange);

			bbmod_shader_set_global_sampler(
				BBMOD_U_SSAO, surface_get_texture(__surSSAO));
		}
		else
		{
			bbmod_shader_set_global_sampler(
				BBMOD_U_SSAO, sprite_get_texture(BBMOD_SprWhite, 0));
		}
	};

	/// @func render(_clearQueues=true)
	///
	/// @desc Renders all added [renderables](./BBMOD_BaseRenderer.Renderables.html)
	/// to the current render target.
	///
	/// @param {Bool} [_clearQueues] If true then all render queues are cleared
	/// at the end of this method. Default value is `true`.
	///
	/// @return {Struct.BBMOD_BaseRenderer} Returns `self`.
	static render = function (_clearQueues = true)
	{
		global.__bbmodRendererCurrent = self;

		var _world = matrix_get(matrix_world);
		var _view = matrix_get(matrix_view);
		var _projection = matrix_get(matrix_projection);
		var _punctualLightsVisible = __build_visible_punctual_lights();

		var i = 0;
		repeat(array_length(Renderables))
		{
			with(Renderables[i++])
			{
				render();
			}
		}

		__render_scene_nodes();

		////////////////////////////////////////////////////////////////////////
		//
		// Reflection probes
		//
		__render_reflection_probes();

		////////////////////////////////////////////////////////////////////////
		//
		// Edit mode
		//
		__render_gizmo_and_instance_ids(false);

		////////////////////////////////////////////////////////////////////////
		//
		// Shadow map
		//
		__render_shadowmaps();

		////////////////////////////////////////////////////////////////////////
		//
		// Background
		//
		global.__bbmodPunctualLightsRenderer = _punctualLightsVisible;

		bbmod_shader_set_global_f(BBMOD_U_ZFAR, bbmod_camera_get_zfar());

		matrix_set(matrix_view, _view);
		matrix_set(matrix_projection, _projection);

		bbmod_render_pass_set(BBMOD_ERenderPass.Background);

		bbmod_render_queues_submit();
		bbmod_material_reset();

		////////////////////////////////////////////////////////////////////////
		//
		// Forward pass
		//
		bbmod_render_pass_set(BBMOD_ERenderPass.Forward);

		bbmod_render_queues_submit();
		bbmod_material_reset();

		////////////////////////////////////////////////////////////////////////
		//
		// Alpha pass
		//
		bbmod_render_pass_set(BBMOD_ERenderPass.Alpha);

		bbmod_render_queues_submit();
		if (_clearQueues)
		{
			bbmod_render_queues_clear();
		}
		bbmod_material_reset();

		////////////////////////////////////////////////////////////////////////
		//
		// Draw editor debug geometry, gizmo and highlight selected instances
		//
		__draw_editor_debug_geometry();
		__overlay_gizmo_and_instance_highlight();

		////////////////////////////////////////////////////////////////////////

		// Reset render pass back to Forward at the end!
		bbmod_render_pass_set(BBMOD_ERenderPass.Forward);

		matrix_set(matrix_world, _world);

		// Unset in case it gets destroyed when the room changes etc.
		bbmod_shader_unset_global(BBMOD_U_SHADOWMAP);
		global.__bbmodPunctualLightsRenderer = undefined;

		return self;
	};

	/// @func present()
	///
	/// @desc Presents the rendered graphics on the screen, with post-processing
	/// applied (if {@link BBMOD_BaseRenderer.PostProcessor} is defined).
	///
	/// @return {Struct.BBMOD_BaseRenderer} Returns `self`.
	///
	/// @note If {@link BBMOD_BaseRenderer.UseAppSurface} is `false`, then this only
	/// draws the gizmo and selected instances. The world matrix is automatically
	/// set to identity before drawing the surfaces and then reset back.
	static present = function ()
	{
		global.__bbmodRendererCurrent = self;

		if (UseAppSurface)
		{
			var _world = matrix_get(matrix_world);
			matrix_set(matrix_world, matrix_build_identity());
			if (PostProcessor != undefined
				&& PostProcessor.Enabled)
			{
				PostProcessor.__renderScale = bbmod_is_browser() ? 1.0 : RenderScale;
				PostProcessor.draw(application_surface, X, Y);
			}
			else
			{
				gpu_push_state();
				gpu_set_blendenable(false);
				draw_surface_stretched(application_surface, X, Y, get_width(), get_height());
				gpu_pop_state();
			}
			matrix_set(matrix_world, _world);
		}

		return self;
	};

	static destroy = function ()
	{
		if (global.__bbmodRendererCurrent == self)
		{
			global.__bbmodRendererCurrent = undefined;
		}

		if (surface_exists(__surSelect))
		{
			surface_free(__surSelect);
		}

		if (surface_exists(__surInstanceHighlight))
		{
			surface_free(__surInstanceHighlight);
		}

		if (surface_exists(__surGizmo))
		{
			surface_free(__surGizmo);
		}

		if (surface_exists(__surFinal))
		{
			surface_free(__surFinal);
		}

		if (surface_exists(__surProbe1))
		{
			surface_free(__surProbe1);
		}

		if (surface_exists(__surProbe2))
		{
			surface_free(__surProbe2);
		}

		if (surface_exists(__surSSAO))
		{
			surface_free(__surSSAO);
		}

		if (surface_exists(__surWork))
		{
			surface_free(__surWork);
		}

		if (UseAppSurface)
		{
			application_surface_enable(false);
			application_surface_draw_enable(true);
		}

		ds_list_destroy(__shadowmapLights);
		ds_list_destroy(__shadowmapHealth);

		var _key = ds_map_find_first(__shadowmapSurfaces);
		repeat(ds_map_size(__shadowmapSurfaces))
		{
			var _surface = __shadowmapSurfaces[?  _key];
			if (surface_exists(_surface))
			{
				surface_free(_surface);
			}
			_key = ds_map_find_next(__shadowmapSurfaces, _key);
		}
		ds_map_destroy(__shadowmapSurfaces);

		_key = ds_map_find_first(__shadowmapCubes);
		repeat(ds_map_size(__shadowmapCubes))
		{
			__shadowmapCubes[?  _key].destroy();
			_key = ds_map_find_next(__shadowmapCubes, _key);
		}
		ds_map_destroy(__shadowmapCubes);

		camera_destroy(__camera2D);

		return undefined;
	};
}
