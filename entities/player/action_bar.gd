extends HBoxContainer
 
@onready var slots : Array = get_children()
@onready var slot_number : int = slots.size()
signal index(i: int)
 
var current_index : int:
	set(value): #refresh UI
		current_index = value
		reset_focus()
		set_focus()
		if slots[current_index].item != null:
			hand.texture = slots[current_index].item.icon
			if slots[current_index].item.type == "Block":
				hand.scale = Vector2(0.5, 0.5)
			else:
				hand.scale = Vector2(1, 1)
		else: hand.texture = null
		
@onready var hand: Sprite2D = $"../../Hand"
func _ready():
	current_index = 0
	
func reset_focus():
	for slot in slots:
		slot.set_process_input(false)
 
func set_focus():
	get_child(current_index).grab_focus()
	get_child(current_index).set_process_input(true)
	index.emit(current_index)
 
func _input(event):
	if event.is_action_pressed("scroll-down"):
		if current_index == get_child_count() - 1:
			current_index = 0
		else:
			current_index += 1
 
	if event.is_action_pressed("scroll-up"):
		if current_index == 0:
			current_index = get_child_count() - 1
		else:
			current_index -= 1
 
func add_item(item : Item, amount):
	for slot in slots:
		if slot.item == null:
			slot.item = item
			slot.amount = amount
			return
	# inventaire plein attention
	
@onready var items: Node2D = $"../../Items"

func use_item():
	var selected_slot = get_selected_slot()
	if selected_slot.item != null:
		if selected_slot.node == null:
			#var file_name : String = selected_slot.item.resource_path.get_file().get_basename()
			#print("file name : ", file_name)
			var node = load("res://inventory/items/" + selected_slot.item.file_name + "/" + selected_slot.item.file_name + ".tscn").instantiate()
			node.item = selected_slot.item
			items.add_child(node)
			selected_slot.node = node

		selected_slot.node.use_item()


func get_selected_slot():
	return slots[current_index]

func get_selected_item():
	return get_selected_slot().item


func _process(delta: float) -> void:
	var n = 0
	for slot in slots: if slot.item != null: n+=1
	#print("number of item in hotbar : ", n)
