extends Item#Resource
class_name Tile

var atlas_coord : Vector2i
var terrain_id : int
var layer : int

func _init(atlas_coords_ : Vector2 = Vector2i.ZERO, terrain_id_ : int = -1, layer_ : int = 0) -> void:
	self.atlas_coord = atlas_coords_
	self.terrain_id = terrain_id_
	self.layer = layer_
