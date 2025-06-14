extends HBoxContainer

class_name WorldContainer
signal select_world
signal delete_world
@onready var world_name_lbl : Label = $WorldNameLbl
@onready var seed_lbl : Label = $SeedLbl
@onready var date_lbl : Label = $CreatedAtLbl

var world_data : Dictionary

func set_world_data(world_data_ : Dictionary) -> void:
	world_data = world_data_
	
	
func _ready() -> void:
	if world_data:
		world_name_lbl.text = world_data.world_name
		seed_lbl.text = str(world_data.seed)
		date_lbl.text = world_data.created_at

	mouse_filter = Control.MOUSE_FILTER_STOP
	world_name_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	seed_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	date_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#accept_event()
		emit_signal("select_world", self)

func set_selected(selected: bool) -> void:
	if selected: modulate = Color(1, 0.757, 0.027)# Color(0.3, 0.8, 1.0)
	else: modulate = Color(1, 1, 1)

@onready var delete_confirm : ConfirmationDialog = $DeleteConfirmationDialog
func _on_delete_world_btn_pressed() -> void:
	delete_confirm.popup_centered()  # Affiche la popup

func _on_delete_confirmation_dialog_confirmed() -> void:
	WorldList.selected_container = null
	emit_signal("delete_world", world_data.world_name)
	queue_free()
