@tool
extends WorldEnvironment
class_name SmogController

@export_group("Smog Controls")
@export var smog_enabled: bool = true:
	set(v):
		smog_enabled = v
		_apply()

@export var smog_color: Color = Color(0.95, 0.6, 0.3, 1.0):
	set(v):
		smog_color = v
		_apply()

@export_range(0.0, 0.2, 0.001)
var smog_density: float = 0.01:
	set(v):
		smog_density = v
		_apply()

@export_group("Distance Fog")
@export var fog_start: float = 140.0:
	set(v):
		fog_start = v
		_apply()

@export var fog_end: float = 1000.0:
	set(v):
		fog_end = v
		_apply()

@export_range(0.1, 4.0, 0.05)
var fog_curve: float = 1.0:
	set(v):
		fog_curve = v
		_apply()

@export_group("Volumetric Fog (Optional)")
@export var volumetric_enabled: bool = false:
	set(v):
		volumetric_enabled = v
		_apply()

@export_range(0.0, 0.2, 0.001)
var volumetric_density: float = 0.005:
	set(v):
		volumetric_density = v
		_apply()

@export_range(-1.0, 1.0, 0.05)
var anisotropy: float = 0.4:
	set(v):
		anisotropy = v
		_apply()

func _ready() -> void:
	_ensure_unique_environment()
	_apply()

func _ensure_unique_environment() -> void:
	if environment == null:
		environment = Environment.new()
	else:
		environment = environment.duplicate(true)

func _apply() -> void:
	if environment == null:
		return

	environment.fog_enabled = smog_enabled
	if not smog_enabled:
		return

	environment.fog_light_color = smog_color

	environment.fog_mode = Environment.FOG_MODE_DEPTH
	environment.fog_density = smog_density
	environment.fog_depth_begin = fog_start
	environment.fog_depth_end = fog_end
	environment.fog_depth_curve = fog_curve

	environment.volumetric_fog_enabled = volumetric_enabled
	environment.volumetric_fog_density = volumetric_density
	environment.volumetric_fog_anisotropy = anisotropy
