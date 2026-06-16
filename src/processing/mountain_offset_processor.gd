class_name MountainOffsetProcessor
extends "res://src/processing/heightmap_processor.gd"

## Drops purple-tier heights uniformly so the mountain base sits flush
## with the dark-green terrace instead of jutting out abruptly.
##
## Must run AFTER WaterPlaneProcessor so tier_indices are already computed
## and stay locked in. We only adjust heightmap values, never re-bin tiers.

func _process_impl(result):
	var tier_indices_raw = result.get("tier_indices")
	if tier_indices_raw == null or not tier_indices_raw is PackedInt32Array:
		push_warning("MountainOffsetProcessor: missing tier_indices, skipping")
		return result

	var tier_indices: PackedInt32Array = tier_indices_raw
	var hm: PackedFloat32Array = result.heightmap
	var pixel_count: int = hm.size()
	var drop: float = config.mountain_drop

	for i: int in range(pixel_count):
		if i >= tier_indices.size():
			break
		# Purple tiers (5 = mountain, 6 = peak) get dropped to align with green platform.
		if tier_indices[i] >= 5:
			hm[i] = hm[i] - drop

	result.heightmap = hm
	return result
