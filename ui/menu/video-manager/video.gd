extends Control

class_name VideoManager

signal display_pause_menu

@export var fullscreen_btn : CheckButton
@export var draw_chunk_btn: CheckButton
@export var render_distance_spin_box: SpinBox
@export var display_fps_btn : CheckButton
@export var display_coords_btn : CheckButton
@export var display_debug_btn : CheckButton

static var video : Dictionary = {}

func _ready() -> void:
	fullscreen_btn.button_pressed = video["fullscreen"]
	draw_chunk_btn.button_pressed = video["draw_chunk_borders"]
	render_distance_spin_box.value = video["render_distance"]
	display_fps_btn.button_pressed = video["display_fps"]
	display_coords_btn.button_pressed = video["display_coords"]
	display_debug_btn.button_pressed = video["display_debug"]

static func set_screen_size(video_ : Dictionary) -> void:
	video = video_
	set_screen_type(video["fullscreen"])
	
static func	set_screen_type(fullscreen : bool) -> void:
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_fullscreen_btn_pressed() -> void:
	video["fullscreen"] = !video["fullscreen"]
	set_screen_type(video["fullscreen"])

func _on_draw_chunk_btn_pressed() -> void:
	video["draw_chunk_borders"] = !video["draw_chunk_borders"]

func _on_render_distance_spin_box_value_changed(value: int) -> void:
	video["render_distance"] = value

func _on_back_pressed() -> void:
	DataManager.options["video"] = video
	DataManager.save_options()
	emit_signal("display_pause_menu")
	queue_free()


func _on_display_fps_pressed() -> void:
	video["display_fps"] = !video["display_fps"]


func _on_display_coords_pressed() -> void:
	video["display_coords"] = !video["display_coords"]

func _on_display_debug_pressed() -> void:
	video["display_debug"] = !video["display_debug"]
