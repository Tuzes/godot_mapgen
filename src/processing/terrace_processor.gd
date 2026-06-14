class_name TerraceProcessor
extends "res://src/processing/heightmap_processor.gd"

## Snaps every height value to its tier midpoint, producing flat bands
## with sharp cliff transitions at threshold boundaries.

func _process_impl(result):
	var thresholds: PackedFloat32Array = config.thresholds
	var midpoints: PackedFloat32Array = config.midpoints
	var tier_count: int = thresholds.size()
	var hm: PackedFloat32Array = result.heightmap
	var pixel_count: int = hm.size()

	for i: int in range(pixel_count):
		var h: float = hm[i]
		var snapped_height: float = midpoints[tier_count - 1]  # fallback: highest tier
		for t: int in range(tier_count):
			if h < thresholds[t]:
				snapped_height = midpoints[t]
				break
		hm[i] = snapped_height

	result.heightmap = hm
	return result
