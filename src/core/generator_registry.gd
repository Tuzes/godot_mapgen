class_name GeneratorRegistry
extends RefCounted

static var _generators: Dictionary = {}

static func register(generator) -> void:
	var name: String = generator.get_generator_name()
	if name.is_empty():
		push_error("GeneratorRegistry: cannot register generator with empty name")
		return
	_generators[name] = generator

static func get_generator(name: String):
	return _generators.get(name, null)

static func get_all_names() -> Array:
	var names: Array = []
	for key in _generators.keys():
		names.append(key)
	names.sort()
	return names

static func has_generator(name: String) -> bool:
	return _generators.has(name)

static func clear() -> void:
	_generators.clear()

static func generator_count() -> int:
	return _generators.size()
