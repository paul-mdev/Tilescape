extends CharacterBody2D

class_name Projectile

var SPEED : int = 300
var direction : Vector2 = Vector2.ZERO



func _physics_process(_delta : float) -> void:
	if is_queued_for_deletion(): return
	#assert(direction.x==-1 or direction.x==1 or direction.x==0 or direction.y==-1 or direction.y==1 or direction.y==0)
	velocity = direction*SPEED
	move_and_slide()
	var last_collision : KinematicCollision2D = get_last_slide_collision()
	if last_collision != null:
		var collider : Object = last_collision.get_collider()
		
		if collider.has_method('remove_health'):
			collider.remove_health(1)
		if collider.has_method('destroy_block'):
			collider.destroy_block(global_position)
		#if collider.has_method('push_back'):
		#	collider.push_back(direction*SPEED/4)
		queue_free()
