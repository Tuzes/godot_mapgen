class_name TerrainRenderer
extends Node3D

@export var world_size: Vector2 = Vector2(384, 384)
@export var height_scale: float = 300.0
@export var data_directory: String = "res://data/"


func render(result) -> void:
	if ClassDB.class_exists("Terrain3D") == false:
		push_error("TerrainRenderer: Terrain3D GDExtension not loaded. Is plugin enabled?")
		return

	var terrain = _get_or_create_terrain()
	if terrain == null:
		return

	if result == null or result.heightmap.size() == 0:
		push_warning("TerrainRenderer: GenResult empty, skipping")
		return

	var height_image: Image = _heightmap_to_image(result)
	var offset_xz: Vector3 = Vector3(-float(result.width) / 2.0, 0.0, -float(result.height_val) / 2.0)
	terrain.data.import_images([height_image, null, null], offset_xz, 0.0, height_scale)
	print("TerrainRenderer: rendered '%s' %dx%d seed=%d scale=%.1f" % [result.generator_name, result.width, result.height_val, result.seed, height_scale])


func clear() -> void:
	var terrain = _get_terrain()
	if terrain:
		terrain.data.clear()


func _get_or_create_terrain():
	var terrain = _get_terrain()
	if terrain:
		return terrain
	if ClassDB.class_exists("Terrain3D") == false:
		return null
	terrain = ClassDB.instantiate("Terrain3D")
	terrain.name = "Terrain3D"
	add_child(terrain, true)
	if get_tree():
		terrain.owner = get_tree().get_current_scene()
	terrain.data_directory = data_directory
	return terrain


func _get_terrain():
	for child in get_children():
		if child.get_class() == "Terrain3D":
			return child
	return null


func _heightmap_to_image(result) -> Image:
	var w: int = result.width
	var h: int = result.height_val
	var img := Image.create(w, h, false, Image.FORMAT_RF)
	for y in range(h):
		for x in range(w):
			var v: float = result.get_height(x, y)
			img.set_pixel(x, y, Color(v, 0.0, 0.0, 1.0))
	return img
