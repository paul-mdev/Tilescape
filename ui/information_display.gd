extends Control

@export var tilemap : TileMapLayer
@export var player : Player

@onready var coord_lbl : Label = $UsefulPanel/Useful/CoordLbl
@onready var fps_lbl : Label = $UsefulPanel/Useful/FpsLbl
#@onready var mouse_coord_lbl : Label = $UsefulPanel/Useful/MouseCoordLbl
@onready var zoom_lbl : Label = $UsefulPanel/Useful/ZoomLbl

@onready var infos_lbl : Label = $InfosPanel/InfosLbl

#@onready var block_lbl : Label = $DebugPanel/Debug/BlockLbl

var render_distance : int = Main.options["video"]["render_distance"]

func debug() -> void:
	var player_local_coord : Vector2i = tilemap.local_to_map(tilemap.to_local(player.global_position))
	coord_lbl.text=str(int(player_local_coord.x))+" X\n"+str(int(player_local_coord.y))+" Y"
	#draw_chunk_borders_lbl.text = "draw chunk borders : " + str(Main.options["video"]["draw_chunk_borders"])
	#render_distance_lbl.text= "render distance : " + str(render_distance)
	fps_lbl.text = str(Engine.get_frames_per_second()) + " fps"
	zoom_lbl.text = str(player.get_node("Camera2D").zoom.x) + " zoom"
	var text : String = "Process time : " + str(round(Performance.get_monitor(Performance.TIME_PROCESS) * 1000)) + " ms\n"
	text += "Physics time : " + str(round(Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS) * 1000)) + " ms\n"
	text += "Mémoire : " + str(round(Performance.get_monitor(Performance.MEMORY_STATIC) / (1024.0 * 1024.0))) + " Mo\n"
	text += "Noeuds : " + str(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)) + "\n"
	text += "Orphelins : " + str(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)) + "\n"
	text += "Draw Calls : " + str(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)) + "\n"
	infos_lbl.text = text
	
func _process(_delta : float) -> void:
	debug()
