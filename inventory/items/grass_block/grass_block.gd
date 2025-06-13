extends AbstractItem
 
#var direction : Vector2 = Vector2.RIGHT
#var is_throwing: bool = true
 #
#func _ready() -> void:
	#set_physics_process(false)
	#item = ItemDatabase.get_item("grass-block")
 #



func use_item() -> void:
	print("grass block.")
	super.use_item()
	#set_physics_process(true)
	#set_physics_process(true)





#func _physics_process(delta):
	#check_direction()
	#position += direction * 400 * delta
 #
#
#func use_item():
	#super.use_item()
	#print("grass")
	#set_physics_process(true)
 #
	#collision.disabled = is_throwing
	#call_deferred("reparent",get_tree().current_scene)
 #
	#if is_throwing:
		#$Timer.start()
	#else:
		#$Timer.stop()
 #
	#is_throwing = !is_throwing
 #
 #
##func _on_timer_timeout():
##	set_physics_process(false)
 #
 #
#func check_direction():
	#var direction_to_mouse = get_global_mouse_position() - global_position
	#var direction_to_player = player.global_position - global_position
 #
 #
	#if is_throwing and direction_to_player.length() > 5:
		#direction = direction_to_player.normalized()
		#set_physics_process(true)
	#elif !is_throwing and direction_to_mouse.length() > 5:
		#direction = direction_to_mouse.normalized()
		#set_physics_process(true)
 #
	#else:
		#set_physics_process(false)
