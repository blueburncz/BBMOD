/// @module Core

/// @func BBMOD_LayeredAnimationPlayer(_model[, _paused])
///
/// @implements {BBMOD_IRenderable}
///
/// @desc An animation player with support for multiple layers, blending and
/// masking. By default there is only a single layer called "Default". Compatible
/// only with animations with optimization level 0 and 1!
///
/// @param {Struct.BBMOD_Model} _model A model that the animation player
/// animates.
/// @param {Bool} [_paused] If `true` then the animation player is created
/// as paused. Defaults to `false`.
///
/// @example
/// Following code shows how to load models and animations in a resource manager
/// object and then play animations in multiple instances of another object.
///
/// ```gml
/// /// @desc Create event of OResourceManager
/// modCharacter = new BBMOD_Model("character.bbmod");
/// animIdle = new BBMOD_Animation("idle.bbanim");
///
/// /// @desc Create event of OCharacter
/// model = OResourceManager.modCharacter;
/// animationPlayer = new BBMOD_LayeredAnimationPlayer(model);
/// animationPlayer.play("Default", OResourceManager.animIdle, true);
///
/// /// @desc Step event of OCharacter
/// animationPlayer.update(delta_time);
///
/// /// @desc Draw event of OCharacter
/// animationPlayer.render();
/// bbmod_material_reset();
/// ```
///
/// @see BBMOD_AnimationPlayer
function BBMOD_LayeredAnimationPlayer(_model, _paused = false) constructor
{
	/// @var {Struct.BBMOD_Model} A model that the animation player animates.
	/// @readonly
	Model = _model;

	/// @var {Array<Struct.BBMOD_AnimationLayer>} An array of animation layers.
	/// By default contains a single layer called "Default".
	/// @readonly
	Layers = [];

	add_layer(new BBMOD_AnimationLayer("Default"));

	/// @var {Bool} If `true`, then the animation playback is paused.
	Paused = _paused;

	/// @var {Real} Number of frames (calls to {@link BBMOD_LayeredAnimationPlayer.update})
	/// to skip. Defaults to 0 (frame skipping is disabled). Increasing the
	/// value increases performance. Use `infinity` to disable computing
	/// animation frames entirely.
	/// @note This does not affect animation events. These are still triggered
	/// even if the frame is skipped.
	Frameskip = 0;

	/// @var {Real}
	/// @private
	__frameskipCurrent = 0;

	/// @var {Real} Controls animation playback speed.
	PlaybackSpeed = 1;

	/// @var {Array<Real>} An array of node transforms in world space.
	/// Useful for attachments.
	/// @see BBMOD_LayeredAnimationPlayer.get_node_transform
	/// @private
	__nodeTransform = array_create(BBMOD_MAX_BONES * 8, 0.0);

	/// @var {Array<Real>} An array containing transforms of all bones.
	/// Used to pass current model pose as a uniform to a vertex shader.
	/// @see BBMOD_LayeredAnimationPlayer.get_transform
	/// @private
	__transformArray = array_create(BBMOD_MAX_BONES * 8, 0.0);

	/// @var {Bool} If `true` then transitions between animations are enabled.
	/// The default value is `true`.
	/// @see BBMOD_Animation.create_transition
	EnableTransitions = true;

	/// @func add_layer(_layer)
	///
	/// @desc Adds an animation layer to this animation player.
	///
	/// @param {Struct.BBMOD_AnimationLayer} _layer The layer to add. Must not
	/// already belong to an animation player!
	///
	/// @return {Struct.BBMOD_LayeredAnimationPlayer} Returns `self`.
	static add_layer = function (_layer)
	{
		gml_pragma("forceinline");

		bbmod_assert(_layer.AnimationPlayer == undefined,
			"Given animation layer already belongs to an animation player!");

		array_push(Layers, _layer);
		_layer.AnimationPlayer = self;

		return self;
	};

	/// @func has_layer(_name)
	///
	/// @desc Checks whether the animation player contains a layer with given
	/// name.
	///
	/// @param {String} _name The name of the animation layer to look for.
	///
	/// @return {Bool} Returns `true` if the animation player has a layer with
	/// given name.
	static has_layer = function (_name)
	{
		gml_pragma("forceinline");
		var _index = 0;
		repeat(array_length(Layers))
		{
			if (Layers[_index++].Name == _name)
			{
				return true;
			}
		}
		return false;
	};

	/// @func get_layer(_name)
	///
	/// @desc Retrieves an animation layer with given name.
	///
	/// @param {String} _name The name of the animation layer to retrieve.
	///
	/// @return {Struct.BBMOD_AnimationLayer} The animation layer with given name
	/// or `undefined` if the animation player does not have one.
	static get_layer = function (_name)
	{
		gml_pragma("forceinline");
		var _index = 0;
		repeat(array_length(Layers))
		{
			var _layer = Layers[_index++];
			if (_layer.Name == _name)
			{
				return _layer;
			}
		}
		return undefined;
	};

	/// @func remove_layer(_nameOrStruct)
	///
	/// @desc Removes an animation layer from the animation player.
	///
	/// @param {String, Struct.BBMOD_AnimationLayer} _nameOrStruct The name of
	/// the animation layer to remove or the layer struct itself.
	///
	/// @return {Struct.BBMOD_AnimationPlayer} Returns `self`.
	static remove_layer = function (_nameOrStruct)
	{
		gml_pragma("forceinline");

		if (is_string(_nameOrStruct))
		{
			var _index = 0;
			repeat(array_length(Layers))
			{
				var _layer = Layers[_index];
				if (_layer.Name == _nameOrStruct)
				{
					array_delete(Layers, _index, 1);
					_layer.AnimationPlayer = undefined;
					break;
				}
				++_index;
			}
		}
		else
		{
			bbmod_assert(_nameOrStruct.AnimationPlayer == self,
				"Given animation layer does not belong to this animation player!");

			var _index = 0;
			repeat(array_length(Layers))
			{
				var _layer = Layers[_index];
				if (_layer == _nameOrStruct)
				{
					array_delete(Layers, _index, 1);
					_layer.AnimationPlayer = undefined;
					break;
				}
				++_index;
			}
		}

		return self;
	};

	/// @func update(_deltaTime)
	///
	/// @desc Updates the animation player. This should be called every frame in
	/// the step event.
	///
	/// @param {Real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	///
	/// @return {Struct.BBMOD_LayeredAnimationPlayer} Returns `self`.
	static update = function (_deltaTime)
	{
		if (!Model.IsLoaded)
		{
			return self;
		}

		if (Paused)
		{
			return self;
		}

		var _layerIndex = 0;
		var _layerIndexLast = array_length(Layers) - 1; // This should be the last one ENABLED!
		var _layerPrev = undefined;
		repeat(array_length(Layers))
		{
			var _layer = Layers[_layerIndex];
			var _isLastLayer = (_layerIndex == _layerIndexLast);
			if (_layer.Enabled)
			{
				_layer.update(_deltaTime, __frameskipCurrent, _layerPrev, _isLastLayer);
				if (_isLastLayer)
				{
					array_copy(__nodeTransform, 0, _layer.__nodeTransform, 0, array_length(_layer.__nodeTransform));
				}
				_layerPrev = _layer;
			}
			++_layerIndex;
		}

		var _boneIndex = 0;
		repeat(Model.BoneCount)
		{
			__bbmod_dquat_mul_array(
				Model.__offsetArray, _boneIndex,
				__nodeTransform, _boneIndex,
				__transformArray, _boneIndex);
			_boneIndex += 8;
		}

		if (Frameskip == infinity)
		{
			__frameskipCurrent = -1;
		}
		else if (++__frameskipCurrent > Frameskip)
		{
			__frameskipCurrent = 0;
		}

		return self;
	};

	/// @func play(_layer, _animation[, _loop])
	///
	/// @desc Starts playing an animation from its start on a layer with given
	/// name.
	///
	/// @param {String} _layer The name of the animation layer.
	/// @param {Struct.BBMOD_Animation} _animation An animation to play.
	/// @param {Bool} [_loop] If `true` then the animation will be looped.
	/// Defaults to `false`.
	///
	/// @return {Struct.BBMOD_LayeredAnimationPlayer} Returns `self`.
	static play = function (_layer, _animation, _loop = false)
	{
		gml_pragma("forceinline");
		var _layerStruct = get_layer(_layer);
		if (_layerStruct != undefined)
		{
			_layerStruct.play(_animation, _loop);
		}
		return self;
	};

	/// @func change(_layer, _animation[, _loop])
	///
	/// @desc Starts playing an animation from its start on a layer with given
	/// name, only if it is a different one that the last played animation on
	/// that layer.
	///
	/// @param {String} _layer The name of the animation layer.
	/// @param {Struct.BBMOD_Animation} _animation The animation to change to,
	/// @param {Bool} [_loop] If `true` then the animation will be looped.
	/// Defaults to `false`.
	///
	/// @return {Struct.BBMOD_LayeredAnimationPlayer} Returns `self`.
	///
	/// @see BBMOD_LayeredAnimationPlayer.Animation
	static change = function (_layer, _animation, _loop = false)
	{
		gml_pragma("forceinline");
		var _layerStruct = get_layer(_layer);
		if (_layerStruct != undefined)
		{
			_layerStruct.change(_animation, _loop);
		}
		return self;
	};

	/// @func get_transform()
	///
	/// @desc Returns an array of current transformations of all bones. This
	/// should be passed to a vertex shader.
	///
	/// @return {Array<Real>} The transformation array.
	static get_transform = function ()
	{
		gml_pragma("forceinline");
		return __transformArray;
	};

	/// @func get_node_transform(_nodeIndex)
	///
	/// @desc Returns a transformation (dual quaternion) of a node, which can be
	/// used for example for attachments.
	///
	/// @param {Real} _nodeIndex An index of a node.
	///
	/// @return {Struct.BBMOD_DualQuaternion} The transformation.
	///
	/// @see BBMOD_Model.find_node_id
	static get_node_transform = function (_nodeIndex)
	{
		gml_pragma("forceinline");
		return new BBMOD_DualQuaternion().FromArray(__nodeTransform, _nodeIndex * 8);
	};

	/// @func submit([_materials])
	///
	/// @desc Immediately submits the animated model for rendering.
	///
	/// @param {Array<Struct.BBMOD_IMaterial>, Array<Pointer.Texture>} [_materials]
	/// An array of either material structs or just textures if you don't wish to
	/// use BBMOD's material system. If `undefined`, then {@link BBMOD_Model.Materials}
	/// is used. Defaults to `undefined`.
	///
	/// @return {Struct.BBMOD_LayeredAnimationPlayer} Returns `self`.
	static submit = function (_materials = undefined)
	{
		gml_pragma("forceinline");
		Model.submit(_materials, get_transform());
		return self;
	};

	/// @func render([_materials])
	///
	/// @desc Enqueues the animated model for rendering.
	///
	/// @param {Array<Struct.BBMOD_Material>} [_materials] An array of materials,
	/// one for each material slot of the model. If not specified, then
	/// {@link BBMOD_Model.Materials} is used. Defaults to `undefined`.
	///
	/// @return {Struct.BBMOD_LayeredAnimationPlayer} Returns `self`.
	static render = function (_materials = undefined)
	{
		gml_pragma("forceinline");
		Model.render(_materials, get_transform());
		return self;
	};
}
