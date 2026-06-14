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

# Preload processing scripts (depends on GenResult from core)
const _PROC_CONFIG = preload("res://src/processing/heightmap_processing_config.gd")
const _PROC_PROCESSOR = preload("res://src/processing/heightmap_processor.gd")
const _PROC_TERRACE = preload("res://src/processing/terrace_processor.gd")
const _PROC_WATER = preload("res://src/processing/water_plane_processor.gd")
const _PROC_PIPELINE = preload("res://src/processing/heightmap_pipeline.gd")

@export_enum("mountains", "pass", "archipelago", "plains", "continent")
var generator_type: String = "mountains"

@export var seed: int = 42
@export_range(64, 1024, 64) var map_resolution: int = 384

@onready var _renderer: Node = $TerrainRenderer

var _pipeline: RefCounted


func _ready() -> void:
	_register_generators()
	_build_pipeline()
	call_deferred("generate")


func generate() -> void:
	var gen = GeneratorRegistry.get_generator(generator_type)
	if gen == null:
		push_error("MapGenController: unknown generator '%s'" % generator_type)
		return

	print("MapGenController: generating '%s' seed=%d res=%d..." % [generator_type, seed, map_resolution])
	var result = gen.generate(seed, map_resolution, map_resolution)

	var proc_t0 := Time.get_ticks_msec()
	var processed_result = _pipeline.process(result)
	var proc_t1 := Time.get_ticks_msec()
	if processed_result == null:
		push_error("MapGenController: processing pipeline returned null")
		return
	result = processed_result
	result.processing_time_ms = float(proc_t1 - proc_t0)

	_renderer.render(result)
	print("MapGenController: done in %.0f ms (gen) + %.0f ms (processing)" % [result.generation_time_ms, result.processing_time_ms])


func randomize_and_generate() -> void:
	seed = randi() % 999999
	generate()


func _build_pipeline() -> void:
	var shared_config = _PROC_CONFIG.new()
	_pipeline = _PROC_PIPELINE.new()
	_pipeline.config = shared_config
	var terrace_processor = _PROC_TERRACE.new()
	terrace_processor.config = shared_config
	var water_processor = _PROC_WATER.new()
	water_processor.config = shared_config
	_pipeline.add_processor(terrace_processor)
	_pipeline.add_processor(water_processor)


func _register_generators() -> void:
	if GeneratorRegistry.generator_count() > 0:
		return

	for gen_name in GENERATOR_SCRIPTS:
		var script = load(GENERATOR_SCRIPTS[gen_name])
		var instance = script.new()
		GeneratorRegistry.register(instance)

	print("MapGenController: registered %d generators" % GeneratorRegistry.generator_count())
