/// @macro {string} An event triggered when an animation player changes to a
/// different animation. The event data will contain the previous animation.
/// You can retrieve the new animation using
/// {@link BBMOD_AnimationPlayer.Animation}.
/// @see BBMOD_AnimationPlayer.on_event
#macro BBMOD_EV_ANIMATION_CHANGE "bbmod_ev_animation_change"

/// @macro {string} An event triggered when an animation finishes playing. The
/// event data will contain the animation that ended.
/// @see BBMOD_AnimationPlayer.on_event
#macro BBMOD_EV_ANIMATION_END "bbmod_ev_animation_end"

/// @macro {string} An event triggered when an animation loops and continues
/// playing from the start. The event data will contain the animation that
/// looped.
/// @see BBMOD_AnimationPlayer.on_event
#macro BBMOD_EV_ANIMATION_LOOP "bbmod_ev_animation_loop"

#macro __BBMOD_EV_ALL "__bbmod_ev_all"

/// @func BBMOD_AnimationPlayer(_model[, _paused])
///
/// @extends BBMOD_Class
///
/// @implements {BBMOD_IEventListener}
/// @implements {BBMOD_IRenderable}
///
/// @desc An animation player. Each instance of an animated model should have
/// its own animation player.
///
/// @param {BBMOD_Model} _model A model that the animation player animates.
/// @param {bool} [_paused] If `true` then the animation player is created
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
/// animationPlayer = new BBMOD_AnimationPlayer(model);
/// animationPlayer.play(OResourceManager.animIdle, true);
///
/// /// @desc Step event of OCharacter
/// animationPlayer.update(delta_time);
///
/// /// @desc Draw event of OCharacter
/// bbmod_material_reset();
/// animationPlayer.render();
/// bbmod_material_reset();
/// ```
///
/// @see BBMOD_Animation
/// @see BBMOD_EventListener
/// @see BBMOD_Model
function BBMOD_AnimationPlayer(_model, _paused=false)
	: BBMOD_Class() constructor
{
	BBMOD_CLASS_GENERATED_BODY;

	implement(BBMOD_IEventListener);

	static Super_Class = {
		destroy: destroy,
	};

	/// @var {BBMOD_Model} A model that the animation player animates.
	/// @readonly
	Model = _model;

	/// @var {ds_list<BBMOD_Animation>} List of animations to play.
	/// @see BBMOD_Animation
	/// @private
	Animations = ds_list_create();

	/// @var {BBMOD_Animation/BBMOD_NONE} The currently playing animation.
	/// @readonly
	Animation = BBMOD_NONE;

	/// @var {bool} If true then {@link BBMOD_AnimationPlayer.Animation} loops.
	/// @readonly
	AnimationLoops = false;

	/// @var {BBMOD_Animation/BBMOD_NONE}
	/// @private
	AnimationLast = BBMOD_NONE;

	/// @var {BBMOD_AnimationInstance}
	/// @private
	AnimationInstanceLast = undefined;

	// FIXME: Fix animation player for models that were not loaded yet!!!

	/// @var {array<BBMOD_Vec3/undefined>} Array of node position overrides.
	/// @private
	NodePositionOverride = array_create(64/*Model.NodeCount*/, undefined);

	/// @var {array<BBMOD_Quaternion/undefined>} Array of node rotation
	/// overrides.
	/// @private
	NodeRotationOverride = array_create(64/*Model.NodeCount*/, undefined);

	/// @var {bool} If `true`, then the animation playback is paused.
	Paused = _paused;

	/// @var {real} The current animation playback time.
	/// @readonly
	Time = 0;

	/// @var {real[]/undefined}
	/// @private
	Frame = undefined;

	/// @var {int} Number of frames (calls to {@link BBMOD_AnimationPlayer.update})
	/// to skip. Defaults to 0 (frame skipping is disabled). Increasing the value
	/// increases performance. Use `infinity` to disable computing animation frames
	/// entirely.
	/// @note This does not affect animation events. These are still triggered
	/// even if the frame is skipped.
	Frameskip = 0;

	/// @var {uint}
	/// @private
	FrameskipCurrent = 0;

	/// @var {real} Controls animation playback speed. Must be a positive number!
	PlaybackSpeed = 1;

	/// @var {real[]} An array of node transforms in world space.
	/// Useful for attachments.
	/// @see BBMOD_AnimationPlayer.get_node_transform
	/// @private
	NodeTransform = array_create(64/*Model.NodeCount*/ * 8, 0.0);

	/// @var {real[]} An array containing transforms of all bones.
	/// Used to pass current model pose as a uniform to a vertex shader.
	/// @see BBMOD_AnimationPlayer.get_transform
	/// @private
	TransformArray = array_create(64/*Model.BoneCount*/ * 8, 0.0);

	static animate = function (_animationInstance, _animationTime) {
		var _model = Model;
		var _animation = _animationInstance.Animation;
		var _frame = _animation.FramesParent[_animationTime];
		Frame = _frame;
		var _transformArray = TransformArray;
		var _offsetArray = _model.OffsetArray;
		var _nodeTransform = NodeTransform;
		var _positionOverrides = NodePositionOverride;
		var _rotationOverrides = NodeRotationOverride;

		static _animStack = [];
		if (array_length(_animStack) < _model.NodeCount)
		{
			array_resize(_animStack, _model.NodeCount);
		}

		_animStack[0] = _model.RootNode;
		var _stackNext = 1;

		repeat (_model.NodeCount)
		{
			if (_stackNext == 0)
			{
				break;
			}

			var _node = _animStack[--_stackNext];

			if (!_node.IsSkeleton)
			{
				continue;
			}

			var _nodeIndex = _node.Index;
			var _nodeOffset = _nodeIndex * 8;
			var _nodePositionOverride = _positionOverrides[_nodeIndex];
			var _nodeRotationOverride = _rotationOverrides[_nodeIndex];
			var _nodeParent = _node.Parent;
			var _parentIndex = (_nodeParent != undefined) ? _nodeParent.Index : -1;

			if (_nodePositionOverride != undefined
				|| _nodeRotationOverride != undefined)
			{
				var _dq = new BBMOD_DualQuaternion().FromArray(_frame, _nodeOffset);
				var _position = (_nodePositionOverride != undefined)
					? _nodePositionOverride
					: _dq.GetTranslation();
				var _rotation = (_nodeRotationOverride != undefined)
					? _nodeRotationOverride
					: _dq.GetRotation();
				_dq.FromTranslationRotation(_position, _rotation);
				if (_parentIndex != -1)
				{
					_dq = _dq.Mul(new BBMOD_DualQuaternion().FromArray(_nodeTransform, _parentIndex * 8));
				}
				_dq.ToArray(_nodeTransform, _nodeOffset);
			}
			else
			{
				if (_parentIndex == -1)
				{
					// No parent transform -> just copy the node transform
					array_copy(_nodeTransform, _nodeOffset, _frame, _nodeOffset, 8);
				}
				else
				{
					// Multiply node transform with parent's transform
					bbmod_dual_quaternion_array_multiply(
						_frame, _nodeOffset, _nodeTransform, _parentIndex * 8, _nodeTransform, _nodeOffset);
				}
			}

			if (_node.IsBone)
			{
				bbmod_dual_quaternion_array_multiply(
					_offsetArray, _nodeOffset,
					_nodeTransform, _nodeOffset,
					_transformArray, _nodeOffset);
			}

			var _children = _node.Children;
			var i = 0;
			repeat (array_length(_children))
			{
				_animStack[_stackNext++] = _children[i++];
			}
		}
	}

	/// @func update(_deltaTime)
	/// @desc Updates the animation player. This should be called every frame in
	/// the step event.
	/// @param {real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	/// @return {BBMOD_AnimationPlayer} Returns `self`.
	static update = function (_deltaTime) {
		if (!Model.IsLoaded)
		{
			return self;
		}

		if (Paused)
		{
			return self;
		}

		Time += _deltaTime * 0.000001 * PlaybackSpeed;

		repeat (ds_list_size(Animations))
		{
			var _animInst = Animations[| 0];
			var _animation = _animInst.Animation;

			if (!_animation.IsLoaded)
			{
				break;
			}

			var _animationTime = _animation.get_animation_time(Time);

			if (_animationTime >= _animation.Duration)
			{
				if (_animInst.Loop)
				{
					Time %= (_animation.Duration / _animation.TicsPerSecond);
					_animationTime %= _animation.Duration;
					_animInst.EventExecuted = -1;
					trigger_event(BBMOD_EV_ANIMATION_LOOP, _animation);
				}
				else
				{
					Time = 0.0;
					ds_list_delete(Animations, 0);
					if (!_animation.IsTransition)
					{
						Animation = BBMOD_NONE;
						trigger_event(BBMOD_EV_ANIMATION_END, _animation);
					}
					continue;
				}
			}

			_animInst.AnimationTime = _animationTime;

			var _nodeSize = Model.NodeCount * 8;
			var _boneSize = Model.BoneCount * 8;

			if (array_length(NodeTransform) < _nodeSize
				|| array_length(TransformArray) != _boneSize)
			{
				array_resize(NodeTransform, _nodeSize);
				array_resize(TransformArray, _boneSize);
			}

			var _animEvents = _animation.Events;
			var _eventIndex = 0;
			var _eventExecuted = _animInst.EventExecuted;

			repeat (array_length(_animEvents) / 2)
			{
				var _eventFrame = _animEvents[_eventIndex];
				if (_eventFrame <= _animationTime && _eventExecuted < _eventFrame)
				{
					trigger_event(_animEvents[_eventIndex + 1], _animation);
				}
				_eventIndex += 2;
			}

			_animInst.EventExecuted = _animationTime;

			//static _iters = 0;
			//static _sum = 0;
			//var _t = get_timer();

			if (FrameskipCurrent == 0)
			{
				if (_animation.Spaces & BBMOD_BONE_SPACE_PARENT)
				{
					animate(_animInst, _animationTime);
				}
				else if (_animation.Spaces & BBMOD_BONE_SPACE_WORLD)
				{
					var _frame = _animation.FramesWorld[_animationTime];
					var _transformArray = TransformArray;
					var _offsetArray = Model.OffsetArray;

					array_copy(NodeTransform, 0, _frame, 0, _nodeSize);
					array_copy(_transformArray, 0, _frame, 0, _boneSize);

					var _index = 0;
					repeat (Model.BoneCount)
					{
						bbmod_dual_quaternion_array_multiply(
							_offsetArray, _index,
							_frame, _index,
							_transformArray, _index);
						_index += 8;
					}
				}
				else if (_animation.Spaces & BBMOD_BONE_SPACE_BONE)
				{
					array_copy(TransformArray, 0, _animation.FramesBone[_animationTime], 0, _boneSize);
					// TODO: Just use the animation's array right away?
				}
			}

			if (Frameskip == infinity)
			{
				FrameskipCurrent = -1;
			}
			else if (++FrameskipCurrent > Frameskip)
			{
				FrameskipCurrent = 0;
			}

			//var _current = get_timer() - _t;
			//_sum += _current;
			//++_iters;
			//show_debug_message("Current: " + string(_current) + "μs");
			//show_debug_message("Average: " + string(_sum / _iters) + "μs");

			AnimationInstanceLast = _animInst;
		}

		return self;
	};

	/// @func play(_animation[, _loop])
	/// @desc Starts playing an animation from its start.
	/// @param {BBMOD_Animation} _animation An animation to play.
	/// @param {bool} [_loop] If `true` then the animation will be looped.
	/// Defaults to `false`.
	/// @return {BBMOD_AnimationPlayer} Returns `self`.
	static play = function (_animation, _loop=false) {
		Animation = _animation;
		AnimationLoops = _loop;

		if (AnimationLast != _animation)
		{
			trigger_event(BBMOD_EV_ANIMATION_CHANGE, Animation);
			AnimationLast = _animation;
		}

		Time = 0;

		var _animationList = Animations;
		var _animationLast = AnimationInstanceLast;

		ds_list_clear(_animationList);

		if (_animationLast != undefined
			&& _animationLast.Animation.TransitionOut + _animation.TransitionIn > 0)
		{
			var _transition = _animationLast.Animation.create_transition(
				_animationLast.AnimationTime,
				_animation,
				0);

			if (_transition != undefined)
			{
				ds_list_add(_animationList, new BBMOD_AnimationInstance(_transition));
			}
		}

		var _animationInstance = new BBMOD_AnimationInstance(_animation);
		_animationInstance.Loop = AnimationLoops;
		ds_list_add(_animationList, _animationInstance);

		return self;
	};

	/// @func change(_animation[, _loop])
	/// @desc Starts playing an animation from its start, only if it is a
	/// different one that the last played animation.
	/// @param {BBMOD_Animation} _animation The animation to change to,
	/// @param {bool} [_loop] If `true` then the animation will be looped.
	/// Defaults to `false`.
	/// @return {BBMOD_AnimationPlayer} Returns `self`.
	/// @see BBMOD_AnimationPlayer.Animation
	static change = function (_animation, _loop=false) {
		gml_pragma("forceinline");
		if (Animation != _animation)
		{
			play(_animation, _loop);
		}
		return self;
	};

	/// @func get_transform()
	/// @desc Returns an array of current transformations of all bones. This
	/// should be passed to a vertex shader.
	/// @return {real[]} The transformation array.
	static get_transform = function () {
		gml_pragma("forceinline");
		return TransformArray;
	};

	/// @func get_node_transform(_nodeIndex)
	/// @desc Returns a transformation (dual quaternion) of a node, which can be
	/// used for example for attachments.
	/// @param {uint} _nodeIndex An index of a node.
	/// @return {BBMOD_DualQuaternion} The transformation.
	/// @see BBMOD_Model.find_node_id
	static get_node_transform = function (_nodeIndex) {
		gml_pragma("forceinline");
		return new BBMOD_DualQuaternion().FromArray(NodeTransform, _nodeIndex * 8);
	};

	/// @func get_node_transform_from_frame(_nodeIndex)
	/// @desc Returns a transformation (dual quaternion) of a node from the last
	/// animation frame. This is useful if you want to add additional
	/// transformations onto an animated bone, instead of competely replacing it.
	/// @param {uint} _nodeIndex An index of a node.
	/// @return {BBMOD_DualQuaternion} The transformation.
	/// @see BBMOD_Model.find_node_id
	/// @see BBMOD_AnimationPlayer.get_node_transform
	static get_node_transform_from_frame = function (_nodeIndex) {
		gml_pragma("forceinline");
		if (Frame == undefined)
		{
			return new BBMOD_DualQuaternion();
		}
		return new BBMOD_DualQuaternion().FromArray(Frame, _nodeIndex * 8);
	};

	/// @func set_node_position(_nodeIndex, _position)
	/// @desc Overrides a position of a node.
	/// @param {uint} _nodeIndex An index of a node.
	/// @param {BBMOD_Vec3/undefined} _position A new position of a node. Use
	/// `undefined` to unset the position override.
	/// @return {BBMOD_AnimationPlayer} Returns `self`.
	static set_node_position = function (_nodeIndex, _position) {
		gml_pragma("forceinline");
		NodePositionOverride[@ _nodeIndex] = _position;
		return self;
	};

	/// @func set_node_rotation(_nodeIndex, _rotation)
	/// @desc Overrides a rotation of a node.
	/// @param {uint} _nodeIndex An index of a node.
	/// @param {BBMOD_Quaternion/undefined} _rotation A new rotation of a node.
	/// Use `undefined` to unset the rotation override.
	/// @return {BBMOD_AnimationPlayer} Returns `self`.
	static set_node_rotation = function (_nodeIndex, _rotation) {
		gml_pragma("forceinline");
		NodeRotationOverride[@ _nodeIndex] = _rotation;
		return self;
	};

	/// @func submit([_materials])
	/// @desc Immediately submits the animated model for rendering.
	/// @param {BBMOD_Material[]/undefined} [_materials] An array of materials,
	/// one for each material slot of the model. If not specified, then
	/// {@link BBMOD_Model.Materials} is used. Defaults to `undefined`.
	/// @return {BBMOD_AnimationPlayer} Returns `self`.
	static submit = function (_materials=undefined) {
		gml_pragma("forceinline");
		Model.submit(_materials, get_transform());
		return self;
	};

	/// @func render([_materials])
	/// @desc Enqueues the animated model for rendering.
	/// @param {BBMOD_Material[]/undefined} [_materials] An array of materials,
	/// one for each material slot of the model. If not specified, then
	/// {@link BBMOD_Model.Materials} is used. Defaults to `undefined`.
	/// @return {BBMOD_AnimationPlayer} Returns `self`.
	static render = function (_materials=undefined) {
		gml_pragma("forceinline");
		Model.render(_materials, get_transform());
		return self;
	};

	static destroy = function () {
		method(self, Super_Class.destroy)();
		ds_list_destroy(Animations);
	};
}