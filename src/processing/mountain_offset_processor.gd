class_name MountainOffsetProcessor
extends "res://src/processing/heightmap_processor.gd"

## Aligns purple-tier mountain base to the dark-green terrace platform.
##
## Strategy: scan all purple cells (tier >= 5), find their minimum height,
## then shift ALL purple cells so that minimum equals the CURRENT green
## platform height (which may have been scaled by ScaleProcessor).
## This keeps the mountain shape intact while guaranteeing the foot is
## glued to the green platform regardless of any prior scaling.
##
## Must run AFTER WaterPlaneProcessor (needs tier_indices) and AFTER
## ScaleProcessor (so we re-align after vertical scaling).

func _process_impl(result):
	var tier_indices_raw = result.get("tier_indices")
	if tier_indices_raw == null or not tier_indices_raw is PackedInt32Array:
		push_warning("MountainOffsetProcessor: missing tier_indices, skipping")
		return result

	var tier_indices: PackedInt32Array = tier_indices_raw
	var hm: PackedFloat32Array = result.heightmap
	var pixel_count: int = hm.size()

	# Target = ACTUAL current green-platform height after any z_scale_low
	# applied by ScaleProcessor. Read it from a real green cell rather than
	# computing midpoints[4] * z_scale_low, so we don't depend on knowing
	# every transform that ran upstream.
	var target_base: float = _find_green_platform_height(hm, tier_indices)
	if is_nan(target_base):
		push_warning("MountainOffsetProcessor: no green tier-4 cell found, falling back to midpoints[4]")
		target_base = config.midpoints[4]

	# Pass 1: find minimum height among purple cells.
	var min_purple: float = INF
	var has_purple: bool = false
	for i: int in range(pixel_count):
		if i >= tier_indices.size():
			break
		if tier_indices[i] >= 5:
			has_purple = true
			if hm[i] < min_purple:
				min_purple = hm[i]

	if not has_purple:
		return result

	# Pass 2: shift all purple cells so min_purple lands on target_base.
	var shift: float = target_base - min_purple
	if is_zero_approx(shift):
		return result

	for i: int in range(pixel_count):
		if i >= tier_indices.size():
			break
		if tier_indices[i] >= 5:
			hm[i] = hm[i] + shift

	result.heightmap = hm
	return result


## Returns the height of any tier-4 (dark-green forest) cell, which is the
## platform that purple mountain feet must align to. Returns NaN if no such
## cell exists in the map.
func _find_green_platform_height(hm: PackedFloat32Array, tier_indices: PackedInt32Array) -> float:
	var pixel_count: int = hm.size()
	for i: int in range(pixel_count):
		if i >= tier_indices.size():
			break
		if tier_indices[i] == 4:
			return hm[i]
	return NAN
