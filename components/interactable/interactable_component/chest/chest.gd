extends Item

class_name Chest

@export var size : int

var chest_manager = null
func activate():
	print("activer " + name)
	
	make_valid_chest_manager()
	chest_manager.open_chest(self)
	
func de_activate():
	print("désactiver " + name)
	#make_valid_chest_manager()
	if chest_manager!= null:
		chest_manager.queue_free()
	#chest_manager.de_activate()

func make_valid_chest_manager():
	if chest_manager == null:
		chest_manager = preload("res://entities/chest/chest-manager.tscn").instantiate()
		parent.get_node("/root/Main/World/UI").add_child(chest_manager)
		
