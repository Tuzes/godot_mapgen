class_name WaterPlaneProcessor
extends "res://src/processing/heightmap_processor.gd"

## Records water-plane metadata on GenResult:
##   water_level, water_color, cliff_color, height_tier_colors
## Also populates tier_indices (0-6 per pixel) and color_map from the processed heightmap.

func _process_impl(result):
	result.water_level = config.water_level
	result.water_color = config.water_color
	result.cliff_color = config.cliff_color
	result.height_tier_colors = config.tier_colors.duplicate()

	var thresholds: PackedFloat32Array = config.thresholds
	var tier_colors: Array[Color] = config.tier_colors
	var hm: PackedFloat32Array = result.heightmap
	var pixel_count: int = hm.size()

	var indices := PackedInt32Array()
	indices.resize(pixel_count)
	var colors := PackedColorArray()
	colors.resize(pixel_count)

	for i: int in range(pixel_count):
		var h: float = hm[i]
		var idx: int = thresholds.size() - 1
		for t: int in range(thresholds.size()):
			if h < thresholds[t]:
				idx = t
				break
		indices[i] = idx
		colors[i] = tier_colors[idx]

	result.tier_indices = indices
	result.biome_indices = indices.duplicate()
	result.color_map = colors
	return result
