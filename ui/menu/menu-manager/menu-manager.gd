extends Control

class_name MenuManager

signal launch_pause_menu
signal launch_world
signal add_container

@onready var world_list : WorldList = $MenuContent/PlayWorld/ScrollContainer/WorldList
@onready var menu : HBoxContainer = $MenuContent/Menu
@onready var generate : VBoxContainer = $MenuContent/GenerateWorld
@onready var play : VBoxContainer = $MenuContent/PlayWorld
@onready var menu_content: VBoxContainer = $MenuContent

@export var default_color : Color = Color(255,0,0)

func set_default_theme(node : Node) -> void:
	return
	#if node is Label or node is TextEdit or node is Button:
		#var new_theme := Theme.new()
		#new_theme.set_color("font_color", "Label", default_color)
		#new_theme.set_color("font_color", "Button", default_color)
		#new_theme.set_color("font_color", "TextEdit", default_color)
		#node.theme = new_theme
		#
	#for child_node in node.get_children():
		#set_default_theme(child_node)

func _ready() -> void:
	WorldList.selected_container = null
	set_default_theme(self)
	self.connect("add_container", world_list.add_container)
	menu.show()
	play.hide()
	generate.hide()
	$Music.play()
	

@onready var camera : Camera2D = $Camera2D
func _on_play_btn_pressed() -> void:
	menu.hide()
	camera.global_position.y+=500
	play.show()
	

func _on_play_cancel_btn_pressed() -> void:
	menu.show()
	camera.global_position.y-=500
	play.hide()
	
func _on_generate_btn_pressed() -> void:
	play.hide()
	generate.show()

func _on_generate_cancel_btn_pressed() -> void:
	play.show()
	generate.hide()
	
func _on_quit_btn_pressed() -> void:
	get_tree().quit()

func _on_parameters_btn_pressed() -> void:
	emit_signal("launch_pause_menu", self)

func _on_play_world_btn_pressed() -> void:
	if WorldList.selected_container != null:
		emit_signal("launch_world", world_list.selected_container.world_data)

func _on_generate_world_btn_pressed() -> void:
	var world_name : String = generate.get_node("WorldBoxContainer/WorldNameTextEdit").text
	if (world_name == ""): world_name = "New world"
		
	var SEED : int = generate.get_node("SeedBoxContainer/SeedBox").value
	var date_info : Dictionary = Time.get_date_dict_from_system()
	var formatted_date : String = "%02d/%02d/%04d" % [date_info.day, date_info.month, date_info.year]
	
	var world_data : Dictionary = World.create_world(world_name, SEED, formatted_date)
	emit_signal("add_container", world_data)
	play.show()
	generate.hide()

func _on_button_pressed() -> void:
	var win : Window = get_viewport()
	win.size = Vector2(640, 360)
	DisplayServer.window_set_size(win.size)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	set_default_theme(self)

func _on_button_2_pressed() -> void:
	var win : Window = get_viewport()
	win.size = Vector2(1280, 720)
	DisplayServer.window_set_size(win.size)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	set_default_theme(self)
	
func _on_button_3_pressed() -> void:
	DisplayServer.window_set_size(get_viewport().get_max_size())
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func hide_menu_content() -> void:
	menu_content.visible = false

func show_menu_content() -> void:
	menu_content.visible = true
