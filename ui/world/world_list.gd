extends VBoxContainer

class_name WorldList

const CONTAINER : PackedScene = preload("res://ui/world/world_container.tscn")
static var selected_container : WorldContainer = null
static var world_name_list : Array = []
func _ready() -> void:
	var world_list : Array = load_all_worlds_data()
	for world_data : Dictionary in world_list:
		add_container(world_data)


func load_all_worlds_data() -> Array:
	var worlds : Array = []
	var base_path : String = "user://worlds"

	var dir : DirAccess = DirAccess.open(base_path)
	if dir == null: return worlds  # Aucun dossier "worlds" encore

	dir.list_dir_begin()
	var world_dir_name : String = dir.get_next()
	while world_dir_name != "":
		world_name_list.append(world_dir_name.to_lower())
		if dir.current_is_dir() and world_dir_name != "." and world_dir_name != "..":
			var world_path : String = base_path + "/" + world_dir_name + "/world.json"
			if FileAccess.file_exists(world_path):
				var file : FileAccess = FileAccess.open(world_path, FileAccess.READ)
				var content : String = file.get_as_text()
				var parsed : Variant = JSON.parse_string(content)
				if typeof(parsed) == TYPE_DICTIONARY:
					worlds.append(parsed)
		world_dir_name = dir.get_next()
	dir.list_dir_end()
	return worlds


# --- DeleteWorld --- #

func delete_world(world_name: String) -> void:
	world_name_list.erase(world_name.to_lower())
	print("delete world")
	var dir_path : String = "user://worlds/%s" % world_name
	var dir : DirAccess = DirAccess.open(dir_path)
	if dir:
		print("Directory found: ", dir_path)
		delete_folder_recursive(dir_path)
	else:
		print("Directory not found: ", dir_path)

# Fonction récursive pour supprimer tous les fichiers et sous-dossiers
func delete_folder_recursive(path : String) -> void:
	print("Entering directory: ", path)

	# Create a new DirAccess object for the current path to handle subdirectories correctly
	var dir : DirAccess = DirAccess.open(path)
	if dir == null:
		print("Failed to open directory: ", path)
		return

	dir.list_dir_begin()  # Start reading the directory
	var file_name : String = dir.get_next()

	# Loop through files and directories
	while file_name != "":
		var current_path : String = path + "/" + file_name
		print("Found file/folder: ", current_path)

		if dir.current_is_dir():  # If it's a directory
			print("Entering subdirectory: ", current_path)
			delete_folder_recursive(current_path)  # Recursively delete subdirectory
		else:
			print("Deleting file: ", current_path)
			dir.remove(current_path)  # Delete the file
		file_name = dir.get_next()  # Continue to the next file/folder

	dir.list_dir_end()  # End the directory reading
	print("Finished reading directory: ", path)

	# Attempt to delete the directory after all contents are removed
	if dir.dir_exists(path):  # Check if the directory still exists
		print("Deleting directory:", path)
		var result : Error = dir.remove(path)  # Try to remove the directory
		if result != OK:
			print("Failed to delete directory: ", path)
		else:
			print("Successfully deleted directory: ", path)
	else:
		print("Directory already deleted or does not exist: ", path)





func add_container(world_data : Dictionary) -> void:
	var container : WorldContainer = CONTAINER.instantiate()
	container.set_world_data(world_data)
	container.connect("select_world", select_world)
	container.connect("delete_world", delete_world)
	#set_default_theme(container)
	add_child(container)


func select_world(container: Node) -> void:
	# Désélectionner l’ancien
	if selected_container and !selected_container.is_queued_for_deletion():
		selected_container.set_selected(false)

	# Sélectionner le nouveau
	selected_container = container
	selected_container.set_selected(true)

	print("Monde sélectionné :", selected_container.world_data.world_name)
