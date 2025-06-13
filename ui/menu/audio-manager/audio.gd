extends Control

class_name AudioManager
signal display_pause_menu

@onready var master_volume : Label  = $VBoxContainer/AudioGridContainer/MasterVolume
@onready var sound_volume : Label  = $VBoxContainer/AudioGridContainer/SoundVolume
@onready var music_volume : Label = $VBoxContainer/AudioGridContainer/MusicVolume

static var audio : Dictionary = {}
func _ready() -> void:
	master_volume.text = str(audio["master"])
	sound_volume.text = str(audio["sound"])
	music_volume.text = str(audio["music"])
	$VBoxContainer/AudioGridContainer/HSliderMaster.value = audio["master"]
	$VBoxContainer/AudioGridContainer/HSliderSound.value = audio["sound"]
	$VBoxContainer/AudioGridContainer/HSliderMusic.value = audio["music"]
	
static func set_audio_volume(audio_ : Dictionary) -> void:
	audio = audio_
	set_master_volume(audio["master"])
	set_sound_volume(audio["sound"])
	set_music_volume(audio["music"])
	
static func set_master_volume(value : float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value/10))	
	
static func set_sound_volume(value : float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound"), linear_to_db(value/10))	
		
static func set_music_volume(value : float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value/10))
	
func _on_h_slider_master_value_changed(value : int) -> void:
	master_volume.text = "%2s"%str(value)
	audio["master"] = value
	set_master_volume(value)
	
func _on_h_slider_sound_value_changed(value : int) -> void:
	sound_volume.text = "%2s"%str(value)
	audio["sound"] = value
	set_sound_volume(value)

func _on_h_slider_music_value_changed(value : int) -> void:
	music_volume.text = "%2s"%str(value)
	audio["music"] = value
	set_music_volume(value)


func _on_back_pressed() -> void:
	Main.options["audio"] = audio
	Main.save_options()
	emit_signal("display_pause_menu")
	queue_free()
