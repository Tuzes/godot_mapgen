## CameraController — Godot-editor-style camera orbiting, panning, and zooming.
##
## Controls (mimics Godot editor viewport):
##   Right-drag   → Orbit around pivot
##   Middle-drag  → Pan (slide camera + pivot in camera-local XY)
##   Scroll       → Zoom in/out along forward axis
##
## Attach to a Camera3D node. The camera orbits a pivot point
## (initially the world origin). Adjust orbit_distance, sensitivity, etc.
class_name CameraController
extends Camera3D


## ---- Configuration ----

## Initial distance from the orbit pivot (meters).
@export var orbit_distance: float = 300.0

## Minimum zoom distance.
@export var min_zoom: float = 20.0

## Maximum zoom distance.
@export var max_zoom: float = 2000.0

## Mouse sensitivity for orbit (radians per pixel).
@export var orbit_sensitivity: float = 0.005

## Mouse sensitivity for pan (world units per pixel at distance).
@export var pan_sensitivity: float = 0.5

## Zoom speed (multiplier per scroll step).
@export var zoom_speed: float = 20.0

## Damping factor for smooth movement (0=instant, higher=slower). 5 is responsive.
@export var damping: float = 8.0

## Invert Y orbit (check if "up" drag should look up).
@export var invert_y: bool = false


## ---- Internal State ----

var _pivot: Vector3 = Vector3.ZERO
var _yaw: float = -PI / 4.0      # Horizontal angle (radians)
var _pitch: float = PI / 5.0     # Vertical angle (radians), from horizontal
var _target_distance: float
var _target_pivot: Vector3
var _target_yaw: float
var _target_pitch: float
var _is_orbiting: bool = false
var _is_panning: bool = false
var _last_mouse_pos: Vector2


## ---- Lifecycle ----

func _ready() -> void:
	_target_distance = orbit_distance
	_target_yaw = _yaw
	_target_pitch = _pitch
	_target_pivot = _pivot
	_apply_camera_transform()


## ---- Input Handling ----

func _unhandled_input(event: InputEvent) -> void:
	# Orbit (right mouse button)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_is_orbiting = event.pressed
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			_is_panning = event.pressed
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_target_distance = max(min_zoom, _target_distance - zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_target_distance = min(max_zoom, _target_distance + zoom_speed)

	# Orbiting
	if _is_orbiting and event is InputEventMouseMotion:
		_target_yaw -= event.relative.x * orbit_sensitivity
		var pitch_delta = event.relative.y * orbit_sensitivity
		if invert_y:
			pitch_delta = -pitch_delta
		_target_pitch = clamp(_target_pitch - pitch_delta, -PI / 2.0 + 0.05, PI / 2.0 - 0.05)

	# Panning
	if _is_panning and event is InputEventMouseMotion:
		var right: Vector3 = global_transform.basis.x
		var up: Vector3 = global_transform.basis.y
		var pan: Vector3 = -event.relative.x * pan_sensitivity * right
		pan += event.relative.y * pan_sensitivity * up
		# Scale pan by distance (farther = faster pan)
		var dist_factor: float = _target_distance / orbit_distance
		_target_pivot += pan * dist_factor


func _process(delta: float) -> void:
	# Apply damping
	var t: float = 1.0 - exp(-damping * delta)
	_yaw = lerp_angle(_yaw, _target_yaw, t)
	_pitch = lerp_angle(_pitch, _target_pitch, t)
	_pivot = _pivot.lerp(_target_pivot, t)
	orbit_distance = lerp(orbit_distance, _target_distance, t)

	_apply_camera_transform()


## ---- Private ----

## Position the camera using spherical coordinates around the pivot.
func _apply_camera_transform() -> void:
	var cam_pos: Vector3 = _pivot + _spherical_to_cartesian(orbit_distance, _yaw, _pitch)
	global_position = cam_pos

	# Look at pivot with world-up for consistent horizon
	var up_hint: Vector3 = Vector3.UP
	look_at(_pivot, up_hint)


## Convert spherical (distance, yaw, pitch) → cartesian offset from pivot.
## Yaw   = rotation around Y axis (0 = looking along -Z, Godot convention)
## Pitch = angle above horizontal plane
func _spherical_to_cartesian(dist: float, yaw: float, pitch: float) -> Vector3:
	return Vector3(
		dist * cos(pitch) * sin(yaw),
		dist * sin(pitch),
		dist * cos(pitch) * cos(yaw)
	)
