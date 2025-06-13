extends Node2D

class_name Dash

const dash_delay : float = 0.2

@onready var duration_timer : Timer = $DurationTimer
@onready var dust_trail : GPUParticles2D = $DustTrail

var ghost_scene : PackedScene = preload("res://components/dash_ghost/dash-ghost.tscn")
var can_dash : bool = true
var sprite_list : Array[Sprite2D]

func _ready() -> void:
	dust_trail.process_material.anim_speed_max = 1.0
func start_dash(sprite_ : Array[Sprite2D] , duration : float) -> void:
	duration_timer.wait_time = duration
	duration_timer.start()
	
	self.sprite_list = sprite_
	instance_ghost()
	
	dust_trail.restart()
	dust_trail.emitting = true
	
func _process(_delta : float) -> void:
	if not $DurationTimer.is_stopped():
		instance_ghost()
	
func instance_ghost() -> void:
	var ghost: Node2D = ghost_scene.instantiate()
	
	ghost.global_position = sprite_list[0].global_position
	#ghost.material.set_shader_parameter("mix_weight", 0.2)
	#ghost.material.set_shader_parameter("whiten", true)
	
	for sprite2D : Sprite2D in sprite_list:
		ghost.get_node(str(sprite2D.name)).visible = sprite2D.visible
		ghost.get_node(str(sprite2D.name)).texture = sprite2D.texture
		ghost.get_node(str(sprite2D.name)).vframes = sprite2D.vframes
		ghost.get_node(str(sprite2D.name)).hframes = sprite2D.hframes
		ghost.get_node(str(sprite2D.name)).frame = sprite2D.frame
		ghost.get_node(str(sprite2D.name)).flip_h = sprite2D.flip_h
		ghost.get_node(str(sprite2D.name)).scale.x=sprite2D.scale.x #sprite2D.get_parent().
		ghost.get_node(str(sprite2D.name)).scale.y=sprite2D.scale.y #sprite2D.get_parent().
		ghost.get_node(str(sprite2D.name)).modulate = sprite2D.modulate
	get_parent().get_parent().add_child(ghost)
	
func is_dashing() -> bool:
	return !duration_timer.is_stopped()

#func stop_dash() -> void:
	#duration_timer.start(0.001)

func end_dash() -> void:
	can_dash = false
	await get_tree().create_timer(dash_delay).timeout
	can_dash = true

func _on_duration_timer_timeout() -> void:
	end_dash()
