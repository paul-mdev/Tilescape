extends AbstractItem
 
#func _ready() -> void:
	#set_physics_process(false)
	#item = ItemDatabase.get_item("teleportation-rod")

func use_item() -> void:
	super.use_item()
	player.global_position = get_global_mouse_position()
