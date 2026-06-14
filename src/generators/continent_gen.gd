class_name ContinentGen
extends "res://src/core/map_generator_base.gd"

func get_generator_name() -> String:
	return "continent"

func _generate_impl(seed: int, width: int, height: int) -> PackedFloat32Array:
	var W := width
	var H := height
	var map := PackedFloat32Array()
	map.resize(W * H)
	for y in range(H):
		for x in range(W):
			var nx: float = float(x) / float(W)
			var ny: float = float(y) / float(H)
			var dx: float = nx - 0.5
			var dy: float = ny - 0.5
			var dist: float = sqrt(dx * dx + dy * dy) * 1.7
			var edge: float = max(0.0, 1.0 - dist * dist)
			var base: float = NoiseUtils.fbm(nx * 2.0, ny * 2.0, 6, seed, 2.0, 0.55)
			var h: float = base * 0.45 + edge * 0.35 + 0.18
			var lake_field: float = NoiseUtils.fbm(nx * 1.5 + 11.0, ny * 1.5 + 11.0, 3, seed + 400, 2.0, 0.5)
			if lake_field < 0.35:
				h -= (0.35 - lake_field) * 0.8
			var river_field: float = NoiseUtils.fbm(nx * 2.5 + 17.0, ny * 2.5 + 17.0, 4, seed + 410, 2.0, 0.5)
			var river: float = 1.0 - abs(2.0 * river_field - 1.0)
			if river > 0.88:
				h -= (river - 0.88) * 1.5
			var mount_field: float = NoiseUtils.fbm(nx * 3.5 + 23.0, ny * 3.5 + 23.0, 4, seed + 420, 2.0, 0.5)
			if mount_field > 0.65:
				h += (mount_field - 0.65) * 0.8
			map[y * W + x] = clamp(h, 0.0, 1.0)
	return map
