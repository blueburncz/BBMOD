/// @func BBMOD_Camera()
/// @desc A first-person and third-person camera with mouselook.
/// @example
/// ```gml
/// // Create event
/// camera = new BBMOD_Camera();
/// camera.FollowObject = OPlayer;
/// camera.Zoom = 0; // Use 0 for FPS, > 0 for TPS
///
/// // End-Step event
/// camera.set_mouselook(true);
/// camera.update(delta_time);
///
/// // Draw event
/// camera.apply();
/// // Render scene here...
/// ```
function BBMOD_Camera() constructor
{
	/// @var {camera} An underlying GameMaker camera.
	/// @readonly
	Raw = camera_create();

	/// @var {real} The camera's exposure value. Defaults to `1`.
	Exposure = 1.0;

	/// @var {BBMOD_Vec3} The camera's positon. Defaults to `[0, 0, 0]`.
	Position = new BBMOD_Vec3(0.0);

	/// @var {BBMOD_Vec3} A position where the camera is looking at.
	/// In FPS mode ({@link BBMOD_Camera.Zoom} equals to 0) this is the camera's
	/// direction. Defaults to `[1, 0, 0]`.
	Target = new BBMOD_Vec3(1.0, 0.0, 0.0);

	/// @var {BBMOD_Vec3} The camera's up vector. Defaults to `[0, 0, 1]`.
	Up = new BBMOD_Vec3(0.0, 0.0, 1.0);

	/// @var {real} The camera's field of view. Defaults to `60`.
	/// @note This does not have any effect when {@link BBMOD_Camera.Orthographic}
	/// is enabled.
	Fov = 60.0;

	/// @var {real} The camera's aspect ratio. Defaults to `16 / 9`.
	AspectRatio = 16.0 / 9.0;

	/// @var {real} Distance to the near clipping plane. Anything closer to the
	/// camera than this will not be visible. Defaults to `0.1`.
	/// @note This can be a negative value if {@link BBMOD_Camera.Orthographic}
	/// is enabled.
	ZNear = 0.1;

	/// @var {real} Distance to the far clipping plane. Anything farther from
	/// the camera than this will not be visible. Defaults to `32768`.
	ZFar = 32768.0;

	/// @var {bool} Use `true` to enable orthographic projection. Defaults to
	/// `false` (perspective projection).
	Orthographic = false;

	/// @var {real} The width of the orthographic projection. Height is computed
	/// using {@link BBMOD_Camera.AspectRatio}. Defaults to the window's width.
	/// @see BBMOD_Camera.Orthographic
	Width = window_get_width();

	/// @var {uint/undefined} An id of an instance to follow or `undefined`. The
	/// object must have a `z` variable (position on the z axis) defined!
	/// Defaults to `undefined`.
	FollowObject = undefined;

	/// @var {bool} Used to determine change of the object to follow.
	/// @private
	FollowObjectLast = undefined;

	/// @var {func/undefined} A function which remaps value in range `0..1` to a
	/// different `0..1` value. This is used to control the follow curve. If
	/// not defined then `lerp` is used. Defaults to `undefined`.
	FollowCurve = undefined;

	/// @var {real} Controls lerp factor between the previous camera position
	/// and the object it follows. Defaults to `1`, which means the camera is
	/// immediately moved to its target position.
	/// {@link BBMOD_Camera.FollowObject} must not be `undefined` for this to
	/// have any effect.
	FollowFactor = 1.0;

	/// @var {BBMOD_Vec3} The camera's offset from its target. Defaults to
	/// `[0, 0, 0]`.
	Offset = new BBMOD_Vec3(0.0);

	/// @var {bool} If `true` then mouselook is enabled. Defaults to `false`.
	/// @readonly
	/// @see BBMOD_Camera.set_mouselook
	MouseLook = false;

	/// @var {real} Controls the mouselook sensitivity. Defaults to `1`.
	MouseSensitivity = 1.0;

	/// @var {BBMOD_Vec2/undefined} The position on the screen where the cursor
	/// is locked when {@link BBMOD_Camera.MouseLook} is `true`.
	/// @private
	MouseLockAt = undefined;

	/// @var {real} The camera's horizontal direction. Defaults to `0`.
	/// @readonly
	Direction = 0.0;

	/// @var {real} The camera's vertical direction. Automatically clamped
	/// between `-89` and `89`. Defaults to `0`.
	/// @readonly
	DirectionUp = 0.0;

	/// @var {real} The camera's distance from its target. Use `0` for a
	/// first-person camera. Defaults to `0`.
	Zoom = 0.0;

	/// @var {bool} If `true` then the camera updates position and orientation
	/// of the 3D audio listener in the {@link BBMOD_Camera.update_matrices}
	/// method. Defaults to `true`.
	AudioListener = true;

	/// @func set_mouselook(_enable)
	/// @desc Enable/disable mouselook. This locks the mouse cursor at its
	/// current position when enabled.
	/// @param {bool} _enable USe `true` to enable mouselook.
	/// @return {BBMOD_Camera} Returns `self`.
	static set_mouselook = function (_enable) {
		if (_enable)
		{
			if (os_browser != browser_not_a_browser)
			{
				bbmod_html5_pointer_lock();
			}
			if (MouseLockAt == undefined)
			{
				MouseLockAt = new BBMOD_Vec2(
					window_mouse_get_x(),
					window_mouse_get_y(),
				);
			}
		}
		else
		{
			MouseLockAt = undefined;
		}
		MouseLook = _enable;
		return self;
	};

	/// @func update_matrices()
	/// @desc Recomputes camera's view and projection matrices.
	/// @return {BBMOD_Camera} Returns `self`.
	/// @note This is called automatically in the {@link BBMOD_Camera.update}
	/// method, so you do not need to call this unless you modify
	/// {@link BBMOD_Camera.Position} or {@link BBMOD_Camera.Target} after the
	/// `update` method.
	/// @example
	/// ```gml
	/// /// @desc Step event
	/// camera.set_mouselook(true);
	/// camera.update(delta_time);
	/// if (camera.Position.Z < 0.0)
	/// {
	///     camera.Position.Z = 0.0;
	/// }
	/// camera.update_matrices();
	/// ```
	static update_matrices = function () {
		gml_pragma("forceinline");
		var _view = matrix_build_lookat(
			Position.X, Position.Y, Position.Z,
			Target.X, Target.Y, Target.Z,
			Up.X, Up.Y, Up.Z);
		camera_set_view_mat(Raw, _view);
		var _proj = Orthographic
			? matrix_build_projection_ortho(Width, -Width / AspectRatio, ZNear, ZFar)
			: matrix_build_projection_perspective_fov(
				-Fov, -AspectRatio, ZNear, ZFar);
		camera_set_proj_mat(Raw, _proj);
		if (AudioListener)
		{
			audio_listener_position(Position.X, Position.Y, Position.Z);
			audio_listener_orientation(
				Target.X - Position.X, Target.Y - Position.Y, Target.Z - Position.Z,
				Up.X, Up.Y, Up.Z);
		}
		return self;
	}

	/// @func update(_deltaTime[, _positionHandler])
	/// @desc Handles mouselook, updates camera's position, matrices etc.
	/// @param {real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	/// @param {func/undefined} [_positionHandler] A function which takes
	/// the camera's position (@{link BBMOD_Vec3}) and returns a new position.
	/// This could be used for example for camera collisions in a third-person
	/// game. Defaults to `undefined`.
	/// @return {BBMOD_Camera} Returns `self`.
	static update = function (_deltaTime, _positionHandler=undefined) {
		if (os_browser != browser_not_a_browser)
		{
			set_mouselook(bbmod_html5_pointer_is_locked());
		}

		if (MouseLook)
		{
			if (os_browser != browser_not_a_browser)
			{
				Direction -= bbmod_html5_pointer_get_movement_x() * MouseSensitivity;
				DirectionUp -= bbmod_html5_pointer_get_movement_y() * MouseSensitivity;
			}
			else
			{
				var _mouseX = window_mouse_get_x();
				var _mouseY = window_mouse_get_y();
				Direction += (MouseLockAt.X - _mouseX) * MouseSensitivity;
				DirectionUp += (MouseLockAt.Y - _mouseY) * MouseSensitivity;
				window_mouse_set(MouseLockAt.X, MouseLockAt.Y);
			}

			DirectionUp = clamp(DirectionUp, -89.0, 89.0);
		}

		var _offsetX = lengthdir_x(Offset.X, Direction - 90.0)
			+ lengthdir_x(Offset.Y, Direction);
		var _offsetY = lengthdir_y(Offset.X, Direction - 90.0)
			+ lengthdir_y(Offset.Y, Direction);
		var _offsetZ = Offset.Z;

		if (Zoom <= 0)
		{
			// First person camera
			if (FollowObject != undefined
				&& instance_exists(FollowObject))
			{
				Position.X = FollowObject.x + _offsetX;
				Position.Y = FollowObject.y + _offsetY;
				Position.Z = FollowObject.z + _offsetZ;
			}

			Target = Position.Add(new BBMOD_Vec3(
				+dcos(Direction),
				-dsin(Direction),
				+dtan(DirectionUp),
			));
		}
		else
		{
			// Third person camera
			if (FollowObject != undefined
				&& instance_exists(FollowObject))
			{
				var _targetNew = new BBMOD_Vec3(
					FollowObject.x + _offsetX,
					FollowObject.y + _offsetY,
					FollowObject.z + _offsetZ,
				);

				if (FollowObjectLast == FollowObject
					&& FollowFactor < 1.0)
				{
					var _factor = 1.0 - bbmod_lerp_delta_time(0.0, 1.0, FollowFactor, _deltaTime);
					if (FollowCurve != undefined)
					{
						_factor = FollowCurve(0.0, 1.0, _factor);
					}
					Target = _targetNew.Lerp(Target, _factor);
				}
				else
				{
					Target = _targetNew;
				}
			}

			var _l = dcos(DirectionUp) * Zoom;
			Position = Target.Add(new BBMOD_Vec3(
				-dcos(Direction) * _l,
				+dsin(Direction) * _l,
				-dsin(DirectionUp) * Zoom,
			));
		}

		if (_positionHandler != undefined)
		{
			Position = _positionHandler(Position);
		}

		update_matrices();

		FollowObjectLast = FollowObject;

		return self;
	};

	/// @func get_view_mat()
	/// @desc Retrieves camera's view matrix.
	/// @return {real[16]} The view matrix.
	static get_view_mat = function () {
		gml_pragma("forceinline");

		if (os_browser == browser_not_a_browser)
		{
			// This returns a struct in HTML5 for some reason...
			return camera_get_view_mat(Raw);
		}

		var _view = matrix_get(matrix_view);
		var _proj = matrix_get(matrix_projection);
		camera_apply(Raw);
		var _retval = matrix_get(matrix_view);
		matrix_set(matrix_view, _view);
		matrix_set(matrix_projection, _proj);
		return _retval;
	};

	/// @func get_proj_mat()
	/// @desc Retrieves camera's projection matrix.
	/// @return {real[16]} The projection matrix.
	static get_proj_mat = function () {
		gml_pragma("forceinline");

		if (os_browser == browser_not_a_browser)
		{
			// This returns a struct in HTML5 for some reason...
			return camera_get_proj_mat(Raw);
		}

		var _view = matrix_get(matrix_view);
		var _proj = matrix_get(matrix_projection);
		camera_apply(Raw);
		var _retval = matrix_get(matrix_projection);
		matrix_set(matrix_view, _view);
		matrix_set(matrix_projection, _proj);
		return _retval;
	};

	/// @func get_right()
	/// @desc Retrieves a vector pointing right relative to the camera's
	/// direction.
	/// @return {BBMOD_Vec3} The right vector.
	static get_right = function () {
		gml_pragma("forceinline");
		var _view = get_view_mat();
		return new BBMOD_Vec3(
			_view[0],
			_view[4],
			_view[8],
		);
	};

	/// @func get_up()
	/// @desc Retrieves a vector pointing up relative to the camera's
	/// direction.
	/// @return {BBMOD_Vec3} The up vector.
	static get_up = function () {
		gml_pragma("forceinline");
		var _view = get_view_mat();
		return new BBMOD_Vec3(
			_view[1],
			_view[5],
			_view[9],
		);
	};

	/// @func get_forward()
	/// @desc Retrieves a vector pointing forward in the camera's direction.
	/// @return {BBMOD_Vec3} The forward vector.
	static get_forward = function () {
		gml_pragma("forceinline");
		var _view = get_view_mat();
		return new BBMOD_Vec3(
			_view[2],
			_view[6],
			_view[10],
		);
	};

	/// @func apply()
	/// @desc Applies the camera.
	/// @return {BBMOD_Camera} Returns `self`.
	/// @example
	/// Following code renders a model from the camera's view.
	/// ```gml
	/// camera.apply();
	/// bbmod_material_reset();
	/// model.submit();
	/// bbmod_material_reset();
	/// ```
	/// @note This also overrides the camera position and exposure passed to
	/// shaders using {@link bbmod_camera_set_position} and
	/// {@link bbmod_camera_set_exposure} respectively!
	static apply = function () {
		gml_pragma("forceinline");
		camera_apply(Raw);
		bbmod_camera_set_position(Position.Clone());
		bbmod_camera_set_zfar(ZFar);
		bbmod_camera_set_exposure(Exposure);
		return self;
	};
}