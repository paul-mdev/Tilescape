extends Node2D

class_name Main

@onready var canvas_layer : CanvasLayer = $CanvasLayer

const MENU : PackedScene = preload("res://ui/menu/menu-manager/menu-manager.tscn")
const WORLD : PackedScene = preload("res://world_gen/world.tscn")
var menu_instance : Control = null
var world_instance : World = null
var pause_menu : Control = null
func _init() -> void:
	ItemDatabase.initialise()
	load_options()
	VideoManager.set_screen_size(options["video"])
	AudioManager.set_audio_volume(options["audio"])
	
func _ready() -> void:
	go_to_menu()


## -------------------------------- SceneManager --------------------------------

func launch_world(world_data: Dictionary) -> void:
	print("launch world")
	world_instance = WORLD.instantiate()
	World.world_data = world_data #world_data est static
	add_child(world_instance)
	menu_instance.queue_free()
	menu_instance = null
	#canvas_layer.remove_child(menu_instance)

func launch_pause_menu(parent_node : Node) -> void:
	pause_menu = load("res://ui/menu/pause/pause.tscn").instantiate()
	pause_menu.parent_node = parent_node
	if parent_node is World:
		pause_menu.connect("options_changed", world_instance.options_changed)
	elif parent_node is MenuManager:
		pause_menu.connect("show_menu_content", parent_node.show_menu_content)
		parent_node.hide_menu_content()
	
	pause_menu.connect("save_and_quit", save_and_quit)
	canvas_layer.add_child(pause_menu)

func _input(event : InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		if pause_menu != null: pause_menu.close_pause_menu()
		elif world_instance!=null:launch_pause_menu(world_instance)

func save_and_quit() -> void:
	world_instance.save_and_quit()
	world_instance.queue_free()
	world_instance = null
	#remove_child(world_instance)
	go_to_menu()
	
func go_to_menu() -> void:
	menu_instance = MENU.instantiate()
	menu_instance.launch_pause_menu.connect(launch_pause_menu)
	menu_instance.launch_world.connect(launch_world)
	canvas_layer.add_child(menu_instance)



## -------------------------------- FileManager --------------------------------

# -- Option -- #

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
	},
	"langage": {
		"current" :"fr",
	},
}


static func save_options(path : String = "user://options.cfg") -> void:
	print("save option")
	print(options)
	var config = ConfigFile.new()
	for section in options.keys():
		for key in options[section].keys():
			config.set_value(section, key, options[section][key])
	config.save(path)


func load_options(path := "user://options.cfg") -> void:
	print("load options")
	var config = ConfigFile.new()
	if config.load(path) != OK:
		print("Fichier options.cfg introuvable, valeurs par défaut utilisées.")
		return
	
	for section in options.keys():
		for key in options[section].keys():
			if config.has_section_key(section, key):
				options[section][key] = config.get_value(section, key)

	print(options)
