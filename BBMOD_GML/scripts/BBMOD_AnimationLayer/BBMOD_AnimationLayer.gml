/// @module Core

/// @func BBMOD_AnimationLayer(_name)
///
/// @implements {BBMOD_IEventListener}
///
/// @desc
///
/// @param {String} _name The name of the animation layer.
///
/// @see BBMOD_LayeredAnimationPlayer
function BBMOD_AnimationLayer(_name) constructor
{
	BBMOD_IEventListener();

	/// @desc {String} The name of the animation layer.
	Name = _name;

	/// @var {Struct.BBMOD_LayeredAnimationPlayer} The animation player to which this
	/// layer belongs or `undefined` (default).
	/// @readonly
	AnimationPlayer = undefined;

	/// @var {Bool} Whether the layer is enabled. Defaults to `true`.
	Enabled = true;

	/// @var {Real} Whether this animation layer uses additive blending. Defaults
	/// to `false`.
	Additive = false;

	/// @var {Real} The blend weight of this animation layer. Defaults to 1.
	Weight = 1.0;

	/// @var {Struct.BBMOD_SkeletonMask} A mask defining which nodes this
	/// animation layer affects or `undefined` (affects all nodes; default).
	Mask = undefined;

	/// @var {Real} Used to play animation in this layer at a faster/slower rate.
	/// Defaults to 1.
	/// @see BBMOD_AnimationPlayer.PlaybackSpeed
	SpeedMultiplier = 1.0;

	////////////////////////////////////////////////////////////////////////////

	/// @var {Real} The current animation playback time (in seconds).
	/// @readonly
	Time = 0;

	/// @var {Array<Struct.BBMOD_Animation>} List of animations to play.
	/// @private
	__animations = [];

	/// @var {Struct.BBMOD_Animation} The currently playing animation or
	/// `undefined`.
	/// @readonly
	Animation = undefined;

	/// @var {Bool} Whether the current animation is played in a loop.
	/// @readonly
	AnimationLoops = false;

	/// @var {Struct.BBMOD_Animation}
	/// @private
	__animationLast = undefined;

	/// @var {Struct.BBMOD_AnimationInstance}
	/// @private
	__animationInstanceLast = undefined;

	/// @var {Array<Struct.BBMOD_Vec3>} Array of node position overrides.
	/// @private
	__nodePositionOverride = array_create(BBMOD_MAX_BONES, undefined);

	/// @var {Array<Struct.BBMOD_Quaternion>} Array of node rotation
	/// overrides.
	/// @private
	__nodeRotationOverride = array_create(BBMOD_MAX_BONES, undefined);

	/// @var {Array<Real>} An array of node transforms in world space.
	/// Useful for attachments.
	/// @see BBMOD_LayeredAnimationPlayer.get_node_transform
	/// @private
	__nodeTransform = array_create(BBMOD_MAX_BONES * 8, 0.0);

	////////////////////////////////////////////////////////////////////////////

	static __animate = function (_animationInstance, _animationTime, _layerPrev, _isLastLayer)
	{
		var _model = AnimationPlayer.Model;
		var _animation = _animationInstance.Animation;
		var _frame = _animation.__framesParent[_animationTime];
		var _nodeTransform = __nodeTransform;
		var _positionOverrides = __nodePositionOverride;
		var _rotationOverrides = __nodeRotationOverride;

		static _animStack = [];
		if (array_length(_animStack) < _model.NodeCount)
		{
			array_resize(_animStack, _model.NodeCount);
		}

		_animStack[@ 0] = _model.RootNode;
		var _stackNext = 1;

		repeat(_model.NodeCount)
		{
			if (_stackNext == 0)
			{
				break;
			}

			var _node = _animStack[--_stackNext];
			var _nodeIndex = _node.Index;
			var _nodeOffset = _nodeIndex * 8;
			var _nodePositionOverride = _positionOverrides[_nodeIndex];
			var _nodeRotationOverride = _rotationOverrides[_nodeIndex];
			var _nodeParent = _node.Parent;
			var _parentIndex = (_nodeParent != undefined) ? _nodeParent.Index : -1;

			//if (_nodePositionOverride != undefined
			//	|| _nodeRotationOverride != undefined)
			//{
				// Current layer
				var _dq = new BBMOD_DualQuaternion().FromArray(_frame, _nodeOffset);
				var _position = (_nodePositionOverride != undefined)
					? _nodePositionOverride
					: _dq.GetTranslation();
				var _rotation = (_nodeRotationOverride != undefined)
					? _nodeRotationOverride
					: _dq.GetRotation();

				// Blend with previous layer
				if (_layerPrev != undefined)
				{
					var _dqPrev = new BBMOD_DualQuaternion().FromArray(_layerPrev.__nodeTransform, _nodeOffset);
					var _positionPrev = _dqPrev.GetTranslation();
					var _rotationPrev = _dqPrev.GetRotation();
					// TODO: Make masking work also for the first animation layer!!!
					var _weight = Weight * ((Mask != undefined) ? Mask.MaskArray[_nodeIndex] : 1.0);
					_position = _positionPrev.Lerp(_position, _weight);
					_rotation = _rotationPrev.Slerp(_rotation, _weight);
				}

				_dq.FromTranslationRotation(_position, _rotation);

				// Transform with parent bone if this is the last layer
				if (_isLastLayer && _parentIndex != -1)
				{
					_dq.MulSelf(new BBMOD_DualQuaternion()
						.FromArray(_nodeTransform, _parentIndex * 8));
				}

				_dq.ToArray(_nodeTransform, _nodeOffset);
			//}

			var _children = _node.Children;
			var i = 0;
			repeat(array_length(_children))
			{
				_animStack[_stackNext++] = _children[i++];
			}
		}
	};

	/// @func update(_deltaTime, _frameskipCurrent, _layerPrev, _isLastLayer)
	///
	/// @desc Updates the animation layer. This should be called every frame in
	/// the step event.
	///
	/// @param {Real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	/// @param {Real} _frameskipCurrent
	/// @param {Struct.BBMOD_AnimationLayer} _layerPrev
	/// @param {Bool} _isLastLayer
	///
	/// @return {Struct.BBMOD_AnimationLayer} Returns `self`.
	static update = function (_deltaTime, _frameskipCurrent, _layerPrev, _isLastLayer)
	{
		var _model = AnimationPlayer.Model;

		Time += _deltaTime * 0.000001 * AnimationPlayer.PlaybackSpeed * SpeedMultiplier;

		repeat(array_length(__animations))
		{
			var _animInst = __animations[0];
			var _animation = _animInst.Animation;

			if (!_animation.IsLoaded)
			{
				break;
			}

			var _time = _animation.__isTransition ? abs(Time) : Time;
			var _animationTime = _animation.get_animation_time(_time);

			if (_animationTime >= _animation.Duration)
			{
				if (_animInst.Loop)
				{
					Time %= (_animation.Duration / _animation.TicsPerSecond);
					_animationTime %= _animation.Duration;
					_animInst.__eventExecuted = -1;
					trigger_event(BBMOD_EV_ANIMATION_LOOP, _animation);
				}
				else
				{
					Time = 0.0;
					array_delete(__animations, 0, 1);
					if (!_animation.__isTransition)
					{
						Animation = undefined;
						trigger_event(BBMOD_EV_ANIMATION_END, _animation);
					}
					continue;
				}
			}

			_animInst.__animationTime = _animationTime;

			var _nodeSize = _model.NodeCount * 8;
			if (array_length(__nodeTransform) < _nodeSize)
			{
				array_resize(__nodeTransform, _nodeSize);
			}

			var _animEvents = _animation.__events;
			var _eventIndex = 0;
			var _eventExecuted = _animInst.__eventExecuted;

			repeat(array_length(_animEvents) / 2)
			{
				var _eventFrame = _animEvents[_eventIndex];
				if (_eventFrame <= _animationTime && _eventExecuted < _eventFrame)
				{
					trigger_event(_animEvents[_eventIndex + 1], _animation);
				}
				_eventIndex += 2;
			}

			_animInst.__eventExecuted = _animationTime;

			if (_frameskipCurrent == 0)
			{
				if (_animation.__spaces & __BBMOD_BONE_SPACE_PARENT)
				{
					__animate(_animInst, _animationTime, _layerPrev, _isLastLayer);
				}
				else
				{
					bbmod_assert(false, "Only animations with optimization level 0 are supported!");
				}
			}

			__animationInstanceLast = _animInst;
		}

		return self;
	};

	/// @func play(_animation[, _loop])
	///
	/// @desc Starts playing an animation from its start.
	///
	/// @param {Struct.BBMOD_Animation} _animation An animation to play.
	/// @param {Bool} [_loop] If `true` then the animation will be looped.
	/// Defaults to `false`.
	///
	/// @return {Struct.BBMOD_AnimationLayer} Returns `self`.
	static play = function (_animation, _loop = false)
	{
		Animation = _animation;
		AnimationLoops = _loop;

		if (__animationLast != _animation)
		{
			trigger_event(BBMOD_EV_ANIMATION_CHANGE, Animation);
			__animationLast = _animation;
		}

		Time = 0;

		__animations = [];
		var _animationLast = __animationInstanceLast;

		if (AnimationPlayer.EnableTransitions
			&& _animationLast != undefined
			&& _animationLast.Animation.TransitionOut + _animation.TransitionIn > 0)
		{
			var _transition = _animationLast.Animation.create_transition(
				_animationLast.__animationTime,
				_animation,
				0);

			if (_transition != undefined)
			{
				array_push(__animations, new BBMOD_AnimationInstance(_transition));
			}
		}

		var _animationInstance = new BBMOD_AnimationInstance(_animation);
		_animationInstance.Loop = AnimationLoops;
		array_push(__animations, _animationInstance);

		return self;
	};

	/// @func change(_animation[, _loop])
	///
	/// @desc Starts playing an animation from its start, only if it is a
	/// different one that the last played animation.
	///
	/// @param {Struct.BBMOD_Animation} _animation The animation to change to,
	/// @param {Bool} [_loop] If `true` then the animation will be looped.
	/// Defaults to `false`.
	///
	/// @return {Struct.BBMOD_AnimationLayer} Returns `self`.
	///
	/// @see BBMOD_AnimationLayer.Animation
	static change = function (_animation, _loop = false)
	{
		gml_pragma("forceinline");
		if (Animation != _animation)
		{
			play(_animation, _loop);
		}
		return self;
	};

	/// @func set_node_position(_nodeIndex, _position)
	///
	/// @desc Overrides a position of a node.
	///
	/// @param {Real} _nodeIndex An index of a node.
	/// @param {Struct.BBMOD_Vec3} _position A new position of a node. Use
	/// `undefined` to unset the position override.
	///
	/// @return {Struct.BBMOD_AnimationLayer} Returns `self`.
	static set_node_position = function (_nodeIndex, _position)
	{
		gml_pragma("forceinline");
		__nodePositionOverride[@ _nodeIndex] = _position;
		return self;
	};

	/// @func set_node_rotation(_nodeIndex, _rotation)
	///
	/// @desc Overrides a rotation of a node.
	///
	/// @param {Real} _nodeIndex An index of a node.
	/// @param {Struct.BBMOD_Quaternion} _rotation A new rotation of a node.
	/// Use `undefined` to unset the rotation override.
	///
	/// @return {Struct.BBMOD_AnimationLayer} Returns `self`.
	static set_node_rotation = function (_nodeIndex, _rotation)
	{
		gml_pragma("forceinline");
		__nodeRotationOverride[@ _nodeIndex] = _rotation;
		return self;
	};
}
