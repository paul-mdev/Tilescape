extends Sprite2D
class_name DroppedItem
 
@onready var collision = $Area2D/CollisionShape2D
#@onready var player = get_tree().current_scene.find_child("Player")
@onready var player = get_node("/root/Main/World/Player")

 
var item: Item = null:
	set(value):
		item = value
 
		if value != null:
			texture = value.icon
			#item.connect("item_used", use_item)
 
#func use_item():
	#print("Item Used") #testing
 
static func instantiate_dropped_item(resource_item : Item):
	var abstract_item = preload("res://inventory/dropped-item/dropped-item.tscn").instantiate()
	abstract_item.item = resource_item
	return abstract_item


var picked_up : bool = false
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player and picked_up == false:
		picked_up = true
		body.add_item(item, 1)
		queue_free()
#		call_deferred("reparent",body)


# gravité pour item

#extends CharacterBody2D
#
#var gravity : float = ProjectSettings.get_setting("physics/2d/default_gravity")
#var item : String = "null"
#func _ready() -> void:
	#assert(item!="null")
	#velocity.x=randi_range(-30,30)
	#velocity.y=-30
	#var texture : Resource = load("res://sprite/item/"+item+".png")
	#if texture!=null:
		#$Sprite2D.texture=texture
	#else:
		#$Sprite2D.texture=load("res://sprite/item/no_texture.png")
		#
#func _process(delta : float) -> void:
	#if not is_on_floor():
		#velocity.y+=gravity/4*delta
	#velocity.x =move_toward(velocity.x,0,20*delta)
	#move_and_slide()
	#
#func _on_area_2d_body_entered(body : Node2D) -> void:
	#if body is Player:
		#queue_free()
