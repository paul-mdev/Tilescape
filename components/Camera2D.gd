extends Camera2D
class_name Camera

var move : bool = false
var default_zoom : Vector2

@export var small_zoom_value : float
@export var medium_zoom_value : float
@export var big_zoom_value : float
var current_zoom_type : int = 0

func _ready() -> void:
	default_zoom = zoom

func _process(delta : float) -> void:
	if !is_current(): return
	if Input.is_action_just_pressed("1"):
		if move:
			global_position+=5*delta*get_local_mouse_position()
		else:
			global_position=Vector2.ZERO

	if Input.is_action_just_pressed("camera"):
		current_zoom_type+=1
		if current_zoom_type>3: current_zoom_type = 0
		match current_zoom_type:
			0: zoom = default_zoom
			1: zoom = Vector2(medium_zoom_value, medium_zoom_value)
			2: zoom = Vector2(big_zoom_value, big_zoom_value)
			3: zoom = Vector2(small_zoom_value, small_zoom_value)
		
static func get_camera_extended_rect(camera_rect : Rect2) -> Rect2:
	var extended_size : Vector2 = camera_rect.size * 2
	var size_difference : Vector2 = (extended_size - camera_rect.size) / 2
	var extended_position : Vector2 = camera_rect.position - size_difference
	return Rect2(extended_position, extended_size)

func get_camera_viewport_rect() -> Rect2:
	var screen_size : Vector2 = get_viewport().get_visible_rect().size #get_viewport_rect().size #get_viewport().get_visible_rect()
	var half_size : Vector2 = (screen_size/ zoom) * 0.5
	return Rect2(Vector2(0, 0) - half_size, screen_size / zoom)
	
func get_global_camera_viewport_rect() -> Rect2:
	var rect : Rect2 = get_camera_viewport_rect()
	rect.position += global_position
	return rect
	
	
func _draw() -> void:
	var camera_rect : Rect2 = get_camera_viewport_rect()
	draw_rect(camera_rect, Color(1, 1, 1, 1), false, -1)
	draw_rect(get_camera_extended_rect(camera_rect), Color(0, 0, 0, 1), false, -1)
