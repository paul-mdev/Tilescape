extends Control
 
var current_scene
var inventory : Dictionary = {
	"grid" : {},
	"hotbar" : {}
}
 
var display_inventory : bool:
	set(value): #refresh UI
		display_inventory = value
		blur_texture.visible = value
		grid.visible = value

@export var hotbar : HBoxContainer
@export var grid : GridContainer
@export var blur_texture : Panel

func _ready() -> void:
	display_inventory = false

func _input(event) -> void:
	if Input.is_action_just_pressed("open-inventory"):
		display_inventory = !display_inventory
 
func add_item(item : Item, amount : int = 1) -> void:
	for slot in hotbar.get_children():
		if slot.item == null:
			slot.item = item
			slot.amount = amount
			return
		elif slot.item == item:
			slot.add_amount(amount)
			return
 
	for slot in grid.get_children():
		if slot.item == null:
			slot.item = item
			slot.amount = amount
			return
		elif slot.item == item:
			slot.add_amount(amount)
			return
	print("Full Inventory")
 
func _on_hotbar_equip(item) -> void:
	if current_scene != null:
		current_scene.currently_equipped = item
 
func use_stackable_item() -> void:
	hotbar.update()
	hotbar.use_current()
 


func get_item_data() -> Dictionary:
	var grid_data : Dictionary = {}
	var hotbar_data : Dictionary = {}
 
	for slot in grid.get_children():
		if slot.item != null:
			grid_data[slot.get_index()] = { "item" : slot.item.resource_path,
													"amount" : slot.amount }
 
	for slot in hotbar.get_children():
		if slot.item != null:
			hotbar_data[slot.get_index()] = { "item" : slot.item.resource_path,
													"amount" : slot.amount }
	return {
		"grid" : grid_data,
		"hotbar" : hotbar_data
	}
 
func save_data() -> void:
	Player.player_data["inventory"] = get_item_data()


func inventory_map(item : Item, amount : int) -> void:
	if item == null:
		return
	if inventory.has(item):
		inventory[item] += amount
		return
 
	inventory[item] = amount


func load_data() -> void:
	# Grid
	var grid_index = Player.player_data["inventory"]["grid"]
	if grid_index != {}:
		# Réinitialiser
		inventory = {}
		for slot in grid.get_children():
			slot.amount = 0
		
		# Charger
		for index in grid_index:
			var item = ResourceLoader.load( grid_index[index]["item"] )
			grid.get_child(index).item = item
			grid.get_child(index).amount = grid_index[index]["amount"]
			inventory_map( item, grid_index[index]["amount"] )
	
	# Hotbar
	var hotbar_index = Player.player_data["inventory"]["hotbar"]
	if hotbar_index != {}:
		# Réinitialiser
		for slot in hotbar.get_children():
			slot.amount = 0
		
		# Charger
		for index in hotbar_index:
			var item = ResourceLoader.load(hotbar_index[index]["item"])
			hotbar.get_child(index).item = item
			hotbar.get_child(index).amount = hotbar_index[index]["amount"]
			inventory_map(item, hotbar_index[index]["amount"])
