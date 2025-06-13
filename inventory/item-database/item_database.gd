extends Node2D

class_name ItemDatabase

static var cache : Dictionary = {}
 
#@export_dir var item_folder
 
static var item_folder : String = "res://inventory/resources/"
static var is_initialised : bool = false

static func initialise() -> void:
	if is_initialised: return
	is_initialised = true
	var folder : DirAccess = DirAccess.open(item_folder)
	folder.list_dir_begin()
 
	var file_name : String = folder.get_next()
 
	while file_name != "":
 
		cache[file_name] = load(item_folder + "/" + file_name)
 
		file_name = folder.get_next()
	print("cache", cache)
	
static func get_item(ID : String) -> Item:
	return cache[ID + ".tres"]
