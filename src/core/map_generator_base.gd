class_name MapGeneratorBase
extends RefCounted

func get_generator_name() -> String:
	push_error("MapGeneratorBase: get_generator_name() must be overridden")
	return ""

func generate(seed: int, width: int, height: int):
	var t0 := Time.get_ticks_msec()
	var heightmap := _generate_impl(seed, width, height)
	var t1 := Time.get_ticks_msec()
	return GenResult.new(heightmap, width, height, seed, get_generator_name(), float(t1 - t0))

func _generate_impl(_seed: int, _width: int, _height: int) -> PackedFloat32Array:
	push_error("MapGeneratorBase: _generate_impl() must be overridden")
	return PackedFloat32Array()
