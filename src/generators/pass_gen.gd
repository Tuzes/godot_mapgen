class_name PassGen
extends "res://src/core/map_generator_base.gd"

func get_generator_name() -> String:
	return "pass"

func _generate_impl(seed: int, width: int, height: int) -> PackedFloat32Array:
	var W := width
	var H := height
	var map := PackedFloat32Array()
	map.resize(W * H)
	var horizontal: bool = NoiseUtils.hash_float(0, 0, seed + 200) > 0.5
	var ridge1: float = 0.28 + NoiseUtils.hash_float(1, 0, seed + 201) * 0.06
	var ridge2: float = 0.66 + NoiseUtils.hash_float(0, 1, seed + 202) * 0.06
	var ridge_width: float = 8.0
	var ridge_peak: float = 0.45
	var passes_a: Array = _sample_passes(1, seed + 220)
	var passes_b: Array = _sample_passes(2, seed + 220)
	var base_land: float = 0.48
	for y in range(H):
		for x in range(W):
			var nx: float = float(x) / float(W)
			var ny: float = float(y) / float(H)
			var along: float = nx if horizontal else ny
			var across: float = ny if horizontal else nx
			var plain: float = (NoiseUtils.fbm(nx * 1.6, ny * 1.6, 4, seed + 211, 2.0, 0.5) - 0.5) * 0.10
			var wobble1: float = (NoiseUtils.fbm(along * 2.5, 0.5, 3, seed + 213, 2.0, 0.5) - 0.5) * 0.04
			var wobble2: float = (NoiseUtils.fbm(along * 2.5, 1.5, 3, seed + 214, 2.0, 0.5) - 0.5) * 0.04
			var dx1: float = (across - (ridge1 + wobble1)) * ridge_width
			var dx2: float = (across - (ridge2 + wobble2)) * ridge_width
			var r1raw: float = exp(-dx1 * dx1)
			var r2raw: float = exp(-dx2 * dx2)
			var dip_a: float = _pass_dip(along, passes_a)
			var dip_b: float = _pass_dip(along, passes_b)
			var r1: float = r1raw * (1.0 - dip_a * 0.95)
			var r2: float = r2raw * (1.0 - dip_b * 0.95)
			var ridge_mask: float = max(r1raw, r2raw)
			var ridge_detail: float = (NoiseUtils.fbm(nx * 5.0, ny * 5.0, 4, seed + 215, 2.0, 0.55) - 0.5) * 0.10 * ridge_mask
			var h: float = base_land + plain + (r1 + r2) * ridge_peak + ridge_detail
			map[y * W + x] = clamp(h, 0.0, 1.0)
	return map

func _sample_passes(channel: int, base_seed: int) -> Array:
	var n: int = 1 + int(NoiseUtils.hash_float(channel, 7, base_seed) * 3.0)
	var passes: Array = []
	for i in range(n):
		var pos: float = 0.15 + NoiseUtils.hash_float(channel, i + 1, base_seed + 10) * 0.7
		var pas_width: float = 0.05 + NoiseUtils.hash_float(channel, i + 100, base_seed + 20) * 0.05
		passes.append({"pos": pos, "width": pas_width})
	return passes

func _pass_dip(along: float, passes: Array) -> float:
	var dip: float = 0.0
	for p in passes:
		var d: float = (along - p["pos"]) / p["width"]
		var v: float = exp(-d * d)
		if v > dip:
			dip = v
	return dip
