extends Item

class_name BlockItem
var atlas_coords : Vector2i


func _ready() -> void:
	var atlas : AtlasTexture = AtlasTexture.new()
	atlas.atlas = preload("res://sprites/autotile/autotile.png")
	var TILE_SIZE : Vector2i = Vector2i(Tiles.TILE_SIZE, Tiles.TILE_SIZE)
	atlas.region = Rect2i(atlas_coords * TILE_SIZE, TILE_SIZE)
	icon = atlas
