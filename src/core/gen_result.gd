class_name GenResult
extends RefCounted

var heightmap: PackedFloat32Array
var width: int
var height_val: int
var seed: int
var generator_name: String
var generation_time_ms: float

func _init(p_heightmap: PackedFloat32Array, p_width: int, p_height: int,
		p_seed: int, p_generator_name: String, p_generation_time_ms: float = 0.0) -> void:
	heightmap = p_heightmap
	width = p_width
	height_val = p_height
	seed = p_seed
	generator_name = p_generator_name
	generation_time_ms = p_generation_time_ms

func get_height(x: int, y: int) -> float:
	if x < 0 or x >= width or y < 0 or y >= height_val:
		return 0.0
	return heightmap[y * width + x]

func cell_count() -> int:
	return width * height_val
