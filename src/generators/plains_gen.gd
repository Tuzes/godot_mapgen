class_name PlainsGen
extends "res://src/core/map_generator_base.gd"

func get_generator_name() -> String:
	return "plains"

func _generate_impl(seed: int, width: int, height: int) -> PackedFloat32Array:
	var W := width
	var H := height
	var map := PackedFloat32Array()
	map.resize(W * H)
	for y in range(H):
		for x in range(W):
			var nx: float = float(x) / float(W)
			var ny: float = float(y) / float(H)
			var base: float = NoiseUtils.fbm(nx * 1.6, ny * 1.6, 4, seed, 2.0, 0.5)
			var h: float = 0.28 + base * 0.27
			var river_field: float = NoiseUtils.fbm(nx * 2.5 + 7.0, ny * 2.5 + 7.0, 4, seed + 300, 2.0, 0.5)
			var river: float = 1.0 - abs(2.0 * river_field - 1.0)
			if river > 0.85:
				h -= (river - 0.85) * 1.2
			h += NoiseUtils.fbm(nx * 8.0, ny * 8.0, 2, seed + 310, 2.0, 0.5) * 0.04
			map[y * W + x] = clamp(h, 0.0, 1.0)
	return map
