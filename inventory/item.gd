extends Resource
class_name Item
 
@export var icon: Texture2D
@export var name: String
var file_name : String
@export_enum("Block", "Wall", "Interactable", "Tool", "Armor", "Consumable") 
var type : String = "Weapon"
var parent : Node

@export_enum("Common","Rare","Epic","Legendary")
var rarity: String = "Common"
 
@export_multiline var description: String
 
func _ready() -> void:
	file_name = resource_path.get_file().get_basename()

signal item_used

func use_item() -> void:
	item_used.emit()
	print("resource item used")
	
