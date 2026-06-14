class_name HeightmapPipeline
extends "res://src/processing/heightmap_processor.gd"

## Ordered chain of HeightmapProcessors.
## Each processor's output is fed to the next; the final GenResult is returned.

var _processors: Array[RefCounted] = []


func add_processor(proc: RefCounted) -> void:
	_processors.append(proc)


func remove_processor(proc: RefCounted) -> void:
	_processors.erase(proc)


func clear() -> void:
	_processors.clear()


func _process_impl(result):
	var current = result
	for proc: RefCounted in _processors:
		current = proc.process(current)
		if current == null:
			return null
	return current
