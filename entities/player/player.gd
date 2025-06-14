extends CharacterBody2D
class_name Player

@onready var sprite : Sprite2D = $Sprite2D
@onready var hand : Sprite2D = $Hand
@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var dash : Dash = $Dash
@onready var camera_2d_batch: Camera2D = $Camera2DBatch
@onready var audio_footsteps: AudioStreamPlayer2D = $AudioFootsteps
@export var hotbar: HBoxContainer
@export var inventory : Control

var direction : int
var dir : String ="left"
var gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")

var SPEED : int = 660

var remaining_jumps: int = 0
var jump_timer: float = 0.0 # Tracks how long the jump button is held
var is_jumping: bool = false
var coyote_timer: float = 0.0 # Tracks time since player left the ground

@export var coyote_time: float = 0.2 # Duration in seconds
@export var max_speed: float = 200.0
@export var acceleration: float = 800.0
@export var friction: float = 600.0 
@export var max_jumps: int = 2
@export var jump_speed: float = -210.0
@export var max_jump_duration: float = 0.2 # Maximum time jump button can be held (in seconds)
@export var fast_fall_multiplier: float = 1.5
@export var air_control_multiplier: float = 0.9

var dash_duration : float = 0.1
var dash_speed : int = 800
var remaining_dashs: int = 2
var max_dashs: int = 2
var was_dashing: bool = false
var post_dash_timer: float = 0.0 # Timer pour la gravité légère après le dash

@export var post_dash_gravity_duration: float = 0.3 # Durée de la gravité légère après le dash (en secondes)
@export var post_dash_gravity_factor: float = 0.5 # Facteur de réduction de la gravité après le dash


var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
var audio_stream_randomizer: AudioStreamRandomizer = AudioStreamRandomizer.new()
var audio_stream_randomizer_destroy_blocks: AudioStreamRandomizer = AudioStreamRandomizer.new()
#var audio_destroy_blocks : AudioStreamPlayer = AudioStreamPlayer.new()
func _ready() -> void:
	randomize()
	ItemDatabase.initialise()
	
	
	#add_child(audio_destroy_blocks)
	# Configuration du randomizer
	audio_stream_randomizer_destroy_blocks.playback_mode = AudioStreamRandomizer.PLAYBACK_RANDOM_NO_REPEATS
	audio_stream_randomizer_destroy_blocks.random_pitch = 0.3  # variation ±10%
	audio_stream_randomizer_destroy_blocks.random_volume_offset_db = 0.1
	audio_stream_randomizer_destroy_blocks.add_stream(-1, preload("res://audio/sound/destroy-blocks/1.wav"), 1.0)
	audio_stream_randomizer_destroy_blocks.add_stream(-1, preload("res://audio/sound/destroy-blocks/2.wav"), 1.0)
	audio_stream_randomizer_destroy_blocks.add_stream(-1, preload("res://audio/sound/destroy-blocks/3.wav"), 1.0)
	audio_stream_randomizer_destroy_blocks.add_stream(-1, preload("res://audio/sound/destroy-blocks/4.wav"), 1.0)
	audio_stream_randomizer_destroy_blocks.add_stream(-1, preload("res://audio/sound/destroy-blocks/5.wav"), 1.0)
	


	# Ajout de l'AudioStreamPlayer à la scène
	add_child(audio_player)

	# Configuration du randomizer
	audio_stream_randomizer.playback_mode = AudioStreamRandomizer.PLAYBACK_RANDOM_NO_REPEATS
	audio_stream_randomizer.random_pitch = 0.3  # variation ±10%
	audio_stream_randomizer.random_volume_offset_db = 0.1

	# Chargement et ajout des sons
	var sound1: AudioStream = preload("res://audio/sound/bird1.wav")
	var sound2: AudioStream = preload("res://audio/sound/bird2.wav")
	audio_stream_randomizer.add_stream(-1, sound1, 1.0)
	audio_stream_randomizer.add_stream(-1, sound2, 1.0)

	# Démarre le timer pour jouer les sons régulièrement
	var timer : Timer = Timer.new()
	timer.wait_time = 2.0
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(play_random_sound)
	add_child(timer)

func play_random_sound() -> void:
	if audio_player.playing: return
	audio_player.stream = audio_stream_randomizer
	audio_player.play()

func play_destroy_blocks_sound() -> void:
	var audio_destroy_blocks : AudioStreamPlayer = AudioStreamPlayer.new()
	audio_destroy_blocks.volume_db=-12
	add_child(audio_destroy_blocks)
	#if audio_destroy_blocks.playing: audio_destroy_blocks.stop()
	audio_destroy_blocks.stream = audio_stream_randomizer_destroy_blocks
	audio_destroy_blocks.play()
	
	
# Called every frame to handle input and update the jump
func handle_jump(delta: float) -> void:
	if Input.is_action_just_pressed("jump") and (is_on_floor() or coyote_timer > 0 or remaining_jumps > 0) and not dash.is_dashing():
		is_jumping = true
		jump_timer = 0.0
		velocity.y = jump_speed # Start the jump
		remaining_jumps -= 1
		coyote_timer = 0.0 # Disable coyote time after jumping

	if is_jumping and not dash.is_dashing():
		jump_timer += delta
		# Allow continued jumping while the button is held and duration is under max_jump_duration
		if Input.is_action_pressed("jump") and jump_timer < max_jump_duration:
			velocity.y = jump_speed
		else:
			if is_jumping:
				velocity.y+=gravity*delta*10
			is_jumping = false # Stop the jump when max duration is reached or button is released

# Get player input
func get_input() -> float:
	return Input.get_axis("move-left", "move-right")
	
# Handle player movement
func move_player(delta: float) -> void:
	direction = int(get_input())
	# Accelerate if there is input until reaching the max speed
	if direction != 0:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)

		if not is_on_floor():
			# Réduire l'accélération en l'air
			velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * air_control_multiplier * delta)
		else:
			velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
			
	# Slow down and stop
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta * 2) # Friction augmentée au sol
	else:
		velocity.x = move_toward(velocity.x, 0, friction * delta) # Friction normale en l'air	

func handle_dash() -> void:	
	if Input.is_action_just_pressed("dash") and remaining_dashs > 0 and not dash.is_dashing() and dash.can_dash:
		# Effet visuel et activation du dash
		dash.start_dash([$Sprite2D], dash_duration)

		remaining_dashs -= 1
		velocity.y = 0

		# Déterminer la direction du dash
		var dash_x : int = int(Input.get_axis("move-left", "move-right"))
		var dash_y : int = int(Input.get_axis("ui_up", "ui_down"))

		# Si aucune direction n'est précisée, utiliser la direction actuelle
		if dash_x == 0 and dash_y == 0:
			dash_x = sign(velocity.x)

		# Appliquer la vitesse de dash
		velocity = Vector2(
			dash_speed * dash_x,
			dash_speed * dash_y
		).limit_length(dash_speed)

		# Marquer comme "dashing"
		was_dashing = true
		post_dash_timer = post_dash_gravity_duration # Activer la gravité légère après

	elif was_dashing and not dash.is_dashing():
		# Transition après le dash
		was_dashing = false
		post_dash_timer = post_dash_gravity_duration	
	
func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		if dash.is_dashing():
			was_dashing = true # Suspendre la gravité pendant le dash
			post_dash_timer = 0.0 # Réinitialiser le timer de gravité post-dash
		else:
			if was_dashing:
				# Le dash vient de se terminer
				was_dashing = false
				post_dash_timer = post_dash_gravity_duration # Déclencher le timer de gravité légère
			
			# Si le post-dash est actif, appliquer une gravité réduite
			if post_dash_timer > 0:
				velocity.y += gravity * post_dash_gravity_factor * delta
				post_dash_timer -= delta
			else:
				# Gravité normale
				if velocity.y > 0: # En chute libre
					velocity.y += gravity * delta * fast_fall_multiplier
				else:
					velocity.y+=gravity*delta
		
			
func handle_floor(delta: float) -> void:
	if is_on_floor():
		coyote_timer = coyote_time # Reset the timer when on the ground
		remaining_jumps = max_jumps
		remaining_dashs = max_dashs
	else:
		coyote_timer -= delta # Decrease the timer when in the air			
		
func play_animation() -> void:
	if direction==1:
		dir="right"
		hand.flip_h=true
	elif direction == -1:
		dir="left"
		hand.flip_h=false
		
	if velocity!=Vector2.ZERO:
		anim.play(dir)
	else:
		anim.play("afk")
		hand.position.y = -6
	
	
func shoot_projectile() -> void:
	var projectile : Projectile = load("res://components/projectile/projectile.tscn").instantiate()
	projectile.global_position = global_position  # Tire depuis le joueur
	get_parent().add_child(projectile)

	# Calcul de la direction normalisée vers la souris
	var direction_vector : Vector2 = (get_global_mouse_position() - global_position).normalized()
	projectile.direction = direction_vector


func get_bounding_rect() -> Rect2:
	return $CollisionPolygon2D.get_collision_polygon_rect()

var is_angel : bool = false
var creative_mod : bool = true
func _physics_process(delta : float) -> void:
	if Input.is_action_just_pressed("creative_mod"): creative_mod = !creative_mod

	#print("Remaining jumps: ", remaining_jumps, " | Coyote timer: ", coyote_timer, " | Remaining dashes : ", remaining_dashs)
	if !creative_mod:
		handle_floor(delta)
		handle_jump(delta)
		handle_dash()
		handle_gravity(delta)
		move_player(delta)
		
		$CollisionPolygon2DAfk.disabled = false
		if velocity==Vector2.ZERO: $CollisionPolygon2D.disabled = true
		else: $CollisionPolygon2D.disabled = false
	
	else:
		$CollisionPolygon2D.disabled = true
		$CollisionPolygon2DAfk.disabled = true

		handle_dash()
		var debug_speed : int = SPEED * 4
		if Input.is_action_pressed("move-left"):
			velocity.x=-debug_speed
			dir="left"
			#hand.flip_h=false
		elif Input.is_action_pressed("move-right"):
			velocity.x=debug_speed
			dir="right"
			#hand.flip_h=true
		else:
			velocity.x = move_toward(velocity.x, 0,delta*debug_speed*5)
			
		if Input.is_action_pressed("up"):
			velocity.y=-debug_speed
		elif Input.is_action_pressed("down"):
			velocity.y=debug_speed
		else:
			velocity.y = move_toward(velocity.y, 0,delta*debug_speed*5)
		
		
	# Si le joueur se déplace
	if velocity != Vector2.ZERO:
		camera_2d_batch.queue_redraw()
		if !audio_footsteps.playing and is_on_floor():
			audio_footsteps.pitch_scale = randf_range(0.8, 1.2)
			audio_footsteps.play()
			#print("play")
			
	if velocity == Vector2.ZERO or !is_on_floor():
		if audio_footsteps.playing:
			#print("stop")
			audio_footsteps.stop()
			var audio_stream_randomizer : AudioStreamRandomizer = AudioStreamRandomizer.new()
			audio_stream_randomizer
	
	play_animation()
	#if Input.is_action_just_pressed("clic_gauche"): shoot_projectile()
	if Input.is_action_just_pressed("clic_gauche"):
		is_angel = !is_angel
		if is_angel: $Sprite2D.texture = preload("res://sprites/chester-angel.png")
		else: $Sprite2D.texture = preload("res://sprites/chester.png")
	
	move_and_slide()



#var caracteres = ["Ⱥ", "ℓ", "ϻ", "Ǟ", "ӿ", "ṋ", "ϊ", "ɲ", "ϲ", "ř", "ḙ", "ŧ", "ƴ", "ї", "ŋ", "ġ", "ẙ", "σ", "ų", "я", "ʝ", "ɇ","Ŧ", "ħ", "є", "ω", "ŋ", "ḙ", "ɍ", "ϲ", "ų", "ѧ", "ї", "σ", "ɲ", "ħ", "ϊ", "ʝ", "ø", "ư","Ş", "ő", "ṁ", "ę", "ϲ", "ѧ", "ŗ"]
#func generer_dialogue():
	#var chaine =""
	#for i in range(randi_range(2,6)):
		#for j in range(randi_range(2,8)):
			#chaine+= caracteres.pick_random()
		#if i==2 or i==4:
			#chaine+="\n"
		#else:
			#chaine+=" "
	#$Dialogue.text=chaine


func _input(event) -> void:
	if event.is_action_pressed("clic_droit"):
		use_item()
 
func add_item(item : Item, amount : int) -> void:
	inventory.add_item(item, amount)
 
func use_item() -> void:
	hotbar.use_item()
	
	
static var player_data : Dictionary = {
	"global_position": Vector2(0, -3000),
	"inventory": {"grid" : {}, "hotbar" : {}},
	"health": 3
}	
	
# -- PlayerData -- #
func save_player_data(world_name : String) -> void:
	print("load_player_data")
	var path : String = "user://worlds/%s/player_data.save" % world_name
	player_data = {
			"global_position": global_position,
			"inventory": inventory.get_item_data(),
			"health": 3  # remplacer par la vie du joueur
		}
	DataManager.save_data(player_data, path)
	print("player data : ", player_data)
	
func load_player_data(world_name : String) -> void:
	print("load_player_data")
	var path : String = "user://worlds/%s/player_data.save" % world_name
	player_data = DataManager.load_data(path)
	if player_data.is_empty():
		player_data = {
			"global_position": Vector2(0, -3000),
			"inventory": {"grid" : {},"hotbar" : {}},
			"health": 3
		}
	print("player data : ", player_data)
	global_position = player_data["global_position"]
	
	inventory.load_data()
