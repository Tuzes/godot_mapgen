class_name HeightmapProcessor
extends RefCounted

const _CONFIG_SCRIPT = preload("res://src/processing/heightmap_processing_config.gd")

var config: Resource = _CONFIG_SCRIPT.new()


## Process a GenResult. Returns the (possibly modified) result for chaining.
## Override _process_impl() in subclasses.
func process(result):
	if result == null:
		return null
	if config == null:
		config = _CONFIG_SCRIPT.new()
	return _process_impl(result)


## Subclass hook — modify result in-place and return it.
func _process_impl(_result):
	return _result
