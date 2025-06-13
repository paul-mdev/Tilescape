extends Control

signal display_pause_menu

@export var action_items: Array[String]
@onready var settings_grid_container = $ButtonsVBox/SettingsGridContainer
@onready var buttons_v_box = $ButtonsVBox

func _ready() -> void:
	create_action_remap_items()
	
func focus_button() -> void:
	if buttons_v_box:
		var button: Button = buttons_v_box.get_child(0)
		if button is Button:
			button.grab_focus()

func _on_visibility_changed() -> void:
	if visible:
		focus_button()

func create_action_remap_items() -> void:
	var previous_item = settings_grid_container.get_child(settings_grid_container.get_child_count() - 1)
	for index in range(action_items.size()):
		var action = action_items[index]
		var label = Label.new()
		label.text = action
		settings_grid_container.add_child(label)
		
		var button = RemapButton.new()
		button.action = action
		button.focus_neighbor_top = previous_item.get_path()
		previous_item.focus_neighbor_bottom = button.get_path()
		#if index == action_items.size() - 1:
		#	main_menu_button.focus_neighbor_top = button.get_path()
		#	button.focus_neighbor_bottom = main_menu_button.get_path()
		previous_item = button
		settings_grid_container.add_child(button)


func _on_back_pressed() -> void:
	emit_signal("display_pause_menu")
	queue_free()
