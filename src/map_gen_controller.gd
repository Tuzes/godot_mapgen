class_name MapGenController
extends Node3D

const GENERATOR_SCRIPTS := {
	"mountains": "res://src/generators/mountains_gen.gd",
	"pass": "res://src/generators/pass_gen.gd",
	"archipelago": "res://src/generators/archipelago_gen.gd",
	"plains": "res://src/generators/plains_gen.gd",
	"continent": "res://src/generators/continent_gen.gd",
}

# Preload core scripts so class_name types are registered before generators are parsed.
const _CORE_NOISE = preload("res://src/core/noise_utils.gd")
const _CORE_GENRESULT = preload("res://src/core/gen_result.gd")
const _CORE_REGISTRY = preload("res://src/core/generator_registry.gd")

@export_enum("mountains", "pass", "archipelago", "plains", "continent")
var generator_type: String = "mountains"

@export var seed: int = 42
@export_range(64, 1024, 64) var map_resolution: int = 384

@onready var _renderer: Node = $TerrainRenderer


func _ready() -> void:
	_register_generators()
	call_deferred("generate")


func generate() -> void:
	var gen = GeneratorRegistry.get_generator(generator_type)
	if gen == null:
		push_error("MapGenController: unknown generator '%s'" % generator_type)
		return

	print("MapGenController: generating '%s' seed=%d res=%d..." % [generator_type, seed, map_resolution])
	var result = gen.generate(seed, map_resolution, map_resolution)
	_renderer.render(result)
	print("MapGenController: done in %.0f ms" % result.generation_time_ms)


func randomize_and_generate() -> void:
	seed = randi() % 999999
	generate()


func _register_generators() -> void:
	if GeneratorRegistry.generator_count() > 0:
		return

	for gen_name in GENERATOR_SCRIPTS:
		var script = load(GENERATOR_SCRIPTS[gen_name])
		var instance = script.new()
		GeneratorRegistry.register(instance)

	print("MapGenController: registered %d generators" % GeneratorRegistry.generator_count())
