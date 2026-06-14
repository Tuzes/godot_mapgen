class_name ArchipelagoGen
extends "res://src/core/map_generator_base.gd"

func get_generator_name() -> String:
	return "archipelago"

func _generate_impl(seed: int, width: int, height: int) -> PackedFloat32Array:
	var W := width
	var H := height
	var map := PackedFloat32Array()
	map.resize(W * H)
	for y in range(H):
		for x in range(W):
			var nx: float = float(x) / float(W)
			var ny: float = float(y) / float(H)
			var warp_low: float = 0.30
			var warp_mid: float = 0.12
			var wx: float = nx \
				+ (NoiseUtils.fbm(nx * 1.2, ny * 1.2, 3, seed + 50, 2.0, 0.55) - 0.5) * warp_low \
				+ (NoiseUtils.fbm(nx * 3.0, ny * 3.0, 3, seed + 52, 2.0, 0.5) - 0.5) * warp_mid
			var wy: float = ny \
				+ (NoiseUtils.fbm(nx * 1.2 + 7.0, ny * 1.2 + 7.0, 3, seed + 51, 2.0, 0.55) - 0.5) * warp_low \
				+ (NoiseUtils.fbm(nx * 3.0 + 9.0, ny * 3.0 + 9.0, 3, seed + 53, 2.0, 0.5) - 0.5) * warp_mid
			var cell: float = NoiseUtils.cellular_noise(wx * 1.8, wy * 1.8, seed + 60)
			var island: float = 1.0 - cell * 1.55
			island = max(0.0, island)
			island = pow(island, 0.55)
			var mid: float = NoiseUtils.fbm(nx * 4.0, ny * 4.0, 4, seed + 70, 2.0, 0.5) * 0.18
			var coast: float = (NoiseUtils.fbm(nx * 12.0, ny * 12.0, 3, seed + 80, 2.0, 0.5) - 0.5) * 0.12
			var edge_dist: float = min(min(nx, ny), min(1.0 - nx, 1.0 - ny))
			var edge_fade: float = min(1.0, edge_dist * 4.0)
			var h: float = island * 0.85 * edge_fade + mid + coast
			h -= 0.02
			map[y * W + x] = clamp(h, 0.0, 1.0)
	return map
