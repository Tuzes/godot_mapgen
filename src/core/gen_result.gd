class_name GenResult
extends RefCounted

var heightmap: PackedFloat32Array
var width: int
var height_val: int
var seed: int
var generator_name: String
var generation_time_ms: float

## --- Pipeline metadata (set by processing stage, neutral defaults) ---

## Per-pixel colour for every height sample (empty = not computed)
var color_map: PackedColorArray = PackedColorArray()

## Per-pixel tier index 0-6 (empty = not computed)
var tier_indices: PackedInt32Array = PackedInt32Array()

## Backward-readable semantic alias for tier_indices.
var biome_indices: PackedInt32Array = PackedInt32Array()

## Horizontal water-plane height (normalised [0,1])
var water_level: float = 0.30

## Water-surface colour. RGB follows the HTML deep-water color; alpha makes the plane translucent.
var water_color: Color = Color(0.10196078431, 0.22745098039, 0.42352941176, 0.45)

## Cliff-face rock colour (yellow-gray)
var cliff_color: Color = Color(0.78, 0.73, 0.52, 1.0)

## Height-tier colours (deep-water → peak)
var height_tier_colors: Array[Color] = []

## Pipeline processing time (ms)
var processing_time_ms: float = 0.0


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
