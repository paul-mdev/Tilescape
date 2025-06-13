extends TileMapLayer

var TILES: Dictionary = Tiles.TILES
const CELL_SIZE : int = 16
const CHUNK_SIZE : Vector2i = Vector2(16,16)
var render_distance : int = Main.options["video"]["render_distance"]
var draw_chunk_borders : bool = Main.options["video"]["draw_chunk_borders"]
var unload_margin : int = 2  # distance supplémentaire avant de décharger

@export var player : Player

@onready var leaf_tilemap: TileMapLayer = $LeafTilemap
@onready var ore_tilemap : TileMapLayer = $OreTilemap
@onready var water_tilemap: TileMapLayer = $WaterTilemap
@onready var terrain_tilemap: TileMapLayer = $TerrainTilemap


@onready var destroy_particules_path : PackedScene = preload("res://components/particules/destroy-particules.tscn")

@onready var common_ores_list : Array[Tile] = [TILES.fuel, TILES.ore]
@onready var uncommon_ores_list : Array[Tile] = [TILES.gold, TILES.bloodstone]
@onready var rare_ores_list : Array[Tile] = [TILES.greencore, TILES.abyss_fuel]
@onready var leaf_list : Array[Tile] = [TILES.leaf, TILES.autumn_leaf, TILES.red_leaf, TILES.sakura_leaf, TILES.pine_leaf]


var rock_layer_rarity : Dictionary = {}
var common_rock_layer : Array[Tile] = [TILES.stone, TILES.sand_stone, TILES.ice]
var uncommon_rock_layer : Array[Tile] =  [TILES.compact_stone]
var rare_rock_layer : Array[Tile] = [TILES.deepstone, TILES.abyss]
var rock_layers : Array[Tile] = common_rock_layer + uncommon_rock_layer + rare_rock_layer
var rock_layer_atlas_coords : Array[Vector2i]

var loaded_chunks: Array[Vector2i] = []
var chunk_keys : Dictionary = {}
var rendered_chunks : Dictionary = {}
var background_overlays : Dictionary = {}
var pending_generation : Dictionary = {}  # clé : chunk_key, valeur : Array de structures à générer
var pending_structures :Dictionary = {}

# Chaque clé correspond à une configuration binaire
# Chaque valeur est l'atlas_coord correspondante
var TILE_LOOKUP_TABLE : Dictionary= {
	0: Vector2i(0, 3),
	1: Vector2i(0, 2),
	4: Vector2i(1, 3),
	5: Vector2i(1, 2),
	7: Vector2i(8, 3),
	16: Vector2i(0, 0),
	17: Vector2i(0, 1),
	20: Vector2i(1, 0),
	21: Vector2i(1, 1),
	23 : Vector2i(4, 2),
	28: Vector2i(8, 0),
	29: Vector2i(4, 1),
	31: Vector2i(8, 1),
	64: Vector2i(3, 3),
	65: Vector2i(3, 2),
	68: Vector2i(2, 3),
	69: Vector2i(2, 2),
	71 : Vector2i(5, 3),
	80: Vector2i(3, 0),
	81: Vector2i(3, 1),
	84: Vector2i(2, 0),
	85: Vector2i(2, 1),
	87: Vector2i(7, 0),
	92: Vector2i(5, 0),
	93: Vector2i(7, 3),
	95: Vector2i(8, 2),
	112: Vector2i(11, 0),
	113: Vector2i(7, 1),
	116: Vector2i(6, 0),
	117: Vector2i(4, 3),
	119: Vector2i(9, 1),
	124: Vector2i(10, 0),
	125: Vector2i(9, 0),
	127: Vector2i(5, 1),
	193: Vector2i(11, 3),
	197: Vector2i(6, 3),
	199: Vector2i(9, 3),
	209: Vector2i(7, 2),
	213: Vector2i(4, 0),
	215: Vector2i(10, 3),
	221: Vector2i(10, 2),
	223: Vector2i(5, 2),
	241: Vector2i(11, 2),
	245: Vector2i(11, 1),
	247: Vector2i(6, 2),
	253: Vector2i(6, 1),
	255: Vector2i(9, 2)
}

var frame_counter : int = 0
var camera : Camera2D

# Built-in

func _init() -> void:
	for tile : Tile in common_rock_layer: rock_layer_rarity[tile] = "common"
	for tile : Tile  in uncommon_rock_layer: rock_layer_rarity[tile] = "uncommon"
	for tile : Tile  in rare_rock_layer: rock_layer_rarity[tile] = "rare"
	for rock_layer_tile : Tile  in rock_layers: rock_layer_atlas_coords.append(rock_layer_tile.atlas_coord)

#func _ready() -> void:
	#var shader_mat = material as ShaderMaterial
	#shader_mat.set_shader_parameter("tile_texture", tile_set.get_texture())
	#shader_mat.set_shader_parameter("inv_t", preload("res://icon.svg"))
	#shader_mat.set_shader_parameter("color_space_vector1", Vector3(1.0, 0.0, 0.0))
	#assert (player != null, "Tilemap : le joueur ne DOIT PAS être null")
	#Utility.print_tile_key_visualizer()
	
func _draw() -> void:
	if draw_chunk_borders:
		for chunk_pos : Vector2i in loaded_chunks:
			draw_rect(Rect2(Vector2i(chunk_pos) * CELL_SIZE * CHUNK_SIZE, CHUNK_SIZE * CELL_SIZE), Color(1, 0, 0, 0.5), false, -1)

func _process(_delta : float) -> void:
	update_loaded_chunks()
	#frame_counter += 1
	#if camera and frame_counter % 60 == 0:
		#render_visible_chunks(Camera.get_camera_extended_rect(camera.get_global_camera_viewport_rect()))
	#
	
# Render visible chunks
					
func render_visible_chunks(camera_rect: Rect2) -> void:
	var top_left : Vector2 = local_to_map(camera_rect.position)
	var bottom_right : Vector2 = local_to_map(camera_rect.position + camera_rect.size)

	var chunk_start : Vector2i = get_chunk_key(top_left)
	var chunk_end : Vector2i = get_chunk_key(bottom_right)

	for x : int in range(chunk_start.x, chunk_end.x + 1):
		for y : int in range(chunk_start.y, chunk_end.y + 1):
			var chunk_key : Vector2i = Vector2i(x, y)
			# Il faut s'assurer que le chunk est load à 100% avant de l'afficher
			if chunk_keys.has(chunk_key) and not rendered_chunks.has(chunk_key) and loaded_chunks.has(chunk_key):
				render_chunk(chunk_key)	

func render_chunk(chunk_key : Vector2i) -> void:
	rendered_chunks[chunk_key] = true

	# set all cells in the chunk
	var top_left : Vector2i = Vector2i(chunk_key.x * CHUNK_SIZE.x, chunk_key.y * CHUNK_SIZE.y)
	for x : int in range(CHUNK_SIZE.x):
		for y : int in range(CHUNK_SIZE.y):
			var pos : Vector2i = Vector2i(top_left.x + x, top_left.y + y)
			if chunk_keys[chunk_key].has(pos):
				set_cell_terrain(pos, chunk_key)

	
# SetCellTerrainConnect / Key	
	
func set_cell_terrain(pos : Vector2i, chunk_key : Vector2i):
	var atlas_coord : Vector2i = chunk_keys[chunk_key][pos]
	var tile : Tile = get_tile_by_atlas_coord(atlas_coord)
	if tile.terrain_id != -1:
		var neighbor_tiles : Array = neighbor_tiles([],atlas_coord, pos)
		if neighbor_tiles.size() < 8: # Pas besoin de changer le terrain si la tuile a tout ses voisins
			var connect_key : int = get_connect_key(pos, atlas_coord)
			var key_offset : Vector2i = get_tile_from_key(connect_key, atlas_coord)
			if key_offset!=TILES.air.atlas_coord:
				if tile.layer == 0:
					set_cell(pos, 0, atlas_coord + key_offset - Vector2i(9, 2)) # offset car j'ai défini les atlas coord de mes tiles comme étant des tiles pleines, ce qui correspond à 9,2
				elif tile.layer == 2:
					ore_tilemap.set_cell(pos, 0, atlas_coord + key_offset - Vector2i(9, 2)) # offset car j'ai défini les atlas coord de mes tiles comme étant des tiles pleines, ce qui correspond à 9,2

		else:
			if tile.layer == 0: set_cell(pos, 0, chunk_keys[chunk_key][pos])
			elif tile.layer == 2: ore_tilemap.set_cell(pos, 0, chunk_keys[chunk_key][pos])
	else:
		if tile.layer == 0: set_cell(pos, 0, chunk_keys[chunk_key][pos])
		elif tile.layer == 1: leaf_tilemap.set_cell(pos, 0, chunk_keys[chunk_key][pos])
		elif tile.layer == 3: water_tilemap.set_cell(pos, 0, chunk_keys[chunk_key][pos])	
func get_connect_key(pos: Vector2i, atlas_coord: Vector2i) -> int:
	var side_bits : Array[int] = [0, 2, 4, 6]  # Index des directions cardinales
	var key : int = 0
	var offsets : Array[Vector2i]= [
		Vector2i(0, -1),   # 0 (haut)
		Vector2i(1, -1),   # 1 (haut-droit)
		Vector2i(1,  0),   # 2 (droite)
		Vector2i(1,  1),   # 3 (bas-droit)
		Vector2i(0,  1),   # 4 (bas)
		Vector2i(-1, 1),   # 5 (bas-gauche)
		Vector2i(-1, 0),   # 6 (gauche)
		Vector2i(-1, -1)   # 7 (haut-gauche)
	]
	# Vérifie les directions cardinales
	for i : int in side_bits: if is_same_tile(pos + offsets[i], atlas_coord): key |= (1 << i)

	# Vérifie les coins seulement si les deux côtés adjacents sont présents
	# coin haut-droit (1) si 0 (haut) et 2 (droite) sont présents
	if ((key & (1 << 0)) and (key & (1 << 2))): if is_same_tile(pos + offsets[1], atlas_coord): key |= (1 << 1)

	# coin bas-droit (3) si 2 (droite) et 4 (bas) sont présents
	if ((key & (1 << 2)) and (key & (1 << 4))): if is_same_tile(pos + offsets[3], atlas_coord): key |= (1 << 3)

	# coin bas-gauche (5) si 4 (bas) et 6 (gauche) sont présents
	if ((key & (1 << 4)) and (key & (1 << 6))): if is_same_tile(pos + offsets[5], atlas_coord): key |= (1 << 5)

	# coin haut-gauche (7) si 6 (gauche) et 0 (haut) sont présents
	if ((key & (1 << 6)) and (key & (1 << 0))): if is_same_tile(pos + offsets[7], atlas_coord): key |= (1 << 7)
	return key

func is_same_tile(pos: Vector2i, atlas_coord: Vector2i) -> bool:
	var chunk_key : Vector2i = get_chunk_key(pos)
	return chunk_keys.has(chunk_key) and chunk_keys[chunk_key].has(pos) and chunk_keys[chunk_key][pos] == atlas_coord

func get_tile_from_key(key: int, atlas_coord : Vector2i) -> Vector2i:
	assert (TILE_LOOKUP_TABLE.has(key), str(atlas_coord))
	return TILE_LOOKUP_TABLE[key]


# Load / Unload chunks
var chunks_to_load : Array[Vector2i] = []
var max_chunks_load_per_frame : int = 3
var center_chunk_i : Vector2i

func update_loaded_chunks(render_distance_ : int = render_distance) -> void:
	center_chunk_i  = ((player.position / CELL_SIZE) / Vector2(CHUNK_SIZE)).floor()
	var new_loaded_chunks : Array[Vector2i] = []
	
	# On remplit la liste des chunks à charger, triés par distance
	chunks_to_load.clear()

	for x : int  in range(center_chunk_i.x - render_distance_, center_chunk_i.x + render_distance_ + 1):
		for y : int in range(center_chunk_i.y - render_distance_, center_chunk_i.y + render_distance_ + 1):
			var chunk_key : Vector2i = Vector2i(x, y)
			new_loaded_chunks.append(chunk_key)
			if not is_chunk_loaded(chunk_key):
				chunks_to_load.append(chunk_key)
				queue_redraw()
				
	# Trie chunks_to_load par distance au joueur (ordre croissant)
	chunks_to_load.sort_custom(_should_swap)

	# Charge un nombre limité de chunks par frame
	var load_count = 0
	while load_count < max_chunks_load_per_frame and chunks_to_load.size() > 0:
		var chunk_key = chunks_to_load.pop_front()
		load_chunk(chunk_key)
		loaded_chunks.append(chunk_key)
		load_count += 1		
				
	for old_chunk : Vector2i in loaded_chunks.duplicate():
		if not old_chunk in new_loaded_chunks:
			var dx : int = abs(old_chunk.x - center_chunk_i.x)
			var dy : int = abs(old_chunk.y - center_chunk_i.y)
			
			# Décharge uniquement si le chunk est loin du joueur
			if dx > render_distance_ + unload_margin or dy > render_distance_ + unload_margin:
				dechunk(old_chunk)
				loaded_chunks.erase(old_chunk)
	
func is_chunk_loaded(chunk_key: Vector2i) -> bool:
	return chunk_key in loaded_chunks

func _should_swap(a: Vector2i, b: Vector2i) -> bool:
	var dist_a = a.distance_to(center_chunk_i)
	var dist_b = b.distance_to(center_chunk_i)
	return dist_a < dist_b  # true si a est plus loin que b, donc on échange pour mettre le plus proche devant

func load_chunk_background_overlay(instance_path : String, chunk_key : Vector2i) -> void:
	var instance : Sprite2D = load(instance_path).instantiate()
	instance.global_position = map_to_local(to_local(chunk_key * CHUNK_SIZE)) - (Vector2i(CELL_SIZE, CELL_SIZE) / 2.0)
	instance.texture.width = CHUNK_SIZE.x * CELL_SIZE
	instance.texture.height = CHUNK_SIZE.y * CELL_SIZE
	add_child(instance)
	background_overlays[chunk_key] = instance
			
func load_chunk(chunk_key : Vector2i) -> void:
	if !chunk_key in chunk_keys:
		#pass
		##for coord : Vector2i in chunk_keys[chunk_key]:
			##set_cell(coord, 0, chunk_keys[chunk_key][coord])
	## Si le chunk n'a jamais été chargé par le passé
	#else:	
		var common_ores : Array[Vector2i] = []
		var uncommon_ores : Array[Vector2i] = []
		var rare_ores : Array[Vector2i] = []
		chunk_keys[chunk_key] = {}
		var top_left : Vector2i = Vector2i(chunk_key.x * CHUNK_SIZE.x, chunk_key.y * CHUNK_SIZE.y)
		var compteur : int = 0
		for x : int in range(CHUNK_SIZE.x):
			for y : int in range(CHUNK_SIZE.y):
				compteur+=1
				if ((compteur)%16==0):
					await get_tree().process_frame

				var coord : Vector2i = top_left + Vector2i(x, y)
				var tile : Tile = ProceduralGen._generate_tile(coord)
				if tile != TILES.air:
					#set_cell(coord, 0, tile.atlas_coord)
					chunk_keys[chunk_key][coord] = tile.atlas_coord
					
					# Minerais
					match rock_layer_rarity.get(tile, null):
						"common": if randi_range(0, 250) == 1: common_ores.append(coord)
						"uncommon": if randi_range(0, 500) == 1: uncommon_ores.append(coord)
						"rare": if randi_range(0, 10000) == 1: rare_ores.append(coord)

					# Assigner la tile au dessus si elle existe dans le dictionnaire
					# Cette méthode peut générer ou non une décoration sur les bordures d'un chunk celon le côté par lequel on l'explore 
					var atlas_tile_above : Vector2i = TILES.air.atlas_coord
					var tile_coord_above : Vector2i = coord + Vector2i(0, -1)
					var chunk_key_above : Vector2i = get_chunk_key(tile_coord_above)
					var is_tile_in_chunk : bool = (chunk_key_above == chunk_key)
					
					if chunk_keys.has(chunk_key_above) and chunk_keys[chunk_key_above].has(tile_coord_above):
						atlas_tile_above = chunk_keys[chunk_key_above][coord + Vector2i(0, -1)]
						
					var tile_above_is_air : bool = (atlas_tile_above == TILES.air.atlas_coord)
					if tile == TILES.sand:
						if tile_above_is_air:
							match randi_range(0, 10):
								1: decorate(coord, chunk_key_above, 0, 1, TILES.cactus.atlas_coord)
								2: decorate(coord, chunk_key_above, 0, 1, TILES.dead_bush.atlas_coord)
								3: decorate(coord, chunk_key_above, 0, 1, TILES.sugar_cane.atlas_coord)
								
						elif atlas_tile_above == TILES.water.atlas_coord:
							var chance : int = randi_range(0, 100)
							if chance < 60: pass
							elif chance < 75: decorate(coord, chunk_key_above, 0, 1, TILES.coral.atlas_coord)
							elif chance < 85: decorate(coord, chunk_key_above, 0, 1, TILES.glowing_seaweed.atlas_coord)
							elif chance < 95: decorate(coord, chunk_key_above, 0, 1, TILES.seashell.atlas_coord)
							elif chance == 99: decorate(coord, chunk_key_above, 0, 1, TILES.chest.atlas_coord)

					elif tile == TILES.snow:
						if tile_above_is_air:
							match randi_range(0, 10):
								1: decorate(coord, chunk_key_above, 0, 1, TILES.pine_tree.atlas_coord)
								2:decorate(coord, chunk_key_above, 0, 1, TILES.dark_pine_tree.atlas_coord)
								3: decorate(coord, chunk_key_above, 0, 1, TILES.cool_rock.atlas_coord)
								4: decorate(coord, chunk_key_above, 0, 1, TILES.coal_rock.atlas_coord)
								5:generate_tree(coord - Vector2i(0, 1), TILES.log, TILES.leaf, is_tile_in_chunk, TreeType.PINE)
								6:generate_tree(coord - Vector2i(0, 1), TILES.pine_log, TILES.pine_leaf, is_tile_in_chunk, TreeType.DARK_PINE)
								
					
					elif tile == TILES.grass:
						if tile_above_is_air:
							match randi_range(0, 2):
								0:decorate(coord, chunk_key_above, 0, 1, TILES.tree.atlas_coord)
								1: generate_tree(coord - Vector2i(0, 1), TILES.log, TILES.leaf, is_tile_in_chunk, TreeType.OAK)
								2: decorate(coord, chunk_key_above, 0, 1, TILES.blooming_tree.atlas_coord)
								3: decorate(coord, chunk_key_above, 0, 1, TILES.shroom_tree.atlas_coord)
								4: decorate(coord, chunk_key_above, 0, 1, TILES.blooming_shroom_tree.atlas_coord)
								5: decorate(coord, chunk_key_above, 0, 1, TILES.rock.atlas_coord)
								6: decorate(coord, chunk_key_above, 0, 1, TILES.cool_rock.atlas_coord)
								7: decorate(coord, chunk_key_above, 0, 1, TILES.coal_rock.atlas_coord)
								
					elif tile == TILES.red_grass:
						if tile_above_is_air:
							match randi_range(0, 10):
								1: generate_tree(coord - Vector2i(0, 1), TILES.red_log, TILES.red_leaf, is_tile_in_chunk, TreeType.RED)#decorate(coord, chunk_key, 0, 1, TILES.red_tree.atlas_coord)
								2: decorate(coord, chunk_key_above, 0, 1, TILES.blooming_red_tree.atlas_coord)
								3: decorate(coord, chunk_key_above, 0, 1, TILES.shroom_red_tree.atlas_coord)
								4: decorate(coord, chunk_key_above, 0, 1, TILES.blooming_shroom_red_tree.atlas_coord)
								5: decorate(coord, chunk_key_above, 0, 1, TILES.rock.atlas_coord)
								6: decorate(coord, chunk_key_above, 0, 1, TILES.cool_rock.atlas_coord)
								7: decorate(coord, chunk_key_above, 0, 1, TILES.coal_rock.atlas_coord)
								
					elif tile == TILES.autumn_grass:
						if tile_above_is_air:
							match randi_range(0, 10):
								1: generate_tree(coord - Vector2i(0, 1), TILES.autumn_log, TILES.autumn_leaf, is_tile_in_chunk, TreeType.AUTUMN)#decorate(coord, chunk_key, 0, 1, TILES.autumn_tree.atlas_coord)
								2: decorate(coord, chunk_key_above, 0, 1, TILES.fallen_autumn_tree.atlas_coord)
								3: decorate(coord, chunk_key_above, 0, 1, TILES.shroom_autumn_tree.atlas_coord)
								4: decorate(coord, chunk_key_above, 0, 1, TILES.blooming_shroom_autumn_tree.atlas_coord)
								5: decorate(coord, chunk_key_above, 0, 1, TILES.rock.atlas_coord)
								6: decorate(coord, chunk_key_above, 0, 1, TILES.cool_rock.atlas_coord)
								7: decorate(coord, chunk_key_above, 0, 1, TILES.coal_rock.atlas_coord)

					elif tile == TILES.sakura_grass:
						if tile_above_is_air:
							match randi_range(0, 10):
								1: generate_tree(coord - Vector2i(0, 1), TILES.sakura_log, TILES.sakura_leaf, is_tile_in_chunk, TreeType.SAKURA)#decorate(coord, chunk_key, 0, 1, TILES.sakura_tree.atlas_coord)
								2: decorate(coord, chunk_key_above, 0, 1, TILES.blooming_sakura_tree.atlas_coord)
								3: decorate(coord, chunk_key_above, 0, 1, TILES.shroom_sakura_tree.atlas_coord)
								4: decorate(coord, chunk_key_above, 0, 1, TILES.blooming_shroom_sakura_tree.atlas_coord)
								5: decorate(coord, chunk_key_above, 0, 1, TILES.rock.atlas_coord)
								6: decorate(coord, chunk_key_above, 0, 1, TILES.cool_rock.atlas_coord)
								7: decorate(coord, chunk_key_above, 0, 1, TILES.coal_rock.atlas_coord)
		
					elif tile == TILES.water:
						if tile_above_is_air: decorate(coord, chunk_key, 0, 0, TILES.water_top.atlas_coord)
						elif randi_range(0, 50) == 0: decorate(coord, chunk_key, 0, 0, TILES.water_variation.atlas_coord)
							
		if !common_ores.is_empty(): generate_ores_group(common_ores, common_ores_list, rock_layer_atlas_coords, 5, 15, "common")
		if !uncommon_ores.is_empty(): generate_ores_group(uncommon_ores, uncommon_ores_list, rock_layer_atlas_coords, 3, 12, "uncommon")
		if !rare_ores.is_empty(): generate_ores_group(rare_ores, rare_ores_list, rock_layer_atlas_coords, 1, 7, "rare")

	if pending_generation.has(chunk_key):
		for item in pending_generation[chunk_key]:
			var coord : Vector2i = item["coord"]
			if !chunk_keys[chunk_key].has(coord) or (chunk_keys[chunk_key].has(coord) and chunk_keys[chunk_key][coord] == TILES.air.atlas_coord):
				chunk_keys[chunk_key][item["coord"]] = item["atlas_coord"]
		pending_generation.erase(chunk_key)

	if pending_structures.has(chunk_key):
		for item in pending_structures[chunk_key]:
			if item["type"] in TreeType:
				var coord : Vector2i = item["coord"]
				if !chunk_keys[chunk_key].has(coord) or (chunk_keys[chunk_key].has(coord) and chunk_keys[chunk_key][coord] == TILES.air.atlas_coord):
					cpt_tree+=1
					print(cpt_tree)
					generate_tree(coord, TILES.log, TILES.leaf, true, item["type"])
		pending_structures.erase(chunk_key)

	render_chunk(chunk_key)
	
var cpt_tree = 0
func decorate(coord : Vector2i, chunk_key : Vector2i, offset_x : int, offset_y : int, atlas_coords : Vector2i) -> void:
	generate_structure_tile(coord - Vector2i(offset_x, offset_y), atlas_coords)
	##set_cell(coord - Vector2i(offset_x, offset_y), 0, atlas_coords)
	##chunk_keys[chunk_key][coord - Vector2i(offset_x, offset_y)] = atlas_coords
	
func dechunk(chunk_key : Vector2i) -> void:
	queue_redraw() #redessine les bordures des chunks
	for coord : Vector2i in chunk_keys[chunk_key]:
		set_cell(coord, 0, TILES.air.atlas_coord)
		leaf_tilemap.set_cell(coord, 0, TILES.air.atlas_coord)
		ore_tilemap.set_cell(coord, 0, TILES.air.atlas_coord)
		water_tilemap.set_cell(coord, 0, TILES.air.atlas_coord)
		
	if background_overlays.has(chunk_key):
		background_overlays[chunk_key].queue_free()
		background_overlays.erase(chunk_key)
	
	if rendered_chunks.has(chunk_key):
		rendered_chunks.erase(chunk_key)


# Utility

func get_tile_by_atlas_coord(atlas_coord : Vector2i) -> Tile:
	for tile : Tile in TILES.values():
		if tile.atlas_coord == atlas_coord:
			return tile
	return null
	
func get_atlas_coord_from_cell(cell : Vector2i) -> Vector2i:
	var chunk_key : Vector2i = get_chunk_key(cell)
	if chunk_keys.has(chunk_key) and chunk_keys[chunk_key].has(cell):
		return chunk_keys[chunk_key][cell]
	return TILES.air.atlas_coord
	
func get_chunk_key(cell: Vector2) -> Vector2i:
	var chunk_x : int = floori(cell.x / CHUNK_SIZE.x)
	var chunk_y : int = floori(cell.y / CHUNK_SIZE.y)
	return Vector2i(chunk_x, chunk_y)


# Generate
enum TreeType { OAK, PINE, DARK_PINE, RED, AUTUMN, SAKURA }
func generate_tree(coord: Vector2i, log_tile: Tile, leaf_tile : Tile, is_tile_in_chunk, tree_type : TreeType) -> void:
	var chunk_key : Vector2i = get_chunk_key(coord)
	if (!is_tile_in_chunk or !chunk_keys.has(chunk_key)):# or !is_chunk_loaded(chunk_key):
		if not pending_structures.has(chunk_key):
			pending_structures[chunk_key] = []
		pending_structures[chunk_key].append({
			"type": tree_type,
			"coord": coord
		})
	else:
		var is_mini_variant = randi() % 6 == 0  # ~16% de chance
		if is_mini_variant:
			var log_size : int = int(floor(sqrt(randi_range(0, 8 * 8 - 1)))) + 1

			for i in range(log_size): generate_structure_tile(coord - Vector2i(0, i), log_tile.atlas_coord)

			var top : Vector2i = coord - Vector2i(0, log_size)
			generate_structure_tile(top + Vector2i(0, -1), leaf_tile.atlas_coord)
			generate_structure_tile(top + Vector2i(-1, 0), leaf_tile.atlas_coord)
			generate_structure_tile(top + Vector2i(0, 0), leaf_tile.atlas_coord)
			generate_structure_tile(top + Vector2i(1, 0), leaf_tile.atlas_coord)
			return		
		
		
		if tree_type == TreeType.OAK or tree_type == TreeType.RED or tree_type == TreeType.AUTUMN:
			#une chance sur deux de générer ça, une chance sur deux de générer un autre type d'arbre
			var log_height: int = randi_range(4, 6)

			# Tronc
			for i in range(log_height): generate_structure_tile(coord - Vector2i(0, i), log_tile.atlas_coord)

			var leaf_center : Vector2i = coord - Vector2i(0, log_height)
			for y in range(-2, 1):  # Évite les feuilles sous le sommet
				for x in range(-2, 3):
					var offset = Vector2i(x, y)
					if abs(x) + abs(y) <= 2 and offset != Vector2i(0, 0):
						generate_structure_tile(leaf_center + offset, leaf_tile.atlas_coord)

			generate_structure_tile(leaf_center, leaf_tile.atlas_coord)
			
			if tree_type == TreeType.AUTUMN:
				# Feuilles retombantes pour le style
				for dx in [-1, 0, 1]:
					for dy in [1]:
						var pos = leaf_center + Vector2i(dx, dy)
						if randi() % 2 == 0:
							generate_structure_tile(pos, leaf_tile.atlas_coord)
		elif tree_type == TreeType.SAKURA:
			var log_height: int = randi_range(3, 5)
			var trunk_bend = randi() % 2 == 0

			# Tronc légèrement incliné ou tordu
			for i in range(log_height):
				var offset = Vector2i(i % 2 if trunk_bend else 0, -i)
				generate_structure_tile(coord + offset, log_tile.atlas_coord)

			var leaf_center = coord + Vector2i((log_height - 1) % 2 if trunk_bend else 0, -log_height)

			# Feuillage en nuages asymétriques
			var leaf_offsets = [
				Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, 0),
				Vector2i(0, -1), Vector2i(1, -1),
				Vector2i(-2, 1), Vector2i(2, 1),
				Vector2i(0, 1), Vector2i(0, 2)
			]
			for offset in leaf_offsets:
				if abs(offset.x) + abs(offset.y) <= 2:  # Pas de feuille isolée
					if randi() % 3 != 0:
						generate_structure_tile(leaf_center + offset, leaf_tile.atlas_coord)


		elif tree_type == TreeType.PINE or tree_type == TreeType.DARK_PINE:
			var variant = randi() % 2
			var log_height: int = randi_range(5, 8)

			# Tronc droit
			for i in range(log_height):
				generate_structure_tile(coord - Vector2i(0, i), log_tile.atlas_coord)

			var top = coord - Vector2i(0, log_height)

			if true:# variant == 0:
				var leaf_layers = 5  # Nombre d'étages
				var max_radius = 5   # Rayon du plus grand étage
				var gap = 1          # Espacement entre les étages (1 tile)

				# Position du sommet du tronc
				var trunk_top = coord - Vector2i(0, log_height)

				# Flèche du haut
				generate_structure_tile(trunk_top, leaf_tile.atlas_coord)

				# Feuilles en couches descendantes
				for i in range(leaf_layers):
					var radius = max_radius - i  # plus petit en montant
					var y_offset = 2 + i * (gap + 1)  # démarre plus bas sous la flèche

					# Centre de la couche
					var layer_center = trunk_top + Vector2i(0, 3-y_offset)

					for x in range(-radius, radius + 1):
						for y in range(1, radius + 1):
							if abs(x) + abs(y) <= radius:
								generate_structure_tile(layer_center + Vector2i(x, -y), leaf_tile.atlas_coord)

			else:
				for i in range(3):
					var layer_pos = top - Vector2i(0, i * 2)  # vers le bas
					for x in range(-2 + i, 3 - i):
						for y in range(-1, 2):
							if abs(x) + abs(y) <= 2 - i:
								generate_structure_tile(layer_pos + Vector2i(x, y), leaf_tile.atlas_coord)

				# Flèche du haut (au sommet du tronc)
				generate_structure_tile(top, leaf_tile.atlas_coord)


			
func generate_structure_tile(coord : Vector2i, atlas_coord : Vector2i):
	var chunk_key = get_chunk_key(coord)
	if chunk_keys.has(chunk_key):
		# Chunk généré → on pose directement
		chunk_keys[chunk_key][coord] = atlas_coord
	else:
		# Chunk pas généré → on sauvegarde pour plus tard
		if not pending_generation.has(chunk_key):
			pending_generation[chunk_key] = []
		pending_generation[chunk_key].append({
			"coord": coord,
			"atlas_coord": atlas_coord
		})

func generate_ores_group(ore_coords : Array[Vector2i], ore_list : Array[Tile], propagation_tile_atlas_coords : Array[Vector2i], min_vein_size: int, max_vein_size: int, label: String) -> void:
	for coord : Vector2i in ore_coords:
		var ore_type : Tile = ore_list[randi() % ore_list.size()]
		var atlas_coord : Vector2i = get_atlas_coord_from_cell(coord)#  get_cell_atlas_coords(coord)
		var found : bool = false
		for rock_layer_atlas_coord : Vector2i in propagation_tile_atlas_coords:
			if atlas_coord == rock_layer_atlas_coord:
				found = true
				generate_ore_vein(coord, ore_type.atlas_coord, propagation_tile_atlas_coords, min_vein_size, max_vein_size)
				break
		if !found:
			print("fail %s : %s" % [label, str(TILES.get(atlas_coord, "inconnu"))])
	
func generate_ore_vein(start_coord : Vector2i, ore_tile: Vector2i, propagation_tiles: Array[Vector2i], min_range : int, max_range : int) -> void:
	var visited : Dictionary = {}
	var to_visit : Array[Vector2i] = [start_coord]
	var ore_count : int = 0
	var max_vein_size : int = randi_range(min_range, max_range)

	while to_visit.size() > 0 and ore_count < max_vein_size:
		var coord: Vector2i = to_visit.pop_back()
		if visited.has(coord):
			continue
		visited[coord] = true

		var found : bool = false
		var atlas_coords : Vector2i = get_atlas_coord_from_cell(coord)
		for atlas_tile : Vector2i in propagation_tiles:
			if atlas_tile == atlas_coords:
				found = true
				break

		if found:
			chunk_keys[get_chunk_key(coord)][coord] = ore_tile
			#ore_tilemap.set_cell(coord, 0, ore_tile)
			ore_count += 1

			var directions : Array[Vector2i] = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
			directions.shuffle()  # Mélange aléatoire à chaque itération

			for direction : Vector2i in directions:
				var neighbor : Vector2i = coord + direction
				if !visited.has(neighbor) and get_atlas_coord_from_cell(neighbor) in propagation_tiles:
					to_visit.append(neighbor)
	
	
# Place / Destroy Blocks

func neighbor_tiles(tiles: Array, atlas_coord : Vector2i, cell : Vector2i) -> Array:
	var directions : Array[Vector2i]= [
		Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), # cardinales
		Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1) # diagonales
	]
	for dir : Vector2i in directions:
		var neighbor : Vector2i = cell + dir
		var neighbor_chunk_key : Vector2i = get_chunk_key(neighbor)
		if chunk_keys.has(neighbor_chunk_key) and chunk_keys[neighbor_chunk_key].has(neighbor):
			if chunk_keys[neighbor_chunk_key][neighbor] == atlas_coord:
				tiles.append(neighbor)
	return tiles

func neighbor_tiles_grouped_by_terrain(cell: Vector2i) -> Dictionary:
	var directions : Array[Vector2i ] = [
		Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1),
		Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)
	]
	var grouped : Dictionary = {}
	for dir : Vector2i in directions:
		var neighbor : Vector2i  = cell + dir
		var chunk_key : Vector2i  = get_chunk_key(neighbor)
		if chunk_keys.has(chunk_key) and chunk_keys[chunk_key].has(neighbor):
			var neighbor_atlas_coord : Vector2i  = chunk_keys[chunk_key][neighbor]
			var tile : Tile = get_tile_by_atlas_coord(neighbor_atlas_coord)
			if tile.atlas_coord == neighbor_atlas_coord and tile.terrain_id != -1:
				if not grouped.has(tile.terrain_id):
					grouped[tile.terrain_id] = []
				grouped[tile.terrain_id].append(neighbor)
				set_cell(neighbor, 0, TILES.air.atlas_coord)
	return grouped

func place_block(coord : Vector2, tile : Tile) -> void:
	var cell: Vector2i = local_to_map(coord)
	var chunk_key : Vector2i = get_chunk_key(cell)
	if !chunk_keys.has(chunk_key): return
	chunk_keys[chunk_key][cell] = tile.atlas_coord
	
	for n_cell in neighbor_tiles([cell], tile.atlas_coord, cell):
		var n_chunk_key : Vector2i = get_chunk_key(n_cell)
		set_cell_terrain(n_cell, n_chunk_key)
	#set_cells_terrain_connect(neighbor_tiles([cell],tile.atlas_coord, cell), 0, tile.terrain_id)
	if tile.terrain_id == -1: set_cell(cell, 0, tile.atlas_coord)

func handle_block_destruction(cell : Vector2i, chunk_key : Vector2i, old_tile : Vector2i) -> void:
	chunk_keys[chunk_key][cell] = TILES.air.atlas_coord
	set_cell(cell, 0, TILES.air.atlas_coord)
	ore_tilemap.set_cell(cell, 0, TILES.air.atlas_coord)
	leaf_tilemap.set_cell(cell, 0, TILES.air.atlas_coord)
	player.play_destroy_blocks_sound()
	# Particules
	#var particle : CPUParticles2D = destroy_particule_effect_path.instantiate()
	#particle.position = coord + Vector2(8, 8)
	#add_child(particle)
	for tile_name in TILES:
		var tile = TILES[tile_name]
		if tile.atlas_coord == old_tile:
			var dropped_item = DroppedItem.instantiate_dropped_item(load("res://inventory/resources/" + tile_name + ".tres"))
			dropped_item.global_position = cell * CELL_SIZE + Vector2i(CELL_SIZE / 4, CELL_SIZE / 4)
			add_child(dropped_item)

			#var grass_block_item = DroppedItem.instantiate_dropped_item(preload("res://inventory/resources/grass_block.tres"))
			#grass_block_item.global_position = cell * CELL_SIZE + Vector2i(CELL_SIZE / 4, CELL_SIZE / 4)
			#add_child(grass_block_item)
			
			
			
			
			
			
			
func destroy_block(coord: Vector2) -> void:
	var cell : Vector2i = local_to_map(coord)
	var chunk_key : Vector2i = get_chunk_key(cell)
	if !chunk_keys.has(chunk_key): return
	var old_tile : Vector2i = TILES.air.atlas_coord
	if chunk_keys.has(chunk_key) and chunk_keys[chunk_key].has(cell): old_tile = chunk_keys[chunk_key][cell]
		
	if old_tile != TILES.air.atlas_coord:
		handle_block_destruction(cell, chunk_key, old_tile)

		var grouped_neighbors : Dictionary = neighbor_tiles_grouped_by_terrain(cell)
		for terrain_id : int in grouped_neighbors:
			var n_cells : Array = grouped_neighbors[terrain_id]
			for n_cell in n_cells:	
				#set_cells_terrain_connect(cells, 0, terrain_id)
				set_cell_terrain(n_cell, get_chunk_key(n_cell))

func destroy_blocks(coords: Array[Vector2]) -> void:
	var terrain_updates : Dictionary = {}  # terrain_id -> Dictionary acting as Set
	var destroyed_cells : Array[Vector2i] = []

	# --- 1ère passe : Supprimer tous les blocs ---
	for coord in coords:
		var cell : Vector2i = local_to_map(coord)
		var chunk_key : Vector2i = get_chunk_key(cell)
		if chunk_keys.has(chunk_key):
			var old_tile : Vector2i = TILES.air.atlas_coord
			if chunk_keys[chunk_key].has(cell):
				old_tile = chunk_keys[chunk_key][cell]

			if old_tile != TILES.air.atlas_coord:
				# Suppression
				handle_block_destruction(cell, chunk_key, old_tile)
				destroyed_cells.append(cell)

	# --- 2ème passe : Trouver les voisins à mettre à jour ---
	for cell in destroyed_cells:
		#var neighbors : Array = neighbor_tiles([], atlas_coord)
		var grouped_neighbors : Dictionary = neighbor_tiles_grouped_by_terrain(cell)

		for terrain_id : int in grouped_neighbors.keys():
			if not terrain_updates.has(terrain_id):
				terrain_updates[terrain_id] = {}

			for neighbor_cell in grouped_neighbors[terrain_id]:
				var chunk_key = get_chunk_key(neighbor_cell)
				if chunk_keys.has(chunk_key) and chunk_keys[chunk_key].has(neighbor_cell):
					if chunk_keys[chunk_key][neighbor_cell] != TILES.air.atlas_coord:
						terrain_updates[terrain_id][neighbor_cell] = true

	# --- Application finale des connexions terrain ---
	for terrain_id : int in terrain_updates.keys():
		var cell_array = terrain_updates[terrain_id].keys()
		for cell in cell_array:
			var chunk_key : Vector2i = get_chunk_key(cell)
			set_cell_terrain(cell, chunk_key)
