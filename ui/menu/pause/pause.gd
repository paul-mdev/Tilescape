extends Control

signal save_and_quit
signal options_changed
signal show_menu_content
@onready var pause_menu_content: VBoxContainer = $PauseMenuContent
@export var save_btn : Button
func make_save_btn_visible() -> void:
	$PauseMenuContent/HBoxContainer/SaveBtn.visible=true

var parent_node : Node = null

func _ready() -> void:
	save_btn.visible = false
	get_tree().paused = true
	assert (parent_node!= null, "Le parent de pause menu doit être assigné")
	if parent_node is World: make_save_btn_visible()


func _on_continuer_pressed() -> void:
	get_tree().paused = !get_tree().paused
	for child in get_children():
		child.visible=!child.visible

func display_pause_menu():
	pause_menu_content.visible = true

func handle_pause_menu_change(child_instance : Control):
	pause_menu_content.visible = false
	child_instance.connect("display_pause_menu", display_pause_menu)
	add_child(child_instance)

func _on_audio_button_pressed() -> void:
	handle_pause_menu_change(load("res://ui/menu/audio-manager/audio.tscn").instantiate())

func _on_video_button_pressed():
	handle_pause_menu_change(load("res://ui/menu/video-manager/video.tscn").instantiate())

func _on_remap_button_pressed() -> void:
	handle_pause_menu_change(load("res://ui/menu/remap/remap-input.tscn").instantiate())

func _on_back_pressed() -> void:
	emit_signal("options_changed")
	close_pause_menu()

func _on_save_btn_pressed() -> void:
	emit_signal("save_and_quit")
	close_pause_menu()

func close_pause_menu() -> void:
	if parent_node is MenuManager: emit_signal("show_menu_content")
	get_tree().paused = false
	queue_free()
