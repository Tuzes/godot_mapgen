class_name MountainsGen
extends "res://src/core/map_generator_base.gd"

func get_generator_name() -> String:
	return "mountains"

func _generate_impl(seed: int, width: int, height: int) -> PackedFloat32Array:
	var W := width
	var H := height
	var map := PackedFloat32Array()
	map.resize(W * H)
	var cx: float = 0.45 + NoiseUtils.hash_float(1, 1, seed + 77) * 0.1
	var cy: float = 0.45 + NoiseUtils.hash_float(2, 2, seed + 77) * 0.1
	for y in range(H):
		for x in range(W):
			var nx: float = float(x) / float(W)
			var ny: float = float(y) / float(H)
			var n: float = NoiseUtils.fbm(nx * 2.5, ny * 2.5, 6, seed, 2.1, 0.55)
			var ridge: float = 1.0 - abs(2.0 * n - 1.0)
			ridge = pow(ridge, 1.4)
			var dx: float = nx - cx
			var dy: float = ny - cy
			var d: float = sqrt(dx * dx + dy * dy)
			var radial: float = max(0.0, 1.0 - d / 0.55)
			var detail: float = NoiseUtils.fbm(nx * 6.0, ny * 6.0, 4, seed + 100, 2.0, 0.5) * 0.15
			var h: float = ridge * 0.5 + radial * 0.45 + detail
			map[y * W + x] = clamp(h, 0.0, 1.0)
	return map
