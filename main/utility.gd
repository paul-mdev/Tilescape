extends Node

class_name Utility

# Tilemap, la fonction custom set_cell_terrain utilise une clé binaire pour chaque atlas_coord
# Comme c'est compliqué à comprendre, on affiche les combinaisons avec ces 3 fonctions

static func print_tile_key_visualizer() -> void:
	for key in range(256):
		print("\nKey: ", key, " (", key_to_binary(key), ")")
		print(draw_key_as_ascii(key))

static func key_to_binary(key: int) -> String:
	return String.num_int64(key, 2).pad_zeros(8)

static func draw_key_as_ascii(key: int) -> String:
	var chars = []
	for i in range(8):
		if (key & (1 << i)) != 0:
			chars.append("#")
		else:
			chars.append(".")

	return "%s %s %s\n%s x %s\n%s %s %s" % [
		chars[7], chars[0], chars[1],
		chars[6], chars[2],
		chars[5], chars[4], chars[3]
	]	
	
	
