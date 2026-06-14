class_name TerrainRenderer
extends Node3D

@export var world_size: Vector2 = Vector2(384, 384)
@export var height_scale: float = 300.0
@export var data_directory: String = "res://data/"
@export var water_size_multiplier: float = 1.5


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

	# Hide Terrain3D's own mesh; we draw our own colored terrace top + cliff walls.
	_hide_terrain_visual(terrain)

	# Recreate visualization meshes (removes stale children first).
	_update_terrace_mesh(result)
	_update_cliff_mesh(result)
	_update_water_plane(result)

	print("TerrainRenderer: rendered '%s' %dx%d seed=%d scale=%.1f" % [result.generator_name, result.width, result.height_val, result.seed, height_scale])


func clear() -> void:
	var terrain = _get_terrain()
	if terrain:
		terrain.data.clear()
	_remove_child_by_name("TerraceMesh")
	_remove_child_by_name("CliffMesh")
	_remove_child_by_name("WaterPlane")


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


# ── Hide Terrain3D's own mesh (we render our own terrace + cliff) ────────────

func _hide_terrain_visual(terrain) -> void:
	if terrain == null:
		return
	if "visible" in terrain:
		terrain.visible = false


# ── Terrace mesh (top faces, colored per height tier) ────────────────────────

func _update_terrace_mesh(result) -> void:
	_remove_child_by_name("TerraceMesh")

	var w: int = result.width
	var h: int = result.height_val
	var heightmap: PackedFloat32Array = result.heightmap

	var tier_indices_raw = result.get("tier_indices")
	var tier_indices: PackedInt32Array
	if tier_indices_raw != null and tier_indices_raw is PackedInt32Array:
		tier_indices = tier_indices_raw
	else:
		tier_indices = PackedInt32Array()

	var tier_colors_raw = result.get("height_tier_colors")
	var tier_colors: Array = []
	if tier_colors_raw != null:
		tier_colors = tier_colors_raw

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var half_w: float = float(w) / 2.0
	var half_h: float = float(h) / 2.0

	for y in range(h):
		for x in range(w):
			var idx: int = y * w + x
			var height_y: float = heightmap[idx] * height_scale
			var color: Color = _color_for_index(idx, tier_indices, tier_colors)

			var x0: float = -half_w + float(x)
			var x1: float = -half_w + float(x + 1)
			var z0: float = -half_h + float(y)
			var z1: float = -half_h + float(y + 1)

			st.set_color(color)
			st.add_vertex(Vector3(x0, height_y, z0))
			st.set_color(color)
			st.add_vertex(Vector3(x1, height_y, z0))
			st.set_color(color)
			st.add_vertex(Vector3(x1, height_y, z1))

			st.set_color(color)
			st.add_vertex(Vector3(x0, height_y, z0))
			st.set_color(color)
			st.add_vertex(Vector3(x1, height_y, z1))
			st.set_color(color)
			st.add_vertex(Vector3(x0, height_y, z1))

	st.generate_normals()
	var terrace_mesh: ArrayMesh = st.commit()
	if terrace_mesh == null or terrace_mesh.get_surface_count() == 0:
		return

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "TerraceMesh"
	mesh_instance.mesh = terrace_mesh
	add_child(mesh_instance, true)
	if get_tree():
		mesh_instance.owner = get_tree().get_current_scene()

	var material := StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.roughness = 0.95
	mesh_instance.material_override = material


func _color_for_index(idx: int, tier_indices: PackedInt32Array, tier_colors: Array) -> Color:
	if tier_indices.size() == 0 or tier_colors.size() == 0:
		return Color(0.6, 0.6, 0.6, 1.0)
	if idx >= tier_indices.size():
		return tier_colors[tier_colors.size() - 1]
	var t: int = tier_indices[idx]
	if t < 0:
		t = 0
	if t >= tier_colors.size():
		t = tier_colors.size() - 1
	return tier_colors[t]


# ── Water plane (translucent blue, at result.water_level) ────────────────────

func _update_water_plane(result) -> void:
	var water_level = result.get("water_level")
	if water_level == null or not water_level is float:
		_remove_child_by_name("WaterPlane")
		return

	_remove_child_by_name("WaterPlane")

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "WaterPlane"
	add_child(mesh_instance, true)
	if get_tree():
		mesh_instance.owner = get_tree().get_current_scene()

	var plane_mesh := PlaneMesh.new()
	var multiplier: float = max(1.0, water_size_multiplier)
	plane_mesh.size = Vector2(float(result.width) * multiplier, float(result.height_val) * multiplier)
	mesh_instance.mesh = plane_mesh
	mesh_instance.position = Vector3(0.0, water_level * height_scale, 0.0)

	var material := StandardMaterial3D.new()
	var water_color = result.get("water_color")
	material.albedo_color = water_color if water_color != null else Color(0.2, 0.4, 0.8, 0.4)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_instance.material_override = material


# ── Cliff visualization (vertical quad strips at tier boundaries) ────────────

func _update_cliff_mesh(result) -> void:
	var tier_indices = result.get("tier_indices")
	if tier_indices == null or not tier_indices is PackedInt32Array or tier_indices.size() == 0:
		_remove_child_by_name("CliffMesh")
		return

	_remove_child_by_name("CliffMesh")

	var w: int = result.width
	var h: int = result.height_val
	var heightmap: PackedFloat32Array = result.heightmap

	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var half_w: float = float(w) / 2.0
	var half_h: float = float(h) / 2.0

	# Horizontal edges (between cell at x and x+1)
	for y in range(h):
		for x in range(w - 1):
			var idx = y * w + x
			var idx_right = y * w + x + 1
			if tier_indices[idx] != tier_indices[idx_right]:
				var h1: float = heightmap[idx] * height_scale
				var h2: float = heightmap[idx_right] * height_scale
				var h_lower: float = min(h1, h2)
				var h_upper: float = max(h1, h2)
				var wx: float = -half_w + float(x + 1)
				var wz_top: float = -half_h + float(y)
				var wz_bot: float = -half_h + float(y + 1)

				# Quad facing +X (two triangles)
				st.add_vertex(Vector3(wx, h_lower, wz_top))
				st.add_vertex(Vector3(wx, h_upper, wz_top))
				st.add_vertex(Vector3(wx, h_upper, wz_bot))
				st.add_vertex(Vector3(wx, h_lower, wz_top))
				st.add_vertex(Vector3(wx, h_upper, wz_bot))
				st.add_vertex(Vector3(wx, h_lower, wz_bot))

	# Vertical edges (between cell at y and y+1)
	for y in range(h - 1):
		for x in range(w):
			var idx = y * w + x
			var idx_down = (y + 1) * w + x
			if tier_indices[idx] != tier_indices[idx_down]:
				var h1: float = heightmap[idx] * height_scale
				var h2: float = heightmap[idx_down] * height_scale
				var h_lower: float = min(h1, h2)
				var h_upper: float = max(h1, h2)
				var wx_left: float = -half_w + float(x)
				var wx_right: float = -half_w + float(x + 1)
				var wz: float = -half_h + float(y + 1)

				# Quad facing +Z (two triangles)
				st.add_vertex(Vector3(wx_left, h_lower, wz))
				st.add_vertex(Vector3(wx_left, h_upper, wz))
				st.add_vertex(Vector3(wx_right, h_upper, wz))
				st.add_vertex(Vector3(wx_left, h_lower, wz))
				st.add_vertex(Vector3(wx_right, h_upper, wz))
				st.add_vertex(Vector3(wx_right, h_lower, wz))

	st.generate_normals()
	var cliff_mesh: ArrayMesh = st.commit()

	if cliff_mesh == null or cliff_mesh.get_surface_count() == 0:
		return  # No cliff faces generated

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "CliffMesh"
	add_child(mesh_instance, true)
	if get_tree():
		mesh_instance.owner = get_tree().get_current_scene()
	mesh_instance.mesh = cliff_mesh

	var material := StandardMaterial3D.new()
	var cliff_color = result.get("cliff_color")
	material.albedo_color = cliff_color if cliff_color != null else Color(0.75, 0.65, 0.35, 1.0)
	material.roughness = 1.0
	# Render both sides so the cliff color is visible from either neighbor's view.
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh_instance.material_override = material


# ── Helpers ──────────────────────────────────────────────────────────────────

func _remove_child_by_name(node_name: String) -> void:
	for child in get_children():
		if child.name == node_name:
			remove_child(child)
			child.queue_free()
			break
