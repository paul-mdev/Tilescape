extends Node2D
class_name AbstractItem

@onready var player = get_node("/root/Main/World/Player")

var item: Item = null:
	set(value):
		item = value

func use_item():
	print("abstract : use item " + item.name)
