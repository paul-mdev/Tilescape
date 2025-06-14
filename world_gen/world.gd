extends Node2D

class_name World

@export var tilemap : TileMapLayer
@export var player : Player


static var world_data: Dictionary ={
	"created_at": "14/05/2025",
	"world_name": "test",
	"seed": 1342721133
}

static var world_name : String

func _ready() -> void:	
	# Initialisation des données
	print("world_data : ", world_data)
	world_name = world_data.world_name

	ProceduralGen.init_noise(world_data.seed)
	tilemap.load_chunk_keys(world_name)
	player.load_player_data(world_name)
	tilemap.camera = player.get_node("Camera2DBatch")
	tilemap.update_loaded_chunks(3)
	tilemap.render_visible_chunks(Camera.get_camera_extended_rect(tilemap.camera.get_global_camera_viewport_rect()))


func save_and_quit() -> void:
	tilemap.save_chunk_keys(world_name)
	save_world_data()
	player.save_player_data(world_name) 

func options_changed() -> void:
	tilemap.render_distance = DataManager.options["video"]["render_distance"]
	tilemap.draw_chunk_borders = DataManager.options["video"]["draw_chunk_borders"]


func _process(_delta : float) -> void:
	handle_mouse()
	queue_redraw()

func _input(_event : InputEvent) -> void:
	if Input.is_action_just_pressed("r"):
		get_tree().reload_current_scene()
		return

var last_modified_coords : Dictionary = {}
var selection_start : Vector2
var selection_end : Vector2
var is_selecting : bool = false

func _draw() -> void:
	# --- Dessin de la sélection de tuiles (déjà existant) ---
	var top_left : Vector2i = tilemap.map_to_local(Vector2i(min(selection_start.x, selection_end.x), min(selection_start.y, selection_end.y))) - Vector2(tilemap.CELL_SIZE, tilemap.CELL_SIZE) / 2
	var bottom_right : Vector2i = tilemap.map_to_local(Vector2i(max(selection_start.x, selection_end.x) + 1, max(selection_start.y, selection_end.y) + 1)) - Vector2(tilemap.CELL_SIZE, tilemap.CELL_SIZE) / 2
	var size : Vector2 = bottom_right - top_left
	draw_rect(Rect2(top_left, size), Color(0, 1, 0, 0.2), true)
	draw_rect(Rect2(top_left, size), Color(0, 1, 0, 1), false, 1.5)


@export var mouse_coord_lbl: Label
@export var block_lbl: Label


func handle_mouse() -> void:
	var ctrl : bool = Input.is_action_pressed("ctrl")
	var left_click : bool = Input.is_action_pressed("clic_gauche")
	var right_click : bool = Input.is_action_pressed("clic_droit")
	var released : bool = Input.is_action_just_released("clic_gauche") or Input.is_action_just_released("clic_droit")
	
	var mouse_pos : Vector2 = get_global_mouse_position()
	var tile_pos : Vector2i = tilemap.local_to_map(tilemap.to_local(mouse_pos))
	var chunk_key : Vector2i = tilemap.get_chunk_key(tile_pos)
	mouse_coord_lbl.text=str(int(tile_pos.x))+" X\n"+str(int(tile_pos.y))+" Y"
	var tile_info : String = "EMPTY"
	if tilemap.chunk_keys.has(chunk_key) and tilemap.chunk_keys[chunk_key].has(tile_pos):
		tile_info = str(tilemap.chunk_keys[chunk_key][tile_pos])
		
	#print(tilemap.draw_key_as_ascii(tilemap.get_connect_key(tile_pos, tilemap.chunk_keys[chunk_key][tile_pos])))
		
	block_lbl.text = tile_info + " tiles"

	var selected_item = player.hotbar.get_selected_item()
	if true:#selected_item != null and selected_item.type == "Block":
		# Début de sélection avec Ctrl
		if ctrl and (left_click or right_click):
			if !is_selecting:
				selection_start = tile_pos
				is_selecting = true
			selection_end = tile_pos
		elif !released:
			selection_start = tile_pos
			selection_end = tile_pos
			
			
			# Action immédiate sans Ctrl
			if left_click and not last_modified_coords.has(tile_pos):
				tilemap.destroy_block(mouse_pos)
				last_modified_coords[tile_pos] = true
			elif right_click and not last_modified_coords.has(tile_pos):
				if selected_item != null and selected_item.type == "Block":
					var player_rect : Rect2 = player.get_bounding_rect()
					var tile_origin : Vector2i = tilemap.map_to_local(tile_pos)
					var tile_rect : Rect2 = Rect2(tile_origin, Vector2(tilemap.CELL_SIZE, tilemap.CELL_SIZE))

					if not tile_rect.intersects(player_rect):
						print(selected_item.name)
						tilemap.place_block(mouse_pos, Tiles.TILES[selected_item.name])
						last_modified_coords[tile_pos] = true
					else:
						print("SKIP TILE AT: ", tile_pos, " intersects player")


		# Fin de sélection avec Ctrl
		else:
			is_selecting = false
			var to_destroy : Array[Vector2] = []

			for x : int in range(min(selection_start.x, selection_end.x), max(selection_start.x, selection_end.x) + 1):
				for y : int in range(min(selection_start.y, selection_end.y), max(selection_start.y, selection_end.y) + 1):
					var pos : Vector2i = Vector2i(x, y)
					if last_modified_coords.has(pos):
						continue

					var world_pos : Vector2 = tilemap.map_to_local(pos)

					if Input.is_action_just_released("clic_gauche"):
						to_destroy.append(world_pos)
						last_modified_coords[pos] = true

					elif Input.is_action_just_released("clic_droit") and selected_item != null and selected_item.type == "Block":
						var player_rect : Rect2 = player.get_bounding_rect()
						var tile_size : Vector2i = Vector2i(tilemap.CELL_SIZE, tilemap.CELL_SIZE)
						var tile_rect : Rect2 = Rect2(world_pos - tile_size / 2.0, tile_size)

						if not tile_rect.intersects(player_rect):
							tilemap.place_block(world_pos, Tiles.TILES[selected_item.name]) #Tiles.TILES.abyss_fuel
							last_modified_coords[pos] = true
						else:
							print("SKIP TILE AT: ", pos, " intersects player")

			# Appelle le batch de destruction en une fois
			if to_destroy.size() > 0:
				tilemap.destroy_blocks(to_destroy)

			# Reset
			last_modified_coords.clear()


# -- World -- #

static func save_world_data() -> void:
	var file : FileAccess = FileAccess.open("user://worlds/%s" % world_data.world_name + "/world.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(world_data, "\t"))
	
static func create_world(world_name: String, SEED : int, created_at: String) -> Dictionary:
	var dir_path : String = "user://worlds/%s" % world_name
	var chunk_path : String = dir_path + "/chunks"

	# Créer dossier du monde
	var dir : DirAccess = DirAccess.open("user://")
	if not dir.dir_exists("worlds"):
		dir.make_dir("worlds")
	if not dir.dir_exists(dir_path):
		dir.make_dir(dir_path)
	if not dir.dir_exists(chunk_path):
		dir.make_dir(chunk_path)

	world_data = {
		"world_name": world_name,
		"seed": SEED,
		"created_at": created_at
	}
	save_world_data()
	return world_data
	
