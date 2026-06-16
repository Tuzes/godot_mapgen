class_name ScaleProcessor
extends "res://src/processing/heightmap_processor.gd"

## Final-stage scaling pass. Three independent multipliers from config:
##
## 1. xy_scale       - horizontal (XZ) cell-spacing multiplier; written as
##                     metadata for the renderer to apply (does NOT resample).
## 2. z_scale_low    - vertical multiplier for tiers 0-4 (water → forest).
##                     Multiplies the height value directly.
## 3. z_scale_high   - vertical multiplier for tiers 5-6 (purple mountain).
##                     Pure multiply on the height value. The mountain base
##                     re-alignment to the green platform is handled by
##                     MountainOffsetProcessor running AFTER this pass.
##
## Must run AFTER WaterPlaneProcessor (needs tier_indices) and BEFORE
## MountainOffsetProcessor (so the foot gets re-glued after scaling).

func _process_impl(result):
	# 1. Horizontal scale - emit as metadata; renderer reads it.
	result.xy_scale = config.xy_scale

	# 2/3. Vertical scaling per tier.
	var tier_indices_raw = result.get("tier_indices")
	if tier_indices_raw == null or not tier_indices_raw is PackedInt32Array:
		push_warning("ScaleProcessor: missing tier_indices, skipping z scale")
		return result

	var tier_indices: PackedInt32Array = tier_indices_raw
	var hm: PackedFloat32Array = result.heightmap
	var pixel_count: int = hm.size()

	var z_low: float = config.z_scale_low
	var z_high: float = config.z_scale_high

	var apply_low: bool = not is_equal_approx(z_low, 1.0)
	var apply_high: bool = not is_equal_approx(z_high, 1.0)

	if not apply_low and not apply_high:
		return result

	for i: int in range(pixel_count):
		if i >= tier_indices.size():
			break
		var t: int = tier_indices[i]
		if t >= 5:
			if apply_high:
				hm[i] = hm[i] * z_high
		else:
			if apply_low:
				hm[i] = hm[i] * z_low

	result.heightmap = hm
	return result
