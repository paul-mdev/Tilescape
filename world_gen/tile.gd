extends Item#Resource
class_name Tile

@export var atlas_coord : Vector2i
@export var terrain_id : int
@export_enum("Tilemap", "Leafs", "Ores", "Liquids")
var layer_type : String
var layer : int

func _init(atlas_coords_ : Vector2 = Vector2i.ZERO, terrain_id_ : int = -1, layer_ : int = 0, layer_type_ : String = "") -> void:
	self.atlas_coord = atlas_coords_
	self.terrain_id = terrain_id_
	self.layer_type = layer_type_
	if(layer_type_ == ""):
		self.layer = layer_
	else:
		if layer_type == "Tilemap": layer = 0
		elif layer_type == "Leafs": layer = 1
		elif layer_type == "Ores": layer = 2
		elif layer_type == "Liquids": layer = 3
