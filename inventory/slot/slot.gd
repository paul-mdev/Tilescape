extends Button
@onready var item_texture: TextureRect = $ItemTexture

func _ready() -> void:
	if item == null:
		item = null
		amount = 0
	else:
		amount = amount
		item = item
# Slot
@export var item : Item = null:
	set(value):
		item = value
		
		if get_parent() and get_parent().has_method("update"):
			get_parent().update()
		
		if value != null:
			if item_texture != null:
				item_texture.texture = value.icon
			
		else:
			$Amount.text = ""
			item_texture.texture = null
			

@export var node : AbstractItem = null:
	set(value):
		node = value
		
		# à vérifiez
		if item != null:
			node.item = item
 
@export var amount : int = 1:
	set(value):
		amount = value
		$Amount.text = str(value)
		if amount <= 0:
			item = null
 
func set_amount(value : int):
	amount = value
 
func add_amount(value : int):
	amount += value
 
func _can_drop_data(_at_position, data):
	if "item" in data:
		return is_instance_of(data.item, Item) and data != self
	return false
 
func _drop_data(_at_position, data):
	if item == data.item:
		amount += data.amount
		data.amount = 0
	else:
		var temp = item
		item = data.item
		data.item = temp
 
		temp = amount
		amount = data.amount
		data.amount = temp
 
	if get_parent().has_method("update"):
		get_parent().update()
	if data.get_parent().has_method("update"):
		data.get_parent().update()
 
	if get_parent().name == "ChestInventory":
		#ChestManager.set_item()
		get_parent().get_parent().set_item()
	if data.get_parent().name == "ChestInventory":
		#ChestManager.set_item()
		data.get_parent().get_parent().set_item()
 
func _get_drag_data(_at_position):
	if item:
		var preview_texture = TextureRect.new()
 
		preview_texture.texture = item.icon
		preview_texture.size = Vector2(32, 32)
		preview_texture.position = -Vector2(16, 16)
 
		var preview = Control.new()
		preview.add_child(preview_texture)
		set_drag_preview(preview)
	
	return self


#func _on_gui_input(event):
	#if event is InputEventMouseButton and Shop.mode == Shop.MODE.ON:
		#if event.is_pressed() and event.button_index == MOUSE_BUTTON_RIGHT:
			#Shop.sell_item(item)
			#if item:
				#amount -= 1
