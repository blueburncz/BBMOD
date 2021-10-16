/// @func BBMOD_Renderer()
/// @extends BBMOD_Class
/// @desc Implements a basic renderer which automatically renders all added
/// [renderables](./BBMOD_Renderer.Renderables.html) sorted by
/// [materials](./BBMOD_Material.html), sorted by their
/// [priority](./BBMOD_Material.Priority.html).
/// @example
/// Following code is a typical use of the renderer.
/// ```gml
/// // Create event
/// renderer = new BBMOD_Renderer()
///     .add(OCharacter)
///     .add(OTree)
///     .add(OTerrain)
///     .add(OSky);
/// renderer.UseAppSurface = true;
/// renderer.RenderScale = 2.0;
///
/// camera = new BBMOD_Camera();
/// camera.FollowObject = OPlayer;
///
/// // Step event
/// camera.set_mouselook(true);
/// camera.update(delta_time);
/// renderer.update(delta_time);
///
/// // Draw event
/// camera.apply();
/// renderer.render();
/// 
/// // Post-Draw event
/// renderer.present();
///
/// // Clean Up event
/// renderer.destroy();
/// ```
/// @see BBMOD_IRenderable
/// @see BBMOD_Camera
function BBMOD_Renderer()
	: BBMOD_Class() constructor
{
	/// @var {BBMOD_IRenderable[]} An array of renderable objects and structs.
	/// These are automatically rendered in {@link BBMOD_Renderer.render}.
	/// @readonly
	/// @see BBMOD_Renderer.add
	/// @see BBMOD_Renderer.remove
	/// @see BBMOD_IRenderable
	Renderables = [];

	/// @var {bool} Set to `true` to enable the `application_surface`.
	/// Use method {@link BBMOD_Renderer.present} to draw the
	/// `application_surface` to the screen. Defaults to `false`.
	UseAppSurface = false;

	/// @var {real} Resolution multiplier for the `application_surface`.
	/// {@link BBMOD_Renderer.UseAppSurface} must be enabled for this to
	/// have any effect. Defaults to 1.
	RenderScale = 1.0;

	/// @func add(_renderable)
	/// @desc Adds a renderable object or struct to the renderer.
	/// @param {BBMOD_IRenderable} _renderable The renderable object or struct
	/// to add.
	/// @return {BBMOD_Renderer} Returns `self`.
	/// @see BBMOD_Renderer.remove
	/// @see BBMOD_IRenderable
	static add = function (_renderable) {
		gml_pragma("forceinline");
		array_push(Renderables, _renderable);
		return self;
	};

	/// @func remove(_renderable)
	/// @desc Removes a renderable object or a struct from the renderer.
	/// @param {BBMOD_IRenderable} _renderable The renderable object or struct
	/// to remove.
	/// @return {BBMOD_Renderer} Returns `self`.
	/// @see BBMOD_Renderer.add
	/// @see BBMOD_IRenderable
	static remove = function (_renderable) {
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

	/// @func update(_deltaTime)
	/// @desc Updates the renderer. This should be called in the Step event.
	/// @param {real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	/// @return {BBMOD_Renderer} Returns `self`.
	static update = function (_deltaTime) {
		if (UseAppSurface)
		{
			application_surface_enable(true);
			application_surface_draw_enable(false);

			var _windowWidth = max(window_get_width(), 1);
			var _windowHeight = max(window_get_height(), 1);
			var _surfaceWidth = floor(max(_windowWidth * RenderScale, 1.0));
			var _surfaceHeight = floor(max(_windowHeight * RenderScale, 1.0));

			if (surface_get_width(application_surface) != _surfaceWidth
				|| surface_get_height(application_surface) != _surfaceHeight)
			{
				surface_resize(application_surface, _surfaceWidth, _surfaceHeight);
			}
		}
		return self;
	};

	/// @func render()
	/// @desc Renders all added [renderables](./BBMOD_Renderer.Renderables.html)
	/// to the current render target.
	/// @return {BBMOD_Renderer} Returns `self`.
	static render = function () {
		var _world = matrix_get(matrix_world);

		var i = 0;
		repeat (array_length(Renderables))
		{
			with (Renderables[i++])
			{
				render();
			}
		}

		bbmod_material_reset();

		var _materials = bbmod_get_materials();
		var i = 0;
		repeat (array_length(_materials))
		{
			var _material = _materials[i++];
			if (_material.has_commands())
			{
				_material.apply();
				_material.submit_queue();
			}
		}

		bbmod_material_reset();
		matrix_set(matrix_world, _world);

		return self;
	};

	/// @func present()
	/// @desc Renders the `application_surface` to the screen.
	/// {@link BBMOD_Renderer.UseAppSurface} must be enabled for this to
	/// have any effect.
	/// @return {BBMOD_Renderer} Returns `self`.
	static present = function () {
		if (UseAppSurface)
		{
			gpu_push_state();
			gpu_set_tex_filter(true);
			draw_surface_stretched(application_surface, 0, 0, window_get_width(), window_get_height());
			gpu_pop_state();
		}
		return self;
	};
}