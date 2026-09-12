/// @module Editor

/// @enum Types of commands stored by {@link BBMOD_Editor} history.
enum BBMOD_EEditorCommand
{
	/// @member A command for a target created outside the editor.
	Create,
	/// @member A completed gizmo transformation command.
	Transform,
	/// @member A deletion command that can restore its selected targets.
	Delete,
};

/// @func BBMOD_Editor([_gizmoSize])
///
/// @desc Owns editor state and the gizmo used to edit BBMOD runtime structs.
function BBMOD_Editor(_gizmoSize = 10.0) constructor
{
	/// @var {Bool} Whether editor behavior is enabled.
	Enabled = false;

	/// @var {Struct.BBMOD_Gizmo} The gizmo owned by this editor.
	Gizmo = new BBMOD_Gizmo(_gizmoSize);

	/// @var {Bool} Whether editor icons are drawn.
	ShowIcons = true;

	/// @var {Real} Screen-space editor icon size.
	IconSize = 24.0;

	/// @var {Real} Distance at which IconSize is applied.
	IconReferenceDistance = 100.0;

	/// @var {Real} Editor wireframe visibility mode.
	WireframeMode = BBMOD_EWireframeMode.Selected;

	/// @var {Struct.BBMOD_Color} Normal wireframe color.
	WireframeColor = BBMOD_C_WHITE;

	/// @var {Struct.BBMOD_Color} Selected wireframe color.
	WireframeColorSelected = BBMOD_C_YELLOW;

	/// @var {Struct.BBMOD_Color} Highlight color for selected instances.
	InstanceHighlightColor = BBMOD_C_ORANGE;

	/// @var {Bool} Whether editor mouse picking is enabled.
	EnableMousepick = true;

	/// @var {Constant.MouseButton} Mouse button used to select targets.
	ButtonSelect = mb_left;

	/// @var {Constant.VirtualKey} Key used for multiple selection.
	KeyMultiSelect = vk_shift;

	/// @var {Constant.VirtualKey} Key used to destroy the current selection.
	DeleteKey = vk_delete;

	/// @var {Array<Constant.VirtualKey>} Key chord used to undo history.
	/// Defaults to `[vk_control, ord("Z")]`.
	UndoKeys = [vk_control, ord("Z")];

	/// @var {Array<Constant.VirtualKey>} Key chord used to redo history.
	/// Defaults to `[vk_control, vk_shift, ord("Z")]`.
	RedoKeys = [vk_control, vk_shift, ord("Z")];

	/// @var {Array<Struct>} Undo history commands.
	UndoStack = [];

	/// @var {Array<Struct>} Redo history commands.
	RedoStack = [];

	/// @var {Real} Maximum number of retained history commands.
	HistoryLimit = 64;

	/// @var {Bool} Whether history application is in progress.
	IsApplyingHistory = false;

	/// @var {Struct} State captured when the current gizmo edit began.
	__historyBeforeEdit = undefined;

	/// @func bind()
	///
	/// @desc Binds the owned gizmo to direct BBMOD struct transforms.
	///
	/// @return {Struct.BBMOD_Editor} Returns `self`.
	static bind = function ()
	{
		var _gizmo = Gizmo;
		var _editor = self;
		_gizmo.__bbmodEditorOwner = self;
		if (_gizmo.__bbmodEditorBound == undefined)
		{
			_gizmo.__bbmodEditorOriginalCallbacks = {
				InstanceExists: _gizmo.InstanceExists,
				GetInstanceGlobalMatrix: _gizmo.GetInstanceGlobalMatrix,
				GetInstancePositionX: _gizmo.GetInstancePositionX,
				GetInstancePositionY: _gizmo.GetInstancePositionY,
				GetInstancePositionZ: _gizmo.GetInstancePositionZ,
				SetInstancePositionX: _gizmo.SetInstancePositionX,
				SetInstancePositionY: _gizmo.SetInstancePositionY,
				SetInstancePositionZ: _gizmo.SetInstancePositionZ,
				GetInstanceRotationX: _gizmo.GetInstanceRotationX,
				GetInstanceRotationY: _gizmo.GetInstanceRotationY,
				GetInstanceRotationZ: _gizmo.GetInstanceRotationZ,
				SetInstanceRotationX: _gizmo.SetInstanceRotationX,
				SetInstanceRotationY: _gizmo.SetInstanceRotationY,
				SetInstanceRotationZ: _gizmo.SetInstanceRotationZ,
				GetInstanceScaleX: _gizmo.GetInstanceScaleX,
				GetInstanceScaleY: _gizmo.GetInstanceScaleY,
				GetInstanceScaleZ: _gizmo.GetInstanceScaleZ,
				SetInstanceScaleX: _gizmo.SetInstanceScaleX,
				SetInstanceScaleY: _gizmo.SetInstanceScaleY,
				SetInstanceScaleZ: _gizmo.SetInstanceScaleZ,
				OnEditBegin: _gizmo.OnEditBegin,
				OnEditEnd: _gizmo.OnEditEnd,
			};
			_gizmo.__bbmodEditorBound = true;
		}
		_gizmo.InstanceExists = function (_value)
		{
			return !is_real(_value) || instance_exists(_value);
		};
		_gizmo.GetInstanceGlobalMatrix = function (_value)
		{
			return new BBMOD_Matrix();
		};
		_gizmo.ApplyStructRotation = method(_editor, function (
			_value, _directionStored, _forward, _right, _up, _rotateByX, _rotateByY, _rotateByZ)
		{
			if (instanceof(_value) != "BBMOD_DirectionalLight"
				&& instanceof(_value) != "BBMOD_SpotLight"
				&& instanceof(_value) != "BBMOD_LensFlare") return;
			if (_rotateByX == undefined) return _value.Direction.Clone();
			var _direction = _directionStored.Clone();
			if (_rotateByX != 0.0)
			{
				_direction = new BBMOD_Quaternion().FromAxisAngle(_forward, _rotateByX)
					.Rotate(_direction);
			}
			if (_rotateByY != 0.0)
			{
				_direction = new BBMOD_Quaternion().FromAxisAngle(_right, _rotateByY)
					.Rotate(_direction);
			}
			if (_rotateByZ != 0.0)
			{
				_direction = new BBMOD_Quaternion().FromAxisAngle(_up, _rotateByZ)
					.Rotate(_direction);
			}
			_value.Direction = _direction.Normalize();
			_value.EditorRotation = new BBMOD_Vec3().FromArray(
				self.get_direction_quaternion(_value.Direction).ToEuler());
		});
		_gizmo.OnEditBegin = method(_gizmo, function ()
		{
			var _owner = self.__bbmodEditorOwner;
			if (_owner != undefined && !_owner.IsApplyingHistory)
			{
				_owner.__historyBeforeEdit = _owner.capture_selection_state(self.Selected);
			}
		});
		_gizmo.OnEditEnd = method(_gizmo, function ()
		{
			var _owner = self.__bbmodEditorOwner;
			if (_owner != undefined)
			{
				_owner.record_transform(_owner.__historyBeforeEdit);
				_owner.__historyBeforeEdit = undefined;
			}
		});
		_gizmo.GetInstancePositionX = method(_editor, function (_value)
		{
			return self.get_position(_value).X;
		});
		_gizmo.GetInstancePositionY = method(_editor, function (_value)
		{
			return self.get_position(_value).Y;
		});
		_gizmo.GetInstancePositionZ = method(_editor, function (_value)
		{
			return self.get_position(_value).Z;
		});
		_gizmo.SetInstancePositionX = method(_editor, function (_value, _x)
		{
			self.set_position_x(_value, _x);
		});
		_gizmo.SetInstancePositionY = method(_editor, function (_value, _y)
		{
			self.set_position_y(_value, _y);
		});
		_gizmo.SetInstancePositionZ = method(_editor, function (_value, _z)
		{
			self.set_position_z(_value, _z);
		});
		_gizmo.GetInstanceRotationX = method(_editor, function (_value)
		{
			return self.get_rotation(_value).X;
		});
		_gizmo.GetInstanceRotationY = method(_editor, function (_value)
		{
			return self.get_rotation(_value).Y;
		});
		_gizmo.GetInstanceRotationZ = method(_editor, function (_value)
		{
			return self.get_rotation(_value).Z;
		});
		_gizmo.SetInstanceRotationX = method(_gizmo, function (_value, _x)
		{
			if (self.EditType == BBMOD_EEditType.Rotation)
			{
				self.__bbmodEditorOwner.set_rotation_x(_value, _x);
			}
		});
		_gizmo.SetInstanceRotationY = method(_gizmo, function (_value, _y)
		{
			if (self.EditType == BBMOD_EEditType.Rotation)
			{
				self.__bbmodEditorOwner.set_rotation_y(_value, _y);
			}
		});
		_gizmo.SetInstanceRotationZ = method(_gizmo, function (_value, _z)
		{
			if (self.EditType == BBMOD_EEditType.Rotation)
			{
				self.__bbmodEditorOwner.set_rotation_z(_value, _z);
			}
		});
		_gizmo.GetInstanceScaleX = method(_editor, function (_value)
		{
			return self.get_scale(_value).X;
		});
		_gizmo.GetInstanceScaleY = method(_editor, function (_value)
		{
			return self.get_scale(_value).Y;
		});
		_gizmo.GetInstanceScaleZ = method(_editor, function (_value)
		{
			return self.get_scale(_value).Z;
		});
		_gizmo.SetInstanceScaleX = method(_editor, function (_value, _x)
		{
			self.set_scale_x(_value, _x);
		});
		_gizmo.SetInstanceScaleY = method(_editor, function (_value, _y)
		{
			self.set_scale_y(_value, _y);
		});
		_gizmo.SetInstanceScaleZ = method(_editor, function (_value, _z)
		{
			self.set_scale_z(_value, _z);
		});
		return self;
	};

	/// @func get_direction_quaternion(_direction)
	///
	/// @desc Converts a direction vector to the editor's rotation quaternion.
	///
	/// @param {Struct.BBMOD_Vec3} _direction The direction to convert.
	///
	/// @return {Struct.BBMOD_Quaternion} The resulting quaternion.
	static get_direction_quaternion = function (_direction)
	{
		return new BBMOD_Quaternion().FromLookRotation(_direction, BBMOD_VEC3_UP);
	};

	/// @func get_editables()
	///
	/// @desc Returns the currently registered editor targets.
	///
	/// @return {Array<Struct>} The current editor targets.
	static get_editables = function ()
	{
		if (!variable_global_exists("__bbmodDirectionalLight"))
		{
			global.__bbmodDirectionalLight = undefined;
		}
		if (!variable_global_exists("__bbmodPunctualLights"))
		{
			global.__bbmodPunctualLights = [];
		}
		if (!variable_global_exists("__bbmodReflectionProbes"))
		{
			global.__bbmodReflectionProbes = [];
		}
		if (!variable_global_exists("__bbmodParticleEmitters"))
		{
			global.__bbmodParticleEmitters = [];
		}
		if (!variable_global_exists("__bbmodLensFlares"))
		{
			global.__bbmodLensFlares = [];
		}
		var _editables = [];
		var _directionalLight = global.__bbmodDirectionalLight;
		if (_directionalLight != undefined) array_push(_editables, _directionalLight);
		var _punctualLights = global.__bbmodPunctualLights;
		for (var i = 0; i < array_length(_punctualLights); ++i)
		{
			array_push(_editables, _punctualLights[i]);
		}
		var _reflectionProbes = global.__bbmodReflectionProbes;
		for (var i = 0; i < array_length(_reflectionProbes); ++i)
		{
			array_push(_editables, _reflectionProbes[i]);
		}
		var _particleEmitters = global.__bbmodParticleEmitters;
		for (var i = 0; i < array_length(_particleEmitters); ++i)
		{
			array_push(_editables, _particleEmitters[i]);
		}
		var _lensFlares = global.__bbmodLensFlares;
		for (var i = 0; i < array_length(_lensFlares); ++i)
		{
			if (_lensFlares[i].Position != undefined)
			{
				array_push(_editables, _lensFlares[i]);
			}
		}
		return _editables;
	};

	/// @func get_position(_value)
	///
	/// @desc Returns a target's world position.
	///
	/// @param {Struct, Id.Instance} _value The target.
	///
	/// @return {Struct.BBMOD_Vec3} The target position.
	static get_position = function (_value)
	{
		if (!is_struct(_value)) return new BBMOD_Vec3(_value.x, _value.y, _value.z);
		return _value.Position;
	};

	/// @func capture_target_state(_value)
	///
	/// @desc Captures the transform and editor-relevant state of a target.
	///
	/// @param {Struct, Id.Instance} _value The target to capture.
	///
	/// @return {Struct} The captured target state.
	static capture_target_state = function (_value)
	{
		var _state = {
			Type: undefined,
			Position: get_position(_value).Clone(),
			Rotation: get_rotation(_value).Clone(),
			Scale: get_scale(_value).Clone(),
		};
		if (!is_struct(_value))
		{
			_state.Z = _value.z;
			_state.Depth = _value.depth;
			_state.ImageIndex = _value.image_index;
			_state.ImageSpeed = _value.image_speed;
			_state.Visible = _value.visible;
			_state.Persistent = _value.persistent;
		}
		else
		{
			_state.Type = instanceof(_value);
			if (_state.Type == "BBMOD_DirectionalLight"
				|| _state.Type == "BBMOD_SpotLight"
				|| _state.Type == "BBMOD_LensFlare")
			{
				_state.Direction = _value.Direction.Clone();
			}
			if (_state.Type == "BBMOD_PointLight"
				|| _state.Type == "BBMOD_SpotLight"
				|| _state.Type == "BBMOD_LensFlare")
			{
				_state.Range = _value.Range;
			}
			if (_state.Type == "BBMOD_SpotLight")
			{
				_state.AngleInner = _value.AngleInner;
				_state.AngleOuter = _value.AngleOuter;
			}
			if (_state.Type == "BBMOD_ReflectionProbe")
			{
				_state.Size = _value.Size.Clone();
			}
		}
		return _state;
	};

	/// @func capture_selection_state(_selection)
	///
	/// @desc Captures state for every live target in a mixed selection.
	///
	/// @param {Id.DsList} _selection The mixed target selection.
	///
	/// @return {Struct} The captured selection state.
	static capture_selection_state = function (_selection)
	{
		var _targets = [];
		var _states = [];
		var _size = ds_list_size(_selection);
		for (var i = 0; i < _size; ++i)
		{
			var _target = _selection[|  i];
			if (!target_exists(_target)) continue;
			array_push(_targets, _target);
			array_push(_states, capture_target_state(_target));
		}
		return { Targets: _targets, States: _states };
	};

	/// @func array_find(_array, _value)
	///
	/// @desc Finds a target by identity in an array.
	///
	/// @param {Array} _array The array to search.
	/// @param {Any} _value The value to find.
	///
	/// @return {Real} The matching index or `-1`.
	static array_find = function (_array, _value)
	{
		for (var i = 0; i < array_length(_array); ++i)
		{
			if (_array[i] == _value) return i;
		}
		return -1;
	};

	/// @func target_exists(_value)
	///
	/// @desc Checks whether an instance or registered struct is still live.
	///
	/// @param {Struct, Id.Instance} _value The target to check.
	///
	/// @return {Bool} Whether the target is live.
	static target_exists = function (_value)
	{
		if (!is_struct(_value)) return instance_exists(_value);
		var _type = instanceof(_value);
		if (_type == "BBMOD_DirectionalLight") return global.__bbmodDirectionalLight == _value;
		if (_type == "BBMOD_PointLight" || _type == "BBMOD_SpotLight")
		{
			return array_find(global.__bbmodPunctualLights, _value) != -1;
		}
		if (_type == "BBMOD_ReflectionProbe")
		{
			return array_find(global.__bbmodReflectionProbes, _value) != -1;
		}
		if (_type == "BBMOD_ParticleEmitter")
		{
			return array_find(global.__bbmodParticleEmitters, _value) != -1;
		}
		if (_type == "BBMOD_LensFlare")
		{
			return array_find(global.__bbmodLensFlares, _value) != -1;
		}
		return true;
	};

	/// @func apply_target_state(_value, _state)
	///
	/// @desc Applies a previously captured target state.
	///
	/// @param {Struct, Id.Instance} _value The target to update.
	/// @param {Struct} _state The captured state to apply.
	///
	/// @return {Struct, Id.Instance} The updated target.
	static apply_target_state = function (_value, _state)
	{
		set_position(_value, _state.Position);
		set_rotation(_value, _state.Rotation);
		set_scale(_value, _state.Scale);
		if (!is_struct(_value))
		{
			_value.z = _state.Z;
			_value.depth = _state.Depth;
			_value.image_index = _state.ImageIndex;
			_value.image_speed = _state.ImageSpeed;
			_value.visible = _state.Visible;
			_value.persistent = _state.Persistent;
		}
		else
		{
			var _type = instanceof(_value);
			if ((_type == "BBMOD_DirectionalLight"
					|| _type == "BBMOD_SpotLight"
					|| _type == "BBMOD_LensFlare") && _state.Direction != undefined)
			{
				_value.Direction = _state.Direction.Clone();
			}
			if (_type == "BBMOD_PointLight"
				|| _type == "BBMOD_SpotLight"
				|| _type == "BBMOD_LensFlare")
			{
				_value.Range = _state.Range;
			}
			if (_type == "BBMOD_SpotLight")
			{
				_value.AngleInner = _state.AngleInner;
				_value.AngleOuter = _state.AngleOuter;
			}
			if (_type == "BBMOD_ReflectionProbe") _value.set_size(_state.Size);
		}
		return _value;
	};

	/// @func states_equal(_first, _second)
	///
	/// @desc Compares two captured target states.
	///
	/// @param {Struct} _first The first state.
	/// @param {Struct} _second The second state.
	///
	/// @return {Bool} Whether the states are equal.
	static states_equal = function (_first, _second)
	{
		if (_first.Position.X != _second.Position.X
			|| _first.Position.Y != _second.Position.Y
			|| _first.Position.Z != _second.Position.Z
			|| _first.Rotation.X != _second.Rotation.X
			|| _first.Rotation.Y != _second.Rotation.Y
			|| _first.Rotation.Z != _second.Rotation.Z
			|| _first.Scale.X != _second.Scale.X
			|| _first.Scale.Y != _second.Scale.Y
			|| _first.Scale.Z != _second.Scale.Z
			|| _first.Type != _second.Type) return false;
		if (_first.Type == "BBMOD_DirectionalLight"
			|| _first.Type == "BBMOD_SpotLight"
			|| _first.Type == "BBMOD_LensFlare")
		{
			if (_first.Direction.X != _second.Direction.X
				|| _first.Direction.Y != _second.Direction.Y
				|| _first.Direction.Z != _second.Direction.Z) return false;
		}
		if (_first.Type == "BBMOD_PointLight"
			|| _first.Type == "BBMOD_SpotLight"
			|| _first.Type == "BBMOD_LensFlare")
		{
			if (_first.Range != _second.Range) return false;
		}
		if (_first.Type == "BBMOD_SpotLight"
			&& (_first.AngleInner != _second.AngleInner
				|| _first.AngleOuter != _second.AngleOuter)) return false;
		if (_first.Type == "BBMOD_ReflectionProbe"
			&& (_first.Size.X != _second.Size.X
				|| _first.Size.Y != _second.Size.Y
				|| _first.Size.Z != _second.Size.Z)) return false;
		if (_first.Type == undefined)
		{
			return _first.Z == _second.Z
				&& _first.Depth == _second.Depth
				&& _first.ImageIndex == _second.ImageIndex
				&& _first.ImageSpeed == _second.ImageSpeed
				&& _first.Visible == _second.Visible
				&& _first.Persistent == _second.Persistent;
		}
		return true;
	};

	/// @func capture_instance_snapshot(_instance)
	///
	/// @desc Captures a GameMaker instance for reversible editor operations.
	///
	/// @param {Id.Instance} _instance The instance to capture.
	///
	/// @return {Struct} The instance snapshot.
	static capture_instance_snapshot = function (_instance)
	{
		var _properties = [];
		bbmod_object_get_property_array(_instance.object_index, _properties);
		var _buffer = buffer_create(256, buffer_grow, 1);
		bbmod_instance_to_buffer(_instance, _buffer, _properties);
		return {
			Buffer: _buffer,
			Properties: _properties,
			ObjectName: object_get_name(_instance.object_index),
			Z: _instance.z,
			Depth: _instance.depth,
			Rotation: _instance.image_angle,
			ScaleX: _instance.image_xscale,
			ScaleY: _instance.image_yscale,
			ImageIndex: _instance.image_index,
			ImageSpeed: _instance.image_speed,
			Visible: _instance.visible,
			Persistent: _instance.persistent,
		};
	};

	/// @func restore_instance_snapshot(_snapshot)
	///
	/// @desc Recreates a GameMaker instance from a captured snapshot.
	///
	/// @param {Struct} _snapshot The instance snapshot.
	///
	/// @return {Id.Instance} The recreated instance.
	static restore_instance_snapshot = function (_snapshot)
	{
		var _properties = ds_map_create();
		_properties[?  _snapshot.ObjectName] = _snapshot.Properties;
		buffer_seek(_snapshot.Buffer, buffer_seek_start, 0);
		var _instance = bbmod_instance_from_buffer(_snapshot.Buffer, _properties);
		ds_map_destroy(_properties);
		_instance.z = _snapshot.Z;
		_instance.depth = _snapshot.Depth;
		_instance.image_angle = _snapshot.Rotation;
		_instance.image_xscale = _snapshot.ScaleX;
		_instance.image_yscale = _snapshot.ScaleY;
		_instance.image_index = _snapshot.ImageIndex;
		_instance.image_speed = _snapshot.ImageSpeed;
		_instance.visible = _snapshot.Visible;
		_instance.persistent = _snapshot.Persistent;
		return _instance;
	};

	/// @func dispose_instance_snapshot(_snapshot)
	///
	/// @desc Releases resources owned by an instance snapshot.
	///
	/// @param {Struct} _snapshot The instance snapshot to dispose.
	static dispose_instance_snapshot = function (_snapshot)
	{
		if (_snapshot != undefined && buffer_exists(_snapshot.Buffer))
		{
			buffer_delete(_snapshot.Buffer);
		}
	};

	/// @func array_insert(_array, _index, _value)
	///
	/// @desc Returns an array with a value inserted at an index.
	///
	/// @param {Array} _array The source array.
	/// @param {Real} _index The insertion index.
	/// @param {Any} _value The value to insert.
	///
	/// @return {Array} The resulting array.
	static array_insert = function (_array, _index, _value)
	{
		var _size = array_length(_array);
		var _result = array_create(_size + 1, undefined);
		for (var i = 0; i < _size + 1; ++i)
		{
			_result[i] = (i == _index) ? _value : _array[i - (i > _index)];
		}
		return _result;
	};

	/// @func capture_struct_delete_snapshot(_value)
	///
	/// @desc Captures a registered struct for reversible deletion.
	///
	/// @param {Struct} _value The registered struct to capture.
	///
	/// @return {Struct} The deletion snapshot.
	static capture_struct_delete_snapshot = function (_value)
	{
		var _type = instanceof(_value);
		var _index = -1;
		var _registry = undefined;
		var _punctualIndex = array_find(global.__bbmodPunctualLights, _value);
		if (_punctualIndex != -1)
		{
			_index = _punctualIndex;
			_registry = "Punctual";
		}
		else if (_type == "BBMOD_DirectionalLight") _index = 0;
		else if (_type == "BBMOD_PunctualLight"
			|| _type == "BBMOD_PointLight" || _type == "BBMOD_SpotLight")
		{
			_index = array_find(global.__bbmodPunctualLights, _value);
		}
		else if (_type == "BBMOD_ReflectionProbe")
		{
			_index = array_find(global.__bbmodReflectionProbes, _value);
		}
		else if (_type == "BBMOD_ParticleEmitter")
		{
			_index = array_find(global.__bbmodParticleEmitters, _value);
		}
		else if (_type == "BBMOD_LensFlare")
		{
			_index = array_find(global.__bbmodLensFlares, _value);
		}
		return {
			Target: _value,
			Type: _type,
			Registry: _registry,
			Index: _index,
			State: capture_target_state(_value),
		};
	};

	/// @func remove_struct(_snapshot)
	///
	/// @desc Removes a registered struct from its runtime registry.
	///
	/// @param {Struct} _snapshot The struct deletion snapshot.
	///
	/// @return {Bool} Whether the struct was removed.
	static remove_struct = function (_snapshot)
	{
		var _type = _snapshot.Type;
		if (_type == "BBMOD_DirectionalLight") bbmod_light_directional_set(undefined);
		else if (_snapshot.Registry == "Punctual"
			|| _type == "BBMOD_PunctualLight"
			|| _type == "BBMOD_PointLight" || _type == "BBMOD_SpotLight")
		{
			var _index = array_find(global.__bbmodPunctualLights, _snapshot.Target);
			if (_index < 0) return false;
			var _remainingLights = array_create(
				array_length(global.__bbmodPunctualLights) - 1, undefined);
			var _remainingIndex = 0;
			for (var i = 0; i < array_length(global.__bbmodPunctualLights); ++i)
			{
				if (i != _index)
				{
					_remainingLights[_remainingIndex++] = global.__bbmodPunctualLights[i];
				}
			}
			global.__bbmodPunctualLights = _remainingLights;
		}
		else if (_type == "BBMOD_ReflectionProbe") bbmod_reflection_probe_remove(_snapshot.Target);
		else if (_type == "BBMOD_ParticleEmitter") bbmod_particle_emitter_remove(_snapshot.Target);
		else if (_type == "BBMOD_LensFlare") bbmod_lens_flare_remove(_snapshot.Target);
		else return false;
		return true;
	};

	/// @func restore_struct(_snapshot)
	///
	/// @desc Restores a registered struct and its registry position.
	///
	/// @param {Struct} _snapshot The struct deletion snapshot.
	///
	/// @return {Struct} The restored struct.
	static restore_struct = function (_snapshot)
	{
		var _target = _snapshot.Target;
		var _type = _snapshot.Type;
		if (_type == "BBMOD_DirectionalLight") bbmod_light_directional_set(_target);
		else if (_snapshot.Registry == "Punctual"
			|| _type == "BBMOD_PunctualLight"
			|| _type == "BBMOD_PointLight" || _type == "BBMOD_SpotLight")
		{
			if (array_find(global.__bbmodPunctualLights, _target) == -1)
			{
				global.__bbmodPunctualLights = self.array_insert(
					global.__bbmodPunctualLights, min(_snapshot.Index, array_length(global
						.__bbmodPunctualLights)), _target);
			}
		}
		else if (_type == "BBMOD_ReflectionProbe")
		{
			global.__bbmodReflectionProbes = self.array_insert(
				global.__bbmodReflectionProbes, _snapshot.Index, _target);
		}
		else if (_type == "BBMOD_ParticleEmitter")
		{
			global.__bbmodParticleEmitters = self.array_insert(
				global.__bbmodParticleEmitters, _snapshot.Index, _target);
		}
		else if (_type == "BBMOD_LensFlare")
		{
			global.__bbmodLensFlares = self.array_insert(
				global.__bbmodLensFlares, _snapshot.Index, _target);
		}
		apply_target_state(_target, _snapshot.State);
		return _target;
	};

	/// @func select(_value)
	///
	/// @desc Sets the transient editor selection.
	///
	/// @param {Struct, Id.Instance} _value The target to select.
	///
	/// @return {Struct, Id.Instance} The selected target.
	static select = function (_value)
	{
		if (!is_real(_value)
			&& (instanceof(_value) == "BBMOD_DirectionalLight"
				|| instanceof(_value) == "BBMOD_SpotLight"
				|| instanceof(_value) == "BBMOD_LensFlare")
			&& _value.Direction != undefined)
		{
			_value.EditorRotation = new BBMOD_Vec3().FromArray(
				get_direction_quaternion(_value.Direction).ToEuler());
		}
		global.__bbmodEditorSelected = _value;
		return _value;
	};

	/// @func clear_selection()
	///
	/// @desc Clears the transient editor selection.
	static clear_selection = function ()
	{
		global.__bbmodEditorSelected = undefined;
	};

	/// @func get_selected()
	///
	/// @desc Returns the transient editor selection.
	///
	/// @return {Struct, Id.Instance} The selected target or `undefined`.
	static get_selected = function ()
	{
		return global.__bbmodEditorSelected;
	};

	/// @func clear_instance_icons()
	///
	/// @desc Clears transient instance icons submitted for the current frame.
	static clear_instance_icons = function ()
	{
		global.__bbmodEditorInstanceIcons = [];
	};

	/// @func remap_history_target(_oldTarget, _newTarget)
	///
	/// @desc Updates history references after an instance is recreated.
	///
	/// @param {Id.Instance} _oldTarget The replaced instance ID.
	/// @param {Id.Instance} _newTarget The recreated instance ID.
	static remap_history_target = function (_oldTarget, _newTarget)
	{
		var _stacks = [UndoStack, RedoStack];
		for (var _stackIndex = 0; _stackIndex < 2; ++_stackIndex)
		{
			var _stack = _stacks[_stackIndex];
			for (var i = 0; i < array_length(_stack); ++i)
			{
				var _command = _stack[i];
				if (_command.Type == BBMOD_EEditorCommand.Transform)
				{
					for (var j = 0; j < array_length(_command.Targets); ++j)
					{
						if (_command.Targets[j] == _oldTarget)
						{
							_command.Targets[j] = _newTarget;
						}
					}
				}
				else if (_command.Type == BBMOD_EEditorCommand.Delete)
				{
					for (var j = 0; j < array_length(_command.Entries); ++j)
					{
						if (_command.Entries[j].Target == _oldTarget)
						{
							_command.Entries[j].Target = _newTarget;
						}
					}
				}
			}
		}
	};

	/// @func filter_instance_selection(_selection)
	///
	/// @desc Copies GameMaker instance targets from a mixed selection.
	///
	/// @param {Id.DsList} _selection The mixed target selection.
	///
	/// @return {Id.DsList} A new list containing instance targets.
	static filter_instance_selection = function (_selection)
	{
		var _instances = ds_list_create();
		for (var i = 0; i < ds_list_size(_selection); ++i)
		{
			var _value = _selection[|  i];
			if (!is_struct(_value)) ds_list_add(_instances, _value);
		}
		return _instances;
	};

	/// @func pick(_projected, _x, _y)
	///
	/// @desc Picks the highest-priority projected editor icon at screen position.
	///
	/// @param {Array<Struct>} _projected Projected icon records.
	/// @param {Real} _x The screen-space X coordinate.
	/// @param {Real} _y The screen-space Y coordinate.
	///
	/// @return {Struct, Id.Instance} The picked target or `undefined`.
	static pick = function (_projected, _x, _y)
	{
		var _picked = undefined;
		var _pickedPriority = -infinity;
		var _pickedDepth = infinity;
		for (var i = 0; i < array_length(_projected); ++i)
		{
			var _icon = _projected[i];
			if (_x < _icon.Left || _x > _icon.Right
				|| _y < _icon.Top || _y > _icon.Bottom) continue;
			if (_icon.Priority > _pickedPriority
				|| (_icon.Priority == _pickedPriority && _icon.Depth < _pickedDepth))
			{
				_picked = _icon.Value;
				_pickedPriority = _icon.Priority;
				_pickedDepth = _icon.Depth;
			}
		}
		return _picked;
	};

	/// @func draw_icons(_projected[, _offsetX, _offsetY, _selection, _selectionColor])
	///
	/// @desc Draws projected editor icons with selection highlighting.
	///
	/// @param {Array<Struct>} _projected Projected icon records.
	/// @param {Real} [_offsetX] The screen-space X offset.
	/// @param {Real} [_offsetY] The screen-space Y offset.
	/// @param {Id.DsList} [_selection] The mixed target selection.
	/// @param {Struct.BBMOD_Color} [_selectionColor] The selection color.
	///
	/// @return {Array<Struct>} The projected icon records.
	static draw_icons = function (
		_projected,
		_offsetX = 0.0,
		_offsetY = 0.0,
		_selection = undefined,
		_selectionColor = BBMOD_C_YELLOW
	)
	{
		var _selectionColorNumeric = make_color_rgb(
			_selectionColor.Red,
			_selectionColor.Green,
			_selectionColor.Blue);
		for (var i = 0; i < array_length(_projected); ++i)
		{
			var _icon = _projected[i];
			var _selected = (_selection != undefined)
				&& ds_list_find_index(_selection, _icon.Value) != -1;
			draw_sprite_ext(
				_icon.Sprite,
				_icon.Frame,
				_icon.X + _offsetX,
				_icon.Y + _offsetY,
				_icon.Scale,
				_icon.Scale,
				0.0,
				_selected ? merge_color(c_white, _selectionColorNumeric, 0.65) : c_white,
				_selected ? min(_icon.Alpha * 1.15, 1.0) : _icon.Alpha);
		}
		return _projected;
	};

	/// @func draw_wireframe(_value[, _color, _alpha])
	///
	/// @desc Draws a BBMOD-owned wireframe for one supported struct.
	///
	/// @param {Struct} _value The supported struct.
	/// @param {Constant.Color} [_color] The wireframe color.
	/// @param {Real} [_alpha] The wireframe alpha.
	///
	/// @return {Struct} The supplied struct.
	static draw_wireframe = function (_value, _color = c_white, _alpha = 1.0)
	{
		var _type = instanceof(_value);
		if (_type == "BBMOD_PointLight")
		{
			bbmod_editor_draw_sphere(_value.Position, _value.Range, _color, _alpha);
		}
		else if (_type == "BBMOD_SpotLight")
		{
			bbmod_editor_draw_cone(_value.Position, _value.Direction, _value.Range,
				_value.AngleInner, _color, _alpha);
			bbmod_editor_draw_cone(_value.Position, _value.Direction, _value.Range,
				_value.AngleOuter, _color, _alpha);
		}
		else if (_type == "BBMOD_DirectionalLight")
		{
			var _direction = _value.Direction.Normalize();
			var _length = 5.0;
			var _offset = _direction.Scale(_length * 0.5);
			var _start = _value.Position.Sub(_offset);
			var _end = _value.Position.Add(_offset);
			bbmod_editor_draw_line(_start, _end, _color, _alpha);
			bbmod_editor_draw_cone(_end, _direction.Scale(-1.0), _length * 0.2,
				20.0, _color, _alpha);
		}
		else if (_type == "BBMOD_ReflectionProbe" && !_value.Infinite)
		{
			bbmod_editor_draw_aabb(_value.Position, _value.Size, _color, _alpha);
		}
		return _value;
	};

	/// @func draw_wireframes(_mode, _selection[, _selectedColor, _unselectedColor, _alpha])
	///
	/// @desc Draws editor wireframes according to the configured mode.
	///
	/// @param {BBMOD_EWireframeMode} _mode The wireframe display mode.
	/// @param {Id.DsList} _selection The mixed target selection.
	/// @param {Struct.BBMOD_Color} [_selectedColor] The selected color.
	/// @param {Struct.BBMOD_Color} [_unselectedColor] The normal color.
	/// @param {Real} [_alpha] The wireframe alpha.
	///
	/// @return {Id.DsList} The supplied selection.
	static draw_wireframes = function (
		_mode,
		_selection,
		_selectedColor = BBMOD_C_YELLOW,
		_unselectedColor = BBMOD_C_WHITE,
		_alpha = 1.0
	)
	{
		if (_mode == BBMOD_EWireframeMode.Never) return _selection;
		if (_mode == BBMOD_EWireframeMode.Selected)
		{
			var _selected = make_color_rgb(
				_selectedColor.Red, _selectedColor.Green, _selectedColor.Blue);
			for (var i = 0; i < ds_list_size(_selection); ++i)
			{
				var _value = _selection[|  i];
				if (!is_real(_value)) draw_wireframe(_value, _selected, _alpha);
			}
			return _selection;
		}
		var _editables = get_editables();
		for (var i = 0; i < array_length(_editables); ++i)
		{
			var _value = _editables[i];
			var _isSelected = ds_list_find_index(_selection, _value) != -1;
			var _color = _isSelected ? _selectedColor : _unselectedColor;
			draw_wireframe(_value,
				make_color_rgb(_color.Red, _color.Green, _color.Blue), _alpha);
		}
		return _selection;
	};

	/// @func project_instance_icons(_viewProjection, _cameraPosition, _width, _height[, _iconSize, _projFlipped, _referenceDistance])
	///
	/// @desc Projects submitted instance icons into screen-space records.
	///
	/// @param {Array<Real>} _viewProjection The view-projection matrix.
	/// @param {Struct.BBMOD_Vec3} _cameraPosition The camera position.
	/// @param {Real} _width The viewport width.
	/// @param {Real} _height The viewport height.
	/// @param {Real} [_iconSize] The base icon size.
	/// @param {Bool} [_projFlipped] Whether the projection is vertically flipped.
	/// @param {Real} [_referenceDistance] The reference distance for scaling.
	///
	/// @return {Array<Struct>} Projected icon records.
	static project_instance_icons = function (
		_viewProjection,
		_cameraPosition,
		_width,
		_height,
		_iconSize = 24.0,
		_projFlipped = false,
		_referenceDistance = 100.0
	)
	{
		if (!variable_global_exists("__bbmodEditorInstanceIcons"))
		{
			global.__bbmodEditorInstanceIcons = [];
		}
		var _projected = [];
		var _icons = global.__bbmodEditorInstanceIcons;
		for (var i = 0; i < array_length(_icons); ++i)
		{
			var _icon = _icons[i];
			var _position = _icon.Position.Add(_icon.Offset);
			var _clipX = _viewProjection[0] * _position.X + _viewProjection[4] * _position.Y
				+ _viewProjection[8] * _position.Z + _viewProjection[12];
			var _clipY = _viewProjection[1] * _position.X + _viewProjection[5] * _position.Y
				+ _viewProjection[9] * _position.Z + _viewProjection[13];
			var _clipZ = _viewProjection[2] * _position.X + _viewProjection[6] * _position.Y
				+ _viewProjection[10] * _position.Z + _viewProjection[14];
			var _clipW = _viewProjection[3] * _position.X + _viewProjection[7] * _position.Y
				+ _viewProjection[11] * _position.Z + _viewProjection[15];
			if (_clipZ < 0.0 || _clipW <= 0.0) continue;
			var _screenX = ((_clipX / _clipW) * 0.5 + 0.5) * _width;
			var _screenY = ((_clipY / _clipW) * 0.5 + 0.5) * _height;
			if (_projFlipped) _screenY = _height - _screenY;
			var _distance = _position.Sub(_cameraPosition).Length();
			if (_icon.FadeEnd > _icon.FadeStart && _distance >= _icon.FadeEnd) continue;
			var _alpha = (_distance > _icon.FadeStart && _icon.FadeEnd > _icon.FadeStart)
				? 1.0 - ((_distance - _icon.FadeStart) / (_icon.FadeEnd - _icon.FadeStart)) : 1.0;
			var _spriteWidth = max(sprite_get_width(_icon.Sprite), 1.0);
			var _spriteHeight = max(sprite_get_height(_icon.Sprite), 1.0);
			var _scale = (_iconSize * clamp(_referenceDistance / max(_distance, 1.0), 0.25, 4.0))
				/ max(_spriteWidth, _spriteHeight);
			var _left = _screenX - sprite_get_xoffset(_icon.Sprite) * _scale;
			var _top = _screenY - sprite_get_yoffset(_icon.Sprite) * _scale;
			array_push(_projected,
			{
				Value: _icon.Value,
				Sprite: _icon.Sprite,
				Frame: _icon.Frame,
				X: _screenX,
				Y: _screenY,
				Left: _left,
				Top: _top,
				Right: _left + _spriteWidth * _scale,
				Bottom: _top + _spriteHeight * _scale,
				Scale: _scale,
				Alpha: _alpha,
				Depth: _clipZ / _clipW,
				Priority: _icon.Priority,
			});
		}
		return _projected;
	};

	/// @func project_editables(_viewProjection, _cameraPosition, _width, _height[, _iconSize, _projFlipped, _referenceDistance])
	///
	/// @desc Projects registered editor targets into screen-space icon records.
	///
	/// @param {Array<Real>} _viewProjection The view-projection matrix.
	/// @param {Struct.BBMOD_Vec3} _cameraPosition The camera position.
	/// @param {Real} _width The viewport width.
	/// @param {Real} _height The viewport height.
	/// @param {Real} [_iconSize] The base icon size.
	/// @param {Bool} [_projFlipped] Whether the projection is vertically flipped.
	/// @param {Real} [_referenceDistance] The reference distance for scaling.
	///
	/// @return {Array<Struct>} Projected icon records.
	static project_editables = function (
		_viewProjection,
		_cameraPosition,
		_width,
		_height,
		_iconSize = 24.0,
		_projFlipped = false,
		_referenceDistance = 100.0
	)
	{
		var _projected = [];
		var _editables = get_editables();
		for (var i = 0; i < array_length(_editables); ++i)
		{
			var _value = _editables[i];
			var _type = instanceof(_value);
			if (_type != "BBMOD_ParticleEmitter"
				&& _type != "BBMOD_LensFlare" && !_value.Enabled) continue;
			var _position = get_position(_value).Add(_value.EditorOffset);
			var _clipX = _viewProjection[0] * _position.X + _viewProjection[4] * _position.Y
				+ _viewProjection[8] * _position.Z + _viewProjection[12];
			var _clipY = _viewProjection[1] * _position.X + _viewProjection[5] * _position.Y
				+ _viewProjection[9] * _position.Z + _viewProjection[13];
			var _clipZ = _viewProjection[2] * _position.X + _viewProjection[6] * _position.Y
				+ _viewProjection[10] * _position.Z + _viewProjection[14];
			var _clipW = _viewProjection[3] * _position.X + _viewProjection[7] * _position.Y
				+ _viewProjection[11] * _position.Z + _viewProjection[15];
			if (_clipZ < 0.0 || _clipW <= 0.0) continue;
			var _screenX = ((_clipX / _clipW) * 0.5 + 0.5) * _width;
			var _screenY = ((_clipY / _clipW) * 0.5 + 0.5) * _height;
			if (_projFlipped) _screenY = _height - _screenY;
			var _distance = _position.Sub(_cameraPosition).Length();
			var _alpha = 1.0;
			if (_value.EditorIconFadeEnd > _value.EditorIconFadeStart)
			{
				if (_distance >= _value.EditorIconFadeEnd) continue;
				if (_distance > _value.EditorIconFadeStart)
				{
					_alpha = 1.0 - (_distance - _value.EditorIconFadeStart)
						/ (_value.EditorIconFadeEnd - _value.EditorIconFadeStart);
				}
			}
			var _spriteWidth = max(sprite_get_width(_value.EditorIconSprite), 1.0);
			var _spriteHeight = max(sprite_get_height(_value.EditorIconSprite), 1.0);
			var _scale = (_iconSize * clamp(
					_referenceDistance / max(_distance, 1.0), 0.25, 4.0))
				/ max(_spriteWidth, _spriteHeight);
			array_push(_projected,
			{
				Value: _value,
				Sprite: _value.EditorIconSprite,
				Frame: _value.EditorIconIndex,
				X: _screenX,
				Y: _screenY,
				Left: _screenX - sprite_get_xoffset(_value.EditorIconSprite) * _scale,
				Top: _screenY - sprite_get_yoffset(_value.EditorIconSprite) * _scale,
				Right: _screenX + (_spriteWidth - sprite_get_xoffset(_value.EditorIconSprite)) * _scale,
				Bottom: _screenY + (_spriteHeight - sprite_get_yoffset(_value.EditorIconSprite)) * _scale,
				Scale: _scale,
				Alpha: _alpha,
				Depth: _clipZ / _clipW,
				Priority: _value.EditorPickPriority,
			});
		}
		return _projected;
	};

	/// @func set_position(_value, _position)
	///
	/// @desc Sets a target's world position.
	///
	/// @param {Struct, Id.Instance} _value The target.
	/// @param {Struct.BBMOD_Vec3} _position The new position.
	///
	/// @return {Struct, Id.Instance} The updated target.
	static set_position = function (_value, _position)
	{
		if (!is_struct(_value))
		{
			_value.x = _position.X;
			_value.y = _position.Y;
			_value.z = _position.Z;
			return _value;
		}
		if (instanceof(_value) == "BBMOD_ReflectionProbe")
		{
			_value.set_position(_position);
		}
		else
		{
			_value.Position = _position;
		}
		return _value;
	};

	/// @func get_scale(_value)
	///
	/// @desc Returns a target's editor scale representation.
	///
	/// @param {Struct, Id.Instance} _value The target.
	///
	/// @return {Struct.BBMOD_Vec3} The scale representation.
	static get_scale = function (_value)
	{
		if (!is_struct(_value)) return new BBMOD_Vec3(_value.image_xscale, _value.image_yscale, 1.0);
		if (instanceof(_value) == "BBMOD_ReflectionProbe") return _value.Size;
		if (instanceof(_value) == "BBMOD_LensFlare") return new BBMOD_Vec3(_value.Range);
		if (instanceof(_value) == "BBMOD_PointLight") return new BBMOD_Vec3(_value.Range);
		if (instanceof(_value) == "BBMOD_SpotLight")
		{
			return new BBMOD_Vec3(_value.AngleOuter, _value.AngleInner, _value.Range);
		}
		return new BBMOD_Vec3(1.0);
	};

	/// @func set_scale(_value, _scale)
	///
	/// @desc Applies a target's editor scale representation.
	///
	/// @param {Struct, Id.Instance} _value The target.
	/// @param {Struct.BBMOD_Vec3} _scale The scale representation.
	///
	/// @return {Struct, Id.Instance} The updated target.
	static set_scale = function (_value, _scale)
	{
		if (!is_struct(_value))
		{
			_value.image_xscale = _scale.X;
			_value.image_yscale = _scale.Y;
			return _value;
		}
		if (instanceof(_value) == "BBMOD_ReflectionProbe")
		{
			_value.set_size(_scale);
		}
		else if (instanceof(_value) == "BBMOD_PointLight")
		{
			_value.Range = max(abs(_scale.X), 0.001);
		}
		else if (instanceof(_value) == "BBMOD_SpotLight")
		{
			_value.AngleOuter = clamp(abs(_scale.X), 0.0, 179.0);
			_value.AngleInner = clamp(abs(_scale.Y), 0.0, _value.AngleOuter);
			_value.Range = max(abs(_scale.Z), 0.001);
		}
		else if (instanceof(_value) == "BBMOD_LensFlare")
		{
			_value.Range = max(abs(_scale.X), 0.001);
		}
		return _value;
	};

	/// @func get_rotation(_value)
	///
	/// @desc Returns a target's editor rotation.
	///
	/// @param {Struct, Id.Instance} _value The target.
	///
	/// @return {Struct.BBMOD_Vec3} The Euler rotation.
	static get_rotation = function (_value)
	{
		if (!is_struct(_value)) return new BBMOD_Vec3(0.0, 0.0, _value.image_angle);
		var _type = instanceof(_value);
		if (_type == "BBMOD_DirectionalLight"
			|| _type == "BBMOD_SpotLight"
			|| _type == "BBMOD_LensFlare")
		{
			return (_value.Direction != undefined)
				? new BBMOD_Vec3().FromArray(
					get_direction_quaternion(_value.Direction).ToEuler())
				: new BBMOD_Vec3();
		}
		return new BBMOD_Vec3();
	};

	/// @func set_rotation(_value, _rotation)
	///
	/// @desc Applies a target's editor rotation.
	///
	/// @param {Struct, Id.Instance} _value The target.
	/// @param {Struct.BBMOD_Vec3} _rotation The Euler rotation.
	///
	/// @return {Struct, Id.Instance} The updated target.
	static set_rotation = function (_value, _rotation)
	{
		if (!is_struct(_value))
		{
			_value.image_angle = _rotation.Z;
			return _value;
		}
		var _type = instanceof(_value);
		if (_type == "BBMOD_DirectionalLight"
			|| _type == "BBMOD_SpotLight"
			|| _type == "BBMOD_LensFlare")
		{
			_value.EditorRotation = _rotation.Clone();
			_value.Direction = new BBMOD_Quaternion().FromEuler(
				_rotation.X, _rotation.Y, _rotation.Z).Rotate(BBMOD_VEC3_FORWARD);
		}
		return _value;
	};

	/// @func set_position_x(_value, _x)
	/// @desc Sets a target's X position.
	///
	/// @param {Struct, Id.Instance} _value The target.
	/// @param {Real} _x The new X position.
	///
	/// @return {Struct, Id.Instance} The updated target.
	static set_position_x = function (_value, _x)
	{
		var _position = get_position(_value).Clone();
		_position.X = _x;
		return set_position(_value, _position);
	};

	/// @func set_position_y(_value, _y)
	/// @desc Sets a target's Y position.
	///
	/// @param {Struct, Id.Instance} _value The target.
	/// @param {Real} _y The new Y position.
	///
	/// @return {Struct, Id.Instance} The updated target.
	static set_position_y = function (_value, _y)
	{
		var _position = get_position(_value).Clone();
		_position.Y = _y;
		return set_position(_value, _position);
	};

	/// @func set_position_z(_value, _z)
	/// @desc Sets a target's Z position.
	///
	/// @param {Struct, Id.Instance} _value The target.
	/// @param {Real} _z The new Z position.
	///
	/// @return {Struct, Id.Instance} The updated target.
	static set_position_z = function (_value, _z)
	{
		var _position = get_position(_value).Clone();
		_position.Z = _z;
		return set_position(_value, _position);
	};

	/// @func set_rotation_x(_value, _x)
	/// @desc Sets a target's X rotation.
	///
	/// @param {Struct, Id.Instance} _value The target.
	/// @param {Real} _x The new X rotation.
	///
	/// @return {Struct, Id.Instance} The updated target.
	static set_rotation_x = function (_value, _x)
	{
		var _rotation = get_rotation(_value).Clone();
		_rotation.X = _x;
		return set_rotation(_value, _rotation);
	};

	/// @func set_rotation_y(_value, _y)
	/// @desc Sets a target's Y rotation.
	///
	/// @param {Struct, Id.Instance} _value The target.
	/// @param {Real} _y The new Y rotation.
	///
	/// @return {Struct, Id.Instance} The updated target.
	static set_rotation_y = function (_value, _y)
	{
		var _rotation = get_rotation(_value).Clone();
		_rotation.Y = _y;
		return set_rotation(_value, _rotation);
	};

	/// @func set_rotation_z(_value, _z)
	/// @desc Sets a target's Z rotation.
	///
	/// @param {Struct, Id.Instance} _value The target.
	/// @param {Real} _z The new Z rotation.
	///
	/// @return {Struct, Id.Instance} The updated target.
	static set_rotation_z = function (_value, _z)
	{
		var _rotation = get_rotation(_value).Clone();
		_rotation.Z = _z;
		return set_rotation(_value, _rotation);
	};

	/// @func set_scale_x(_value, _x)
	/// @desc Sets a target's X scale.
	///
	/// @param {Struct, Id.Instance} _value The target.
	/// @param {Real} _x The new X scale.
	///
	/// @return {Struct, Id.Instance} The updated target.
	static set_scale_x = function (_value, _x)
	{
		var _scale = get_scale(_value).Clone();
		_scale.X = _x;
		return set_scale(_value, _scale);
	};

	/// @func set_scale_y(_value, _y)
	/// @desc Sets a target's Y scale.
	///
	/// @param {Struct, Id.Instance} _value The target.
	/// @param {Real} _y The new Y scale.
	///
	/// @return {Struct, Id.Instance} The updated target.
	static set_scale_y = function (_value, _y)
	{
		var _scale = get_scale(_value).Clone();
		_scale.Y = _y;
		return set_scale(_value, _scale);
	};

	/// @func set_scale_z(_value, _z)
	/// @desc Sets a target's Z scale.
	///
	/// @param {Struct, Id.Instance} _value The target.
	/// @param {Real} _z The new Z scale.
	///
	/// @return {Struct, Id.Instance} The updated target.
	static set_scale_z = function (_value, _z)
	{
		var _scale = get_scale(_value).Clone();
		_scale.Z = _z;
		return set_scale(_value, _scale);
	};

	/// @func can_undo()
	/// @desc Returns whether an undo command is available.
	///
	/// @return {Bool} Whether an undo command is available.
	static can_undo = function ()
	{
		return array_length(UndoStack) > 0;
	};

	/// @func can_redo()
	/// @desc Returns whether a redo command is available.
	///
	/// @return {Bool} Whether a redo command is available.
	static can_redo = function ()
	{
		return array_length(RedoStack) > 0;
	};

	/// @func clear_history()
	/// @desc Clears undo and redo history.
	///
	/// @return {Struct.BBMOD_Editor} Returns `self`.
	static clear_history = function ()
	{
		for (var i = 0; i < array_length(UndoStack); ++i)
		{
			dispose_history_command(UndoStack[i]);
		}
		for (var i = 0; i < array_length(RedoStack); ++i)
		{
			dispose_history_command(RedoStack[i]);
		}
		UndoStack = [];
		RedoStack = [];
		return self;
	};

	/// @func undo()
	/// @desc Applies the latest editor history command in reverse.
	///
	/// @return {Struct.BBMOD_Editor} Returns `self`.
	static undo = function ()
	{
		if (!can_undo()) return self;
		var _index = array_length(UndoStack) - 1;
		var _command = UndoStack[_index];
		array_delete(UndoStack, _index, 1);
		IsApplyingHistory = true;
		apply_history_command(_command, true);
		IsApplyingHistory = false;
		array_push(RedoStack, _command);
		return self;
	};

	/// @func redo()
	/// @desc Reapplies the latest undone editor history command.
	///
	/// @return {Struct.BBMOD_Editor} Returns `self`.
	static redo = function ()
	{
		if (!can_redo()) return self;
		var _index = array_length(RedoStack) - 1;
		var _command = RedoStack[_index];
		array_delete(RedoStack, _index, 1);
		IsApplyingHistory = true;
		apply_history_command(_command, false);
		IsApplyingHistory = false;
		array_push(UndoStack, _command);
		return self;
	};

	/// @func delete_selected()
	/// @desc Removes the current selection and records a reversible command.
	/// @return {Struct.BBMOD_Editor} Returns `self`.
	static delete_selected = function ()
	{
		if (IsApplyingHistory) return self;
		delete_selection();
		return self;
	};

	/// @func add_created(_target)
	///
	/// @desc Adds a manually created target to editor history.
	///
	/// @param {Struct, Id.Instance} _target The newly created target.
	///
	/// @return {Struct.BBMOD_Editor} Returns `self`.
	static add_created = function (_target)
	{
		var _entry;
		if (is_struct(_target))
		{
			_entry = {
				Kind: "Struct",
				Target: _target,
				Snapshot: capture_struct_delete_snapshot(_target),
			};
		}
		else
		{
			_entry = {
				Kind: "Instance",
				Target: _target,
				Snapshot: capture_instance_snapshot(_target),
			};
		}
		for (var i = 0; i < array_length(RedoStack); ++i)
		{
			dispose_history_command(RedoStack[i]);
		}
		array_push(UndoStack,
		{
			Type: BBMOD_EEditorCommand.Create,
			Entries: [_entry],
		});
		RedoStack = [];
		select(_target);
		Gizmo.clear_selection();
		Gizmo.select(_target);
		while (array_length(UndoStack) > HistoryLimit)
		{
			var _discarded = UndoStack[0];
			array_delete(UndoStack, 0, 1);
			dispose_history_command(_discarded);
		}
		return self;
	};

	/// @func dispose_history_command(_command)
	///
	/// @desc Releases resources owned by a history command.
	///
	/// @param {Struct} _command The history command to dispose.
	static dispose_history_command = function (_command)
	{
		if (_command.Type != BBMOD_EEditorCommand.Delete
			&& _command.Type != BBMOD_EEditorCommand.Create) return;
		for (var i = 0; i < array_length(_command.Entries); ++i)
		{
			var _entry = _command.Entries[i];
			if (_entry.Kind == "Instance")
			{
				dispose_instance_snapshot(_entry.Snapshot);
			}
		}
	};

	/// @func apply_history_command(_command, _undo)
	///
	/// @desc Applies or reverses one history command.
	///
	/// @param {Struct} _command The history command.
	/// @param {Bool} _undo Whether to apply the command in reverse.
	static apply_history_command = function (_command, _undo)
	{
		if (_command.Type == BBMOD_EEditorCommand.Transform)
		{
			var _states = _undo ? _command.Before : _command.After;
			Gizmo.clear_selection();
			for (var i = 0; i < array_length(_command.Targets); ++i)
			{
				var _target = _command.Targets[i];
				if (!target_exists(_target)) continue;
				apply_target_state(_target, _states[i]);
				Gizmo.select(_target);
				select(_target);
			}
			Gizmo.update_position();
		}
		else if (_command.Type == BBMOD_EEditorCommand.Delete)
		{
			Gizmo.clear_selection();
			clear_selection();
			for (var i = 0; i < array_length(_command.Entries); ++i)
			{
				var _entry = _command.Entries[i];
				if (_undo)
				{
					if (_entry.Kind == "Instance")
					{
						var _oldTarget = _entry.Target;
						_entry.Target = restore_instance_snapshot(_entry.Snapshot);
						remap_history_target(_oldTarget, _entry.Target);
					}
					else
					{
						_entry.Target = restore_struct(_entry.Snapshot);
					}
					Gizmo.select(_entry.Target);
					select(_entry.Target);
				}
				else if (_entry.Kind == "Instance")
				{
					if (target_exists(_entry.Target)) instance_destroy(_entry.Target);
				}
				else
				{
					remove_struct(_entry.Snapshot);
				}
			}
			Gizmo.update_position();
		}
		else if (_command.Type == BBMOD_EEditorCommand.Create)
		{
			Gizmo.clear_selection();
			clear_selection();
			for (var i = 0; i < array_length(_command.Entries); ++i)
			{
				var _entry = _command.Entries[i];
				if (!_undo)
				{
					if (_entry.Kind == "Instance")
					{
						var _oldTarget = _entry.Target;
						_entry.Target = restore_instance_snapshot(_entry.Snapshot);
						remap_history_target(_oldTarget, _entry.Target);
					}
					else
					{
						_entry.Target = restore_struct(_entry.Snapshot);
					}
					select(_entry.Target);
					Gizmo.select(_entry.Target);
				}
				else if (_entry.Kind == "Instance")
				{
					if (target_exists(_entry.Target)) instance_destroy(_entry.Target);
				}
				else
				{
					remove_struct(_entry.Snapshot);
				}
			}
			Gizmo.update_position();
		}
	};

	/// @func delete_selection()
	///
	/// @desc Deletes the current selection and records a reversible command.
	static delete_selection = function ()
	{
		var _entries = [];
		var _selection = Gizmo.Selected;
		var _size = ds_list_size(_selection);
		for (var i = 0; i < _size; ++i)
		{
			var _target = _selection[|  i];
			if (!target_exists(_target)) continue;
			if (!is_struct(_target))
			{
				array_push(_entries,
				{
					Kind: "Instance",
					Target: _target,
					Snapshot: capture_instance_snapshot(_target),
				});
				instance_destroy(_target);
			}
			else
			{
				var _snapshot = capture_struct_delete_snapshot(_target);
				if (remove_struct(_snapshot))
				{
					array_push(_entries, { Kind: "Struct", Target: _target, Snapshot: _snapshot });
				}
			}
		}
		if (array_length(_entries) == 0) return;
		Gizmo.clear_selection();
		clear_selection();
		for (var i = 0; i < array_length(RedoStack); ++i)
		{
			dispose_history_command(RedoStack[i]);
		}
		array_push(UndoStack,
		{
			Type: BBMOD_EEditorCommand.Delete,
			Entries: _entries,
		});
		RedoStack = [];
		while (array_length(UndoStack) > HistoryLimit)
		{
			var _discarded = UndoStack[0];
			array_delete(UndoStack, 0, 1);
			dispose_history_command(_discarded);
		}
	};

	/// @func record_transform(_before)
	///
	/// @desc Records a completed gizmo transform as one history command.
	///
	/// @param {Struct} _before The state captured at edit start.
	static record_transform = function (_before)
	{
		if (IsApplyingHistory || _before == undefined) return;
		var _targets = [];
		var _beforeStates = [];
		var _afterStates = [];
		var _size = array_length(_before.Targets);
		for (var i = 0; i < _size; ++i)
		{
			var _target = _before.Targets[i];
			if (!target_exists(_target)) continue;
			var _afterState = capture_target_state(_target);
			if (states_equal(_before.States[i], _afterState)) continue;
			array_push(_targets, _target);
			array_push(_beforeStates, _before.States[i]);
			array_push(_afterStates, _afterState);
		}
		if (array_length(_targets) == 0) return;
		for (var i = 0; i < array_length(RedoStack); ++i)
		{
			dispose_history_command(RedoStack[i]);
		}
		array_push(UndoStack,
		{
			Type: BBMOD_EEditorCommand.Transform,
			Targets: _targets,
			Before: _beforeStates,
			After: _afterStates,
		});
		RedoStack = [];
		while (array_length(UndoStack) > HistoryLimit)
		{
			array_delete(UndoStack, 0, 1);
		}
	};

	/// @func shortcut_pressed(_keys)
	///
	/// @desc Returns whether all keys in a configurable chord are active.
	///
	/// @param {Array<Constant.VirtualKey>} _keys The shortcut key chord.
	///
	/// @return {Bool} Whether the chord is currently pressed.
	static shortcut_pressed = function (_keys)
	{
		if (array_length(_keys) == 0) return false;
		var _allDown = true;
		var _anyPressed = false;
		for (var i = 0; i < array_length(_keys); ++i)
		{
			_allDown &= keyboard_check(_keys[i]);
			_anyPressed |= keyboard_check_pressed(_keys[i]);
		}
		return _allDown && _anyPressed;
	};

	/// @func update(_deltaTime)
	///
	/// @desc Updates the owned gizmo.
	///
	/// @param {Real} _deltaTime Elapsed time in microseconds.
	///
	/// @return {Struct.BBMOD_Editor} Returns `self`.
	static update = function (_deltaTime)
	{
		if (Enabled)
		{
			global.__bbmodEditorCurrent = self;
			if (!Gizmo.IsEditing)
			{
				if (shortcut_pressed(RedoKeys))
				{
					redo();
				}
				else if (shortcut_pressed(UndoKeys))
				{
					undo();
				}
				else if (keyboard_check_pressed(DeleteKey)
					&& !ds_list_empty(Gizmo.Selected))
				{
					delete_selected();
				}
			}
			Gizmo.update(_deltaTime);
		}
		return self;
	};

	/// @func destroy()
	///
	/// @desc Destroys the editor and its owned gizmo.
	///
	/// @return {Undefined} Always returns `undefined`.
	static destroy = function ()
	{
		if (variable_global_exists("__bbmodEditorCurrent")
			&& global.__bbmodEditorCurrent == self)
		{
			global.__bbmodEditorCurrent = undefined;
		}
		clear_history();
		Gizmo = Gizmo.destroy();
		return undefined;
	};

	bind();
}

/// @var {Struct.BBMOD_Editor} The currently active editor context or `undefined`.
/// @private
global.__bbmodEditorCurrent = undefined;

/// @var {Struct} The transient editor-selected target or `undefined`.
/// @private
global.__bbmodEditorSelected = undefined;

/// @var {Array<Struct>} Instance editor icons submitted for the current frame.
/// @private
global.__bbmodEditorInstanceIcons = [];

/// @func bbmod_editor_submit_instance_icon(_position, _sprite[, _subimage[, _priority[, _fadeStart[, _fadeEnd[, _offset]]]]])
/// @desc Submits an icon for the current instance ID for the current frame.
function bbmod_editor_submit_instance_icon(
	_position,
	_sprite,
	_subimage = 0,
	_priority = 0,
	_fadeStart = 100.0,
	_fadeEnd = 120.0,
	_offset = undefined
)
{
	if (!variable_global_exists("__bbmodEditorCurrent")
		|| global.__bbmodEditorCurrent == undefined
		|| !global.__bbmodEditorCurrent.Enabled)
	{
		return undefined;
	}
	if (!variable_global_exists("__bbmodEditorInstanceIcons"))
	{
		global.__bbmodEditorInstanceIcons = [];
	}
	if (!variable_global_exists("__bbmodInstanceID") || global.__bbmodInstanceID == 0)
	{
		return undefined;
	}
	array_push(global.__bbmodEditorInstanceIcons,
	{
		Value: global.__bbmodInstanceID,
		Position: _position,
		Sprite: _sprite,
		Frame: _subimage,
		Priority: _priority,
		FadeStart: _fadeStart,
		FadeEnd: _fadeEnd,
		Offset: _offset ?? new BBMOD_Vec3(),
	});
	return global.__bbmodInstanceID;
}
