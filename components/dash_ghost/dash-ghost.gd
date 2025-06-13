extends Node2D

func _ready() -> void:
	var tween:Tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_QUART) 
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self,"modulate:a",0.0,0.2)
