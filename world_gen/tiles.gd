extends Node

class_name Tiles
const TILE_SIZE : int = 16

static var TILES : Dictionary = {
	# tiles
	"grass": Tile.new(Vector2i(9, 2), 0),
	"dirt": Tile.new(Vector2i(9, 6), 1),
	"stone": Tile.new(Vector2i(9, 10), 2),
	"compact_stone": Tile.new(Vector2i(9, 14), 3),
	"white_stone": Tile.new(Vector2i(27, 2), -1),
	"sand": Tile.new(Vector2i(9, 18), 4),
	"sand_stone": Tile.new(Vector2i(9, 22), 5),
	#"snow": Tile.new(Vector2i(9, 26), 6),
	"snow": Tile.new(Vector2i(28, 0), -1),
	"ice": Tile.new(Vector2i(9, 30), 7),
	
	"autumn_grass": Tile.new(Vector2i(9, 34), 14),
	"red_grass": Tile.new(Vector2i(21, 34), 15),
	"sakura_grass": Tile.new(Vector2i(33, 34), 16),
	
	"log": Tile.new(Vector2i(24, 11), -1),
	"red_log": Tile.new(Vector2i(25, 11), -1),
	"autumn_log": Tile.new(Vector2i(26, 11), -1),
	"sakura_log": Tile.new(Vector2i(27, 11), -1),
	"pine_log": Tile.new(Vector2i(28, 11), -1),
	
	
	# leaf
	"leaf": Tile.new(Vector2i(24, 10), -1, 1),
	"red_leaf": Tile.new(Vector2i(25, 10), -1, 1),
	"autumn_leaf": Tile.new(Vector2i(26, 10), -1, 1),
	"sakura_leaf": Tile.new(Vector2i(27, 10), -1, 1),
	"pine_leaf": Tile.new(Vector2i(28, 10), -1, 1),
	

	# minerais
	"fuel": Tile.new(Vector2i(21, 2), 8, 2),
	"ore": Tile.new(Vector2i(21, 6), 9, 2),
	"gold": Tile.new(Vector2i(21, 10), 10, 2),
	"bloodstone": Tile.new(Vector2i(21, 14), 11, 2),
	"greencore": Tile.new(Vector2i(21, 18), 12, 2),
	"abyss_fuel": Tile.new(Vector2i(21, 22), 13, 2),
	
	"deepstone": Tile.new(Vector2i(29, 2), -1),
	"abyss": Tile.new(Vector2i(30, 2), -1),
	
	# décorations
	"rock": Tile.new(Vector2i(24, 3), -1),
	"cool_rock": Tile.new(Vector2i(25, 3), -1),
	"coal_rock": Tile.new(Vector2i(26, 3), -1),
	"chest": Tile.new(Vector2i(27, 3), -1),
	
	"tree": Tile.new(Vector2i(24, 4), -1),
	"blooming_tree": Tile.new(Vector2i(24, 5), -1),
	"shroom_tree": Tile.new(Vector2i(24, 6), -1),
	"blooming_shroom_tree": Tile.new(Vector2i(24, 7), -1),
	"blue_flowers": Tile.new(Vector2i(24, 8), -1),
	"blue_potted_flower": Tile.new(Vector2i(24, 9), -1),
	
	"red_tree": Tile.new(Vector2i(25, 4), -1),
	"blooming_red_tree": Tile.new(Vector2i(25, 5), -1),
	"shroom_red_tree": Tile.new(Vector2i(25, 6), -1),
	"blooming_shroom_red_tree": Tile.new(Vector2i(25, 7), -1),
	"red_flowers": Tile.new(Vector2i(25, 8), -1),
	"red_potted_flower": Tile.new(Vector2i(25, 9), -1),
	
	"autumn_tree": Tile.new(Vector2i(26, 4), -1),
	"fallen_autumn_tree": Tile.new(Vector2i(26, 5), -1),
	"shroom_autumn_tree": Tile.new(Vector2i(26, 6), -1),
	"blooming_shroom_autumn_tree": Tile.new(Vector2i(26, 7), -1),
	"yellow_flowers": Tile.new(Vector2i(26, 8), -1),
	"yellow_potted_flower": Tile.new(Vector2i(26, 9), -1),
	
	"sakura_tree": Tile.new(Vector2i(27, 4), -1),
	"blooming_sakura_tree": Tile.new(Vector2i(27, 5), -1),
	"shroom_sakura_tree": Tile.new(Vector2i(27, 6), -1),
	"blooming_shroom_sakura_tree": Tile.new(Vector2i(27, 7), -1),
	"sakura_flowers": Tile.new(Vector2i(27, 8), -1),
	"sakura_potted_tree": Tile.new(Vector2i(27, 9), -1),
	
	"pine_tree": Tile.new(Vector2i(28, 4), -1),
	"dark_pine_tree": Tile.new(Vector2i(29, 4), -1),
	
	"cactus": Tile.new(Vector2i(28, 5), -1),
	"dead_bush": Tile.new(Vector2i(29, 5), -1),
	"glowing_seaweed": Tile.new(Vector2i(28, 6), -1),
	"sugar_cane": Tile.new(Vector2i(29, 6), -1),
	"coral": Tile.new(Vector2i(28, 7), -1),
	"seashell": Tile.new(Vector2i(29, 7), -1),

	"cloud": Tile.new(Vector2i(30, 0), -1),
	"dark_cloud": Tile.new(Vector2i(31, 0), -1),
	
	"water_top": Tile.new(Vector2i(24, 0), -1, 3),
	"water_variation": Tile.new(Vector2i(25, 0), -1, 3),
	"water": Tile.new(Vector2i(26, 0), -1, 3),
	
	"air": Tile.new(Vector2i(-1, -1), -1),
	"solid": Tile.new(Vector2i(10, 1), -1),
}
