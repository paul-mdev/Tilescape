extends Node

class_name DataManager

## -------------------------------- DataManager --------------------------------


# -- Abstract -- #
static func save_data(data: Dictionary, path: String) -> void:
	var file : FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_var(data)
	file.close()

static func load_data(path: String) -> Dictionary:
	if FileAccess.file_exists(path):
		var file : FileAccess = FileAccess.open(path, FileAccess.READ)
		var data : Dictionary = file.get_var()
		file.close()
		return data
	else:
		print("Aucun fichier trouvé à :", path)
		return {}



# -- Options -- #

static var options : Dictionary = {
	"audio": {
		"master": 10,
		"sound": 5,
		"music": 5
	},
	"video": {
		"fullscreen": true,
		"camera_zoom_type": 0,
		"render_distance": 2,
		"draw_chunk_borders" : true,
		"display_fps" : true,
		"display_coords" : true,
		"display_debug" : false,
	},
	"langage": {
		"current" :"fr",
	},
}


static func save_options(path : String = "user://options.cfg") -> void:
	print("save option")
	print(options)
	var config : ConfigFile = ConfigFile.new()
	for section in options.keys():
		for key in options[section].keys():
			config.set_value(section, key, options[section][key])
	config.save(path)


static func load_options(path : String = "user://options.cfg") -> void:
	print("load options")
	var config : ConfigFile = ConfigFile.new()
	if config.load(path) != OK:
		print("Fichier options.cfg introuvable, valeurs par défaut utilisées.")
		return
	
	for section in options.keys():
		for key in options[section].keys():
			if config.has_section_key(section, key):
				options[section][key] = config.get_value(section, key)

	print(options)
