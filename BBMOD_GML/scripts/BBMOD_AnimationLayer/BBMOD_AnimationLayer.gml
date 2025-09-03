/// @module LayeredAnimationPlayer

/// @func BBMOD_AnimationLayer(_name)
///
/// @implements {BBMOD_IEventListener}
///
/// @desc A single layer of a layered animation player. Each layer plays its own
/// animation and can affect a selected portion of the skeleton. Individual
/// layers can be mixed or additively blended together.
///
/// @param {String} _name The name of the animation layer.
///
/// @see BBMOD_LayeredAnimationPlayer
function BBMOD_AnimationLayer(_name) constructor
{
	BBMOD_IEventListener();

	/// @desc {String} The name of the animation layer.
	Name = _name;

	/// @var {Struct.BBMOD_LayeredAnimationPlayer} The animation player to which
	/// this layer belongs or `undefined` (default).
	/// @readonly
	AnimationPlayer = undefined;

	/// @var {Bool} Whether the layer is enabled. Defaults to `true`.
	Enabled = true;

	/// @var {Real} Whether this animation layer is additively blended on top of
	/// the layer that comes before it. Defaults to `false`.
	Additive = false;

	/// @var {Real} The blend weight of this animation layer. Use values in
	/// range 0..1, where 0 means the layer has no effect and 1 (default) means
	/// the layer has full effect.
	Weight = 1.0;

	/// @var {Struct.BBMOD_SkeletonMask} A mask defining which nodes this
	/// animation layer affects or `undefined` (affects all nodes; default).
	Mask = undefined;

	/// @var {Real} Used to play animation in this layer at a faster/slower rate.
	/// Defaults to 1.
	/// @see BBMOD_LayeredAnimationPlayer.PlaybackSpeed
	PlaybackSpeed = 1.0;

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

	////////////////////////////////////////////////////////////////////////////

	static __animate = function (_animationInstance, _animationTime, _layerPrev, _isLastLayer)
	{
		var _model = AnimationPlayer.Model;
		var _animation = _animationInstance ? _animationInstance.Animation : undefined;
		var _frame = _animation ? _animation.__framesParent[_animationTime] : undefined;
		var _animationPlayerNodeTransform = AnimationPlayer.__nodeTransform;
		var _positionOverrides = __nodePositionOverride;
		var _rotationOverrides = __nodeRotationOverride;
		var _nodes = _model.get_node_array();

		var _index = 0;
		repeat(_model.NodeCount)
		{
			var _node = _nodes[_index++];
			var _nodeIndex = _node.Index;
			var _nodeOffset = _nodeIndex * 8;
			var _nodePositionOverride = _positionOverrides[_nodeIndex];
			var _nodeRotationOverride = _rotationOverrides[_nodeIndex];
			var _nodeParent = _node.Parent;
			var _parentIndex = (_nodeParent != undefined) ? _nodeParent.Index : -1;

			// Current layer

			//var _dqBase = _node.Transform;
			var _nodeTransform = _node.Transform;
			var _nodeTransformReal = _nodeTransform.Real;
			var _nodeTransformDual = _nodeTransform.Dual;
			var _dqBaseRealX = _nodeTransformReal.X;
			var _dqBaseRealY = _nodeTransformReal.Y;
			var _dqBaseRealZ = _nodeTransformReal.Z;
			var _dqBaseRealW = _nodeTransformReal.W;
			var _dqBaseDualX = _nodeTransformDual.X;
			var _dqBaseDualY = _nodeTransformDual.Y;
			var _dqBaseDualZ = _nodeTransformDual.Z;
			var _dqBaseDualW = _nodeTransformDual.W;

			//var _dq = (_frame != undefined) ? new BBMOD_DualQuaternion().FromArray(_frame, _nodeOffset) : _dqBase.Clone

			var _dqRealX, _dqRealY, _dqRealZ, _dqRealW,
				_dqDualX, _dqDualY, _dqDualZ, _dqDualW;

			if (_frame != undefined)
			{
				_dqRealX = _frame[_nodeOffset + 0];
				_dqRealY = _frame[_nodeOffset + 1];
				_dqRealZ = _frame[_nodeOffset + 2];
				_dqRealW = _frame[_nodeOffset + 3];
				_dqDualX = _frame[_nodeOffset + 4];
				_dqDualY = _frame[_nodeOffset + 5];
				_dqDualZ = _frame[_nodeOffset + 6];
				_dqDualW = _frame[_nodeOffset + 7];
			}
			else
			{
				_dqRealX = _dqBaseRealX;
				_dqRealY = _dqBaseRealY;
				_dqRealZ = _dqBaseRealZ;
				_dqRealW = _dqBaseRealW;
				_dqDualX = _dqBaseDualX;
				_dqDualY = _dqBaseDualY;
				_dqDualZ = _dqBaseDualZ;
				_dqDualW = _dqBaseDualW;
			}

			//var _position = (_nodePositionOverride != undefined)
			//	? _nodePositionOverride
			//	: _dq.GetTranslation();
			//var _rotation = (_nodeRotationOverride != undefined)
			//	? _nodeRotationOverride
			//	: _dq.GetRotation();

			var _positionX, _positionY, _positionZ;
			var _rotationX, _rotationY, _rotationZ, _rotationW;

			if (_nodePositionOverride != undefined)
			{
				_positionX = _nodePositionOverride.X;
				_positionY = _nodePositionOverride.Y;
				_positionZ = _nodePositionOverride.Z;
			}
			else
			{
				// Dual.Scale(2.0)
				var _q10 = _dqDualX * 2.0;
				var _q11 = _dqDualY * 2.0;
				var _q12 = _dqDualZ * 2.0;
				var _q13 = _dqDualW * 2.0;

				// Real.Conjugate()
				var _q20 = -_dqRealX;
				var _q21 = -_dqRealY;
				var _q22 = -_dqRealZ;
				var _q23 = _dqRealW;

				//return Dual.Scale(2.0).Mul(Real.Conjugate());
				_positionX = _q13 * _q20 + _q10 * _q23 + _q11 * _q22 - _q12 * _q21;
				_positionY = _q13 * _q21 + _q11 * _q23 + _q12 * _q20 - _q10 * _q22;
				_positionZ = _q13 * _q22 + _q12 * _q23 + _q10 * _q21 - _q11 * _q20;
			}

			if (_nodeRotationOverride != undefined)
			{
				_rotationX = _nodeRotationOverride.X;
				_rotationY = _nodeRotationOverride.Y;
				_rotationZ = _nodeRotationOverride.Z;
				_rotationW = _nodeRotationOverride.W;
			}
			else
			{
				_rotationX = _dqRealX;
				_rotationY = _dqRealY;
				_rotationZ = _dqRealZ;
				_rotationW = _dqRealW;
			}

			// Blend with previous layer

			//var _dqPrev = (_layerPrev != undefined)
			//	? new BBMOD_DualQuaternion().FromArray(AnimationPlayer.__nodeTransform, _nodeOffset)
			//	: _dqBase;

			var _dqPrevRealX, _dqPrevRealY, _dqPrevRealZ, _dqPrevRealW,
				_dqPrevDualX, _dqPrevDualY, _dqPrevDualZ, _dqPrevDualW;

			if (_layerPrev != undefined)
			{
				_dqPrevRealX = _animationPlayerNodeTransform[_nodeOffset + 0];
				_dqPrevRealY = _animationPlayerNodeTransform[_nodeOffset + 1];
				_dqPrevRealZ = _animationPlayerNodeTransform[_nodeOffset + 2];
				_dqPrevRealW = _animationPlayerNodeTransform[_nodeOffset + 3];
				_dqPrevDualX = _animationPlayerNodeTransform[_nodeOffset + 4];
				_dqPrevDualY = _animationPlayerNodeTransform[_nodeOffset + 5];
				_dqPrevDualZ = _animationPlayerNodeTransform[_nodeOffset + 6];
				_dqPrevDualW = _animationPlayerNodeTransform[_nodeOffset + 7];
			}
			else
			{
				_dqPrevRealX = _dqBaseRealX;
				_dqPrevRealY = _dqBaseRealY;
				_dqPrevRealZ = _dqBaseRealZ;
				_dqPrevRealW = _dqBaseRealW;
				_dqPrevDualX = _dqBaseDualX;
				_dqPrevDualY = _dqBaseDualY;
				_dqPrevDualZ = _dqBaseDualZ;
				_dqPrevDualW = _dqBaseDualW;
			}

			var _weight = Weight * ((Mask != undefined) ? Mask.MaskArray[_nodeIndex] : 1.0);

			//var _positionPrev = _dqPrev.GetTranslation();
			//var _rotationPrev = _dqPrev.GetRotation();

			var _positionPrevX, _positionPrevY, _positionPrevZ;

			{
				// Dual.Scale(2.0)
				var _q10 = _dqPrevDualX * 2.0;
				var _q11 = _dqPrevDualY * 2.0;
				var _q12 = _dqPrevDualZ * 2.0;
				var _q13 = _dqPrevDualW * 2.0;

				// Real.Conjugate()
				var _q20 = -_dqPrevRealX;
				var _q21 = -_dqPrevRealY;
				var _q22 = -_dqPrevRealZ;
				var _q23 = _dqPrevRealW;

				//return Dual.Scale(2.0).Mul(Real.Conjugate());
				_positionPrevX = _q13 * _q20 + _q10 * _q23 + _q11 * _q22 - _q12 * _q21;
				_positionPrevY = _q13 * _q21 + _q11 * _q23 + _q12 * _q20 - _q10 * _q22;
				_positionPrevZ = _q13 * _q22 + _q12 * _q23 + _q10 * _q21 - _q11 * _q20;
			}

			var _rotationPrevX = _dqPrevRealX;
			var _rotationPrevY = _dqPrevRealY;
			var _rotationPrevZ = _dqPrevRealZ;
			var _rotationPrevW = _dqPrevRealW;

			if (Additive)
			{
				//var _positionBase = _dqBase.GetTranslation();
				//var _rotationBase = _dqBase.GetRotation();

				var _positionBaseX, _positionBaseY, _positionBaseZ;

				{
					// Dual.Scale(2.0)
					var _q10 = _dqBaseDualX * 2.0;
					var _q11 = _dqBaseDualY * 2.0;
					var _q12 = _dqBaseDualZ * 2.0;
					var _q13 = _dqBaseDualW * 2.0;

					// Real.Conjugate()
					var _q20 = -_dqBaseRealX;
					var _q21 = -_dqBaseRealY;
					var _q22 = -_dqBaseRealZ;
					var _q23 = _dqBaseRealW;

					//return Dual.Scale(2.0).Mul(Real.Conjugate());
					_positionBaseX = _q13 * _q20 + _q10 * _q23 + _q11 * _q22 - _q12 * _q21;
					_positionBaseY = _q13 * _q21 + _q11 * _q23 + _q12 * _q20 - _q10 * _q22;
					_positionBaseZ = _q13 * _q22 + _q12 * _q23 + _q10 * _q21 - _q11 * _q20;
				}

				var _rotationBaseX = _dqBaseRealX;
				var _rotationBaseY = _dqBaseRealY;
				var _rotationBaseZ = _dqBaseRealZ;
				var _rotationBaseW = _dqBaseRealW;

				//var _positionDelta = _position.Sub(_positionBase);

				var _positionDeltaX = _positionX - _positionBaseX;
				var _positionDeltaY = _positionY - _positionBaseY;
				var _positionDeltaZ = _positionZ - _positionBaseZ;

				//var _rotationDelta = _rotation.Mul(_rotationBase.Conjugate());

				var _rotationDeltaX = _rotationW * (-_rotationBaseX) + _rotationX * _rotationBaseW + _rotationY * (-_rotationBaseZ) - _rotationZ * (-_rotationBaseY);
				var _rotationDeltaY = _rotationW * (-_rotationBaseY) + _rotationY * _rotationBaseW + _rotationZ * (-_rotationBaseX) - _rotationX * (-_rotationBaseZ);
				var _rotationDeltaZ = _rotationW * (-_rotationBaseZ) + _rotationZ * _rotationBaseW + _rotationX * (-_rotationBaseY) - _rotationY * (-_rotationBaseX);
				var _rotationDeltaW = _rotationW * _rotationBaseW - _rotationX * (-_rotationBaseX) - _rotationY * (-_rotationBaseY) - _rotationZ * (-_rotationBaseZ);

				//_position = _positionPrev.Add(_positionDelta.Scale(_weight));

				_positionX = _positionPrevX + _positionDeltaX * _weight;
				_positionY = _positionPrevY + _positionDeltaY * _weight;
				_positionZ = _positionPrevZ + _positionDeltaZ * _weight;

				//var _rotScaled = new BBMOD_Quaternion().Slerp(_rotationDelta, _weight);

				var _rotScaledX, _rotScaledY, _rotScaledZ, _rotScaledW;

				{
					var _q10 = 0.0;
					var _q11 = 0.0;
					var _q12 = 0.0;
					var _q13 = 1.0;

					var _q20 = _rotationDeltaX;
					var _q21 = _rotationDeltaY;
					var _q22 = _rotationDeltaZ;
					var _q23 = _rotationDeltaW;

					var _norm;

					_norm = 1.0 / sqrt(_q10 * _q10
						+ _q11 * _q11
						+ _q12 * _q12
						+ _q13 * _q13);

					_q10 *= _norm;
					_q11 *= _norm;
					_q12 *= _norm;
					_q13 *= _norm;

					_norm = sqrt(_q20 * _q20
						+ _q21 * _q21
						+ _q22 * _q22
						+ _q23 * _q23);

					_q20 *= _norm;
					_q21 *= _norm;
					_q22 *= _norm;
					_q23 *= _norm;

					var _dot = _q10 * _q20
						+ _q11 * _q21
						+ _q12 * _q22
						+ _q13 * _q23;

					if (_dot < 0.0)
					{
						_dot = -_dot;
						_q20 *= -1.0;
						_q21 *= -1.0;
						_q22 *= -1.0;
						_q23 *= -1.0;
					}

					if (_dot > 0.9995)
					{
						_rotScaledX = lerp(_q10, _q20, _weight);
						_rotScaledY = lerp(_q11, _q21, _weight);
						_rotScaledZ = lerp(_q12, _q22, _weight);
						_rotScaledW = lerp(_q13, _q23, _weight);
					}
					else
					{
						var _theta0 = arccos(_dot);
						var _theta = _theta0 * _weight;
						var _sinTheta = sin(_theta);
						var _sinTheta0 = sin(_theta0);
						var _s2 = _sinTheta / _sinTheta0;
						var _s1 = cos(_theta) - (_dot * _s2);

						_rotScaledX = (_q10 * _s1) + (_q20 * _s2);
						_rotScaledY = (_q11 * _s1) + (_q21 * _s2);
						_rotScaledZ = (_q12 * _s1) + (_q22 * _s2);
						_rotScaledW = (_q13 * _s1) + (_q23 * _s2);
					}
				}

				//_rotation = _rotScaled.Mul(_rotationPrev).Normalize();

				_rotationX = _rotScaledW * _rotationPrevX + _rotScaledX * _rotationPrevW + _rotScaledY * _rotationPrevZ - _rotScaledZ * _rotationPrevY;
				_rotationY = _rotScaledW * _rotationPrevY + _rotScaledY * _rotationPrevW + _rotScaledZ * _rotationPrevX - _rotScaledX * _rotationPrevZ;
				_rotationZ = _rotScaledW * _rotationPrevZ + _rotScaledZ * _rotationPrevW + _rotScaledX * _rotationPrevY - _rotScaledY * _rotationPrevX;
				_rotationW = _rotScaledW * _rotationPrevW - _rotScaledX * _rotationPrevX - _rotScaledY * _rotationPrevY - _rotScaledZ * _rotationPrevZ;

				{
					var _lengthSqr = (
						_rotationX * _rotationX
						+ _rotationY * _rotationY
						+ _rotationZ * _rotationZ
						+ _rotationW * _rotationW
					);
	
					if (_lengthSqr > math_get_epsilon())
					{
						var _n = 1.0 / sqrt(_lengthSqr);
						_rotationX *= _n;
						_rotationY *= _n;
						_rotationZ *= _n;
						_rotationW *= _n;
					}
				}
			}
			else
			{
				//_position = _positionPrev.Lerp(_position, _weight);

				_positionX = lerp(_positionPrevX, _positionX, _weight);
				_positionY = lerp(_positionPrevY, _positionY, _weight);
				_positionZ = lerp(_positionPrevZ, _positionZ, _weight);

				//_rotation = _rotationPrev.Slerp(_rotation, _weight);

				{
					var _q10 = _rotationPrevX;
					var _q11 = _rotationPrevY;
					var _q12 = _rotationPrevZ;
					var _q13 = _rotationPrevW;

					var _q20 = _rotationX;
					var _q21 = _rotationY;
					var _q22 = _rotationZ;
					var _q23 = _rotationW;

					var _norm;

					_norm = 1.0 / sqrt(_q10 * _q10
						+ _q11 * _q11
						+ _q12 * _q12
						+ _q13 * _q13);

					_q10 *= _norm;
					_q11 *= _norm;
					_q12 *= _norm;
					_q13 *= _norm;

					_norm = sqrt(_q20 * _q20
						+ _q21 * _q21
						+ _q22 * _q22
						+ _q23 * _q23);

					_q20 *= _norm;
					_q21 *= _norm;
					_q22 *= _norm;
					_q23 *= _norm;

					var _dot = _q10 * _q20
						+ _q11 * _q21
						+ _q12 * _q22
						+ _q13 * _q23;

					if (_dot < 0.0)
					{
						_dot = -_dot;
						_q20 *= -1.0;
						_q21 *= -1.0;
						_q22 *= -1.0;
						_q23 *= -1.0;
					}

					if (_dot > 0.9995)
					{
						_rotationX = lerp(_q10, _q20, _weight);
						_rotationY = lerp(_q11, _q21, _weight);
						_rotationZ = lerp(_q12, _q22, _weight);
						_rotationW = lerp(_q13, _q23, _weight);
					}
					else
					{
						var _theta0 = arccos(_dot);
						var _theta = _theta0 * _weight;
						var _sinTheta = sin(_theta);
						var _sinTheta0 = sin(_theta0);
						var _s2 = _sinTheta / _sinTheta0;
						var _s1 = cos(_theta) - (_dot * _s2);

						_rotationX = (_q10 * _s1) + (_q20 * _s2);
						_rotationY = (_q11 * _s1) + (_q21 * _s2);
						_rotationZ = (_q12 * _s1) + (_q22 * _s2);
						_rotationW = (_q13 * _s1) + (_q23 * _s2);
					}
				}
			}

			//_dq.FromTranslationRotation(_position, _rotation);

			{
				//Real = _r.Normalize(); // Already normalized!

				//Dual = new BBMOD_Quaternion(_t.X, _t.Y, _t.Z, 0).Mul(Real).Scale(0.5);
				_dqRealX = _rotationX;
				_dqRealY = _rotationY;
				_dqRealZ = _rotationZ;
				_dqRealW = _rotationW;

				var _tX = _positionX;
				var _tY = _positionY;
				var _tZ = _positionZ;
				// var _tW = 0;

				_dqDualX = (_tY * _dqRealZ - _tZ * _dqRealY
					/*+ _tW * _realX*/
					+ _tX * _dqRealW) * 0.5;
				_dqDualY = (_tZ * _dqRealX - _tX * _dqRealZ
					/*+ _tW * _realY*/
					+ _tY * _dqRealW) * 0.5;
				_dqDualZ = (_tX * _dqRealY - _tY * _dqRealX
					/*+ _tW * _realZ*/
					+ _tZ * _dqRealW) * 0.5;
				_dqDualW = ( /*_tW * _realW*/ -_tX * _dqRealX
					- _tY * _dqRealY - _tZ * _dqRealZ) * 0.5;
			}

			// Transform with parent bone if this is the last layer
			if (_isLastLayer && _parentIndex != -1)
			{
				//_dq.MulSelf(new BBMOD_DualQuaternion()
				//	.FromArray(_animationPlayerNodeTransform, _parentIndex * 8));

				var _dq1r0 = _dqRealX;
				var _dq1r1 = _dqRealY;
				var _dq1r2 = _dqRealZ;
				var _dq1r3 = _dqRealW;
				var _dq1d0 = _dqDualX;
				var _dq1d1 = _dqDualY;
				var _dq1d2 = _dqDualZ;
				var _dq1d3 = _dqDualW;

				var _parentOffset = _parentIndex * 8;

				var _dq2r0 = _animationPlayerNodeTransform[_parentOffset + 0];
				var _dq2r1 = _animationPlayerNodeTransform[_parentOffset + 1];
				var _dq2r2 = _animationPlayerNodeTransform[_parentOffset + 2];
				var _dq2r3 = _animationPlayerNodeTransform[_parentOffset + 3];
				var _dq2d0 = _animationPlayerNodeTransform[_parentOffset + 4];
				var _dq2d1 = _animationPlayerNodeTransform[_parentOffset + 5];
				var _dq2d2 = _animationPlayerNodeTransform[_parentOffset + 6];
				var _dq2d3 = _animationPlayerNodeTransform[_parentOffset + 7];

				_dqRealX = (_dq2r3 * _dq1r0 + _dq2r0 * _dq1r3 + _dq2r1 * _dq1r2 - _dq2r2 * _dq1r1);
				_dqRealY = (_dq2r3 * _dq1r1 + _dq2r1 * _dq1r3 + _dq2r2 * _dq1r0 - _dq2r0 * _dq1r2);
				_dqRealZ = (_dq2r3 * _dq1r2 + _dq2r2 * _dq1r3 + _dq2r0 * _dq1r1 - _dq2r1 * _dq1r0);
				_dqRealW = (_dq2r3 * _dq1r3 - _dq2r0 * _dq1r0 - _dq2r1 * _dq1r1 - _dq2r2 * _dq1r2);

				_dqDualX = (_dq2d3 * _dq1r0 + _dq2d0 * _dq1r3 + _dq2d1 * _dq1r2 - _dq2d2 * _dq1r1)
					+ (_dq2r3 * _dq1d0 + _dq2r0 * _dq1d3 + _dq2r1 * _dq1d2 - _dq2r2 * _dq1d1);
				_dqDualY = (_dq2d3 * _dq1r1 + _dq2d1 * _dq1r3 + _dq2d2 * _dq1r0 - _dq2d0 * _dq1r2)
					+ (_dq2r3 * _dq1d1 + _dq2r1 * _dq1d3 + _dq2r2 * _dq1d0 - _dq2r0 * _dq1d2);
				_dqDualZ = (_dq2d3 * _dq1r2 + _dq2d2 * _dq1r3 + _dq2d0 * _dq1r1 - _dq2d1 * _dq1r0)
					+ (_dq2r3 * _dq1d2 + _dq2r2 * _dq1d3 + _dq2r0 * _dq1d1 - _dq2r1 * _dq1d0);
				_dqDualW = (_dq2d3 * _dq1r3 - _dq2d0 * _dq1r0 - _dq2d1 * _dq1r1 - _dq2d2 * _dq1r2)
					+ (_dq2r3 * _dq1d3 - _dq2r0 * _dq1d0 - _dq2r1 * _dq1d1 - _dq2r2 * _dq1d2);
			}

			//_dq.ToArray(_animationPlayerNodeTransform, _nodeOffset);

			_animationPlayerNodeTransform[@ _nodeOffset + 0] = _dqRealX;
			_animationPlayerNodeTransform[@ _nodeOffset + 1] = _dqRealY;
			_animationPlayerNodeTransform[@ _nodeOffset + 2] = _dqRealZ;
			_animationPlayerNodeTransform[@ _nodeOffset + 3] = _dqRealW;
			_animationPlayerNodeTransform[@ _nodeOffset + 4] = _dqDualX;
			_animationPlayerNodeTransform[@ _nodeOffset + 5] = _dqDualY;
			_animationPlayerNodeTransform[@ _nodeOffset + 6] = _dqDualZ;
			_animationPlayerNodeTransform[@ _nodeOffset + 7] = _dqDualW;
		}
	};

	/// @func update(_deltaTime, _frameskipCurrent, _layerPrev, _isLastLayer)
	///
	/// @desc Updates the animation layer. This is called automatically by the
	/// animation player that the layer belongs to!
	///
	/// @param {Real} _deltaTime How much time has passed since the last frame
	/// (in microseconds).
	/// @param {Real} _frameskipCurrent The current frameskip value. Animation
	/// is actually updated only when frameskip equals 0.
	/// @param {Struct.BBMOD_AnimationLayer} _layerPrev The previous layer or
	/// `undefined`.
	/// @param {Bool} _isLastLayer Whether this layer is the last enabled layer
	/// inside of the animation player.
	///
	/// @return {Struct.BBMOD_AnimationLayer} Returns `self`.
	static update = function (_deltaTime, _frameskipCurrent, _layerPrev, _isLastLayer)
	{
		var _model = AnimationPlayer.Model;

		var _animationCount = array_length(__animations);
		if (_animationCount == 0)
		{
			if (_frameskipCurrent == 0)
			{
				__animate(undefined, Time, _layerPrev, _isLastLayer);
			}
			return self;
		}

		var _animation = __animations[0].Animation;
		Time += _deltaTime * 0.000001 * AnimationPlayer.PlaybackSpeed * PlaybackSpeed * _animation.PlaybackSpeed;

		repeat(_animationCount)
		{
			var _animInst = __animations[0];
			_animation = _animInst.Animation;

			if (!_animation.IsLoaded)
			{
				break;
			}

			var _time = _animation.__isTransition ? abs(Time) : Time;
			var _animationTime = _animation.get_animation_time(_time);
			var _animationDuration = _animation.Duration;
			var _animationTimeWrapped = bbmod_wrap_value(_animationTime, _animationDuration);

			if (_animationTime < 0 || _animationTime >= _animationDuration)
			{
				if (_animInst.Loop)
				{
					Time = bbmod_wrap_value(Time, _animationDuration / _animation.TicsPerSecond);
					_animationTime = _animationTimeWrapped;
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
			if (array_length(AnimationPlayer.__nodeTransform) < _nodeSize)
			{
				array_resize(AnimationPlayer.__nodeTransform, _nodeSize);
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
