class_name NoiseUtils
extends RefCounted

static func hash_int(x: int, y: int, seed: int) -> int:
	var x32: int = x & 0xFFFFFFFF
	var y32: int = y & 0xFFFFFFFF
	var h: int = ((seed & 0xFFFFFFFF) ^ 0x9E3779B9) & 0xFFFFFFFF
	h = ((h ^ (h >> 16)) * 0x85EBCA6B + x32) & 0xFFFFFFFF
	h = ((h ^ (h >> 13)) * 0xC2B2AE35 + y32) & 0xFFFFFFFF
	h = ((h ^ (h >> 16)) * 0x27D4EB2F) & 0xFFFFFFFF
	return (h ^ (h >> 15)) & 0xFFFFFFFF

static func hash_float(x: int, y: int, seed: int) -> float:
	return float(hash_int(x, y, seed)) / 4294967296.0

static func smooth_step(t: float) -> float:
	return t * t * (3.0 - 2.0 * t)

static func value_noise(x: float, y: float, seed: int) -> float:
	var ix: int = int(floor(x))
	var iy: int = int(floor(y))
	var fx: float = x - float(ix)
	var fy: float = y - float(iy)
	var sx: float = smooth_step(fx)
	var sy: float = smooth_step(fy)
	var v00: float = hash_float(ix, iy, seed)
	var v10: float = hash_float(ix + 1, iy, seed)
	var v01: float = hash_float(ix, iy + 1, seed)
	var v11: float = hash_float(ix + 1, iy + 1, seed)
	var a: float = v00 + (v10 - v00) * sx
	var b: float = v01 + (v11 - v01) * sx
	return a + (b - a) * sy

static func fbm(x: float, y: float, octaves: int, seed: int,
		lacunarity: float = 2.0, gain: float = 0.5) -> float:
	var value: float = 0.0
	var amp: float = 1.0
	var freq: float = 1.0
	var max_val: float = 0.0
	for i in range(octaves):
		value += amp * value_noise(x * freq, y * freq, seed + i * 9973)
		max_val += amp
		amp *= gain
		freq *= lacunarity
	return value / max_val

static func cellular_noise(x: float, y: float, seed: int) -> float:
	var ix: int = int(floor(x))
	var iy: int = int(floor(y))
	var min_dist: float = INF
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			var cx: int = ix + dx
			var cy: int = iy + dy
			var px: float = float(cx) + hash_float(cx, cy, seed)
			var py: float = float(cy) + hash_float(cx, cy, seed + 3331)
			var ex: float = x - px
			var ey: float = y - py
			var d: float = ex * ex + ey * ey
			if d < min_dist:
				min_dist = d
	return min(1.0, sqrt(min_dist))
